GIT_ROOT="$(git rev-parse --show-toplevel)"
TEST_DIR="${GIT_ROOT}/tests"
HELM_CACHE="${TEST_DIR}/.tmp/cache/$(uname)/helm"
REAL_HOME="${HOME}"

is_windows() {
    ! [[ "$(uname)" == "Darwin" || "$(uname)" == "Linux" ]]
}

_shasum() {
    # MacOS have shasum, others have sha1sum
    if command -v shasum >/dev/null; then
        shasum "$@"
    else
        sha1sum "$@"
    fi
}

initiate() {
    {
        mkdir -p "${HELM_CACHE}/home"
        if [ ! -d "${HELM_CACHE}/chart" ]; then
            helm create "${HELM_CACHE}/chart"
        fi
    } >&2
}

setup() {
    # https://github.com/bats-core/bats-core/issues/39
    if [[ ${BATS_TEST_NAME:?} == "${BATS_TEST_NAMES[0]:?}" ]]; then
        initiate
    fi

    SEED="${RANDOM}"

    TEST_TEMP_DIR="$(TMPDIR="${W_TEMP:-/tmp/}" mktemp -d)"
    HOME="$(mktemp -d)"

    # Use a temporary config-repository reseted after every suite
    export HELM_CONFIG_SCHEME_REPOSITORY="${TEST_TEMP_DIR}/config-repository"

    # shellcheck disable=SC2034
    XDG_DATA_HOME="${HOME}"

    # Windows
    # See: https://github.com/helm/helm/blob/b4f8312dbaf479e5f772cd17ae3768c7a7bb3832/pkg/helmpath/lazypath_windows.go#L22
    # shellcheck disable=SC2034
    APPDATA="${HOME}"

    # install helm plugin
    helm_plugin_install git
    helm plugin install "${GIT_ROOT}"

    # copy .kube from real home
    if [ -d "${REAL_HOME}/.kube" ]; then
        cp -r "${REAL_HOME}/.kube" "${HOME}"
    fi

    # copy assets
    cp -r "${TEST_DIR}/assets" "${TEST_TEMP_DIR}"
}

teardown() {
    # https://stackoverflow.com/a/13864829/8087167
    if [ -n "${RELEASE+x}" ]; then
        helm del "${RELEASE}"
    fi

    # https://github.com/bats-core/bats-file/pull/29
    chmod -R 777 "${TEST_TEMP_DIR}"

    temp_del "${TEST_TEMP_DIR}"
}

create_chart() {
    {
        cp -r "${HELM_CACHE}/chart" "${TEST_TEMP_DIR}"
    } >&2
}

create_config_scheme() {
    {
        export CUSTOM_ENV_VAR="${1}"
        helm config-scheme add "${1}" \
            "${TEST_TEMP_DIR}/rand-assets/values.yaml" \
            "${TEST_TEMP_DIR}/assets/values.yaml" \
            "${TEST_TEMP_DIR}/assets/{{chart}}.yaml" \
            "${TEST_TEMP_DIR}/assets/{{release}}.yaml" \
            "${TEST_TEMP_DIR}/assets/{{CUSTOM_ENV_VAR}}.yaml" \
            "${TEST_TEMP_DIR}/assets/{{namespace}}/values.yaml" \
            "${TEST_TEMP_DIR}/assets/{{namespace}}/{{chart}}.yaml" \
            "${TEST_TEMP_DIR}/assets/{{namespace}}/{{release}}.yaml" \
            "${TEST_TEMP_DIR}/assets/{{namespace}}/{{CUSTOM_ENV_VAR}}.yaml"
    } >&2
}

helm_plugin_install() {
    {
        if ! env APPDATA="${HELM_CACHE}/home/" HOME="${HELM_CACHE}/home/" helm plugin list | grep -q "${1}"; then
            case "${1}" in
            git)
                # See: https://github.com/aslafy-z/helm-git/pull/120
                #URL="https://github.com/aslafy-z/helm-git"
                URL="https://github.com/jkroepke/helm-git"
                VERSION="patch-1"
                ;;
            esac

            env APPDATA="${HELM_CACHE}/home/" HOME="${HELM_CACHE}/home/" helm plugin install "${URL}" ${VERSION:+--version ${VERSION}}
        fi

        cp -r "${HELM_CACHE}/home/." "${HOME}"
    } >&2
}
