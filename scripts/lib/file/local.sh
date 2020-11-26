#!/usr/bin/env sh

set -eu

_file_local_file_get() {
    file="${1}"
    res="${3}"

    if [ -s "${file}" ]; then
        tmpfile="$(_file_tmpfile "${2}")"

        cp -f "${file}" "${tmpfile}"
        echo "${tmpfile}" >>"${res}"
    fi
}

_file_local_regex_get() {
    find "$(dirname "${1}")" -type f 2>/dev/null | grep -E "${1}" | sort | while read -r valueFile; do
        _file_local_file_get "${valueFile}" "${2}" "${3}"
    done
}

_file_local_dir_get() {
    find "${1}" -maxdepth 1 -type f -name '*yaml' -or -name '*yml' | sort | while read -r valueFile; do
        _file_local_file_get "${valueFile}" "${2}" "${3}"
    done
}
