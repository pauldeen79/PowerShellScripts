# Example how to find lines that match multiple conditions

Get-ChildItem -Path "D:\Git\CrossCutting\src" -Recurse -Filter *.cs | 
    ForEach-Object {
        $name = $_.FullName
        Get-Content $name | 
        # Where-Object { $_ -match ' Task<' -and $_ -notmatch 'Async' -and $_ -notmatch 'Task.FromResult' -and $_ -notmatch 'Func<'} |
        Where-Object { $_ -match '\.Add' -and $_ -match 'Async' -and $_ -notmatch '() =>' } |
        ForEach-Object { "$($name): $_" }
    }
