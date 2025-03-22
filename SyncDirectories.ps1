# Synchronizes directories ony-way.
# New files and directories are copied from source to target.
# Orphan files and directories are removed from the target.
# Optional flag to do a dry run, to show what is performed.

param (
    [string]$SourceDir,
    [string]$TargetDir,
    [switch]$DryRun
)

function Sync-Directories {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceDir,

        [Parameter(Mandatory = $true)]
        [string]$TargetDir,

        [switch]$DryRun
    )

    if (!(Test-Path -LiteralPath $SourceDir)) {
        Write-Error "Source directory '$SourceDir' does not exist."
        return
    }
    if (!(Test-Path -LiteralPath $TargetDir)) {
        Write-Host "Target directory '$TargetDir' does not exist. Creating it..."
        if (-not $DryRun) { New-Item -ItemType Directory -Path $TargetDir | Out-Null }
    }

    # Get source and target file lists
    $SourceFiles = Get-ChildItem -LiteralPath $SourceDir -Recurse -File
    $TargetFiles = Get-ChildItem -LiteralPath $TargetDir -Recurse -File

    # Copy missing or updated files from source to target
    foreach ($file in $SourceFiles) {
        $RelativePath = $file.FullName.Substring($SourceDir.Length).TrimStart('\')
        $TargetPath = Join-Path $TargetDir $RelativePath
        $TargetFolder = Split-Path -Path $TargetPath -Parent

        if (!(Test-Path -LiteralPath $TargetFolder)) {
            Write-Host "Creating directory: $TargetFolder"
            if (-not $DryRun) { New-Item -ItemType Directory -Path $TargetFolder | Out-Null }
        }

        if (!(Test-Path -LiteralPath $TargetPath) -or ($file.LastWriteTimeUtc -gt (Get-Item -LiteralPath $TargetPath).LastWriteTimeUtc)) {
            Write-Host "Copying: $RelativePath"
            if (-not $DryRun) { Copy-Item -LiteralPath $file.FullName -Destination $TargetPath -Force }
        }
    }

    # Delete files in target that do not exist in source
    foreach ($file in $TargetFiles) {
        $RelativePath = $file.FullName.Substring($TargetDir.Length).TrimStart('\')
        $SourcePath = Join-Path $SourceDir $RelativePath
        
        if (!(Test-Path -LiteralPath $SourcePath)) {
            Write-Host "Deleting: $($file.FullName)"
            if (-not $DryRun) { Remove-Item -LiteralPath $file.FullName -Force }
        }
    }

    # Remove empty directories in target
    $TargetDirs = Get-ChildItem -LiteralPath $TargetDir -Recurse -Directory | Sort-Object -Property FullName -Descending
    foreach ($dir in $TargetDirs) {
        if (-not (Get-ChildItem -LiteralPath $dir.FullName -Recurse)) {
            Write-Host "Removing empty directory: $($dir.FullName)"
            if (-not $DryRun) { Remove-Item -LiteralPath $dir.FullName -Force }
        }
    }
}

# Call the function automatically when the script runs
Sync-Directories -SourceDir $SourceDir -TargetDir $TargetDir -DryRun:$DryRun
