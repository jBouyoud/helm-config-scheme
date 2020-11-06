#!/usr/bin/env sh

set -eu

edit_usage() {
    cat <<EOF
helm config-scheme edit NAME SUB-COMMAND SUB-COMMAND-ARGS...

Edit an existing NAME configuration scheme

Available Commands:
  -  append FILE-URI...

     Add new FILE-URIs to the end of NAME configuration scheme

  -  insert-at INDEX FILE-URI...

     Add new FILE-URIs at INDEX of NAME configuration scheme

  -  replace INDEX FILE-URI

     Replace an existing file_uri at INDEX by FILE-URI of NAME configuration scheme

$(file_uri_substitution_help)

EOF
}

_edit_check_index() {
    count="$(repository_scheme_file_uri_count "${1}")"
    if [ "${2}" -lt 0 ]; then
        log_error "[edit] INDEX must be in [O;${count}["
        exit 2
    elif [ "${2}" -ge "${count}" ]; then
        log_error "[edit] INDEX must be in [O;${count}["
        exit 2
    fi
}

edit() {
    if [ $# -lt 2 ]; then
        edit_usage
        exit 1
    fi
    scheme_name="${1}"
    subcommand="${2}"
    shift 2

    if ! repository_scheme_exists "${scheme_name}"; then
        log_error "[edit] Scheme '${scheme_name}' doesn't exists"
        exit 2
    fi

    case "${subcommand}" in
    append)
        if [ $# -lt 1 ]; then
            edit_usage
            exit 1
        fi
        for file_uri in "$@"; do
            repository_scheme_append_file_uri "${scheme_name}" "${file_uri}"
        done
        ;;
    insert-at)
        if [ $# -lt 2 ]; then
            edit_usage
            exit 1
        fi
        idx="${1}"
        _edit_check_index "${scheme_name}" "${idx}"

        shift
        for file_uri in "$@"; do
            repository_scheme_insert_file_uri "${scheme_name}" "${idx}" "${file_uri}"
            idx=$((idx + 1))
        done
        ;;
    replace)
        if [ $# -ne 2 ]; then
            edit_usage
            exit 1
        fi
        idx="${1}"
        file_uri="${2}"

        _edit_check_index "${scheme_name}" "${idx}"
        repository_scheme_replace_file_uri "${scheme_name}" "${idx}" "${file_uri}"
        ;;
    *)
        edit_usage
        exit 1
        ;;
    esac
}
