param(
    [string]$RootPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "Scanning for projects under $RootPath..."

# Find all test projects
$projects = Get-ChildItem -Path $RootPath -Recurse -Filter *.csproj |
    Where-Object { $_.Name -like "*.csproj" }

if (-not $projects) {
    Write-Host "No projects found."
    exit
}

$packageVersions = @{}

foreach ($project in $projects) {
    Write-Host "Processing $($project.FullName)..."

    [xml]$xml = Get-Content $project.FullName

    $ns = $xml.Project.NamespaceURI
    $nsmgr = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    if ($ns) { $nsmgr.AddNamespace("msb", $ns) }

    $packageRefs = if ($ns) {
        $xml.SelectNodes("//msb:PackageReference", $nsmgr)
    } else {
        $xml.SelectNodes("//PackageReference")
    }

    foreach ($pkg in $packageRefs) {
        $include = $pkg.Include
        $version = $pkg.Version

        if (-not $include) { continue }

        # Capture version if present
        if ($version) {
            if (-not $packageVersions.ContainsKey($include)) {
                $packageVersions[$include] = $version
            }
            elseif ($packageVersions[$include] -ne $version) {
                Write-Warning "Package $include has multiple versions: '$($packageVersions[$include])' and '$version'"
            }

            # Remove Version attribute
            $pkg.RemoveAttribute("Version")
        }
    }

    # Save updated project file
    $xml.Save($project.FullName)
}

# Create Directory.Packages.props
$propsPath = Join-Path $RootPath "Directory.Packages.props"

Write-Host "Generating $propsPath..."

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($propsPath, $settings)

$writer.WriteStartDocument()
$writer.WriteStartElement("Project")

$writer.WriteStartElement("PropertyGroup")
$writer.WriteElementString("ManagePackageVersionsCentrally", "true")
$writer.WriteEndElement()

$writer.WriteStartElement("ItemGroup")

foreach ($pkg in $packageVersions.Keys | Sort-Object) {
    $writer.WriteStartElement("PackageVersion")
    $writer.WriteAttributeString("Include", $pkg)
    $writer.WriteAttributeString("Version", $packageVersions[$pkg])
    $writer.WriteEndElement()
}

$writer.WriteEndElement() # ItemGroup
$writer.WriteEndElement() # Project
$writer.WriteEndDocument()

$writer.Flush()
$writer.Close()

Write-Host "Done!"