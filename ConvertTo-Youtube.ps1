<#
.Description
ConvertTo-Youtube utilizes an installation of ffmpeg to convert a video file to a YouTube-like format. Also allows slicing the file and fading.
#>
function ConvertTo-Youtube {
    [Alias("ctyt","ct-yt")]
    
    [CmdletBinding(DefaultParametersetName = 'None')]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [Alias("i")][string]$InputPath,
        [Parameter(Position=1)]
        [Alias("o")][string]$OutputPath,
        [Alias("ss")][float]$StartCut = "0",
        [Alias("t")][float]$CutLength = "0",
        [Alias("fade")][switch]$FadeInOut,
        [Alias("fadetime")][float]$FadeLength = 1.5,
        [Alias("fps")][int]$Framerate = "0",
        [Alias("vf")][System.Collections.ArrayList]$VideoFilter,
        [Alias("af")][System.Collections.ArrayList]$AudioFilter,
        [Alias("f")][switch]$Force
    )
    $Verbose = $MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true
    if (($StartCut -gt 0) -and ($CutLength -eq 0)) {
        Write-Error "Must specify a value greater than zero for cut length if specifying start time"
        exit 2
    }
    if ($OutputPath -eq "") {
        Write-Verbose "No output name specified, assuming suffix _output.mp4" -Verbose:$Verbose
        $OutputPath = $InputPath + "_output.mp4"
    }
    $ArgumentList = [System.Collections.ArrayList]@('-i',$InputPath,'-b:v','10M','-minrate:v','8M','-maxrate:v','12M')
    if ($VideoFilter -eq $null) { $VideoFilter = New-Object -TypeName System.Collections.ArrayList }
    if ($AudioFilter -eq $null) { $AudioFilter = New-Object -TypeName System.Collections.ArrayList }
    if ($FadeInOut) {
        if ($CutLength -ne 0) {
            $fadeouttime = [float]$StartCut + [float]$CutLength - $FadeLength
        } else {
            Write-Verbose "Getting file information as no cut length was specified" -Verbose:$Verbose
            $fileinfo = ConvertFrom-Json ((ffprobe -v quiet -print_format json -show_format -show_streams -print_format json "$InputPath") -join " ") -Verbose:$Verbose
            $fadeouttime = [float]$fileinfo.streams[0].duration - $FadeLength
        }
        $VFilterFadeArgs = @("fade=t=in:st=$StartCut`:d=$FadeLength", "fade=t=out:st=$fadeouttime`:d=$FadeLength")
        $VideoFilter.AddRange($VFilterFadeArgs)
        $AFilterFadeArgs = @("afade=t=in:st=$StartCut`:d=$FadeLength", "afade=t=out:st=$fadeouttime`:d=$FadeLength")
        $AudioFilter.AddRange($AFilterFadeArgs)
    }

    if ($Framerate -ne 0) {
        Write-Verbose "Adding FPS filter to video filters list" -Verbose:$Verbose
        $VideoFilter.Add("fps=$($Framerate)") > $null
    }

    if ($VideoFilter.Count -gt 0) {
        Write-Verbose "Video filters were found, adding to argument list" -Verbose:$Verbose
        $VFilterList = $VideoFilter -join ","
        $ArgumentList.AddRange(@("-vf","`"$VFilterList`""))
    }

    if ($AudioFilter.Count -gt 0) {
        Write-Verbose "Audio filters were found, adding to argument list" -Verbose:$Verbose
        $AFilterList = $AudioFilter -join ","
        $ArgumentList.AddRange(@("-af", "`"$AFilterList`""))
    }

    if ($CutLength -ne 0) {
        Write-Verbose "Adding cut start and length to argument list" -Verbose:$Verbose
        $ArgumentList.AddRange(@('-ss',$StartCut))
        $ArgumentList.AddRange(@('-t',$CutLength))
    }

    $ArgumentList.Add($OutputPath) > $null

    if ($Verbose) {
        $ArgumentList.AddRange(@("-loglevel","verbose"))
    } else {
        $ArgumentList.AddRange(@("-loglevel","fatal"))
    }
    if ($Force) {
        $ArgumentList.Add("-y") > $null
    }
    Write-Verbose "Executing ffmpeg with these arguments:`r`n$($ArgumentList -join " ")" -Verbose:$Verbose
    ffmpeg $ArgumentList
}
