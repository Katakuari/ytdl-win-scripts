# Created: 22.08.2020
# Author: Katakuari - https://github.com/Katakuari
using namespace System.Management.Automation.Host

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

	$diff = [ChoiceDescription]::new("&Different format")
	$choices = [ChoiceDescription[]]("&Yes", "&No", $diff)
	$title = "Download another video in the same or different format?"
	$result = $host.ui.PromptForChoice($title, $null , $choices, 1)
	switch ($result) {
		0 { ytdl($fileformat) }
		1 { break }
		2 { selection }
	}
}

function reqCheck {
	if (($null -eq (Get-ChildItem -Path $PSScriptRoot -File -Filter "yt-dlp.exe")) -or ($null -eq (Get-ChildItem -Path $PSScriptRoot -Directory -Filter *ffmpeg*))) {
		Write-Host "[ ERROR ] Either youtube-dl.exe, ffmpeg, or both not found!" -ForegroundColor Red
		Write-Host "[ INFO ] Please check what is missing, download it from its respective website and place it in the folder like this:`
		.\yt-dlp.exe`
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
	Clear-Host
	Set-Location $PSScriptRoot
	$mp4 = [ChoiceDescription]::new("MP4&1`b", "Download file in MP4 video format.")
	$m4a = [ChoiceDescription]::new("M4A&2`b", "Download file in M4A audio format.")
	$mp3 = [ChoiceDescription]::new("MP3&3`b", "Download file in MP3 audio format.")
	$upd = [ChoiceDescription]::new("&Update YT-DLP", "Update YT-DLP to latest version.")
	$formats = [ChoiceDescription[]]($mp4, $m4a, $mp3, $upd)

	$title = "Action or format choice"
	$message = "What format should the downloaded file have?"
	$result = $host.ui.PromptForChoice($title, $message, $formats, 0)

	switch ($result) {
		0 { ytdl("mp4") }
		1 { ytdl("m4a") }
		2 { ytdl("mp3") }
		3 {
			Start-Process -FilePath ".\yt-dlp.exe" -ArgumentList "-U" -Wait -NoNewWindow
			Start-Sleep 3
			Clear-Host
			selection
		}
	}
}

reqCheck
selection

explorer.exe "$outdir"
Remove-Variable -Name "outdir" -Force
Set-Location $PSScriptRoot
Exit