#!/usr/bin/env bash

set -eo pipefail

function is_dev() {
  [[ "${1}" =~ .+-dev$ ]]
}

PR_TITLE="${1}"

if ! [[ "${PR_TITLE}" =~ ^Bump[[:space:]]version:[[:space:]](.+?)[[:space:]]→[[:space:]](.+?)$ ]]; then
  echo "::error::The pull request title \"${PR_TITLE}\" is not in the expected format."
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
  echo "mike deploy dev"
  mike deploy dev
else
  if [[ "${OLD_IS_DEV}" != "true" ]]; then
    echo "mike retitle --message \"Remove latest from title of ${OLD_VERSION}\" \"${OLD_VERSION}\" \"${OLD_VERSION}\""
    mike retitle --message "Remove latest from title of ${OLD_VERSION}" "${OLD_VERSION}" "${OLD_VERSION}"
  fi
  echo "mike deploy --update-aliases --title \"${NEW_VERSION} (latest)\" \"${NEW_VERSION}\" \"latest\""
  mike deploy --update-aliases --title "${NEW_VERSION} (latest)" "${NEW_VERSION}" "latest"
fi
