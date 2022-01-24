#!/usr/bin/env sh

set -eu

# Path to current directory
SCRIPT_DIR="$(dirname "$0")"

if [ "$(uname)" = "Darwin" ]; then
    if ! command -v realpath >/dev/null; then
        brew install coreutils
    fi
fi

# Try something different

YQ_PATH="${HELM_PLUGIN_DIR}/.bin/"
mkdir -p "${YQ_PATH}"

YQ_DEFAULT_VERSION="4.9.6"
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

YQ_URL="${YQ_URL:-"https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${YQ_PLATFORM}_${YQ_ARCH}${YQ_SUFFIX}"}"

# Retrieve sha256 with : `cat checksums | awk '{print $1; print $19;}'`
# shellcheck disable=SC2034
YQ_SHA_darwin_amd64="8ef8160d69a5bb24e101ca4fcbad2e997b575a6dbb2f6e88f8d393cafeba3b40"
# shellcheck disable=SC2034
YQ_SHA_linux_368="faf5d5537f1ac5f48bea57c1f5296d4a1faee5bd946a2e5f01348c2aa45cdf85"
# shellcheck disable=SC2034
YQ_SHA_linux_amd64="a1cfa39a9538e27f11066aa5659b32f9beae1eea93369d395bf45bcfc8a181dc"
# shellcheck disable=SC2034
YQ_SHA_windows_368="a26d63eca8f4e2307aa8a74de750877bfd2f7fdb3e8f00b230192e04b18cc619"
# shellcheck disable=SC2034
YQ_SHA_windows_amd64="8023170aea489b7f1a52fbdc047dccc5fbfb25dca33b43082a71942721d06f50"

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
