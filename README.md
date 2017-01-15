# Visual Studio Extension Batch Installer

Visual studio is a great tool to develop software, however, when it comes to develop software on different machines, developers usually find themselfs having a hard time synchronizing their development enviroments.  
In order to ease some of the situation, this repository contains PowerShell scripts to help automatically update/install VSIX from a list of Visual Studio market place links.

There is an extension which allows you to synchronize the extensions across machines (
[Roaming Extension Manager](https://marketplace.visualstudio.com/items?itemName=VisualStudioPlatformTeam.RoamingExtensionManager)
).
It works sufficiently well, however, the interface is cluttered with extensions I'd rather not synchronize, which makes me loose overview.

Requirements
------------

The scripts where developed on PowerShell 5.1. At least PowerShell 3.0 is required for some web call; anything inbetween is not tested.

Usage
-----

* Run Process-Packages.ps1 in an elevated PowerShell console. This downloads and installs all packages in Packages.md


As these scripts were mainly written to improve my own development experience, the best way to use this repository is to fork it and populate custom 'Packages.md'.
However, if you have any improvement I would be happy to integrate your pull-requests.

-- Basil Fierz
