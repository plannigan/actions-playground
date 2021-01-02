#!/usr/bin/env bash

set -eo pipefail

echo "::group::Configure Git User"
"${GITHUB_ACTION_PATH}/configure_git_user.sh"
echo "::endgroup::"

echo "::group::Pull down latest docs commit"
git fetch --no-tags --prune --progress --no-recurse-submodules --depth=1 origin gh-pages
echo "::endgroup::"

echo "::group::Publish documentation"
if [[ "${VERSION_BUMP_PR}" == "false" ]]; then
  if [[ "${VERSION_NAME}" == "" ]]; then
    echo "::error::'version_name' must be specified when 'version_bump_pr' is false."
    exit 1
  fi
  echo "mike deploy \"${VERSION_NAME}\""
  mike deploy "${VERSION_NAME}"
elif [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]]; then
  echo "::error::version_bump_pr can only be used for pull request events."
  exit 1
else
  "${GITHUB_ACTION_PATH}/update_docs_for_version.sh" "${PR_TITLE}"
fi
echo "git push origin gh-pages"
git push origin gh-pages
echo "::endgroup::"
