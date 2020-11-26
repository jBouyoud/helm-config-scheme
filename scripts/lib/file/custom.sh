#!/usr/bin/env sh

_file_custom_get() {
    uri="${1}"
    tmpfile="$(_file_tmpfile "${2}")"
    res="${3}"

    helm template "${SCRIPT_DIR}/lib/file/helm-values-getter" -f "${uri}" 2>/dev/null |
        sed -E -e "s/^# Source: .+$//" -e "s/^---$//" >"${tmpfile}"

    if [ -s "${tmpfile}" ]; then
        echo "${tmpfile}" >>"${res}"
    fi
}
