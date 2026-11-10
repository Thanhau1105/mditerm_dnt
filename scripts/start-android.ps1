[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DeviceId,
    [string]$ApiBaseUrl = 'http://10.0.2.2:3000/api'
)

$ErrorActionPreference = 'Stop'
$parsedApiUrl = $null
if (-not [Uri]::TryCreate($ApiBaseUrl, [UriKind]::Absolute, [ref]$parsedApiUrl) -or
    $parsedApiUrl.Scheme -notin @('http', 'https') -or
    -not $parsedApiUrl.AbsolutePath.TrimEnd('/').EndsWith('/api')) {
    throw 'ApiBaseUrl must be an absolute HTTP(S) URL ending in /api.'
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'flutter was not found in PATH.'
}

$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath (Join-Path $projectRoot 'frontend')
try {
    & flutter run -d $DeviceId "--dart-define=API_BASE_URL=$ApiBaseUrl"
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter Android exited with code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

