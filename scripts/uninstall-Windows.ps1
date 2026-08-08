param(
    [switch]$Purge
)

$linkPath = Join-Path -Path (Join-Path -Path $env:USERPROFILE -ChildPath "bin") -ChildPath "hymns.bat"

if (Test-Path -Path $linkPath) {
    Remove-Item -Path $linkPath -Force
    Write-Host "已移除指令連結：$linkPath"
} else {
    Write-Host "找不到指令連結：$linkPath，可能尚未安裝或已移除"
}

$targetDb = Join-Path -Path $env:USERPROFILE -ChildPath ".hymnsdb"

if ($Purge) {
    if (Test-Path -Path $targetDb) {
        Remove-Item -Path $targetDb -Recurse -Force
        Write-Host "已刪除資料庫資料夾：$targetDb"
    }
} else {
    Write-Host "資料庫資料夾 $targetDb 已保留；如需一併刪除請加上 -Purge 參數"
}

Write-Host "解除安裝完成"
