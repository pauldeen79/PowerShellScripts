param (
    [string]$Directory
)

function Delete-All-Scaffolded-Content-Not-Implemented {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (!(Test-Path -LiteralPath $Directory)) {
        Write-Error "Directory '$Directory' does not exist."
        return
    }

    foreach ($file in Get-ChildItem -Path $Directory -File -Recurse -Filter "*.cs" | Select-String -pattern "NotImplementedException" | Select-Object -Unique path) { Remove-Item $file.path}
}

# Call the function automatically when the script runs
Delete-All-Scaffolded-Content-Not-Implemented -Directory $Directory
