#!/usr/bin/env sh

set -eu

remove_usage() {
    cat <<EOF
helm config-scheme remove NAME

Remove NAME configuration scheme
EOF
}

remove() {
    if [ $# -lt 1 ]; then
        remove_usage
        exit 1
    fi
    scheme_name="${1}"

    if ! repository_scheme_exists "${scheme_name}"; then
        log_error "[remove] Scheme '${scheme_name}' doesn't exists"
        exit 2
    fi

    repository_delete_scheme "${scheme_name}"
}
