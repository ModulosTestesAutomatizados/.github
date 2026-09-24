#!/usr/bin/env bash
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/resolve-adapter.sh"
source "$script_dir/validate-sprint.sh"

version=$(bash "$script_dir/prepare-release.sh")
validate_release_branch "$RELEASE_BRANCH"
select_adapter "$ADAPTER" "${PROJECT_PATH:-.}"
node_script=$(as_node_path "$script_dir/version.mjs")
if [[ "$ADAPTER" == changesets ]]; then
  package=$(node -p "JSON.parse(require('node:fs').readFileSync(process.argv[1], 'utf8')).name" "$(as_node_path "$PROJECT_DIR/package.json")")
  tag="$package@$version"
  prefix="$package@"
else
  tag="v$version"
  prefix=v
fi
repo="$GITHUB_REPOSITORY"
sha="$GITHUB_SHA"
body="Sprint $MILESTONE; commit integrado $sha."
if [[ -n "${CHANGELOG_PATH:-}" ]]; then
  root=$(realpath "${GITHUB_WORKSPACE:-$(pwd)}")
  [[ "$CHANGELOG_PATH" != /* && "$CHANGELOG_PATH" != *'..'* ]] || {
    echo 'changelog_path inválido' >&2; exit 1;
  }
  changelog=$(realpath "$root/$CHANGELOG_PATH")
  [[ "$changelog" == "$root/"* && -f "$changelog" ]] || {
    echo 'Changelog fora do repositório ou inexistente' >&2; exit 1;
  }
  body=$(<"$changelog")
fi

report() {
  local outcome="$1" url="${2:-}"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf 'version=%s\ntag=%s\nrelease_url=%s\noutcome=%s\n' "$version" "$tag" "$url" "$outcome" >> "$GITHUB_OUTPUT"
  fi
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    printf '### Publicação %s\nVersão: %s · tag: %s · commit: %s\n' "$outcome" "$version" "$tag" "$sha" >> "$GITHUB_STEP_SUMMARY"
  fi
}

current_ref_sha() {
  local payload type object_sha
  payload=$(gh api "repos/$repo/git/ref/tags/$tag" 2>/dev/null) || return 1
  type=$(node -p 'JSON.parse(process.argv[1]).object.type' "$payload")
  object_sha=$(node -p 'JSON.parse(process.argv[1]).object.sha' "$payload")
  if [[ "$type" == tag ]]; then
    payload=$(gh api "repos/$repo/git/tags/$object_sha")
    type=$(node -p 'JSON.parse(process.argv[1]).object.type' "$payload")
    object_sha=$(node -p 'JSON.parse(process.argv[1]).object.sha' "$payload")
  fi
  [[ "$type" == commit ]] || { echo 'Tag não aponta diretamente para commit' >&2; return 2; }
  printf '%s' "$object_sha"
}

latest=$(git tag --list "$prefix*" --sort=-v:refname)
latest=${latest%%$'\n'*}
if [[ -n "$latest" && "$latest" != "$tag" ]]; then
  older=${latest#"$prefix"}
  if [[ $(node "$node_script" compare "$older" "$version") == none ]]; then
    echo "Versão $version não supera a última tag $latest" >&2
    exit 1
  fi
fi

if ref_sha=$(current_ref_sha); then
  if [[ "$ref_sha" != "$sha" ]]; then
    report conflict
    echo "Conflito: $tag aponta para $ref_sha, não $sha. Nunca mova uma tag publicada." >&2
    exit 1
  fi
else
  # POST git/refs é create-only: uma execução concorrente não consegue sobrescrever.
  if ! gh api -X POST "repos/$repo/git/refs" -f "ref=refs/tags/$tag" -f "sha=$sha" >/dev/null; then
    ref_sha=''
    for attempt in 1 2 3; do
      if ref_sha=$(current_ref_sha); then break; fi
      sleep 1
    done
    [[ -n "$ref_sha" ]] || { echo 'Falha ao criar/consultar tag; investigar antes de repetir' >&2; exit 1; }
    if [[ "$ref_sha" != "$sha" ]]; then
      report conflict
      echo "Conflito concorrente: $tag aponta para $ref_sha" >&2
      exit 1
    fi
  fi
fi

if release=$(gh api "repos/$repo/releases/tags/$tag" 2>/dev/null); then
  url=$(node -p 'JSON.parse(process.argv[1]).html_url' "$release")
  report already-published "$url"
  printf 'Release já publicada: %s\n' "$url"
  exit 0
fi

if ! release=$(gh api -X POST "repos/$repo/releases" -f "tag_name=$tag" -f "target_commitish=$sha" -f "name=$tag" -f "body=$body"); then
  # Outra execução pode ter concluído a release entre o GET anterior e o POST.
  release=''
  for attempt in 1 2 3; do
    if release=$(gh api "repos/$repo/releases/tags/$tag" 2>/dev/null); then break; fi
    sleep 1
  done
  if [[ -n "$release" ]]; then
    url=$(node -p 'JSON.parse(process.argv[1]).html_url' "$release")
    report already-published "$url"
    printf 'Release já publicada por execução concorrente: %s\n' "$url"
    exit 0
  fi
  echo 'Tag criada mas release falhou. Reexecute após corrigir o erro; a tag será preservada.' >&2
  exit 1
fi
url=$(node -p 'JSON.parse(process.argv[1]).html_url' "$release")
report published "$url"
printf 'Release publicada: %s\n' "$url"
