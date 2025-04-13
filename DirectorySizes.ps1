# Gets size of sub directories in gigabytes

param (
    [string]$Dir
)

function Get-Directory-Sizes {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Dir
    )

    if (!(Test-Path -LiteralPath $Dir)) {
        Write-Error "Directory '$Dir' does not exist."
        return
    }

    Get-ChildItem -Path $Dir -Directory | ForEach-Object {
        $size = (Get-ChildItem -Path $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{
            Directory = $_.FullName
            SizeGB    = '{0:N2}' -f ($size / 1GB)
        }
    } | Sort-Object SizeGB -Descending
}

# Call the function automatically when the script runs
Get-Directory-Sizes -Dir $Dir