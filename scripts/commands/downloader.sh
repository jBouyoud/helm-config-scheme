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

    value_files="${TMP_DIR}/result"
    repository_view_scheme "${scheme_name}" | while read -r file_template; do
        eval "file=\"${file_template}\""

        # shellcheck disable=SC2154
        log_info_line "[downloader] Loading values for '${file}' "

        # shellcheck disable=SC2154
        value_files_list="$(file_get "${file}" "${TMP_DIR}")"

        cat "${value_files_list}" >>"${value_files}"

        count="$(wc <"${value_files_list}" -l | awk '{print $1}')"
        if [ "${count}" -eq 0 ]; then
            printf "skipped.\n" >&2
        else
            printf "done. %s file(s) loaded.\n" "${count}" >&2
        fi
        rm -f "${value_files_list}"
    done

    count="$(wc <"${value_files}" -l | awk '{print $1}')"
    if [ "${count}" -eq 0 ]; then
        printf ''
    else
        yq_select=""
        while read -r value_file; do
            if [ "${yq_select}" != "" ]; then
                yq_select="${yq_select} *"
            fi
            yq_select="${yq_select} select(filename == \"${value_file}\")"
        done <"${value_files}"

        # shellcheck disable=SC2046
        _yq eval-all -M "explode(.) |${yq_select}" $(cat "${value_files}")
    fi
}
