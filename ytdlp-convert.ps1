<# LACKING
#>

# Get *_CONVERT_ME files 
$sourceFolder = "D:/Files/Videos/temp"
$outputFolder = "D:/Files/Videos"
$sourceFolderfiles = Get-ChildItem -Path $sourceFolder -Filter *_CONVERT_ME*

# Used to cleanup leftover files
function Cleanup {
    param (
        [Parameter(Mandatory = $True)]
        [string]$Path
    )

    $thumbExtensions = @(".webp", ".jpg", ".png")
    $tempExtension = @('.mkv', '.temp.mkv.concat')

    # If tempFile, delete
    # if (Test-Path -Path $(($Path -replace '_CONVERT_ME', '') + $tempExtension[0]) -PathType Leaf) {
    #     & moveToRecycleBin.ps1 "$(($Path -replace '_CONVERT_ME', '') + $tempExtension[0])"
    # }

    if (Test-Path -Path $($Path + $tempExtension[0]) -PathType Leaf) {
        & moveToRecycleBin.ps1 "$($Path + $tempExtension[0])"
    }

    if (Test-Path -Path $($Path + $tempExtension[1]) -PathType Leaf) {
        & moveToRecycleBin.ps1 "$($Path + $tempExtension[1])"
    }
    
    # For thumbnail, if ends in image format, delete
    foreach ($extension in $thumbExtensions) {
        if (Test-Path "$Path$extension" -PathType Leaf) {
            & moveToRecycleBin.ps1 "$Path$extension"
        }   
    }
}

# Loop though all files with "convert_me"
foreach ($file in $sourceFolderfiles) {
    $outputFile = Join-Path $outputFolder (($file.BaseName -replace "_CONVERT_ME", "") + ".mp4")
    $tempFile = $file.Name -like "*.temp.*"

    # If exists in outputFolder directory, cleanup leftovers and exit
    if (Test-Path $outputFile) {
        Cleanup $($sourceFolder + "/" + $file.BaseName)
    }

    # Move if already mp4, and not a temp file
    elseif ($file.Extension.Equals('.mp4') -and $(-not $tempFile)) {
        Move-Item -Path $file.FullName -Destination $outputFile
        Write-Host -ForegroundColor DarkGreen "Moved & Renamed $($file.BaseName)"    
    }

    # Convert using ffmpeg, if not a temp file
	# UPDATE: using handbrake-cli now because of multi-threading, displaying ETA, optimizations, etc
    elseif ($file.Extension.Equals('.mkv') -and $(-not $tempFile)) {
		& HandBrakeCLI --input $file.FullName --encoder x264 -O --output $outputFile
        #& ffmpeg.exe -i $file.FullName -c:v h264 -c:a copy -n $outputFile
        & moveToRecycleBin.ps1 $file.FullName
    }
}