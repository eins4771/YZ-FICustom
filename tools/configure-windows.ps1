param(
    [string]$FlutterRoot = "$env:USERPROFILE\develop\flutter",
    [string]$AndroidSdk = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$JdkRoot = "$env:ProgramFiles\Android\Android Studio\jbr"
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program exited with $LASTEXITCODE" }
}

function Add-UserPath {
    param([string[]]$Entries)
    $current = [Environment]::GetEnvironmentVariable('Path', 'User')
    $paths = @($current -split ';' | Where-Object { $_ })
    foreach ($entry in $Entries) {
        if ($paths -notcontains $entry) { $paths += $entry }
    }
    [Environment]::SetEnvironmentVariable('Path', ($paths -join ';'), 'User')
    $env:Path = ($Entries -join ';') + ';' + $env:Path
}

$flutter = Join-Path $FlutterRoot 'bin\flutter.bat'
if (-not (Test-Path -LiteralPath $flutter)) {
    throw 'Install the official Flutter stable SDK before running this script.'
}
if (-not (Test-Path -LiteralPath (Join-Path $JdkRoot 'bin\java.exe'))) {
    # User-local CLI builds do not need Android Studio's administrator approval.
    $JdkRoot = Join-Path $env:USERPROFILE 'develop\jdk21'
    if (-not (Test-Path -LiteralPath (Join-Path $JdkRoot 'bin\java.exe'))) {
        Write-Host 'Downloading an official Eclipse Temurin JDK 21 for the current user...'
        $jdkAssets = Invoke-RestMethod 'https://api.adoptium.net/v3/assets/latest/21/hotspot?architecture=x64&image_type=jdk&os=windows&vendor=eclipse'
        $jdkPackage = @($jdkAssets)[0].binary.package
        if (-not $jdkPackage.link -or -not $jdkPackage.checksum) { throw 'JDK download metadata is incomplete.' }
        $jdkTemp = Join-Path $env:TEMP ('yz-ficustom-jdk-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $jdkTemp -Force | Out-Null
        $jdkZip = Join-Path $jdkTemp 'jdk.zip'
        Invoke-WebRequest $jdkPackage.link -OutFile $jdkZip
        if ((Get-FileHash -LiteralPath $jdkZip -Algorithm SHA256).Hash -ne $jdkPackage.checksum) {
            throw 'JDK checksum verification failed.'
        }
        $jdkExtract = Join-Path $jdkTemp 'extracted'
        Expand-Archive -LiteralPath $jdkZip -DestinationPath $jdkExtract
        $jdkSource = Get-ChildItem -LiteralPath $jdkExtract -Directory | Select-Object -First 1
        if (-not $jdkSource) { throw 'JDK archive did not contain a JDK directory.' }
        New-Item -ItemType Directory -Path $JdkRoot -Force | Out-Null
        Copy-Item -Path (Join-Path $jdkSource.FullName '*') -Destination $JdkRoot -Recurse -Force
    }
}

New-Item -ItemType Directory -Path $AndroidSdk -Force | Out-Null
$env:JAVA_HOME = $JdkRoot
$env:ANDROID_HOME = $AndroidSdk
[Environment]::SetEnvironmentVariable('JAVA_HOME', $JdkRoot, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $AndroidSdk, 'User')
[Environment]::SetEnvironmentVariable('FLUTTER_ROOT', $FlutterRoot, 'User')
Add-UserPath @((Join-Path $FlutterRoot 'bin'), (Join-Path $AndroidSdk 'platform-tools'), (Join-Path $AndroidSdk 'cmdline-tools\latest\bin'))

$sdkManager = Join-Path $AndroidSdk 'cmdline-tools\latest\bin\sdkmanager.bat'
if (-not (Test-Path -LiteralPath $sdkManager)) {
    Write-Host 'Downloading official Android command-line tools metadata...'
    [xml]$repository = (Invoke-WebRequest 'https://dl.google.com/android/repository/repository2-1.xml').Content
    $package = $repository.SelectSingleNode("//*[local-name()='remotePackage' and @path='cmdline-tools;latest']")
    if (-not $package) { throw 'Android command-line tools package not found in official metadata.' }
    $archive = $package.SelectSingleNode("./*[local-name()='archives']/*[local-name()='archive'][*[local-name()='host-os']='windows']/*[local-name()='complete']")
    if (-not $archive) { throw 'Windows command-line tools archive not found.' }
    $url = $archive.SelectSingleNode("./*[local-name()='url']").InnerText
    $checksum = $archive.SelectSingleNode("./*[local-name()='checksum']")
    $algorithm = $checksum.GetAttribute('type').Replace('-', '').ToUpperInvariant()
    if (-not $algorithm) { $algorithm = 'SHA1' }
    if ($algorithm -notin @('SHA1', 'SHA256', 'SHA512')) { throw "Unsupported checksum: $algorithm" }
    $downloadRoot = Join-Path $env:TEMP 'yz-ficustom-android-tools'
    New-Item -ItemType Directory -Path $downloadRoot -Force | Out-Null
    $zipPath = Join-Path $downloadRoot 'commandlinetools-win.zip'
    Invoke-WebRequest ("https://dl.google.com/android/repository/" + $url) -OutFile $zipPath
    $actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm $algorithm).Hash
    if ($actualHash -ne $checksum.InnerText.Trim()) { throw 'Android tools checksum verification failed.' }
    $extractRoot = Join-Path $downloadRoot ([guid]::NewGuid().ToString('N'))
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot
    $latest = Join-Path $AndroidSdk 'cmdline-tools\latest'
    New-Item -ItemType Directory -Path $latest -Force | Out-Null
    Copy-Item -Path (Join-Path $extractRoot 'cmdline-tools\*') -Destination $latest -Recurse -Force
}

$extension = Get-Content -Raw (Join-Path $FlutterRoot 'packages\flutter_tools\gradle\src\main\kotlin\FlutterExtension.kt')
$api = [regex]::Match($extension, 'compileSdkVersion:\s*Int\s*=\s*(\d+)').Groups[1].Value
$ndk = [regex]::Match($extension, 'ndkVersion:\s*String\s*=\s*"([^"]+)"').Groups[1].Value
if (-not $api -or -not $ndk) { throw 'Could not determine Android SDK requirements from the installed Flutter SDK.' }

Write-Host "Installing Android SDK API $api and Flutter NDK $ndk..."
$androidCli = Join-Path $AndroidSdk 'cmdline-tools\latest\bin\android.exe'
if (Test-Path -LiteralPath $androidCli) {
    # Current command-line tools use Android CLI. Native slash paths avoid the
    # deprecated sdkmanager.bat compatibility wrapper's argument conversion.
    Invoke-Checked $androidCli @('--no-metrics', "--sdk=$AndroidSdk", 'sdk', 'install', 'platform-tools', "platforms/android-$api", 'build-tools/36.0.0', "ndk/$ndk", 'cmake/3.22.1')
} else {
    Write-Host 'Accepting Android SDK licenses for the requested development tools...'
    1..80 | ForEach-Object { 'y' } | & $sdkManager "--sdk_root=$AndroidSdk" --licenses
    if ($LASTEXITCODE -ne 0) { throw 'Android SDK license setup failed.' }
    Invoke-Checked $sdkManager @("--sdk_root=$AndroidSdk", 'platform-tools', "platforms;android-$api", 'build-tools;36.0.0', "ndk;$ndk", 'cmake;3.22.1')
}
foreach ($required in @('platform-tools\adb.exe', "platforms\android-$api\android.jar", 'build-tools\36.0.0\aapt.exe', "ndk\$ndk\source.properties", 'cmake\3.22.1\bin\cmake.exe')) {
    if (-not (Test-Path -LiteralPath (Join-Path $AndroidSdk $required))) {
        throw "Android SDK package installation is incomplete: $required"
    }
}
Invoke-Checked $flutter @('config', '--no-analytics')
Invoke-Checked $flutter @('config', '--android-sdk', $AndroidSdk)
Invoke-Checked $flutter @('config', '--jdk-dir', $JdkRoot)
Invoke-Checked $flutter @('config', '--enable-android', '--enable-web', '--no-enable-windows-desktop')
Invoke-Checked $flutter @('precache', '--android', '--web')
Invoke-Checked $flutter @('doctor', '-v')

$settingsPath = Join-Path (Split-Path $PSScriptRoot -Parent) '.vscode\settings.json'
if (-not (Test-Path -LiteralPath $settingsPath)) {
    New-Item -ItemType Directory -Path (Split-Path $settingsPath -Parent) -Force | Out-Null
    @{ 'dart.flutterSdkPath' = $FlutterRoot } | ConvertTo-Json | Set-Content -LiteralPath $settingsPath -Encoding utf8
}

Write-Host 'Windows Flutter/Android configuration complete. Restart VS Code and terminals to refresh PATH.'
