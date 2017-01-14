# Address pointing to market place page where the extension is found
$uri = $args[0]

Import-Module BitsTransfer

# Access the scripts with the download link
$script = (Invoke-WebRequest -ErrorAction:SilentlyContinue -URI $uri).Scripts | Where-Object { $_.class -Like "vss-extension" }

# Convert to JSON for easier access
$content = $script.innerText | ConvertFrom-Json

[string] $outputPath = ""

if ($content.deploymentType -Like "vsix")
{
    $outputFile = $content.extensionName + ".vsix"
    Write-Host "Found a Visual Studio Extension: " $outputFile $content.versions.version

    $asset = $content.versions.files | Where-Object { $_.assetType -match "vsix" }
    $link = $asset.source

    if (-not (Test-Path "cache"))
    {
        $createdDirectory = New-Item -Name "cache" -ItemType directory
    }

    $outputPath = $PSScriptRoot + "\cache\" + $outputFile
    Start-BitsTransfer -Source $link -Destination $outputPath
}

# Path of the saved file
$outputPath
