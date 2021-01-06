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

YQ_DEFAULT_VERSION="4.2.1"
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
YQ_SHA_darwin_amd64="9d84f133675164694039fc9072a322e3ec0c96444a68be38082ebc85ec11d55a"
# shellcheck disable=SC2034
YQ_SHA_linux_368="2b0afeff49ee9b0c44c652cf925f04fc8f9c4d237b8a6ad89173b239ca44a17b"
# shellcheck disable=SC2034
YQ_SHA_linux_amd64="51018dedf4cb510c7cf6c42663327605e7e0c315747fe584fbf83cc10747449c"
# shellcheck disable=SC2034
YQ_SHA_windows_368="1f264f96934ce8bcf45de018e8f6094eb9a9c560a8032308b2085483a2a0a7fd"
# shellcheck disable=SC2034
YQ_SHA_windows_amd64="d17497653f8f22f22c4cfd9de2277f8a66e9a29932061f5c8a45468c38399ca9"

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
