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
        echo "local"
        ;;
    esac
}

_file_get() {
    file_type=$(_file_get_protocol "${1}")

    _file_"${file_type}"_get "$@"
}
