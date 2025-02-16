<# LACKING
- Supress output from calling moveRecycleBin.ps1
- Add complaint if argument was incorrect, etc
- Add a way to intercept Ctrl+C (try-catch-finally shows message even when Ctrl+C not pressed)
- Separate playlist as another argument. 
- if playlist, exclude from list of downloaded links (if you downloaded just one video from the playlist, it prevents from downloading the other videos from the playlist
#>

<# LIMITATIONS
- 
#>
param (
	[Parameter(Mandatory = $true)]
	[ValidateSet('audio', 'video', 'playlist', 'video-timecode')]
	[string]$Type,
	[Parameter(Mandatory = $true)]
	[string[]]$Url,
	[string]$Convert = 'noconvert',
	[string]$start = '',
	[string]$end = ''
)

# Container for all arguments.
# Removed this line, blocks entire playlist link even when downloading just one video from playlist:
# '--download-archive', 'D:/Files/yt-dlp-downloaded.txt'
$arguments = @(
	'-N', 5, 
	'--embed-metadata', 
	'--embed-thumbnail', 
	'--no-mtime', 
	'--no-check-certificates'
	)


# Define types of download
$audio = @(
	'--extract-audio', 
	'--audio-format', 'mp3', 
	'--audio-quality', '3', 
	'-P', "D:/Files/Music/Downloaded" , 
	'-P', "temp:temp" , 
	'-o', "%(title)s.%(ext)s")
$video = @(
	'-f', "((bv*[width>=1800][width<=2500])/(bv*[width>=1500]))+ba[ext=m4a]/bv*+ba[ext=m4a]/bv*+ba/b", 
	'--embed-subs', 
	'--sub-langs', "'en.*'", 
	'--sponsorblock-remove', 'all', 
	'-P', "D:/Files/Videos/temp", 
	'-o', "%(title)s_CONVERT_ME")
$video_timecode = @(
	'-f', "((bv*[width>=1800][width<=2500])/(bv*[width>=1500]))+ba[ext=m4a]/bv*+ba[ext=m4a]/bv*+ba/b", 
	#'--embed-subs', 
	#'--sub-langs', "'en.*'", 
	'--sponsorblock-remove', 'all', 
	'--external-downloader', 'ffmpeg', '--external-downloader-args', "-ss $start -to $end",
	'-P', "D:/Files/Videos/temp", 
	'-o', "%(title)s_CONVERT_ME")
$no_playlist = '--no-playlist' 

# Add specifc type of download
switch ($type) {
	'audio' { $arguments += ($audio + $no_playlist) }
	'video' { $arguments += ($video + $no_playlist) }
	'playlist' { $arguments += $video + @('--yes-playlist') }
	'video-timecode' { 
		if ([string]::IsNullOrEmpty($start) -eq $false -or [string]::IsNullOrEmpty($end) -eq $false) {
			$arguments += ($video_timecode + $no_playlist)
		} else {
			Write-Host -ForegroundColor DarkRed "Provide a START & END timecode to download. Format is 'hh:mm:ss:msms-hh:mm:ss:msms'"
			return;
		}
	}
}

# Add all urls
foreach ($u in $Url) {
	$arguments += "$u"
}

# Run
Write-Host -ForegroundColor DarkGreen "Downloading ..."
$ytDlpPath = (pyenv which yt-dlp)
& $ytDlpPath @arguments

if ($Convert.Equals('convert')) {
	Write-Host -ForegroundColor DarkGreen "Converting ..."
	& ytdlp-convert.ps1
} 
	
else {
	Write-Host -ForegroundColor DarkGreen "Skipping Conversion ..."
}
Write-Host -ForegroundColor DarkGreen "Done."
