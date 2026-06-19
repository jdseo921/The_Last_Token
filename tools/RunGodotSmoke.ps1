param(
	[string]$GodotExe = "$env:USERPROFILE\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe",
	[string[]]$Scenes = @(
		"res://scenes/main/Main.tscn",
		"res://scenes/arcade/ArcadeHub.tscn",
		"res://scenes/maps/CabinetRow.tscn",
		"res://scenes/maps/SnackAlcove.tscn",
		"res://scenes/maps/MaintenanceHall.tscn",
		"res://scenes/maps/StaffCorridor.tscn",
		"res://scenes/maps/PrizeCorner.tscn",
		"res://scenes/cutscenes/MemoryEcho.tscn",
		"res://scenes/arcade/StaffRoom.tscn"
	),
	[int]$QuitAfterSeconds = 2
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $GodotExe)) {
	throw "Godot executable not found: $GodotExe"
}

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$runRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("the_last_token_godot_smoke_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $runRoot | Out-Null

try {
	Write-Host "Project smoke: $projectRoot"
	$projectLog = Join-Path $runRoot "project_open.log"
	& $GodotExe --headless --disable-crash-handler --path $projectRoot --log-file $projectLog --quit
	if ($LASTEXITCODE -ne 0) {
		throw "Project open smoke failed with exit code $LASTEXITCODE"
	}

	foreach ($scene in $Scenes) {
		$safeName = ($scene -replace "[^A-Za-z0-9_]+", "_").Trim("_")
		$sceneLog = Join-Path $runRoot "$safeName.log"
		Write-Host "Scene smoke: $scene"
		& $GodotExe --headless --disable-crash-handler --path $projectRoot --log-file $sceneLog --scene $scene --quit-after $QuitAfterSeconds
		if ($LASTEXITCODE -ne 0) {
			throw "Scene smoke failed for $scene with exit code $LASTEXITCODE"
		}
	}
	Write-Host "Godot smoke checks passed."
}
finally {
	if (Test-Path -LiteralPath $runRoot) {
		Remove-Item -LiteralPath $runRoot -Recurse -Force
	}
}
