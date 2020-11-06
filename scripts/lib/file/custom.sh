#!/usr/bin/env sh

_file_custom_get() {
    helm template "${SCRIPT_DIR}/lib/file/helm-values-getter" -f "${1}" |
        sed -E -e "s/^# Source: .+$//" -e "s/^---$//"
}
