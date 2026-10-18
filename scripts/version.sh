#!/usr/bin/env bash
set -euo pipefail

for cmd in {git,sed}; do
  if [[ ! -x "$(command -v "${cmd}")" ]]; then
    printf 'error: command not found: %s\n' "${cmd}" >&2
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

version() {
  # shellcheck source=./branch.sh
  source "${SCRIPT_DIR}/branch.sh"

  local version
  version="$(current_tag)"

  if [[ -z ${version} ]]; then
    version="$(next_version)"
  fi

  printf '%s\n' "${version}"
}

current_tag() {
  local tag
  tag="$(git describe --tags --exact-match 2>/dev/null)"
  printf '%s' "${tag}"
}

last_accessible_tag() {
  local tag
  tag="$(git describe --tags --abbrev=0 2>/dev/null)"
  if [[ -z ${tag} ]]; then
    tag="0.0.0"
  fi
  printf '%s' "${tag}"
}

increment_minor() {
  local version="$1"
  # Remove 'v' prefix if present
  version="${version#v}"
  IFS='.' read -r major minor _ <<<"${version}"
  # Validate that major and minor are numbers
  if ! [[ "${major}" =~ ^[0-9]+$ ]] || ! [[ "${minor}" =~ ^[0-9]+$ ]]; then
    printf 'error: invalid version format: %s\n' "$1" >&2
    exit 1
  fi
  local next_minor="$((minor + 1))"
  printf '%s.%s.%s' "${major}" "${next_minor}" "0"
}

increment_major() {
  local version="$1"
  # Remove 'v' prefix if present
  version="${version#v}"
  IFS='.' read -r major minor _ <<<"${version}"
  # Validate that major is a number
  if ! [[ "${major}" =~ ^[0-9]+$ ]]; then
    printf 'error: invalid version format: %s\n' "$1" >&2
    exit 1
  fi
  local next_major="$((major + 1))"
  printf '%s.%s.%s' "${next_major}" "0" "0"
}

next_version() {
  last_accessible_tag="$(last_accessible_tag)"

  local version
  bodies="$(git log --format=%B "${last_accessible_tag}..HEAD" 2>/dev/null || [[ "${last_accessible_tag}" = "0.0.0" ]])"
  if grep -qi "BREAKING CHANGE" <<<"${bodies}"; then
    version="$(increment_major "${last_accessible_tag}")"
  else
    version="$(increment_minor "${last_accessible_tag}")"
  fi

  current_branch="$(branch)"
  if [[ ${current_branch} =~ main|master ]] && [[ -z "$(git status --porcelain)" ]]; then
    printf '%s' "${version}"
    return 0
  fi

  local pre_release
  # Remove leading zeros but keep at least one character
  pre_release="$(printf '%s' "${current_branch}" | sed 's/^0*\(.\)/\1/')"

  if [[ -n ${pre_release} ]]; then
    version="${version}-${pre_release}"
  fi

  local commit_hash
  commit_hash="$(git rev-parse --short HEAD)"
  local build_metadata
  build_metadata="${commit_hash}"

  if [[ -n "$(git status --porcelain)" ]]; then
    build_metadata="${build_metadata}.dirty"
  fi

  version="${version}.${build_metadata}"

  printf '%s' "${version}"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  version "$@"
fi
