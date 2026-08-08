#!/bin/bash
set -e

if [ -n "${SUDO_USER}" ]; then
    realHome=$(dscl . -read "/Users/${SUDO_USER}" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
    if [ -z "${realHome}" ]; then
        realHome=$(eval echo "~${SUDO_USER}")
    fi
else
    realHome="${HOME}"
fi

projectRoot="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sourceDb="${projectRoot}/.hymnsdb"
targetDb="${realHome}/.hymnsdb"

if [ -d "${sourceDb}" ]; then
    if [ -d "${targetDb}" ]; then
        echo "偵測到 ${targetDb} 已存在，略過搬移，請自行合併資料" >&2
    else
        mv "${sourceDb}" "${targetDb}"
    fi
fi

if [ -n "${SUDO_USER}" ] && [ -d "${targetDb}" ]; then
    chown -R "${SUDO_USER}:staff" "${targetDb}"
fi

targetFile="${projectRoot}/HymnsCLI.py"
linkDir="/usr/local/bin"
linkPath="${linkDir}/hymns"
mkdir -p "${linkDir}"
chmod +x "${targetFile}"
ln -sf "${targetFile}" "${linkPath}"

echo "安裝完成，請執行 hymns 開始使用"
