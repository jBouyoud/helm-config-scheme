#!/usr/bin/env sh

set -eu

file_uri_substitution_help() {
    cat <<EOF

FILE-URI specify values in a YAML file or a URL

File uri support some substitutions:

| variable         | substituted by                                          | default value |
| ---------------- | ------------------------------------------------------- | ------------- |
| {{namespace}}    | Helm command namespace                                  | unknown       |
| {{release}}      | Helm release name                                       | RELEASE-NAME  |
| {{chart}}        | Helm chart name                                         | CHART_NAME    |
| {{my_env}}       | Replaced by the environment variable value for "my_env" | unknown       |

Example:
- local/file.yaml
- https://my.repo.com/config/{{namespace}}/file.yaml
- git+https://github.com/user/repo/{{chart}}.yaml?ref=master
- secrets://local/{{release}}.yaml
- local/{{my_env}}.yaml

EOF
}

file_uri_subst() {
    file_uri="${1}"

    if [ -z "${file_uri}" ]; then
        log_error "No file uri specified"
        exit 1
    fi

    echo "${file_uri}" | sed 's/{{/${/g' | sed 's/}}/}/g'
}

unset_subst_args() {
    unset namespace chart release
}

export_subst_args() {
    # shellcheck disable=SC2034
    export namespace="${HELM_NAMESPACE:-unknown}"
    # shellcheck disable=SC2034
    export chart="CHART-NAME"
    # shellcheck disable=SC2034
    export release="RELEASE-NAME"
    # shellcheck disable=SC2086
    _get_subst_args_value ${1}

    # Refine chart value
    if [ -d "${chart}" ]; then
        chart="$(realpath "${chart}")"
    fi
    chart="$(basename "${chart}")"
    # Remove Semver
    chart="$(echo "${chart}" | sed -E 's/(.+)-[0-9]+\.[0-9]+\.[0-9]+(-.+)?/\1/')"
    # Remove ext
    chart="${chart%%.*}"

    log_info "[substitution] Args namespace=${namespace}, chart=${chart}, release=${release}"
}

_get_subst_args_value() {
    args=""

    # Remove all flags, and put all args into var
    i=1
    while [ "$i" -le "$#" ]; do
        eval "arg=\${$i}"
        # shellcheck disable=SC2154
        is_flag="$(_is_helm_flag "${arg}")"

        if [ "${is_flag}" -gt 0 ]; then
            i=$((i + is_flag))
        else
            args="${args} ${arg}"
            i=$((i + 1))
        fi
    done

    log_info "[substitution] analyzing arguments $args"
    # shellcheck disable=SC2086
    set -- $args

    while [ $# -gt 0 ]; do
        case "${1:-}" in
        lint)
            return
            ;;
        template)
            if [ $# -ge 3 ]; then
                release="${2}"
                chart="${3}"
            else
                chart="${2}"
            fi
            return
            ;;
        install | upgrade)
            release="${2}"
            chart="${3}"
            return
            ;;
        esac
        shift
    done
}

_is_helm_flag() {
    case "${1:-}" in
    -g | --generate-name)
        log_error " Unable to proceed repeatable configuration with a generated name"
        return 2
        ;;
    --name-template)
        log_error " name-template flag is not supported"
        return 2
        ;;
    # Global Flags :: Key, Value
    --repository-config | --repository-cache | --registry-config | -n | --namespace | \
        --kubeconfig | --kube-token | --kube-context | --kube-as-user | --kube-as-group | \
        --kube-apiserver)
        echo 2
        ;;
    # Value Options Flags https://github.com/helm/helm/blob/master/cmd/helm/flags.go#L41
    -f | --values | --set | --set-string | --set-file)
        echo 2
        ;;
    # ChartPathOptionsFlags https://github.com/helm/helm/blob/master/cmd/helm/flags.go#L48
    --version | --keyring | --repo | --username | --password | --cert-file | --key-file | --ca-file)
        echo 2
        ;;
    # https://github.com/helm/helm/blob/master/cmd/helm/flags.go#L63
    -o | --output | --post-renderer)
        echo 2
        ;;
    --timeout | --description)
        echo 2
        ;;
    # Template Flags
    -s | --show-only | --output-dir | --api-versions | --release-name)
        echo 2
        ;;
    # Upgrade Flags
    --history-max)
        # Already existing
        # --timeout | --description
        echo 2
        ;;
    -*)
        echo 1
        ;;
    *)
        echo 0
        ;;
    esac
}
