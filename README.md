# HymnsCLI 終端機詩歌本

在終端機中查詢與瀏覽詩歌的小工具，支援依編號查詢與關鍵字搜尋。

## 專案結構

```
HymnsCLI/
├── HymnsCLI.py                主程式
├── requirements.txt            Python 相依套件
├── .hymnsdb/                   詩歌資料庫（安裝時會搬移至使用者家目錄下）
└── scripts/                     各平台安裝／解除安裝腳本
    ├── setup.sh                 安裝：Linux／Termux／MiniRootFS 通用（自動偵測環境）
    ├── setup-macOS.sh            安裝：macOS
    ├── setup-Windows.ps1         安裝：Windows
    ├── uninstall.sh               解除安裝：Linux／Termux／MiniRootFS 通用
    ├── uninstall-macOS.sh         解除安裝：macOS
    └── uninstall-Windows.ps1      解除安裝：Windows
```

## 事前準備

0. 您必須取得詩歌本資料庫，並將其放置到專案根目錄為.hymnsdb資料夾，包含db,bb,er,xg,xb,yb資料夾，裡面的檔案命名如db1.txt --> 大本詩歌第一首。寄信到shareuser.se7510@gmail.com要求解壓縮密碼。
1. 確認環境已安裝 Python 3。
2. 安裝相依套件：

```
pip3 install -r requirements.txt
```

3. 若 `.hymnsdb/` 資料夾內尚無資料，請將您原有的詩歌資料庫複製進去
   （詳見 `.hymnsdb/README.txt`）。

## 安裝方式

務必先 `cd` 到本專案根目錄再執行對應腳本。

| 環境 | 指令 |
|---|---|
| 大多數 Linux（Ubuntu/Debian 等） | `sudo bash scripts/setup.sh` |
| macOS | `sudo bash scripts/setup-macOS.sh` |
| Windows | `powershell -ExecutionPolicy Bypass -File scripts\setup-Windows.ps1` |
| Termux | `bash scripts/setup.sh` |
| Linux MiniRootFS | `sh scripts/setup.sh` |

安裝完成後即可在任意目錄下執行 `hymns` 指令。

Windows 使用者請確認使用者資料夾下的 `bin\` 已加入 `Path` 環境變數，
否則無法直接呼叫 `hymns`。

`scripts/setup.sh` 為 Linux／Termux／MiniRootFS 通用腳本，會依序偵測：

1. 是否處於 Termux 環境（依 `$PREFIX` 路徑判斷），若是則安裝連結至
   `$PREFIX/bin`；
2. 若非 Termux，再檢查是否具備 `getent` 指令：有則視為一般 Linux，
   依 `SUDO_USER` 解析真實家目錄並設定資料夾擁有者；沒有則視為
   MiniRootFS 環境，直接以目前 `$HOME` 為準，兩者皆安裝連結至
   `/usr/local/bin`。

不需依環境分別選擇腳本，也不需自行指定參數。

macOS 因不具備 GNU 的 `getent` 指令，改用系統原生的 `dscl` 解析真實家目錄，
故獨立成 `setup-macOS.sh`，不可直接使用 `setup.sh`。

## 使用方式

```
hymns            互動式查詢，依詩集代碼與首數查找
hymns --search   關鍵字查詢模式
```

詩集代碼對照：`db`=詩歌本、`bb`=補充本、`er`=兒童詩歌、`xb`=新歌誦詠、`yb`=青年詩歌、`xg`=其他。

## 解除安裝

`scripts/uninstall.sh` 為 Linux／Termux／MiniRootFS 通用腳本，
會自動偵測並移除對應環境下的 `hymns` 指令連結
（`/usr/local/bin/hymns` 或 Termux 的 `$PREFIX/bin/hymns`），
不需依環境分別選擇腳本。macOS 因家目錄解析方式不同，需使用獨立的
`uninstall-macOS.sh`。

```
sh scripts/uninstall.sh            移除指令連結，保留 ~/.hymnsdb 資料
sh scripts/uninstall.sh --purge    移除指令連結，並一併刪除 ~/.hymnsdb 資料
```

```
sudo sh scripts/uninstall-macOS.sh            macOS：保留 ~/.hymnsdb 資料
sudo sh scripts/uninstall-macOS.sh --purge    macOS：連同資料一併刪除
```

若原本以 `sudo bash scripts/setup.sh`（或 `setup-macOS.sh`）安裝，
解除安裝時建議同樣加上 `sudo` 執行，避免權限不足導致無法移除
`/usr/local/bin/hymns`。

Windows 環境請使用：

```
powershell -ExecutionPolicy Bypass -File scripts\uninstall-Windows.ps1
powershell -ExecutionPolicy Bypass -File scripts\uninstall-Windows.ps1 -Purge
```

預設皆不會刪除詩歌資料庫，需明確加上 `--purge`（Windows 為 `-Purge`）才會刪除，
避免誤刪重要資料。

## 重新安裝或更新

安裝腳本具備冪等性（idempotent）：若偵測到使用者家目錄下已存在
`.hymnsdb`，會直接略過搬移動作並提示訊息，不會覆蓋或巢狀嵌入既有資料。

