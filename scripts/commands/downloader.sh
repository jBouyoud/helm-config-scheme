#!/usr/bin/env sh

set -eu

# Create temporary directory
TMP_DIR="${HELM_CONFIG_SCHEME_TMP_DIR:-$(mktemp -d)}"

YQ_PATH="${HELM_PLUGIN_DIR}/.bin/"

_trap_hook() {
    unset_subst_args
    rm -rf "${TMP_DIR}"
}

_yq() {
    if [ -f "${YQ_PATH}/yq" ]; then
        "${YQ_PATH}/yq" "$@"
    else
        "${YQ_PATH}/yq.exe" "$@"
    fi
}

downloader() {
    if [ $# -ne 2 ]; then
        log_error "[downloader] Not able to download config, missing args"
        exit 2
    fi
    uri="${1}"
    parent_process_cmd_line="${2}"

    case "${uri}" in
    "config://"*) ;;

    *)
        log_error "[downloader] URI '${uri}' not supported"
        exit 2
        ;;
    esac

    scheme_name=$(printf '%s' "${uri}" | sed 's!config://!!')

    if ! repository_scheme_exists "${scheme_name}"; then
        log_error "[downloader] Scheme '${scheme_name}' doesn't exists"
        exit 2
    fi

    # build parameters
    export_subst_args "${parent_process_cmd_line}"

    idx=0
    repository_view_scheme "${scheme_name}" | while read -r file_template; do
        log_info "[downloader] Looking for '${file_template}'..."

        eval "file=${file_template}"
        # shellcheck disable=SC2154
        file_content="$( (_file_get "${file}" || printf ''))"

        if [ -z "${file_content}" ]; then
            log_info "[downloader] Ignored config source : ${file}"
        else
            log_info "[downloader] Loaded config source : ${file}"
            printf '%s\n' "${file_content}" >"${TMP_DIR}/file-${idx}"
            idx=$((idx + 1))
        fi
    done

    if [ "$(find "${TMP_DIR}" -type f | wc -l)" -le 1 ]; then
        cat "${TMP_DIR}/file-0" 2>/dev/null || printf ''
    else
        _yq merge -x "${TMP_DIR}"/file-*
    fi
}
