# Created: 22.08.2020
# Author: Katakuari - https://github.com/Katakuari

New-Variable -Name parentdir -Value (Split-Path $Script:MyInvocation.MyCommand.Path) -Option ReadOnly # Get parent directory of script
New-Variable -Name outdir -Value "$HOME\Downloads" -Option ReadOnly # Destination for video download

New-Variable -Name WC -Value (New-Object System.Net.WebClient) -Option ReadOnly # Create WebClient and set links in case ffmpeg and/or ytdl are not found
New-Variable -Name ffmpeglink -Value "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -Option ReadOnly
New-Variable -Name ytdllink -Value "https://youtube-dl.org/downloads/latest/youtube-dl.exe" -Option ReadOnly


Write-Host "[ INFO ] Please make sure you have your txt configs in the configs directory." -ForegroundColor Cyan

function ytdl ([string]$fileformat) {
    # File format passed from selection
    Write-Host "Chosen file format: $fileformat"
    Write-Host ""
    
    $config = Get-ChildItem -Path $parentdir -File -Filter "configs\*$fileformat*.txt"
    if ($null -eq $config) {
        # If no config found, show error and ask if script should continue
        Write-Host "[ ERROR ] No txt config found for chosen format. Please create a txt config for $fileformat." -ForegroundColor Red
        $continue = Read-Host -Prompt "Continue anyway? [Y/N] (Default N)"
        switch ($continue) {
            Y { break }
            N { Exit }
            Default { Exit }
        }
    }

    $vidlink = Read-Host -Prompt "Video or playlist link"
    Set-Location $outdir

    if ($null -eq (Get-ChildItem -Path $parentdir -File -Filter "youtube-dl.exe")) {
        reqCheck("ytdlcheck")
    } 
<#     else {
        $ytdlu = Read-Host -Prompt "Check for Youtube-dl update? [Y/N] (Default N)"
        switch ($ytdlu) {
            Y { 
                & $parentdir\youtube-dl.exe -U 
                Start-Sleep -s 1.5
            }
            N { break }
            Default { break }
        }
    } #>

    try {
        # Try running FFMPEG from PATH
        ffmpeg -hide_banner -loglevel panic
        & $parentdir\youtube-dl.exe --config-location $parentdir\configs\$config $vidlink
    }
    catch {
        # Check if FFMPEG exists in parent directory
        if ($null -eq (Get-ChildItem -Path $parentdir -Directory -Filter *ffmpeg*)) {
            reqCheck("ffmpegcheck")
        }
        $ffmpegdir = Get-ChildItem -Path $parentdir -Directory -Filter *ffmpeg*

        & $parentdir\youtube-dl.exe --ffmpeg-location $parentdir\$ffmpegdir\bin --config-location $parentdir\configs\$config $vidlink
    }

    $again = Read-Host -Prompt "Download another video or playlist in the same format? [Y/N] (Default N)"
    switch ($again) {
        Y { ytdl($fileformat) }
        N { break }
        Default { break }
    }
}

function reqCheck ([string]$req) {
    switch ($req) {
        ytdlcheck {
            Write-Host "[ WARNING ] youtube-dl.exe not found!" -ForegroundColor Yellow
            $ytdlmiss = Read-Host "Do you wish to download it now? [Y/N] (Default N)"
            switch ($ytdlmiss) {
                Y {
                    try {
                        $WC.DownloadFile($ytdllink, "$parentdir\youtube-dl.exe")
                        Write-Host "[ INFO ] Download successful." -ForegroundColor Cyan
                        Write-Host ""
                        break
                    }
                    catch {
                        Write-Host "[ ERROR ] Could not download file! Check link in script!" -ForegroundColor Red
                        Pause
                        Exit
                    }
                }
                N { Exit }
                Default { Exit }
            }
        }

        ffmpegcheck {
            Write-Host "[ WARNING ] No FFMPEG folder found!" -ForegroundColor Yellow
            $ffmpegmiss = Read-Host "Do you wish to download FFMPEG now? [Y/N] (Default N)"
            switch ($ffmpegmiss) {
                Y {
                    try {
                        $WC.DownloadFile($ffmpeglink, "$parentdir\ffmpeg.zip")
                        Expand-Archive -Path "$parentdir\ffmpeg.zip" -DestinationPath "$parentdir"
                        Remove-Item -Path "$parentdir\ffmpeg.zip" -Force
                        Remove-Item -Path -Recurse "$parentdir\*ffmpeg*\doc"
                        Remove-Item -Path -Recurse "$parentdir\*ffmpeg*\presets"
                        Write-Host "[ INFO ] Done! Continuing..." -ForegroundColor Cyan
                        break
                    }                 
                    catch {
                        Write-Host "[ ERROR ] Could not download or extract file! Check link in script and parent folder!" -ForegroundColor Red
                        Pause
                        Exit
                    } 
                }
                N { Exit }
                Default { Exit }
            }
        }
        Default { break }
    }
}

function selection {
    Write-Host "Available download formats: 1 - mp4 (default) | 2 - m4a | 3 - mp3 | 4 - custom"
    Write-Host "Press Enter to continue with default."

    $modesel = Read-Host -Prompt "Enter number"
    switch ($modesel) {
        1 { ytdl("mp4") }
        2 { ytdl("m4a") }
        3 { ytdl("mp3") }
        4 {
            Write-Host "[ INFO ] Please make sure a txt config for the format exists before you continue!" -ForegroundColor Cyan
            $custfileformat = Read-Host -Prompt "Custom file format"
            ytdl("$custfileformat")
        }
        Default { ytdl("mp4") }
    }
}

selection

explorer.exe "$outdir"
Set-Location $parentdir
Exit