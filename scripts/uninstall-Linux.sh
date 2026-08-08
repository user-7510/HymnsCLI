#!/bin/sh
set -e

purgeData=0
for arg in "$@"; do
    if [ "${arg}" = "--purge" ]; then
        purgeData=1
    fi
done

removeLink() {
    linkPath="$1"
    if [ -e "${linkPath}" ] || [ -L "${linkPath}" ]; then
        if [ -w "$(dirname "${linkPath}")" ]; then
            rm -f "${linkPath}"
        elif command -v sudo >/dev/null 2>&1; then
            sudo rm -f "${linkPath}"
        else
            rm -f "${linkPath}"
        fi
        echo "已移除指令連結：${linkPath}"
    fi
}

removeLink "/usr/local/bin/hymns"
if [ -n "${PREFIX}" ]; then
    removeLink "${PREFIX}/bin/hymns"
fi

if [ -n "${SUDO_USER}" ]; then
    realHome=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
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
