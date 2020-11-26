#!/usr/bin/env sh

set -eu

# Output infos
QUIET="${HELM_CONFIG_SCHEME_QUIET:-false}"

log_info() {
    if [ "${QUIET}" = "false" ]; then
        printf "[config-scheme]%s\n" "$@" >&2
    fi
}

log_info_line() {
    if [ "${QUIET}" = "false" ]; then
        printf "[config-scheme]%s" "$@" >&2
    fi
}

log_error() {
    echo
    printf "[config-scheme]%s\n" "$@"
}
