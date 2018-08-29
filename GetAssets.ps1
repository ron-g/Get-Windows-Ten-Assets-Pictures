<#
.SYNOPSIS
GetAssets finds the Windows Ten ...Assets folder inside a user's profile directory and copies the spotlight desktop backgrounds to a new location before they disappear.

.DESCRIPTION
GetAssets finds the Windows Ten ...Assets folder inside a user's profile directory and copies the spotlight desktop backgrounds to a new location before they disappear.

.PARAMETER ProfDir
The "ProfDir" argument defines a folder inside the current user's profile directory, e.g. "c:\Users\jdoe\Pictures", where the pictures should be copied. The default value for ProfDir is "Pictures".

.PARAMETER AbsolutePath
The "AbsolutePath" argument defines an alternative path to store the pictures, which doesn't have to be in the user's profile directory.

.EXAMPLE
GetAssets.ps1 -AbsolutePath "B:\GoogleDrive\PicsToSort"

Stores the pictures in a GoogleDrive folder on a different data volume.

.EXAMPLE
GetAssets.ps1 -ProfDir "Pictures"

Stores the pictures in the "Pictures" folder of the current user.
#>

[CmdletBinding()]
param (
	# Where in the user's profile directory should the items be copied?
	[Parameter(Mandatory=$False)]
	[string]$ProfDir = "Pictures",
	
	[Parameter(Mandatory=$False)]
	[Alias('Path')]
	[string]$AbsolutePath = ""	
)

$WARNTEXTBG='black'
$WARNTEXTFG='yellow'

if($ProfDir -and $AbsolutePath){
	$RootPath = $AbsolutePath
	Write-Host `
		-BackgroundColor $WARNTEXTBG `
		-ForegroundColor $WARNTEXTFG `
		"`nArguments `"ProfDir`" and `"AbsolutePath`" are mutually exclusive.`nBecause both were defined, we're using `"$AbsolutePath`".`n"
	}
else {
	$RootPath = (Get-Content env:/USERPROFILE) + "\" + $ProfDir
	}

# Make target folder c:\users\username\$ProfDir\$NewDir
$NewDir = New-Item `
	-Path $RootPath `
	-Name ("Assets_" + (Get-Content env:/COMPUTERNAME) + "_" + (Get-Content env:/USERNAME) + "_" + (get-date -UFormat "%Y%m%d_%H%M%S")) `
	-ItemType Directory `
	-Verbose

# Find the "Assets" folder inside AppData...
$AssetsDir = Get-ChildItem `
	-Path ((Get-Content env:/USERPROFILE) + "\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager*" ) `
	-Filter "Assets" `
	-Recurse `
	-Force `
	-ErrorAction SilentlyContinue 

# Files are named like 64 hexadecimal characters, presumably the sha256sum of something. The "-Filter" argument can be removed to just get all files in the folder.
# For each file found, copy it to the new directory, suffixed with a PNG extension.
# After copying, Windows Explorer can be used to find the actual picture files. Add "Domension", or "Height" and "Width" to the columns, turn on "Details" view, and order by the aforementioned columns. The small dimension files will be thumbnails of sorts, and files which aren't really PNGs won't have any dimensions.
Get-ChildItem `
	-Path $AssetsDir `
	-Filter "????????????????????????????????????????????????????????????????" `
	-Recurse `
	-Force | `
		Where-Object { $_.Length -gt 102400 } | `
			ForEach-Object { 
				copy-item `
					-Path $_.FullName `
					-destination ("$NewDir" + "\" + "$_" + ".png") `
					-Verbose
				}

# Start-Sleep is added to allow quick review of the Verbose output.
Start-Sleep 10
