<#
Created: 22.08.2020
Author: Katakuari - https://github.com/Katakuari

FFmpeg-Builds for yt-dlp, available @ https://github.com/yt-dlp/FFmpeg-Builds
yt-dlp, available @ https://github.com/yt-dlp/yt-dlp
#>
using namespace System.Management.Automation.Host

##################### VARS #####################
New-Variable -Name outputDir -Value "$HOME\Downloads" -Option ReadOnly # Destination for video download
$ffmpegDir = ((Get-ChildItem -Path "$PSScriptRoot" -File -Recurse -Filter "ffmpeg.exe").DirectoryName)

$ytdlpURI = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
$ffmpegURI = "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"


##################### FUNC #####################
function ytdl {
	param(
		[Parameter(Mandatory = $true)]
		[string[]]$fileFormat
	)

	##################### CONF #####################
	$conf_Default = @(
		"--ffmpeg-location", $ffmpegDir,
		"-P", $outputDir
		"--console-title", "--geo-bypass",
		"--progress", "--yes-playlist",
		"-ciw"

		if ($null -ne $browser) {
			"--cookies-from-browser", $browser
		}

		if ($fileFormat -eq "mp4") {
			"-f", "bestvideo[ext=mp4]+bestaudio"
		}

		if ($fileFormat -eq "m4a") {
			"-x", "-f", "bestaudio", "--audio-format", "m4a"
		}

		if ($fileFormat -eq "mp3") {
			"-x", "-f", "bestaudio", "--audio-format", "mp3"
		}
	)
	################### CONF END ###################

	Clear-Host
	Write-Host "Currently chosen format: $fileFormat`n"

	# Request link from the user
	$vidlink = Read-Host -Prompt "[D] - Change format`n[Enter] - Exit`n`nVideo or playlist link"

	if ($vidlink -like "d") {
		Clear-Variable -Name vidlink -Force
		selection
	} elseif ($null -eq $vidlink -or "" -eq $vidlink) {
		explorer.exe "$outputDir"
		Exit
	}


	# Start YTDL with found ffmpeg and chosen config; to keep downloaded files add -k
	& "$PSScriptRoot\yt-dlp.exe" $conf_Default $vidlink
	Start-Sleep 3

	Clear-Variable -Name vidlink -Force

	# Go back to start with same format
	ytdl($fileFormat)
}


function reqCheck {
	$ytdlpFile = (Get-ChildItem -Path "$PSScriptRoot" -File -Filter "yt-dlp.exe")

	if (($null -eq $ytdlpFile) -or ($null -eq $ffmpegDir)) {

		Write-Host "[ ERROR ] Missing yt-dlp or ffmpeg!" -ForegroundColor Red
		$title = "Download them automatically?"
		$choices = [ChoiceDescription[]]("&Yes (Recommended)", "&No")
		$result = $host.ui.PromptForChoice($title, $null, $choices, 0)

		switch ($result) {
			0 {
				Write-Host "[ INFO ] Downloading required files. Please wait..." -ForegroundColor Cyan

				# Download latest yt-dlp version, if missing 
				if ($null -eq $ytdlpFile) {
					Start-BitsTransfer -Source $ytdlpURI -Destination "$PSScriptRoot\yt-dlp.exe" -Priority Foreground
					Start-Sleep 1
				}

				# Download yt-dlp's ffmpeg binaries
				if ($null -eq $ffmpegDir) {
					Start-BitsTransfer -Source $ffmpegURI -Destination "$PSScriptRoot\ffmpeg.zip" -Priority Foreground
					Start-Sleep 2

					Expand-Archive -Path "$PSScriptRoot\ffmpeg.zip" -DestinationPath "$PSScriptRoot" -Force
					Get-ChildItem -Path "$PSScriptRoot" -Directory -Filter "ffmpeg-*" | Rename-Item -NewName "ffmpeg" -Force

					Remove-Item -Path "$PSScriptRoot\ffmpeg.zip" -Recurse -Force
					$script:ffmpegDir = ((Get-ChildItem -Path "$PSScriptRoot" -File -Recurse -Filter "ffmpeg.exe").DirectoryName)
				}
			}
			1 {
				Write-Host "[ INFO ] Please download yt-dlp and ffmpeg and put them in this folder according to the README." -ForegroundColor Yellow
				Pause
				Write-Host "[ INFO ] Opening websites now..." -ForegroundColor Cyan
				Start-Process "https://github.com/yt-dlp/yt-dlp/releases/latest"
				Start-Process "https://github.com/yt-dlp/FFmpeg-Builds/releases/latest"
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
	Start-Sleep 3
	Invoke-Expression $PSCommandPath
}


function selection {
	Clear-Host

	$mp4 = [ChoiceDescription]::new("MP4&1`b", "Download file in MP4 or the other best available video format.")
	$m4a = [ChoiceDescription]::new("M4A&2`b", "Download file in M4A audio format.")
	$mp3 = [ChoiceDescription]::new("MP3&3`b", "Download file in MP3 audio format.")
	$creds = [ChoiceDescription]::new("Use &cookies/logins", "Select the browser to get the cookies for logins.")
	$upd = [ChoiceDescription]::new("&Update yt-dlp", "Update yt-dlp to latest version.")
	$updslf = [ChoiceDescription]::new("Update &script", "Update PowerShell script to latest version.")
	$formats = [ChoiceDescription[]]($mp4, $m4a, $mp3, $creds, $upd, $updslf)

	$title = "Please choose an output format."
	$result = $host.ui.PromptForChoice($title, $null, $formats, 0)

	switch ($result) {
		0 { ytdl -fileFormat "MP4" }
		1 { ytdl -fileFormat "M4A" }
		2 { ytdl -fileFormat "MP3" }
		3 {
			Write-Host "Please state the browser where the cookies/login should be taken from.`nCurrently supported browsers are:`nbrave / chrome / chromium / edge / firefox / opera / safari / vivaldi / whale"
			$script:browser = Read-Host "Browser"
			selection
		}
		4 {
			Start-Process -FilePath "$PSScriptRoot\yt-dlp.exe" -ArgumentList "-U" -Wait -NoNewWindow
			Start-Sleep 2
			Clear-Host
			selection
		}
		5 { updateSelf }
	}
}


##################### EXEC #####################
reqCheck
selection

explorer.exe "$outputDir"
Remove-Variable -Name "outputDir" -Force
Exit