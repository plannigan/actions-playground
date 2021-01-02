#!/usr/bin/env bash

set -eo pipefail

function is_dev() {
  [[ "${1}" =~ .+-dev$ ]]
}

VERSION_NAME="${VERSION_NAME:-}"
VERSION_BUMP_PR="${VERSION_NAME:-false}"
PR_TITLE="${PR_TITLE:-}"

if [[ "${VERSION_NAME}" == "" && "${VERSION_BUMP_PR}" == "false" ]]; then
  echo "::error::'version_name' must be specified when 'version_bump_pr' is false."
  exit 1
fi

if [[ "${VERSION_BUMP_PR}" == "false" ]]; then
  mike deploy --push "${VERSION_NAME}"
  exit 0
fi

if [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]]; then
  echo "::error::version_bump_pr can only be used for pull request events."
  exit 1
fi
if [[ "${PR_TITLE}" =~ ^Bump\sversion:\s(.+?)\s→\s(.+?)$ ]]; then
  echo "::error::The pull request title is not in the expected format."
  exit 1
fi

OLD_VERSION="${BASH_REMATCH[1]}"
NEW_VERSION="${BASH_REMATCH[2]}"

NEW_IS_DEV="false"
OLD_IS_DEV="false"

if is_dev "${OLD_VERSION}"; then
  OLD_IS_DEV="true"
fi
if is_dev "${NEW_VERSION}"; then
  NEW_IS_DEV="true"
fi

if [[ "${NEW_IS_DEV}" == "true" ]]; then
  mike deploy --push dev
else
  if [[ "${OLD_IS_DEV}" != "true" ]]; then
    mike retitle --message "Remove latest from title of ${OLD_VERSION}" "${OLD_VERSION}" "${OLD_VERSION}"
  fi
  mike deploy --push --update-aliases --title "${NEW_VERSION} (latest)" "${NEW_VERSION}" "latest"
fi
