# Address pointing to market place page where the extension is found
$uri = $args[0]

# Access the scripts with the download link
$script = (Invoke-WebRequest -URI $uri).Scripts | Where-Object { $_.class -Like "vss-extension" }

# Convert to JSON for easier access
$content = $script.innerText | ConvertFrom-Json

[string] $outputPath = ""

if ($content.deploymentType -Like "vsix")
{
    $outputFile = $content.extensionName + ".vsix"
    Write-Host "Found a Visual Studio Extension: "$outputFile $content.versions.version

    $asset = $content.versions.files | Where-Object { $_.assetType -match "vsix" }
    $link = $asset.source

    if (-not (Test-Path "cache"))
    {
        $createdDirectory = New-Item -Name "cache" -ItemType directory
    }

	Write-Host "Downloading: "$link
    $outputPath = $PSScriptRoot + "\cache\" + $outputFile
    #Start-BitsTransfer -Source $link -Destination $outputPath
	
	# Use C# web client to download file
	(New-Object System.Net.WebClient).DownloadFile($link, $outputPath)
	
	Write-Host "Downloaded: "$outputPath
}

# Path of the saved file
$outputPath
