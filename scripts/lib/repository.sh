#!/usr/bin/env sh

set -eu

# Configuration directly for all scheme
CONFIG_REPOSITORY="${HELM_CONFIG_SCHEME_REPOSITORY:-${HELM_PLUGIN_DIR}/repository}"

# Make sure that directory exists
mkdir -p "${CONFIG_REPOSITORY}"

_repository_scheme_file() {
    echo "${CONFIG_REPOSITORY}/${1}"
}

repository_scheme_exists() {
    test -f "$(_repository_scheme_file "${1}")"
}

repository_create_scheme() {
    scheme_name="${1}"

    log_info "[registry] Creating '${scheme_name}'"
    printf '' >"$(_repository_scheme_file "${scheme_name}")"
}

repository_scheme_append_file_uri() {
    scheme_name="${1}"
    file_uri="${2}"

    log_info "[registry] Add file uri '${file_uri}' to scheme '${scheme_name}'"
    file_uri_scheme="$(file_uri_subst "${file_uri}")"
    scheme_file="$(_repository_scheme_file "${scheme_name}")"

    echo "${file_uri_scheme}" >>"${scheme_file}"
}
