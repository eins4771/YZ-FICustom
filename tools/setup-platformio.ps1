param([string]$Python = '')

$ErrorActionPreference = 'Stop'
$venv = Join-Path $env:USERPROFILE '.platformio\penv'
if (-not $Python) {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:ProgramFiles\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe"
    )
    $Python = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (-not $Python) { throw 'Python was not found. Pass -Python with an installed Python executable.' }
if (-not (Test-Path -LiteralPath (Join-Path $venv 'Scripts\python.exe'))) {
    & $Python -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw 'Creating the PlatformIO Python environment failed.' }
}
& (Join-Path $venv 'Scripts\python.exe') -m pip install --upgrade platformio
if ($LASTEXITCODE -ne 0) { throw 'Installing PlatformIO failed.' }
$scripts = Join-Path $venv 'Scripts'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (@($userPath -split ';') -notcontains $scripts) {
    [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $scripts), 'User')
}
& (Join-Path $scripts 'platformio.exe') --version
if ($LASTEXITCODE -ne 0) { throw 'PlatformIO verification failed.' }
