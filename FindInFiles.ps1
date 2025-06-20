# Example how to find lines that match multiple conditions

Get-ChildItem -Path "D:\MyDirectory" -Recurse -Filter *.cs | 
    ForEach-Object {
        $name = $_.FullName
        Get-Content $name | 
        Where-Object { $_ -match ' Task<' -and $_ -notmatch 'Async' -and $_ -notmatch 'Task.FromResult' -and $_ -notmatch 'Func<'} |
        ForEach-Object { "$($name): $_" }
    }
