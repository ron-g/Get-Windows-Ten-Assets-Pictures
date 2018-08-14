# Where in the user's profile directory should the items be copied?
$ProfDir = "Pictures"

# Make target folder c:\users\username\$ProfDir\$NewDir
$NewDir = New-Item `
	-Path ((Get-Content env:/USERPROFILE) + "\" + $ProfDir) `
	-Name ("Assets_" + (get-date -UFormat "%Y%m%d_%H%M%S")) `
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
		ForEach-Object { 
			copy-item `
				-Path $_.FullName `
				-destination ("$NewDir" + "\" + "$_" + ".png") `
				-Verbose
			}

# Start-Sleep is added to allow quick review of the Verbose output.
Start-Sleep 10
