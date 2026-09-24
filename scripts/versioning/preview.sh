#!/usr/bin/env bash
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/resolve-adapter.sh"
source "$script_dir/validate-sprint.sh"

: "${GITHUB_EVENT_PATH:?É necessário um evento pull_request}"
: "${GITHUB_REPOSITORY:?Informe o repositório consumidor}"
: "${RELEASE_BRANCH:?Informe release_branch}"
: "${ADAPTER:?Informe adapter}"
validate_release_branch "$RELEASE_BRANCH"
node_script=$(as_node_path "$script_dir/version.mjs")
IFS='|' read -r pr base head issue < <(node "$node_script" event "$(as_node_path "$GITHUB_EVENT_PATH")")
[[ -n "${issue:-}" ]] || { echo 'PR sem issue válida' >&2; exit 1; }
git check-ref-format --branch "$base" >/dev/null
[[ "$base" == "$RELEASE_BRANCH" || "$base" == develop || "$base" == feature/* ]] || {
  echo "Destino de PR não reconhecido para prévia: $base" >&2; exit 1;
}
validate_pr_issue "$issue" "$GITHUB_REPOSITORY" "$MILESTONE"
unset GH_TOKEN GITHUB_TOKEN || true

cd "${GITHUB_WORKSPACE:-$(pwd)}"
git rev-parse --verify "origin/$base^{commit}" >/dev/null
[[ "$(git rev-parse HEAD)" == "$head" ]] || {
  echo 'Checkout não corresponde ao HEAD atual do PR' >&2; exit 1;
}
merge_base=$(git merge-base "origin/$base" HEAD)
validate_commit_range "$merge_base" HEAD
select_adapter "$ADAPTER" "${PROJECT_PATH:-.}"

if [[ -f "$PROJECT_DIR/package.json" ]]; then
  current=$(node -p "JSON.parse(require('node:fs').readFileSync(process.argv[1], 'utf8')).version" "$(as_node_path "$PROJECT_DIR/package.json")")
else
  current=0.0.0
fi
if [[ "$ADAPTER" == standard-version ]]; then
  package_rel="${PROJECT_PATH:-.}/package.json"
  package_rel="${package_rel#./}"
  base_package=$(git show "$merge_base:$package_rel") || {
    echo 'package.json não existe no commit base' >&2; exit 1;
  }
  base_version=$(node -p 'JSON.parse(process.argv[1]).version' "$base_package")
  commit_result=$(node "$node_script" analyze "$merge_base" HEAD "$base_version")
  expected=$(node -p 'JSON.parse(process.argv[1]).candidate_version' "$commit_result")
  [[ "$current" == "$base_version" || "$current" == "$expected" ]] || {
    echo "Versão do package.json ($current) diverge da prévia ($expected)" >&2; exit 1;
  }
else
  commit_result=$(node "$node_script" analyze "$merge_base" HEAD "$current")
fi
result="$commit_result"

case "$ADAPTER" in
  standard-version)
    dry_run=$(cd "$PROJECT_DIR" && "$ADAPTER_BIN" --dry-run)
    if [[ "$current" == "$base_version" ]]; then
      result=$(node "$node_script" standard "$dry_run" "$base_version")
    else
      # A versão já foi registrada no PR; dry-run do HEAD calcularia um segundo bump.
      result="$commit_result"
    fi
    ;;
  changesets)
    package=$(node -p "JSON.parse(require('node:fs').readFileSync(process.argv[1], 'utf8')).name" "$(as_node_path "$PROJECT_DIR/package.json")")
    status_file=$(mktemp "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/changesets-XXXXXXXX.json")
    trap 'rm -f "$status_file"' EXIT
    (cd "${GITHUB_WORKSPACE:-$(pwd)}" && "$ADAPTER_BIN" status --output "$status_file")
    result=$(node "$node_script" changesets "$(as_node_path "$status_file")" "$package")
    ;;
  jgitver)
    if [[ "$ADAPTER_BIN" == */mvnw ]]; then
      raw=$(cd "$PROJECT_DIR" && bash "$ADAPTER_BIN" -q -DforceStdout help:evaluate -Dexpression=project.version)
    else
      raw=$(cd "$PROJECT_DIR" && "$ADAPTER_BIN" -q -DforceStdout help:evaluate -Dexpression=project.version)
    fi
    version=${raw##*$'\n'}
    node "$node_script" version "$version" >/dev/null
    latest_tag=$(git tag --merged "$merge_base" --list 'v[0-9]*' --sort=-v:refname)
    latest_tag=${latest_tag%%$'\n'*}
    bump=$(node "$node_script" compare "${latest_tag:-v0.0.0}" "$version")
    result=$(node -e 'let r=JSON.parse(process.argv[1]);r.bump=process.argv[3];r.candidate_version=process.argv[2];r.summary+="; jgitver "+process.argv[2];process.stdout.write(JSON.stringify(r))' "$commit_result" "$version" "$bump")
    ;;
  go-gitsemver)
    version=$(cd "$PROJECT_DIR" && "$ADAPTER_BIN" --show-variable SemVer)
    latest_tag=$(git tag --merged "$merge_base" --list 'v[0-9]*' --sort=-v:refname)
    latest_tag=${latest_tag%%$'\n'*}
    bump=$(node "$node_script" compare "${latest_tag:-v0.0.0}" "$version")
    result=$(node -e 'let r=JSON.parse(process.argv[1]);r.bump=process.argv[3];r.candidate_version=process.argv[2];r.summary+="; go-gitsemver "+process.argv[2];process.stdout.write(JSON.stringify(r))' "$commit_result" "$version" "$bump")
    ;;
esac

bump=$(node -p 'JSON.parse(process.argv[1]).bump' "$result")
candidate=$(node -p 'JSON.parse(process.argv[1]).candidate_version' "$result")
summary=$(node -p 'JSON.parse(process.argv[1]).summary' "$result")
[[ "$candidate" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] || {
  echo "Versão candidata inválida: $candidate" >&2; exit 1;
}
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  printf 'bump=%s\ncandidate_version=%s\nsummary=%s\n' "$bump" "$candidate" "$summary" >> "$GITHUB_OUTPUT"
fi
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '### Prévia de versão\nPR #%s · issue #%s · sprint %s\n\n%s → %s\n' "$pr" "$issue" "$MILESTONE" "$bump" "$candidate" >> "$GITHUB_STEP_SUMMARY"
fi
printf '%s\n' "$summary → $candidate"
