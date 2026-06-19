param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [int]$Size = 96,
    [int]$Width = 0,
    [int]$Height = 0
)

Add-Type -AssemblyName System.Drawing

$source = [System.Drawing.Bitmap]::new($InputPath)
$cornerColors = @(
    $source.GetPixel(0, 0),
    $source.GetPixel($source.Width - 1, 0),
    $source.GetPixel(0, $source.Height - 1),
    $source.GetPixel($source.Width - 1, $source.Height - 1)
)

$keyR = [int](($cornerColors | Measure-Object -Property R -Average).Average)
$keyG = [int](($cornerColors | Measure-Object -Property G -Average).Average)
$keyB = [int](($cornerColors | Measure-Object -Property B -Average).Average)

$cutout = [System.Drawing.Bitmap]::new($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt $source.Height; $y++) {
    for ($x = 0; $x -lt $source.Width; $x++) {
        $pixel = $source.GetPixel($x, $y)
        $dr = [double]($pixel.R - $keyR)
        $dg = [double]($pixel.G - $keyG)
        $db = [double]($pixel.B - $keyB)
        $distance = [Math]::Sqrt(($dr * $dr) + ($dg * $dg) + ($db * $db))

        if ($distance -lt 46.0) {
            $cutout.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $pixel.R, $pixel.G, $pixel.B))
        } elseif ($distance -lt 118.0) {
            $alpha = [Math]::Min(255, [Math]::Max(0, [int](($distance - 46.0) / 72.0 * 255.0)))
            $cutout.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $pixel.R, $pixel.G, $pixel.B))
        } else {
            $cutout.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $pixel.R, $pixel.G, $pixel.B))
        }
    }
}

$outWidth = $Size
$outHeight = $Size
if ($Width -gt 0) {
    $outWidth = $Width
}
if ($Height -gt 0) {
    $outHeight = $Height
}

$resized = [System.Drawing.Bitmap]::new($outWidth, $outHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($resized)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
$graphics.DrawImage($cutout, 0, 0, $outWidth, $outHeight)

$outDir = Split-Path -Parent $OutputPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

$resized.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$resized.Dispose()
$cutout.Dispose()
$source.Dispose()
