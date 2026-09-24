#!/usr/bin/env bash
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/resolve-adapter.sh"
source "$script_dir/validate-sprint.sh"

: "${GITHUB_REPOSITORY:?Informe o repositório consumidor}"
: "${GITHUB_SHA:?Publicação exige SHA integrado}"
: "${TARGET_BRANCH:?Informe target_branch}"
: "${RELEASE_BRANCH:?Informe release_branch}"
: "${ADAPTER:?Informe adapter}"
[[ "${GITHUB_EVENT_NAME:-}" == push && "${GITHUB_REF_NAME:-}" == "$TARGET_BRANCH" ]] || {
  echo 'Publicação permitida apenas em push na branch de destino após merge' >&2; exit 1;
}
[[ "$(git rev-parse HEAD)" == "$GITHUB_SHA" ]] || {
  echo 'Checkout não corresponde ao commit integrado' >&2; exit 1;
}
validate_release_branch "$RELEASE_BRANCH"
[[ "$TARGET_BRANCH" =~ ^[A-Za-z0-9_.\/-]+$ ]] || { echo 'target_branch inválida' >&2; exit 1; }
default_branch=$(gh api "repos/$GITHUB_REPOSITORY" --jq '.default_branch')
[[ "$TARGET_BRANCH" == "$default_branch" ]] || {
  echo "Publicação permitida somente na branch principal ($default_branch)" >&2; exit 1;
}

milestone_json=$(gh api -X GET "repos/$GITHUB_REPOSITORY/milestones" -f state=all -f per_page=100)
milestone_number=$(node -e 'const items=JSON.parse(process.argv[1]);const m=items.find(v=>v.title===process.argv[2]);if(!m||m.state!=="closed"||m.open_issues!==0)process.exit(1);process.stdout.write(String(m.number))' "$milestone_json" "$MILESTONE") || {
  echo "Milestone $MILESTONE deve estar fechada com zero issues abertas" >&2; exit 1;
}
issues_json=$(gh api -X GET "repos/$GITHUB_REPOSITORY/issues" -f state=closed -f milestone="$milestone_number" -f per_page=100)
node -e 'const list=JSON.parse(process.argv[1]);if(!list.some(i=>i.title===process.argv[2]&&i.state==="closed"&&!i.pull_request))process.exit(1)' "$issues_json" "$MILESTONE" || {
  echo "Épica $MILESTONE deve estar encerrada" >&2; exit 1;
}

prs_json=$(gh api -X GET "repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/pulls" -f per_page=100)
pr_number=$(node -e 'const list=JSON.parse(process.argv[1]);const pr=list.find(p=>p.merged_at&&p.merge_commit_sha===process.argv[2]&&p.base.ref===process.argv[3]&&[process.argv[4],"develop"].includes(p.head.ref));if(!pr)process.exit(1);process.stdout.write(String(pr.number))' "$prs_json" "$GITHUB_SHA" "$TARGET_BRANCH" "$RELEASE_BRANCH") || {
  echo 'Commit não corresponde a PR de release/develop mesclado na branch de publicação' >&2; exit 1;
}
decision=$(gh pr view "$pr_number" -R "$GITHUB_REPOSITORY" --json reviewDecision --jq .reviewDecision)
[[ "$decision" == APPROVED ]] || { echo "PR #$pr_number sem review APPROVED vigente" >&2; exit 1; }
body=$(gh api "repos/$GITHUB_REPOSITORY/pulls/$pr_number" --jq '.body // ""')
[[ "$body" == *'Homologação: aprovada'* ]] || {
  echo "PR #$pr_number requer registro 'Homologação: aprovada' revisado" >&2; exit 1;
}

unset GH_TOKEN GITHUB_TOKEN || true
select_adapter "$ADAPTER" "${PROJECT_PATH:-.}"
node_script=$(as_node_path "$script_dir/version.mjs")
case "$ADAPTER" in
  standard-version|changesets)
    version=$(node -p "JSON.parse(require('node:fs').readFileSync(process.argv[1], 'utf8')).version" "$(as_node_path "$PROJECT_DIR/package.json")")
    ;;
  jgitver)
    if [[ "$ADAPTER_BIN" == */mvnw ]]; then
      version=$(cd "$PROJECT_DIR" && bash "$ADAPTER_BIN" -q -DforceStdout help:evaluate -Dexpression=project.version)
    else
      version=$(cd "$PROJECT_DIR" && "$ADAPTER_BIN" -q -DforceStdout help:evaluate -Dexpression=project.version)
    fi
    version=${version##*$'\n'}
    ;;
  go-gitsemver)
    version=$(cd "$PROJECT_DIR" && "$ADAPTER_BIN" --show-variable SemVer)
    ;;
esac
version=$(node "$node_script" stable "$version")
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Versão publicada inválida' >&2; exit 1; }
if [[ "$ADAPTER" == changesets ]]; then
  package=$(node -p "JSON.parse(require('node:fs').readFileSync(process.argv[1], 'utf8')).name" "$(as_node_path "$PROJECT_DIR/package.json")")
  [[ "$package" =~ ^@[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || {
    echo 'Para Changesets selecione um package com nome @scope/name' >&2; exit 1;
  }
  TAG="$package@$version"
else
  TAG="v$version"
fi
export TAG
printf '%s\n' "$version"
