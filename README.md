# ytdl-win-scripts
Powershell script using youtube-dl.exe

### Requirements (will be downloaded, if needed)
- Set Powershell Execution Policy to RemoteSigned (as Administrator, do `Set-ExecutionPolicy RemoteSigned` then confirm)
- Youtube-dl Windows version (available @ https://youtube-dl.org/downloads/latest/youtube-dl.exe )
- FFMPEG Windows version (available @ https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip )

Folder structure should look something like:
```
.\configs\...
.\*ffmpeg*\bin\<exe-files>
.\youtube-dl.exe
.\ytdl.ps1
```

The script will recognize missing exe files and ask you to download them.
