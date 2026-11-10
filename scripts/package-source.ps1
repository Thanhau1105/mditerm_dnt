[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_-]+\.zip$')]
    [string]$ArchiveName = 'vku_student_management_source.zip'
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$projectRoot = Split-Path -Parent $PSScriptRoot
$archivePath = Join-Path (Split-Path -Parent $projectRoot) $ArchiveName
if (Test-Path -LiteralPath $archivePath) {
    throw 'Source ZIP already exists. Move or rename it before packaging again.'
}
Push-Location -LiteralPath $projectRoot
try {
    $sourceFiles = @(git ls-files --cached --others --exclude-standard)
    if ($LASTEXITCODE -ne 0 -or $sourceFiles.Count -lt 50) {
        throw 'Cannot collect complete source files. Run git init in the project first.'
    }
    foreach ($relativePath in $sourceFiles) {
        if (($relativePath -match '(^|/)\.env($|\.)' -and
             $relativePath -notmatch '(^|/)\.env\.example$') -or
            $relativePath -match '(^|/)(node_modules|build|\.git|\.dart_tool)/') {
            throw 'Source inventory contains private or generated files.'
        }
    }
    $zipStream = [System.IO.File]::Open($archivePath, [System.IO.FileMode]::CreateNew)
    $zipArchive = $null
    try {
        $zipArchive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
        foreach ($relativePath in $sourceFiles) {
            $sourcePath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $relativePath))
            if (-not $sourcePath.StartsWith($projectRoot + [System.IO.Path]::DirectorySeparatorChar,
                                           [System.StringComparison]::OrdinalIgnoreCase)) {
                throw 'Source path escaped the project directory.'
            }
            $entryName = 'vku_student_management/' + $relativePath.Replace('\', '/')
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $zipArchive, $sourcePath, $entryName,
                [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    }
    finally {
        if ($null -ne $zipArchive) { $zipArchive.Dispose() }
        $zipStream.Dispose()
    }
    $verifyArchive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
    try {
        if ($verifyArchive.Entries.Count -ne $sourceFiles.Count -or
            @($verifyArchive.Entries | Where-Object {
                $_.FullName -match '/\.env$|/node_modules/|/build/'
            }).Count -gt 0) { throw 'ZIP verification failed.' }
        Write-Output "Packaged and verified $($verifyArchive.Entries.Count) source files. No .env or build/dependency outputs."
    }
    finally { $verifyArchive.Dispose() }
    Get-Item -LiteralPath $archivePath | Select-Object FullName, Length
}
finally { Pop-Location }
