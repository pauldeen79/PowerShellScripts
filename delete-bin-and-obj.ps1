param (
    [string]$Directory
)

function Delete-Bin-And-Obj {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (!(Test-Path -LiteralPath $Directory)) {
        Write-Error "Directory '$Directory' does not exist."
        return
    }

    Get-ChildItem $Directory -include bin,obj -Recurse | foreach ($_) { Remove-Item $_.fullname -Force -Recurse }
}

# Call the function automatically when the script runs
Delete-Bin-And-Obj -Directory $Directory
