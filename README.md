# ytdl-win-scripts
A Powershell script using YT-DLP to download video or audio files.

### Requirements
- yt-dlp Windows version (available @ https://github.com/yt-dlp/yt-dlp/releases)
- FFMPEG essentials (available @ https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-github)

### Important notes
- Run the Powershell script at least once to automatically download missing requirements.
- When running the Powershell script, you might get an error saying running scripts is disabled on your system.
  This can be bypassed either temporarily or permanently.
  - Temporary solution, must be used every time you want to run the script:\
    Win + R -> `powershell -ExecutionPolicy Bypass <PATH TO SCRIPT>\ytdl.ps1`
  - Permanent solution, can be reset anytime (more information on [about Execution Policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1)):\
    Open Powershell as Admin -> `Set-ExecutionPolicy RemoteSigned`
