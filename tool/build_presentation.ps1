$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot
$apk = Join-Path $projectRoot 'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk'
$saved = Join-Path $projectRoot 'build/presentation-backup/app-arm64-v8a-release.apk'
$demo = Join-Path $projectRoot 'build/app/outputs/flutter-apk/mygrovia-presentation-arm64-release.apk'
$hadStandardApk = Test-Path -LiteralPath $apk
if ($hadStandardApk) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $saved) -Force | Out-Null
    Copy-Item -LiteralPath $apk -Destination $saved -Force
}
try {
    & flutter build apk --release --split-per-abi --target-platform android-arm64 --no-pub --android-project-arg=mygroviaPresentation=true
    if ($LASTEXITCODE -ne 0) { throw 'Presentation APK build failed.' }
    Copy-Item -LiteralPath $apk -Destination $demo -Force
    Write-Output ('Presentation APK: ' + $demo)
} finally {
    if ($hadStandardApk) { Copy-Item -LiteralPath $saved -Destination $apk -Force }
}
