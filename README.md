# ConvertTo-Youtube
Simple PowerShell wrapper for ffmpeg video reprocessing

ConvertTo-Youtube is a cmdlet for PowerShell to help with converting videos into an optimized Youtube-like format. It acts as a wrapper for ffmpeg, and includes flags for cutting the video, fading in/out, and setting FPS such as for Twitter.

To install the ConvertTo-Youtube cmdlet, clone the repo to your PowerShell profile directory and add a sourcing line. To find your PowerShell profile, enter `$profile` and it'll list the location and filename. You can then use a simple invocation reference to source it, like below.

```powershell
$ProfilePath = (Get-Item $profile).DirectoryName
. "$ProfilePath\ConvertTo-Youtube\ConvertTo-Youtube.ps1"
```

Because PowerShell and ffmpeg are both cross-platform with the same flags, this script will also work on Linux. It currently has issues with files with spaces or odd characters in the name however.