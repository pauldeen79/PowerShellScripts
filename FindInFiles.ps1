# Example how to find lines that match multiple conditions

Get-ChildItem -Path "C:\Workspace" -Recurse -Filter *.csproj | 
    ForEach-Object {
        $name = $_.FullName
        Get-Content $name | 
        # Where-Object { $_ -match ' Task<' -and $_ -notmatch 'Async\(' -and $_ -notmatch 'Async<' -and $_ -notmatch 'Task.FromResult' -and $_ -notmatch 'Func<'} |
        # Where-Object { $_ -match '\.Add' -and $_ -match 'Async' -and $_ -notmatch '() =>' } |
        Where-Object { $_ -cmatch 'CsharpExpressionDumper' }
        ForEach-Object { "$($name): $_" }
    }
