<#
Created: 22.08.2020
Author: Katakuari - https://github.com/Katakuari

FFmpeg-Builds for yt-dlp, available @ https://github.com/yt-dlp/FFmpeg-Builds
yt-dlp, available @ https://github.com/yt-dlp/yt-dlp
#>
using namespace System.Management.Automation.Host

##################### VARS #####################
New-Variable -Name outputDir -Value "$HOME\Downloads" -Option ReadOnly # Destination for video download
New-Variable -Name scriptDir -Value "$PSScriptRoot" -Option ReadOnly

$ytdlpURI = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
$ffmpegURI = "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"


##################### CONF #####################
$conf_Default = @(
	"--console-title", "--geo-bypass", "--progress", "--yes-playlist", "-ciw",
	"--ffmpeg-location", "$ffmpegDir",
	"-P", $outputDir

	if ($null -ne $browser) {
		"--cookies-from-browser", $browser
	}

)

$conf_mp4 = @("-f", "bestvideo[ext=mp4]+bestaudio")
$conf_m4a = @("-x", "-f", "bestaudio", "--audio-format", "m4a")
$conf_mp3 = @("-x", "-f", "bestaudio", "--audio-format", "mp3")


##################### FUNC #####################
function ytdl {
	param(
		[Parameter(Mandatory = $true)]
		[string[]]$fileFormat,
		[Parameter(Mandatory = $true)]
		[string]$fileExtension
	)

	Clear-Host
	Write-Host "Currently chosen format: $fileExtension`n"

	# Request link from the user
	$vidlink = Read-Host -Prompt "[D] - Change format`n[Enter] - Exit`n`nVideo or playlist link"

	# Set location to download dir
	Set-Location $outdir

	if ($vidlink -like "d") {
		Clear-Variable -Name vidlink -Force
		selection
	} elseif ($null -eq $vidlink -or "" -eq $vidlink) {
		explorer.exe "$outdir"
		Set-Location $PSScriptRoot
		Exit
	}

	
	# Start YTDL with found ffmpeg and chosen config; to keep downloaded files add -k
	& "$scriptDir\yt-dlp.exe" $conf_Default $fileFormat $vidlink
	Start-Sleep 3

	Clear-Variable -Name vidlink -Force
	# Go back to start with same format
	ytdl($fileformat)
}


function reqCheck {
	if (($null -eq (Get-ChildItem -Path "$scriptDir" -File -Filter "yt-dlp.exe")) -or ($null -eq (Get-ChildItem -Path "$scriptDir" -Recurse -File -Filter "ff*.exe"))) {
		Write-Host "[ ERROR ] Missing yt-dlp or ffmpeg!" -ForegroundColor Red

		$choices = [ChoiceDescription[]]("&Yes (Recommended)", "&No")
		$title = "Download them automatically?"
		$result = $host.ui.PromptForChoice($title, $null, $choices, 0)
		switch ($result) {
			0 {
				Write-Host "[ INFO ] Downloading required files. Please wait..." -ForegroundColor Cyan

				# Download latest yt-dlp version, if missing 
				if ($null -eq (Get-ChildItem -Path $scriptDir -File -Filter "yt-dlp.exe")) {
					Start-BitsTransfer -Source $ytdlpURI -Destination "$scriptDir\yt-dlp.exe" -Priority Foreground
				}

				# Download yt-dlp's ffmpeg binaries
				if ($null -eq (Get-ChildItem -Path "$scriptDir" -Recurse -File -Filter "ff*.exe")) {
					Start-BitsTransfer -Source $ffmpegURI -Destination "$scriptDir\ffmpeg.zip" -Priority Foreground
					Start-Sleep 2

					Expand-Archive -Path "$scriptDir\ffmpeg.zip" -DestinationPath "$scriptDir" -Force
					Get-ChildItem -Path "$scriptDir" -Directory -Filter "ffmpeg-*" | Rename-Item -NewName "ffmpeg" -Force

					Remove-Item -Path "$scriptDir\ffmpeg.zip" -Recurse -Force
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

	# Set ffmpeg path to found exec
	$script:ffmpegDir = (Get-ChildItem -Path "$scriptDir" -File -Recurse -Filter "ffmpeg.exe").FullName | Split-Path -Parent
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
	Set-Location $PSScriptRoot
	$mp4 = [ChoiceDescription]::new("MP4&1`b", "Download file in MP4 video format.")
	$m4a = [ChoiceDescription]::new("M4A&2`b", "Download file in M4A audio format.")
	$mp3 = [ChoiceDescription]::new("MP3&3`b", "Download file in MP3 audio format.")
	$creds = [ChoiceDescription]::new("Browser &cookies", "Select the browser to get the cookies for logins.")
	$upd = [ChoiceDescription]::new("&Update YT-DLP", "Update YT-DLP to latest version.")
	$updslf = [ChoiceDescription]::new("Update &script", "Update PowerShell script to latest version.")
	$formats = [ChoiceDescription[]]($mp4, $m4a, $mp3, $creds, $upd, $updslf)

	$title = "Please choose an output format."
	$result = $host.ui.PromptForChoice($title, $null, $formats, 0)

	switch ($result) {
		0 { ytdl -fileFormat $conf_mp4 -fileExtension "MP4" }
		1 { ytdl -fileFormat $conf_m4a -fileExtension "M4A" }
		2 { ytdl -fileFormat $conf_mp3 -fileExtension "MP3" }
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

reqCheck
selection

explorer.exe "$outdir"
Remove-Variable -Name "outdir" -Force
Set-Location $PSScriptRoot
Exit