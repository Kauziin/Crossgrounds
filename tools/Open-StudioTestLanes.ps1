[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PlaceFile,

    [string[]]$Lanes = @('bots', 'weapons'),

    [string]$StudioExecutable,

    [switch]$PrepareOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$source = (Resolve-Path -LiteralPath $PlaceFile -ErrorAction Stop).Path
$extension = [IO.Path]::GetExtension($source).ToLowerInvariant()
if ($extension -notin @('.rbxl', '.rbxlx')) {
    throw 'PlaceFile must be a complete .rbxl or .rbxlx place, not an .rbxm model package.'
}

$uniqueLanes = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($lane in $Lanes) {
    if ($lane -notmatch '^[a-zA-Z][a-zA-Z0-9_-]{0,31}$') {
        throw "Invalid lane name '$lane'. Use letters, numbers, hyphens or underscores."
    }
    if (-not $uniqueLanes.Add($lane)) {
        throw "Duplicate lane name '$lane'."
    }
}
if ($Lanes.Count -lt 2) {
    throw 'Provide at least two lanes for independent Studio sessions.'
}

if (-not $PrepareOnly) {
    if (-not $StudioExecutable) {
        $versionRoot = Join-Path $env:LOCALAPPDATA 'Roblox\Versions'
        $candidate = Get-ChildItem -LiteralPath $versionRoot -Filter RobloxStudioBeta.exe -File -Recurse |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (-not $candidate) { throw 'RobloxStudioBeta.exe was not found. Pass -StudioExecutable.' }
        $StudioExecutable = $candidate.FullName
    }
    $StudioExecutable = (Resolve-Path -LiteralPath $StudioExecutable -ErrorAction Stop).Path
}

$workspace = Split-Path -Parent $PSScriptRoot
$runId = '{0}-{1}' -f (Get-Date -Format 'yyyyMMdd-HHmmss'), ([guid]::NewGuid().ToString('N').Substring(0, 8))
$runFolder = Join-Path (Join-Path $workspace 'test-runs') $runId
New-Item -ItemType Directory -Path $runFolder -ErrorAction Stop | Out-Null

$sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
$rows = @()
foreach ($lane in $Lanes) {
    $laneFolder = Join-Path $runFolder $lane
    New-Item -ItemType Directory -Path $laneFolder -ErrorAction Stop | Out-Null
    $copy = Join-Path $laneFolder ("Crossgrounds-{0}{1}" -f $lane, $extension)
    Copy-Item -LiteralPath $source -Destination $copy -ErrorAction Stop
    $copyHash = (Get-FileHash -LiteralPath $copy -Algorithm SHA256).Hash
    if ($copyHash -ne $sourceHash) { throw "Snapshot changed while copying the $lane lane." }

    $rows += [pscustomobject]@{
        RunId = $runId
        Lane = $lane
        PlaceFile = $copy
        SourceSHA256 = $sourceHash
        ProcessId = $null
    }
}

$manifest = Join-Path $runFolder 'lanes.csv'
$rows | Export-Csv -LiteralPath $manifest -NoTypeInformation -Encoding UTF8
if (-not $PrepareOnly) {
    foreach ($row in $rows) {
        # Each lane opens a different file. These are interactive windows for manual playtests.
        $process = Start-Process -FilePath $StudioExecutable `
            -ArgumentList "--task EditFile --localPlaceFile `"$($row.PlaceFile)`"" -PassThru
        $row.ProcessId = $process.Id
        $rows | Export-Csv -LiteralPath $manifest -NoTypeInformation -Encoding UTF8
    }
}

$rows | Format-Table Lane, ProcessId, PlaceFile -AutoSize
Write-Output "Manifest: $manifest"
Write-Output 'Launch requested. Wait for both windows to load, then confirm a distinct studio_id for each lane before starting Play.'
