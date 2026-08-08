#!/bin/sh
set -e

envName="linux"
isTermux=0
if [ -n "${PREFIX}" ]; then
    case "${PREFIX}" in
        */com.termux/*) isTermux=1 ;;
    esac
fi

projectRoot="$(cd "$(dirname "$0")/.." && pwd)"
sourceDb="${projectRoot}/.hymnsdb"

if [ "${isTermux}" = "1" ]; then
    envName="termux"
    targetDb="${HOME}/.hymnsdb"
    linkDir="${PREFIX}/bin"
elif command -v getent >/dev/null 2>&1; then
    envName="linux"
    if [ -n "${SUDO_USER}" ]; then
        realHome=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
    else
        realHome="${HOME}"
    fi
    targetDb="${realHome}/.hymnsdb"
    linkDir="/usr/local/bin"
else
    envName="miniroot"
    targetDb="${HOME}/.hymnsdb"
    linkDir="/usr/local/bin"
fi

if [ -d "${sourceDb}" ]; then
    if [ -d "${targetDb}" ]; then
        echo "偵測到 ${targetDb} 已存在，略過搬移，請自行合併資料" >&2
    else
        mv "${sourceDb}" "${targetDb}"
    fi
fi

if [ "${envName}" = "linux" ] && [ -n "${SUDO_USER}" ] && [ -d "${targetDb}" ]; then
    chown -R "${SUDO_USER}:${SUDO_USER}" "${targetDb}"
fi

targetFile="${projectRoot}/HymnsCLI.py"
mkdir -p "${linkDir}"
linkPath="${linkDir}/hymns"
chmod +x "${targetFile}"
ln -sf "${targetFile}" "${linkPath}"

echo "安裝完成，請執行 hymns 開始使用"

