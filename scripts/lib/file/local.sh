#!/usr/bin/env sh

set -eu

_file_local_get() {
    cat "${1}" 2>/dev/null
}
