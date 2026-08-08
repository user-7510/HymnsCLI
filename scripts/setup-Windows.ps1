$projectRoot = Split-Path -Path $PSScriptRoot -Parent
$sourceDb = Join-Path -Path $projectRoot -ChildPath ".hymnsdb"
$targetDb = Join-Path -Path $env:USERPROFILE -ChildPath ".hymnsdb"

if (Test-Path -Path $sourceDb -PathType Container) {
    if (Test-Path -Path $targetDb -PathType Container) {
        Write-Warning "偵測到 $targetDb 已存在，略過搬移，請自行合併資料"
    } else {
        Move-Item -Path $sourceDb -Destination $targetDb -Force
    }
}

$targetFile = Join-Path -Path $projectRoot -ChildPath "HymnsCLI.py"
$binDir = Join-Path -Path $env:USERPROFILE -ChildPath "bin"
if (-not (Test-Path -Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}
$linkPath = Join-Path -Path $binDir -ChildPath "hymns.bat"
$wrapperCommand = "@echo off`r`npython `"$targetFile`" %*"
Set-Content -Path $linkPath -Value $wrapperCommand

Write-Host "安裝完成，請確認 $binDir 已加入 Path，之後即可執行 hymns"
