# Sort C# properties by name.
# Copy all properties to your clipboard, then run this script.
# After that, the sorted lines are copied to your clipboard again, so you can paste them directly in your source code.
# Note that the script assumes a property is on one line, like this:
#    [DefaultValue(true)] bool AddImplicitOperatorOnBuilder { get; }
#    [Required(AllowEmptyStrings = true)] string AddMethodNameFormatString { get; }
#    bool AddNullChecks { get; }
#    etc.

# Read clipboard content as raw text and split into lines
$lines = Get-Clipboard -Raw | Out-String | ForEach-Object { $_ -split "`r?`n" }

# Extract property name, sort, and return the sorted lines
$sortedLines = $lines |
    Where-Object { $_.Trim() -ne "" } |
    ForEach-Object {
        $line = $_.Trim()
        if ($line -match '\b([\w\d_]+)\s*\{\s*get;') {
            [PSCustomObject]@{
                Line = $line
                PropertyName = $matches[1]
            }
        }
    } |
    Sort-Object PropertyName |
    Select-Object -ExpandProperty Line

# Join and put sorted result back on the clipboard
$sortedText = $sortedLines -join "`r`n"
Set-Clipboard -Value $sortedText

# Optionally also show the sorted result
$sortedText
