[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$backendDirectory = Join-Path $projectRoot 'backend'

if (-not (Test-Path -LiteralPath (Join-Path $backendDirectory '.env'))) {
    throw 'Missing backend/.env. Copy backend/.env.example to backend/.env and configure MongoDB locally.'
}
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    throw 'npm.cmd was not found in PATH.'
}

Push-Location -LiteralPath $backendDirectory
try {
    & npm.cmd run dev
    if ($LASTEXITCODE -ne 0) {
        throw "Backend exited with code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

