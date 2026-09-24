#!/usr/bin/env bash
set -euo pipefail

validate_release_branch() {
  [[ "$1" =~ ^release/v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || {
    echo "Branch deve ter formato release/vMAJOR.MINOR.PATCH: $1" >&2; return 1;
  }
  MILESTONE="${1#release/}"
  export MILESTONE
}

validate_commit_range() {
  git rev-parse --verify "$1^{commit}" >/dev/null
  git rev-parse --verify "$2^{commit}" >/dev/null
  git merge-base --is-ancestor "$1" "$2" || {
    echo 'A base do PR não é ancestral do commit analisado' >&2; return 1;
  }
  [[ "$1" != "$2" ]] || { echo 'PR sem commits novos' >&2; return 1; }
}

validate_pr_issue() {
  local issue_number="$1" repo="$2" milestone="$3" actual parent_url parent_number
  [[ "$issue_number" =~ ^[1-9][0-9]*$ && "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || {
    echo 'Issue ou repositório inválido no evento de PR' >&2; return 1;
  }
  actual=$(gh api "repos/$repo/issues/$issue_number" --jq '.milestone.title // ""')
  [[ "$actual" == "$milestone" ]] || {
    echo "Issue #$issue_number deve estar vinculada à milestone $milestone" >&2; return 1;
  }
  parent_url=$(gh api "repos/$repo/issues/$issue_number" --jq '.parent_issue_url // ""')
  parent_number=${parent_url##*/}
  [[ "$parent_number" =~ ^[1-9][0-9]*$ ]] || {
    echo "Issue #$issue_number deve ser sub-issue da épica $milestone" >&2; return 1;
  }
  actual=$(gh api "repos/$repo/issues/$parent_number" --jq '.title // ""')
  [[ "$actual" == "$milestone" ]] || {
    echo "Épica da issue #$issue_number deve se chamar $milestone" >&2; return 1;
  }
}
