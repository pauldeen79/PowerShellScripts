# Compare two branches, excluding interfaces, generated code, test code and (global) usings
# main is the branch to compare to
# dataframework is the branch with changes that needs to be compared and merged to main
git diff main dataframework --name-only |
Where-Object {
    $_ -like "*.cs" -and
    $_ -notlike "*.generated.cs" -and
    $_ -notmatch "Test" -and
    $_ -notmatch "CodeGeneration" -and
    $_ -notmatch "Usings.cs" -and
    -not ((Split-Path $_ -Leaf) -match "^I.*\.cs$")
} |
Set-Content changes.txt