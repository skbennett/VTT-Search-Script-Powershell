
param(
    [string]$SearchText
)

$IndexFile = Join-Path $PSScriptRoot "index.csv"

if (!(Test-Path $IndexFile))
{
    Write-Host "index.csv not found."
    Write-Host "Run Build-Index.ps1 first."
    exit
}

$Rows = Import-Csv $IndexFile

$Matches = @()

foreach ($Row in $Rows)
{
    $Count = ([regex]::Matches(
        $Row.Text.ToLower(),
        [regex]::Escape($SearchText.ToLower())
    )).Count

    if ($Count -gt 0)
    {
        $Matches += [PSCustomObject]@{
            Meeting   = $Row.Meeting
            Timestamp = $Row.Timestamp
            Count     = $Count
            Text      = $Row.Text
        }
    }
}

$Grouped = $Matches |
    Group-Object Meeting |
    Sort-Object {
        ($_.Group | Measure-Object Count -Sum).Sum
    } -Descending

foreach ($Meeting in $Grouped)
{
    $TotalHits = ($Meeting.Group | Measure-Object Count -Sum).Sum

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host $Meeting.Name -ForegroundColor Yellow
    Write-Host "Total Hits: $TotalHits"
    Write-Host ""

    foreach ($Item in $Meeting.Group | Select-Object -First 5)
    {
        Write-Host "[$($Item.Timestamp)]" -ForegroundColor Green
        Write-Host $Item.Text
        Write-Host ""
    }
}
