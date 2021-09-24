# ConvertTo-Youtube
Simple Powershell wrapper for ffmpeg video reprocessing

ConvertTo-Youtube is a cmdlet for Powershell to help with converting videos into an optimized Youtube-like format. It acts as a wrapper for ffmpeg, and includes flags for cutting the video, fading in/out, and setting FPS such as for Twitter.

To install the ConvertTo-Youtube cmdlet, clone the repo to your Powershell profile directory and add a sourcing line. To find your Powershell profile, enter `$profile` and it'll list the location and filename. You can then use a simple invocation reference to source it, like below.

```powershell
$ProfilePath = (Get-Item $profile).DirectoryName
. "$ProfilePath\ConvertTo-Youtube\ConvertTo-Youtube.ps1"
```