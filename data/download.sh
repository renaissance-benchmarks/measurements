#!/bin/bash
set -euo pipefail

DOWNLOAD () {
    local RECD="${1}"
    local FILE="${2}"
    local LINK="https://zenodo.org/record/${RECD}/files/${FILE}?download=1${FILE}"
    curl "${LINK}" --output "${FILE}"
    aunpack "${FILE}"
}

DOWNLOAD 4492935 20210109-0.11.0-91cf51ddb8af003685eca89f96371fd2e7bb3c7e.tar.xz
DOWNLOAD 4492861 20200608-0.11.0-91cf51ddb8af003685eca89f96371fd2e7bb3c7e.tar.xz
