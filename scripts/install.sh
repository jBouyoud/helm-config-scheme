#!/usr/bin/env sh

set -eu

# Path to current directory
SCRIPT_DIR="$(dirname "$0")"

if [ "$(uname)" = "Darwin" ]; then
    if ! command -v realpath >/dev/null; then
        brew install coreutils
    fi
fi

YQ_PATH="${HELM_PLUGIN_DIR}/.bin/"
mkdir -p "${YQ_PATH}"

YQ_DEFAULT_VERSION="3.4.1"
YQ_VERSION="${YQ_VERSION:-"${YQ_DEFAULT_VERSION}"}"

YQ_PLATFORM="windows"
if [ "$(uname)" = "Darwin" ]; then
    YQ_PLATFORM="darwin"
elif [ "$(uname)" = "Linux" ]; then
    YQ_PLATFORM="linux"
fi

YQ_ARCH="386"
if [ "$(uname -m)" = "x86_64" ]; then
    YQ_ARCH="amd64"
fi

YQ_SUFFIX=""
if [ "${YQ_PLATFORM}" = "windows" ]; then
    YQ_SUFFIX=".exe"
fi

YQ_URL="${YQ_URL:-"https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${YQ_PLATFORM}_${YQ_ARCH}${YQ_SUFFIX}"}"

# shellcheck disable=SC2034
YQ_SHA_darwin_amd64="5553d4640550debed5213a5eb6016d3a3485ca8a36e9c71996610280755d5a50"
# shellcheck disable=SC2034
YQ_SHA_linux_368="ba57700f41cf21bf019af0eec47cf9884f70c25bc5abb0f3347bd42f19609739"
# shellcheck disable=SC2034
YQ_SHA_linux_amd64="adbc6dd027607718ac74ceac15f74115ac1f3caef68babfb73246929d4ffb23c"
# shellcheck disable=SC2034
YQ_SHA_windows_368="6292e14b0c199f2bd33e18a8bfe67f100084837163e1e2bc4934bcd7990a5087"
# shellcheck disable=SC2034
YQ_SHA_windows_amd64="987d31d3a9b75f9cb0f202173aab033d333d2406ba2caa7dba9d16a5204c2167"

YQ_SHA_DEFAULT_NAME="YQ_SHA_${YQ_PLATFORM}_${YQ_ARCH}"
eval YQ_SHA_DEFAULT="\$${YQ_SHA_DEFAULT_NAME}"
YQ_SHA="${YQ_SHA:-"${YQ_SHA_DEFAULT}"}"

RED='\033[0;31m'
NOC='\033[0m'

get_sha_256() {
    if [ ! -f "${1}" ]; then
        res=''
    elif command -v sha256sum >/dev/null; then
        res=$(sha256sum "$1")
    elif command -v shasum >/dev/null; then
        res=$(shasum -a 256 "$1")
    else
        res=''
    fi

    echo "$res" | cut -d ' ' -f 1
}

# shellcheck source=scripts/lib/http.sh
. "${SCRIPT_DIR}/lib/http.sh"

if [ -n "${SKIP_YQ_INSTALL+x}" ] && [ "${SKIP_YQ_INSTALL}" = "true" ]; then
    echo "Skipping yq installation."
    exit 0
fi

YQ_SHA256="$(get_sha_256 "${YQ_PATH}")"

if [ "${YQ_SHA256}" != "${YQ_SHA}" ] || [ "${YQ_SHA256}" = "" ]; then
    echo "Installing/Upgrading yq dependency..."

    if ! download "${YQ_URL}" >/tmp/yq; then
        printf "${RED}%s${NOC}\n" "Can't download yq ..."
        exit 1
    fi

    YQ_SHA256="$(get_sha_256 /tmp/yq)"
    if [ "${YQ_SHA256}" = "${YQ_SHA}" ] || [ "${YQ_SHA256}" = "" ]; then
        chmod +x /tmp/yq
        mv /tmp/yq "${YQ_PATH}/yq${YQ_SUFFIX}"
    else
        printf "${RED}%s${NOC}\n" "Checksum mismatch : expected ${YQ_SHA} but was ${YQ_SHA256}"
        if [ "${YQ_VERSION}" != "${YQ_DEFAULT_VERSION}" ]; then
            printf "${RED}%s${NOC}\n" "Forgot to set YQ_SHA?"
        fi
        echo "Ignoring ..."
    fi
    rm -f /tmp/yq
fi
