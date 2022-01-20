# ytdl-win-scripts
A Powershell/Python script using youtube-dl.exe to download video or audio files.

### Requirements
- For the Powershell script, set Execution Policy to RemoteSigned (as Administrator, do `Set-ExecutionPolicy RemoteSigned` then confirm)
- Youtube-dl Windows version (available @ https://youtube-dl.org/downloads/latest/youtube-dl.exe )
- FFMPEG Windows version (available @ https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip )

The Powershell script will recognize missing exe files and ask you to download them.

Folder structure should look something like:
```
ytdl-win-scripts
\configs\<configs>.txt
\*ffmpeg*\bin\<exe-files>
\youtube-dl.exe
\ytdl.ps1
\ytdl.py
```

