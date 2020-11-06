#!/usr/bin/env sh

set -eu

list_usage() {
    cat <<EOF
helm config-scheme list

View all configured configuration schemes
EOF
}

list() {
    repository_list_scheme | while read -r scheme; do
        printf "%s\t%i file-uri(s)\n" "${scheme}" "$(repository_scheme_file_uri_count "${scheme}")"
    done
}
