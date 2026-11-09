
$Folder = $PSScriptRoot

$Results = @()

foreach ($File in Get-ChildItem $Folder -Filter *.vtt)
{
    Write-Host "Processing $($File.Name)..."

    $Lines = Get-Content $File.FullName

    for ($i = 0; $i -lt $Lines.Count; $i++)
    {
        if ($Lines[$i] -match '^(\d{2}:\d{2}:\d{2})\.\d{3}\s-->')
        {
            $Timestamp = $Matches[1]

            $Text = ""

            $j = $i + 1

            while (
                $j -lt $Lines.Count -and
                $Lines[$j] -ne "" -and
                $Lines[$j] -notmatch '^\d{2}:\d{2}:\d{2}\.\d{3}\s-->'
            )
            {
                $Text += " " + $Lines[$j]
                $j++
            }

            if ($Text.Trim().Length -gt 0)
            {
                $Results += [PSCustomObject]@{
                    Meeting   = $File.BaseName
                    Timestamp = $Timestamp
                    Text      = $Text.Trim()
                }
            }
        }
    }
}

$Results | Export-Csv `
    (Join-Path $Folder "index.csv") `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host ""
Write-Host "Index built successfully."
Write-Host "$($Results.Count) transcript segments indexed."
