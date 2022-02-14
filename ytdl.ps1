# Created: 22.08.2020
# Author: Katakuari - https://github.com/Katakuari

New-Variable -Name outdir -Value "$HOME\Downloads" -Option ReadOnly # Destination for video download

function ytdl ([string]$fileformat) {
	# File format passed from selection
	Write-Host "Chosen file format: $fileformat`n"
    
	$config = Get-ChildItem -Path $PSScriptRoot -File -Filter "configs\*$fileformat*.txt"
	if ($null -eq $config) {
		Write-Host "[ ERROR ] No txt config found for chosen format. Please create a txt config for $fileformat." -ForegroundColor Red
		Pause
		Exit
	}

	$ffmpegdir = Get-ChildItem -Path $PSScriptRoot -Directory -Filter *ffmpeg*
	$vidlink = Read-Host -Prompt "Video or playlist link"
	Set-Location $outdir

	# Start YTDL with found ffmpeg and chosen config; to keep downloaded files add -k
	& $PSScriptRoot\yt-dlp.exe --ffmpeg-location $PSScriptRoot\$ffmpegdir\bin --config-location $PSScriptRoot\configs\$config $vidlink

	
	$again = Read-Host -Prompt "Download another video or playlist in the same format? [Y/N]"
	switch ($again) {
		Y { ytdl($fileformat) }
		N { break }
		Default { break }
	}
}

function reqCheck {
	if (($null -eq (Get-ChildItem -Path $PSScriptRoot -File -Filter "youtube-dl.exe")) -or ($null -eq (Get-ChildItem -Path $PSScriptRoot -Directory -Filter *ffmpeg*))) {
		Write-Host "[ ERROR ] Either youtube-dl.exe, ffmpeg, or both not found!" -ForegroundColor Red
		Write-Host "[ INFO ] Please check what is missing, download it from its respective website and place it in the folder like this:`
		.\youtube-dl.exe`
		.\*ffmpeg*\bin\<exe-files>" -ForegroundColor Cyan
		Pause

		Write-Host "[ INFO ] Opening websites..." -ForegroundColor Cyan
		Start-Process "https://github.com/yt-dlp/yt-dlp/releases"
		Start-Process "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-github"
		Start-Sleep -Seconds 1
		Exit
	}
}

function selection {
	Write-Host "Available download formats: 1 - mp4 (default) | 2 - m4a | 3 - mp3`nPress Enter to continue with default." -ForegroundColor Cyan

	$modesel = Read-Host -Prompt "Enter number"
	switch ($modesel) {
		1 { ytdl("mp4") }
		2 { ytdl("m4a") }
		3 { ytdl("mp3") }
		Default { ytdl("mp4") }
	}
}

reqCheck
selection

explorer.exe "$outdir"
Set-Location $PSScriptRoot
Exit