param (
    [string]$Directory
)

function Delete-All-Generated-Content {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (!(Test-Path -LiteralPath $Directory)) {
        Write-Error "Directory '$Directory' does not exist."
        return
    }

    Get-ChildItem -Path $Directory -Filter *.template.generated.cs -Recurse | foreach { Remove-Item -Path $_.FullName }
}

# Call the function automatically when the script runs
Delete-All-Generated-Content -Directory $Directory
