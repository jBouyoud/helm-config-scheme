#!/usr/bin/env sh

set -eu

# Configuration directly for all scheme
CONFIG_REPOSITORY="${HELM_CONFIG_SCHEME_REPOSITORY:-${HELM_PLUGIN_DIR}/repository}"

# Make sure that directory exists
mkdir -p "${CONFIG_REPOSITORY}"

_repository_scheme_file() {
    echo "${CONFIG_REPOSITORY}/${1}"
}

repository_list_scheme() {
    ls -1 "${CONFIG_REPOSITORY}"
}

repository_scheme_exists() {
    test -f "$(_repository_scheme_file "${1}")"
}

repository_view_scheme() {
    cat "$(_repository_scheme_file "${1}")"
}

repository_create_scheme() {
    scheme_name="${1}"

    log_info "[registry] Creating '${scheme_name}'"
    printf '' >"$(_repository_scheme_file "${scheme_name}")"
}

repository_delete_scheme() {
    rm -f "$(_repository_scheme_file "${1}")"
}

repository_scheme_file_uri_count() {
    repository_view_scheme "${1}" | wc -l | awk '{print $1}'
}

repository_scheme_append_file_uri() {
    scheme_name="${1}"
    file_uri="${2}"

    log_info "[registry] Add file uri '${file_uri}' to scheme '${scheme_name}'"
    file_uri_scheme="$(file_uri_subst "${file_uri}")"
    scheme_file="$(_repository_scheme_file "${scheme_name}")"

    echo "${file_uri_scheme}" >>"${scheme_file}"
}

_sed_i() {
    # MacOS syntax is different for in-place
    if [ "$(uname)" = "Darwin" ]; then
        sed -i "" "$@"
    else
        sed -i "$@"
    fi
}

repository_scheme_insert_file_uri() {
    scheme_name="${1}"
    index="${2}"
    file_uri="${3}"

    log_info "[registry] Add file uri '${file_uri}' to scheme '${scheme_name}'"
    file_uri_scheme="$(file_uri_subst "${file_uri}")"
    scheme_file="$(_repository_scheme_file "${scheme_name}")"

    sed "${index}s/\(.*\)/\1#${file_uri}/" "${scheme_file}" | tr '#' '\n' >"${scheme_file}.tmp"
    mv "${scheme_file}.tmp" "${scheme_file}"
}

repository_scheme_replace_file_uri() {
    scheme_name="${1}"
    index="${2}"
    file_uri="${3}"

    log_info "[registry] Add file uri '${file_uri}' to scheme '${scheme_name}'"
    file_uri_scheme="$(file_uri_subst "${file_uri}")"
    scheme_file="$(_repository_scheme_file "${scheme_name}")"

    _sed_i "$((index + 1))s/.*/${file_uri}/" "${scheme_file}"
}
