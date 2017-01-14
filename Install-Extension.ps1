function Get-VisualStudioVersions()
{
    $vsRegEntries = Get-ChildItem "HKLM:\Software\WOW6432Node\Microsoft\VisualStudio" |
                        ForEach-Object { Get-ItemProperty $_.PSPath | Where-Object { $_ -match "InstallDir" } }

    $vsRegEntries | ForEach-Object { $_.PSChildName }
}

function Get-ExtensionIdentifierXml($manifestContent)
{
    # Find all the package identity
    $vsExtensionID = $manifestContent.PackageManifest.MetaData.Identity.Id
    if (!$vsExtensionID)
    {
        $vsExtensionID = $manifestContent.Vsix.Identifier.Id
    }

    # Use ID as output
    $vsExtensionID
}

function Get-ExtensionIdentifierFile($manifestPath)
{
    [xml]$manifestContent = Get-Content -Path $manifestPath
    
    Get-ExtensionIdentifierXml $manifestContent
}

function Get-ExtensionIdentifierVsix($file)
{
    Add-Type -assembly "system.io.compression.filesystem"
    $zip = [io.compression.zipfile]::OpenRead($file)
    $file = $zip.Entries | where-object { $_.Name -Like "extension.vsixmanifest"}
    $stream = $file.Open()

    $reader = New-Object IO.StreamReader($stream)
    [xml]$manifestContent = $reader.ReadToEnd()
    
    Get-ExtensionIdentifierXml $manifestContent

    $reader.Close()
    $stream.Close()
    $zip.Dispose()
}

function Get-VisualStudioInstallDir($version)
{
    # Collect all the Visual studio installation directories from the registry
    $vsRegEntry = Get-ChildItem "HKLM:\Software\WOW6432Node\Microsoft\VisualStudio" |
                    ForEach-Object { Get-ItemProperty $_.PSPath } |
                    Where-Object {$_ -match "InstallDir" -and $_.PSChildName -Like $version }

    $vsRegEntry.InstallDir
}

function Get-LocalExtensionIDs($version)
{
    # Collect all the Visual studio installation directories from the registry
    $vsRegEntries = Get-ChildItem "HKLM:\Software\WOW6432Node\Microsoft\VisualStudio" |
                        ForEach-Object { Get-ItemProperty $_.PSPath | Where-Object { $_ -match "InstallDir" -and $_.PSChildName -Like $version } }

    # Directory for the admin extensions
    $vsLocalExtensionDir = $vsRegEntries | ForEach-Object { [System.Environment]::ExpandEnvironmentVariables("%LocalAppData%") + "\Microsoft\VisualStudio\" + $_.PSChildName + "\Extensions" } | ForEach-Object { Get-ChildItem $_ }
        
    # Find all the package identites
    $vsLocalExtensionIDs = $vsLocalExtensionDir | ForEach-Object { Get-ChildItem $_.pspath } | Where-Object {$_ -Like "extension.vsixmanifest"} | ForEach-Object { Get-ExtensionIdentifierFile $_.FullName }

    # Use IDs as output
    $vsLocalExtensionIDs
}

function Get-AdminExtensionIDs($version)
{
    # Find the Visual studio installation directory
    $vsRegEntry = Get-VisualStudioInstallDir $version

    # Directory for the admin extensions
    $vsAdminExtensionDirs = ($vsRegEntry + "Extensions") | ForEach-Object { Get-ChildItem $_ }

    # Find all the package identites
    $vsAdminExtensionIDs = $vsAdminExtensionDirs | ForEach-Object { Get-ChildItem $_.pspath } | Where-Object {$_ -Like "extension.vsixmanifest"} | ForEach-Object { Get-ExtensionIdentifierFile $_.FullName }

    # Use IDs as output
    $vsAdminExtensionIDs
}

# Visual Studio version
[string]$vsVersion = $args[0]

# Path the to extension to install
$vsix = $args[1]

# Check against installed Visual Studios
if ((Get-VisualStudioVersions) -notcontains $vsVersion)
{
    Write-Error "Requested Visual Studio version is not installed"
    Return
}

# Installed extension
$vsExtensionIDs = (Get-LocalExtensionIDs 14.0) + (Get-AdminExtensionIDs 14.0)

$vsExtensionIDs 

# ID of requested extension
$vsixID = Get-ExtensionIdentifierVsix $vsix

# Construct path to VSIXInstaller
$vsixInstaller = (Get-VisualStudioInstallDir $vsVersion) + "VSIXInstaller.exe"

if ($vsExtensionIDs -contains $vsixID)
{
    Write-Host "Uninstalling current version of extension: """$vsixID""""
    
    $args = "/q /a /u:"""+$vsixID+""""
    Start-Process $vsixInstaller $args -Wait
}

Write-Host "Installing: """$vsix""""

$args = "/q /a """+$vsix+""""
Start-Process $vsixInstaller $args -Wait
