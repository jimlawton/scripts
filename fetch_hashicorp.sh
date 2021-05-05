#!/bin/bash

HC_KEY_ID="72D7468F"

CURL_CMD="curl --remote-name --silent --show-error --fail "
BASE_URL="https://releases.hashicorp.com"

if [ -z "$3" ]; then ARG_ERR=ERR; fi
if [ -z "$2" ]; then ARG_ERR=ERR; fi
if [ -z "$1" ]; then ARG_ERR=ERR; fi
if [ -n "$ARG_ERR" ]; then
    echo "Usage: $0 <package> <platform> <version>"
    exit
fi

package=$1
platform=$2
version=$3

# Check for dependencies.
if ! command -v gpg &>/dev/null; then
    echo "gpg could not be found!"
    exit 1
fi
if ! command -v shasum &>/dev/null; then
    echo "shasum could not be found!"
    exit 1
fi

# Import HashiCorp GPG signing key.
gpg --receive-keys "${HC_KEY_ID}"
if [ $? -ne 0 ]; then
    echo "Error importing HashiCorp signing key"
    exit 1
fi

# Fetch the package.
pkg_url="${BASE_URL}/${package}/${version}/${package}_${version}_${platform}.zip"
echo "Fetching ${pkg_url}"
${CURL_CMD} ${pkg_url}
if [ $? -ne 0 ]; then
    echo "Error fetching ${pkg_url}"
    exit 1
fi

# Fetch the SHASUMS file.
shasums_url="${BASE_URL}/${package}/${version}/${package}_${version}_SHA256SUMS"
echo "Fetching ${shasums_url}"
${CURL_CMD} ${shasums_url}
if [ $? -ne 0 ]; then
    echo "Error fetching ${shasums_url}"
    # Clean up.
    rm -f ${package}_${version}_${platform}.zip
    exit 1
fi

# Fetch the SHASUMS signature file.
sig_url="${BASE_URL}/${package}/${version}/${package}_${version}_SHA256SUMS.sig"
echo "Fetching ${sig_url}"
${CURL_CMD} ${sig_url}
if [ $? -ne 0 ]; then
    echo "Error fetching ${sig_url}"
    # Clean up.
    rm -f ${package}_${version}_${platform}.zip ${package}_${version}_SHA256SUMS
    exit 1
fi

# Verify the signature file is untampered.
gpg --verify ${package}_${version}_SHA256SUMS.sig ${package}_${version}_SHA256SUMS
if [ $? -ne 0 ]; then
    echo "Signature file failed to verify!"
    # Clean up.
    rm -f ${package}_${version}_${platform}.zip ${package}_${version}_SHA256SUMS ${package}_${version}_SHA256SUMS.sig
    exit 1
fi

# Verify the SHASUM matches the archive.
shasum --ignore-missing -a 256 -c ${package}_${version}_SHA256SUMS
if [ $? -ne 0 ]; then
    echo "Package failed to verify!"
    # Clean up.
    rm -f ${package}_${version}_${platform}.zip ${package}_${version}_SHA256SUMS ${package}_${version}_SHA256SUMS.sig
    exit 1
fi
