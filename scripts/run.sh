#!/usr/bin/env sh

set -eu

# Path to current directory
SCRIPT_DIR="$(dirname "$0")"

# Make sure HELM_BIN is set (normally by the helm command)
HELM_BIN="${HELM_BIN:-helm}"

# shellcheck source=scripts/lib/log.sh
. "${SCRIPT_DIR}/lib/log.sh"

# shellcheck source=scripts/lib/is_help.sh
. "${SCRIPT_DIR}/lib/is_help.sh"

# shellcheck source=scripts/lib/file_uri_substitution.sh
. "${SCRIPT_DIR}/lib/file_uri_substitution.sh"

# shellcheck source=scripts/lib/repository.sh
. "${SCRIPT_DIR}/lib/repository.sh"

_trap_hook() {
    true
}

_trap() {
    _trap_hook
}

trap _trap EXIT

usage() {
    cat <<EOF
Repeatable configuration scheme for Helm Charts

This plugin provides a convenient way to manage a set of configuration scheme
And allow to use those defined scheme in your chart operations

Available Commands:
  add     Create a new configuration scheme
  edit    Edit a configuration scheme
  list    List existing configuration scheme
  remove  Remove a configuration scheme
  view    View a configuration scheme

Configuration scheme usage with : 'config://<scheme-name>'
EOF
}

while true; do
    case "${1:-}" in
    add | edit | list | remove | view)
        # shellcheck disable=SC1090
        . "${SCRIPT_DIR}/commands/${1}.sh"

        if is_help "${2:-}"; then
            "${1}_usage"
            exit 0
        fi

        "${@}"
        break
        ;;
    downloader)
        log_error "Error: Not yet implemented."
        exit 2
        ;;
    --help | -h | help)
        usage
        break
        ;;
    --quiet | -q)
        # shellcheck disable=SC2034
        QUIET=true
        ;;
    "")
        usage
        exit 1
        ;;
    esac

    shift
done

exit 0
