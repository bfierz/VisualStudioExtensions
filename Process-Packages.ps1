﻿$content = Get-Content "Packages.md"

$regex = [regex]"(https.*)\)"
$matches = $content | ForEach-Object { $regex.Matches($_) }
$links = $matches | ForEach-Object { $_.Groups[1].Value }

# Download all the extensions
$files = $links | ForEach-Object { .\Download-Extension.ps1 $_ }

# Install all the extensions
$files | ForEach-Object { if (Test-Path $_) {.\Install-Extension.ps1 14.0 $_ } }
