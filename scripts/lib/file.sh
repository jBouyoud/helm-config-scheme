#!/usr/bin/env sh

set -eu

# shellcheck source=scripts/lib/file/local.sh
. "${SCRIPT_DIR}/lib/file/local.sh"

# shellcheck source=scripts/lib/file/custom.sh
. "${SCRIPT_DIR}/lib/file/custom.sh"

_file_get_protocol() {
    case "$1" in
    *://*)
        echo "custom"
        ;;
    *)
        if [ -d "$1" ]; then
            echo "local_dir"
        elif [ -f "$1" ]; then
            echo "local_file"
        else
            echo "local_regex"
        fi
        ;;
    esac
}

_file_tmpfile() {
    mktemp "${1}/tmp.XXXXXXXXXX"
}

file_get() {
    file_type="$(_file_get_protocol "${1}")"
    tmpdir="${2}"
    res="$(_file_tmpfile "${tmpdir}")"
    touch "${res}"
    echo "${res}"

    _file_"${file_type}"_get "${1}" "${tmpdir}" "${res}"
}
