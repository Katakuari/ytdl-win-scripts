# ytdl-win-scripts
A Powershell/Python script using youtube-dl.exe to download video or audio files.

### Requirements
- The Python script was written with Python 3.10.2, but may be compatible with 3.7+ (not tested).
- For the Powershell script, set Execution Policy to RemoteSigned (as Administrator, do `Set-ExecutionPolicy RemoteSigned` then confirm)
- yt-dlp Windows version (available @ https://github.com/yt-dlp/yt-dlp/releases )
- FFMPEG essentials (available @ https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-github )

The Powershell script will recognize missing exe files and ask you to download them.

Folder structure should look something like:
```
ytdl-win-scripts
\configs\<configs>.txt
\*ffmpeg*\bin\<exe-files>
\yt-dlp.exe
\ytdl.ps1
\ytdl.py
```

