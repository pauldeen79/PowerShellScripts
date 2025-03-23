param (
    [string]$Directory
)

function Get-Csharp-Statistics {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (!(Test-Path -LiteralPath $Directory)) {
        Write-Error "Directory '$Directory' does not exist."
        return
    }

    $list = New-Object Collections.Generic.List[LineCountInfo]
    foreach ($SubDirectory in Get-ChildItem -Path $Directory -Directory)
    {
        [long]$totalLines = 0;
        [long]$generatedLines = 0;
        [long]$notGeneratedLines = 0;
        foreach ($file in Get-ChildItem -Path $SubDirectory.FullName -File -Filter *.cs -Recurse)
        {
            $lineCount = (Get-Content $file.FullName).Length
            $totalLines += $lineCount
            if ($file.FullName.EndsWith(".template.generated.cs"))
            {
                $generatedLines += $lineCount
            }
            else
            {
                $notGeneratedLines += $lineCount
            }
        }
        $item = [LineCountInfo]::new()
        $item.Directory = $SubDirectory.Name
        $item.GeneratedLines = $generatedLines
        $item.NotGeneratedLines = $notGeneratedLines
        $item.TotalLines = $totalLines
        $list.Add($item)
    }

    $list | Format-Table -AutoSize -Property Directory, GeneratedLines, NotGeneratedLines, TotalLines
}

class LineCountInfo {
    [string]$Directory;
    [long]$GeneratedLines;
    [long]$NotGeneratedLines;
    [long]$TotalLines;
}

# Call the function automatically when the script runs
Get-Csharp-Statistics -Directory $Directory
