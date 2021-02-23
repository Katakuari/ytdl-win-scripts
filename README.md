# ytdl-win-scripts
Powershell script using Youtube-dl's Windows version

### Requirements (will be downloaded, if needed)
- Set Powershell Execution Policy to RemoteSigned (as Administrator, do `Set-ExecutionPolicy RemoteSigned` then confirm)
- Youtube-dl Windows version (available @ https://youtube-dl.org/downloads/latest/youtube-dl.exe )
- FFMPEG Windows version (available @ https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip )

The youtube-dl.exe should be in the same folder as the script itself. 
FFMPEG should either be registered in PATH or should have the following folder structure:
ffmpeg > bin > exe files

The script will recognize missing exe files and download them if needed (you will be asked).
