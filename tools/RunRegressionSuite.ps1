param(
	[string]$GodotExe = "C:\Tools\Godot\Godot_v4.7-stable_win64_console.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $GodotExe)) {
	$fallback = Join-Path $env:USERPROFILE "Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
	if (Test-Path -LiteralPath $fallback) {
		$GodotExe = $fallback
	} else {
		throw "Godot 4.7 console executable not found. Pass -GodotExe explicitly."
	}
}

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logRoot = Join-Path $projectRoot "tmp\qa\$stamp"
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

$fatalLogPatterns = @(
	"SCRIPT ERROR: Parse Error",
	"SCRIPT ERROR: Compile Error",
	"Failed to load script",
	"Failed to instantiate an autoload"
)

function Test-FatalGodotLog([string]$LogPath) {
	return Select-String -LiteralPath $LogPath -Quiet -SimpleMatch -Pattern $fatalLogPatterns
}

$editorLog = Join-Path $logRoot "EditorParse.log"
Write-Host "PRECHECK editor parse"
& $GodotExe --headless --editor --path $projectRoot --log-file $editorLog --quit
if ($LASTEXITCODE -ne 0 -or (Test-FatalGodotLog $editorLog)) {
	throw "Godot editor parse failed. Log: $editorLog"
}
Write-Host "PASS editor parse" -ForegroundColor Green

$bootLog = Join-Path $logRoot "MainSceneBoot.log"
Write-Host "PRECHECK main scene boot"
& $GodotExe --headless --disable-crash-handler --path $projectRoot --log-file $bootLog "res://scenes/main/Main.tscn" --quit-after 2
if ($LASTEXITCODE -ne 0 -or (Test-FatalGodotLog $bootLog)) {
	throw "Main scene boot failed. Log: $bootLog"
}
Write-Host "PASS main scene boot" -ForegroundColor Green

$tests = @(
	"DebugDiagnosticsSmoke.gd",
	"StorylineSanitySmoke.gd",
	"QuestFlowAudit.gd",
	"RequiredRouteStateSmoke.gd",
	"LoreConsistencySmoke.gd",
	"DialoguePoolSmoke.gd",
	"DialogueStyleSmoke.gd",
	"DialoguePortraitSmoke.gd",
	"DialogueHandoffSmoke.gd",
	"PostMinigameDialogueSmoke.gd",
	"OpeningArrivalSmoke.gd",
	"NavigationUiSmoke.gd",
	"HallwayFlowSmoke.gd",
	"ClosingShiftEchoesSmoke.gd",
	"CircuitSodaStoryHandoffSmoke.gd",
	"PrizeEchoHandoffSmoke.gd",
	"ArchiveHistorySmoke.gd",
	"BrokenHighScoreSmoke.gd",
	"CircuitSodaSmoke.gd",
	"TruthFilterSmoke.gd",
	"HybridExplorerSmoke.gd",
	"MinigameUiArchitectureSmoke.gd",
	"MinigameLayoutAudit.gd",
	"MinigamePauseCoverageSmoke.gd",
	"PauseMenuSmoke.gd",
	"UnknownVoiceMusicDuckSmoke.gd",
	"PresentationConsistencySmoke.gd",
	"SaveSlotDisplaySmoke.gd",
	"ScenePathSmoke.gd",
	"GameSanityAudit.gd"
)

$failures = @()
foreach ($testName in $tests) {
	$scriptPath = "res://scripts/qa/$testName"
	$logPath = Join-Path $logRoot ($testName + ".log")
	Write-Host ("QA {0}" -f $testName)
	& $GodotExe --headless --disable-crash-handler --path $projectRoot --log-file $logPath --script $scriptPath
	$processFailed = $LASTEXITCODE -ne 0
	$compileFailure = Test-FatalGodotLog $logPath
	if ($processFailed -or $compileFailure) {
		$failures += $testName
		Write-Host ("FAIL {0} — {1}" -f $testName, $logPath) -ForegroundColor Red
	} else {
		Write-Host ("PASS {0}" -f $testName) -ForegroundColor Green
	}
}

if ($failures.Count -gt 0) {
	throw ("Regression suite failed: {0}. Logs: {1}" -f ($failures -join ", "), $logRoot)
}

Write-Host ("All {0} regression checks passed. Logs: {1}" -f $tests.Count, $logRoot) -ForegroundColor Green
