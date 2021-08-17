# Created: 22.08.2020
# Author: Katakuari - https://github.com/Katakuari

New-Variable -Name parentdir -Value (Split-Path $Script:MyInvocation.MyCommand.Path) -Option ReadOnly # Get parent directory of script
New-Variable -Name outdir -Value "$HOME\Downloads" -Option ReadOnly # Destination for video download

function ytdl ([string]$fileformat) {
	# File format passed from selection
	Write-Host "Chosen file format: $fileformat"
	Write-Host ""
    
	$config = Get-ChildItem -Path $parentdir -File -Filter "configs\*$fileformat*.txt"
	if ($null -eq $config) {
		# If no config found, show error and ask if script should continue
		Write-Host "[ ERROR ] No txt config found for chosen format. Please create a txt config for $fileformat." -ForegroundColor Red
		Pause
		Exit
	}

	$ffmpegdir = Get-ChildItem -Path $parentdir -Directory -Filter *ffmpeg*
	$vidlink = Read-Host -Prompt "Video or playlist link"
	Set-Location $outdir

	& $parentdir\youtube-dl.exe --ffmpeg-location $parentdir\$ffmpegdir\bin --config-location $parentdir\configs\$config $vidlink

	
	$again = Read-Host -Prompt "Download another video or playlist in the same format? [Y/N]"
	switch ($again) {
		Y { ytdl($fileformat) }
		N { break }
		Default { break }
	}
}

function reqCheck {
	if (($null -eq (Get-ChildItem -Path $parentdir -File -Filter "youtube-dl.exe")) -or ($null -eq (Get-ChildItem -Path $parentdir -Directory -Filter *ffmpeg*))) {
		Write-Host "[ ERROR ] Either youtube-dl.exe, ffmpeg, or both not found!" -ForegroundColor Red
		Write-Host "[ INFO ] Please check what is missing, download it from its respective website and place it in the folder like this:`
		[.]\youtube-dl.exe`
		[.]\*ffmpeg*\bin\<exe-files>" -ForegroundColor Cyan
		Pause

		Write-Host "[ INFO ] Opening websites..." -ForegroundColor Cyan
		Start-Process "https://youtube-dl.org/downloads/"
		Start-Process "https://www.gyan.dev/ffmpeg/builds/"
		Start-Sleep -Seconds 1
		Exit
	}
}

function selection {
	Write-Host "Available download formats: 1 - mp4 (default) | 2 - m4a | 3 - mp3"
	Write-Host "Press Enter to continue with default."

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
Set-Location $parentdir
Exit