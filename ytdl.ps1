# Created: 22.08.2020
# Author: Katakuari - https://github.com/Katakuari
#
# FFmpeg essentials build by GyanD on GitHub, available @ https://www.gyan.dev/ffmpeg/builds/, licensed under GPLv3 - https://www.gnu.org/licenses/gpl-3.0.html
# 7-Zip Extra by Igor Pavlov, available @ https://www.7-zip.org/download.html, licensed under GNU LGPL - https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
# YT-DLP, available @ https://github.com/yt-dlp/yt-dlp, licensed under Unlicense - https://unlicense.org/

using namespace System.Management.Automation.Host

New-Variable -Name outdir -Value "$HOME\Downloads" -Option ReadOnly # Destination for video download

function ytdl ([string]$fileformat) {
	# Clear Terminal
	Clear-Host

	# File format passed from selection
	Write-Host "Currently chosen format: $fileformat`n"

	# Get config file for chosen format
	$config = Get-ChildItem -Path $PSScriptRoot -File -Filter "configs\*$fileformat*.txt"
	if ($null -eq $config) {
		Write-Host "[ ERROR ] No txt config found for chosen format. Please create a txt config for $fileformat." -ForegroundColor Red
		Pause
		Exit
	}

	# Set ffmpeg path to found exec
	$ffmpegdir = (Get-ChildItem -Path "$PSScriptRoot\ffmpeg" -File -Recurse -Filter "ffmpeg.exe").FullName | Split-Path -Parent

	# Request link from the user
	$vidlink = Read-Host -Prompt "[D] - Change format`n[Enter] - Exit`n`nVideo or playlist link"

	# Set location to download dir
	Set-Location $outdir

	if ($vidlink -like "d") {
		selection
	} elseif ($null -or "" -eq $vidlink) {
		break
	}

	# Start YTDL with found ffmpeg and chosen config; to keep downloaded files add -k
	& $PSScriptRoot\yt-dlp.exe --ffmpeg-location $ffmpegdir --config-location $PSScriptRoot\configs\$config $vidlink

	# Sleep 3 seconds after download
	Start-Sleep 3

	# Go back to start with same format
	ytdl($fileformat)
}

function reqCheck {
	if (($null -eq (Get-ChildItem -Path $PSScriptRoot -File -Filter "yt-dlp.exe")) -or ($null -eq (Get-ChildItem -Path "$PSScriptRoot\ffmpeg" -Recurse -File -Filter "ff*.exe"))) {
		Write-Host "[ ERROR ] Missing yt-dlp.exe or ffmpeg!`n" -ForegroundColor Red

		$choices = [ChoiceDescription[]]("&Yes", "&No")
		$title = "Download them automatically?"
		$result = $host.ui.PromptForChoice($title, $null, $choices, 0)
		switch ($result) {
			0 {
				Write-Host "[ INFO ] Downloading required files. Please wait..." -ForegroundColor Cyan

				if ($null -eq (Get-ChildItem -Path $PSScriptRoot -File -Filter "yt-dlp.exe")) {
					$ytdlpURI = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
					Invoke-WebRequest -Uri $ytdlpURI -OutFile "$PSScriptRoot\yt-dlp.exe"
				}

				if ($null -eq (Get-ChildItem -Path "$PSScriptRoot\ffmpeg" -Recurse -File -Filter "ff*.exe")) {
					$ffmpegURI = "https://github.com/GyanD/codexffmpeg/releases/download/5.1/ffmpeg-5.1-essentials_build.7z"
					Invoke-WebRequest -Uri $ffmpegURI -OutFile "$PSScriptRoot\ffmpeg.7z"

					& "$PSScriptRoot\7z\7za.exe" x -o"$PSScriptRoot\ffmpegzip" "$PSScriptRoot\ffmpeg.7z"
					Get-ChildItem -Path "$PSScriptRoot\ffmpegzip" -File -Recurse -Filter "ff*.exe" | Copy-Item -Destination "$PSScriptRoot\ffmpeg"
					Start-Sleep 1

					Remove-Item -Path "$PSScriptRoot\ffmpegzip" -Recurse -Force
					Remove-Item -Path "$PSScriptRoot\ffmpeg.7z" -Force
				}
			}
			1 {
				Write-Host "[ INFO ] Please download yt-dlp and ffmpeg and put them in this folder according to the README."
				Pause
				Write-Host "[ INFO ] Opening websites now..." -ForegroundColor Cyan
				Start-Process "https://github.com/yt-dlp/yt-dlp/releases"
				Start-Process "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-github"
				Start-Sleep -Seconds 1
				Exit
			}
		}
	}
}

function updateSelf {
	$poshScriptUrl = "https://raw.githubusercontent.com/Katakuari/ytdl-win-scripts/main/ytdl.ps1"
	Invoke-WebRequest -OutFile $PSCommandPath -Uri $poshScriptUrl
	Write-Host "Updated self."
	Start-Sleep 5
	Invoke-Expression $PSCommandPath
}

function selection {
	Clear-Host
	Set-Location $PSScriptRoot
	$mp4 = [ChoiceDescription]::new("MP4&1`b", "Download file in MP4 video format.")
	$m4a = [ChoiceDescription]::new("M4A&2`b", "Download file in M4A audio format.")
	$mp3 = [ChoiceDescription]::new("MP3&3`b", "Download file in MP3 audio format.")
	$upd = [ChoiceDescription]::new("&Update YT-DLP", "Update YT-DLP to latest version.")
	$updslf = [ChoiceDescription]::new("Update &script", "Update PowerShell script to latest version.")
	$formats = [ChoiceDescription[]]($mp4, $m4a, $mp3, $upd, $updslf)

	$title = "Please choose an output format."
	$result = $host.ui.PromptForChoice($title, $null, $formats, 0)

	switch ($result) {
		0 { ytdl("mp4") }
		1 { ytdl("m4a") }
		2 { ytdl("mp3") }
		3 {
			Start-Process -FilePath ".\yt-dlp.exe" -ArgumentList "-U" -Wait -NoNewWindow
			Start-Sleep 2
			Clear-Host
			selection
		}
		4 { updateSelf }
	}
}

reqCheck
selection

explorer.exe "$outdir"
Remove-Variable -Name "outdir" -Force
Set-Location $PSScriptRoot
Exit