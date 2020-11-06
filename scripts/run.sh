#!/usr/bin/env sh

set -eu

# Output debug infos
QUIET="${HELM_CONFIG_SCHEME_QUIET:-false}"

# Make sure HELM_BIN is set (normally by the helm command)
HELM_BIN="${HELM_BIN:-helm}"

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
        echo "Error: Not yet implemented."
        exit 2
        ;;
    downloader)
        echo "Error: Not yet implemented."
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
