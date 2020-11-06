#!/usr/bin/env sh

set -eu

add_usage() {
    cat <<EOF
helm config-scheme add NAME FILE-URI...

Create a new configuration scheme NAME with all specified FILE-URI

$(file_uri_substitution_help)

EOF
}

add() {
    if [ $# -lt 2 ]; then
        add_usage
        exit 1
    fi
    scheme_name="${1}"
    shift

    if repository_scheme_exists "${scheme_name}"; then
        log_error "[add] Scheme '${scheme_name}' already exists"
        exit 2
    fi

    repository_create_scheme "${scheme_name}"

    for file_uri in "$@"; do
        repository_scheme_append_file_uri "${scheme_name}" "${file_uri}"
    done
}
