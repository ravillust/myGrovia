$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$propertiesPath = Join-Path $projectRoot 'android/key.properties'
$keyFolder = Join-Path $env:USERPROFILE '.android/mygrovia'
$keyPath = Join-Path $keyFolder 'mygrovia-release.jks'
$keytool = 'C:/Program Files/Android/Android Studio/jbr/bin/keytool.exe'
if ((Test-Path -LiteralPath $propertiesPath) -or (Test-Path -LiteralPath $keyPath)) {
    throw 'Signing files already exist. Reuse them; do not replace an existing release key.'
}
if (-not (Test-Path -LiteralPath $keytool)) {
    throw 'Android Studio keytool was not found. Set its path in this script.'
}
New-Item -ItemType Directory -Path $keyFolder -Force | Out-Null
$randomBytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($randomBytes)
$rng.Dispose()
$env:MYGROVIA_SIGNING_PASSWORD = [Convert]::ToBase64String($randomBytes)
try {
    & $keytool -genkeypair -noprompt -keystore $keyPath -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias mygrovia-release -dname 'CN=myGrovia Release, OU=Class Demo, O=myGrovia, C=ID' -storepass:env MYGROVIA_SIGNING_PASSWORD -keypass:env MYGROVIA_SIGNING_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Keytool failed.' }
    $properties = @(
        'storePassword=' + $env:MYGROVIA_SIGNING_PASSWORD
        'keyPassword=' + $env:MYGROVIA_SIGNING_PASSWORD
        'keyAlias=mygrovia-release'
        'storeFile=' + $keyPath.Replace('\', '/')
    )
    [IO.File]::WriteAllLines($propertiesPath, $properties, [Text.Encoding]::ASCII)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $grant = $identity + ':(F)'
    foreach ($privatePath in @($keyPath, $propertiesPath)) {
        & icacls.exe $privatePath /inheritance:r /grant:r $grant | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Could not restrict signing file permissions.' }
    }
    Write-Output ('Release keystore created: ' + $keyPath)
    Write-Output 'android/key.properties is private and ignored by Git. Passwords were not printed.'
} finally {
    Remove-Item Env:MYGROVIA_SIGNING_PASSWORD -ErrorAction SilentlyContinue
}
