param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Add-Type -AssemblyName System.Drawing

$source = [System.Drawing.Bitmap]::new($InputPath)
$sheet = [System.Drawing.Bitmap]::new(256, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None

for ($direction = 0; $direction -lt 8; $direction++) {
    for ($frame = 0; $frame -lt 2; $frame++) {
        $x = $direction * 32
        $y = $frame * 32
        $offsetX = 0
        $offsetY = 0
        if ($frame -eq 1) {
            $offsetY = -1
            if ($direction -eq 1 -or $direction -eq 2 -or $direction -eq 3) {
                $offsetX = 1
            } elseif ($direction -eq 5 -or $direction -eq 6 -or $direction -eq 7) {
                $offsetX = -1
            }
        }
        $state = $graphics.Save()
        $centerX = $x + 16
        $centerY = $y + 16
        $graphics.TranslateTransform($centerX, $centerY)
        if ($direction -eq 5 -or $direction -eq 6 -or $direction -eq 7) {
            $graphics.ScaleTransform(-1, 1)
        }
        $graphics.TranslateTransform(-$centerX, -$centerY)
        $graphics.DrawImage($source, $x + $offsetX, $y + $offsetY, 32, 32)
        $graphics.Restore($state)
    }
}

$outDir = Split-Path -Parent $OutputPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

$sheet.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$sheet.Dispose()
$source.Dispose()
