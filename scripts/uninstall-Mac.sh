#!/bin/bash
set -e

purgeData=0
for arg in "$@"; do
    if [ "${arg}" = "--purge" ]; then
        purgeData=1
    fi
done

linkPath="/usr/local/bin/hymns"
if [ -e "${linkPath}" ] || [ -L "${linkPath}" ]; then
    if [ -w "$(dirname "${linkPath}")" ]; then
        rm -f "${linkPath}"
    else
        sudo rm -f "${linkPath}"
    fi
    echo "已移除指令連結：${linkPath}"
else
    echo "找不到指令連結：${linkPath}，可能尚未安裝或已移除"
fi

if [ -n "${SUDO_USER}" ]; then
    realHome=$(dscl . -read "/Users/${SUDO_USER}" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
    if [ -z "${realHome}" ]; then
        realHome=$(eval echo "~${SUDO_USER}")
    fi
else
    realHome="${HOME}"
fi

if [ "${purgeData}" = "1" ]; then
    if [ -d "${realHome}/.hymnsdb" ]; then
        rm -rf "${realHome}/.hymnsdb"
        echo "已刪除資料庫資料夾：${realHome}/.hymnsdb"
    fi
else
    echo "資料庫資料夾 ${realHome}/.hymnsdb 已保留；如需一併刪除請加上 --purge"
fi

echo "解除安裝完成"
