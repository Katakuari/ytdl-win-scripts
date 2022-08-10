# ytdl-win-scripts
A Powershell/Python script using YT-DLP to download video or audio files.

### Requirements
- yt-dlp Windows version (available @ https://github.com/yt-dlp/yt-dlp/releases)
- FFMPEG essentials (available @ https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-github)

### Important notes
- Run the Powershell script at least once to automatically download missing requirements.
- The Powershell script might ask you to set the Execution Policy to RemoteSigned.  
If it doesn't, you might have to set it yourself like this: Open Powershell as Admin, do `Set-ExecutionPolicy RemoteSigned`, then confirm.
- The Python script was written with Python 3.10.2, but may be compatible with 3.7+ (not tested).


The folder structure for both the Powershell and Python version should look something like this:
```
<ytdl-win-scripts root>
    configs\<configs>.txt
    ffmpeg\bin\<exe-files>
    yt-dlp.exe
    ytdl.ps1
    ytdl.py
```

