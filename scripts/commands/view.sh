#!/usr/bin/env sh

set -eu

view_usage() {
    cat <<EOF
helm config-scheme view NAME

View configured files uri in NAME configuration scheme
EOF
}

view() {
    if [ $# -lt 1 ]; then
        view_usage
        exit 1
    fi
    scheme_name="${1}"

    if ! repository_scheme_exists "${scheme_name}"; then
        log_error "[view] Scheme '${scheme_name}' doesn't exists"
        exit 2
    fi

    repository_view_scheme "${scheme_name}" | sed '=' | sed 'N; s/\n/ /'
}
