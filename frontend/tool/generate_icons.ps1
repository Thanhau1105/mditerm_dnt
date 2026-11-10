param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$frontendRoot = Split-Path -Parent $PSScriptRoot

function Write-VkuIcon([int]$Size, [string]$Destination) {
    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.Clear([System.Drawing.Color]::FromArgb(18, 59, 117))
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $font = New-Object System.Drawing.Font('Segoe UI', ([single]($Size * 0.29)), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rectangle = New-Object System.Drawing.RectangleF(0, 0, $Size, $Size)
    $graphics.DrawString('VKU', $font, $brush, $rectangle, $format)
    $accent = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(79, 193, 233))
    $graphics.FillRectangle($accent, [single]($Size * 0.25), [single]($Size * 0.73), [single]($Size * 0.5), [single]($Size * 0.035))
    $bitmap.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    $accent.Dispose()
    $format.Dispose()
    $font.Dispose()
    $brush.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

Write-VkuIcon 48 (Join-Path $frontendRoot 'web\favicon.png')
foreach ($size in @(192, 512)) {
    Write-VkuIcon $size (Join-Path $frontendRoot "web\icons\Icon-$size.png")
    Write-VkuIcon $size (Join-Path $frontendRoot "web\icons\Icon-maskable-$size.png")
}
foreach ($entry in @(@('mdpi', 48), @('hdpi', 72), @('xhdpi', 96), @('xxhdpi', 144), @('xxxhdpi', 192))) {
    Write-VkuIcon ([int]$entry[1]) (Join-Path $frontendRoot "android\app\src\main\res\mipmap-$($entry[0])\ic_launcher.png")
}
Write-Output 'Generated VKU web and Android icons.'
