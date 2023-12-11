function Write-EPRInstallLog {
    <#
    .SYNOPSIS
        Easit custom Powershell logger.
    .DESCRIPTION
        Easit custom Powershell logger works similar to log4j that is used with Java applications.

        Two different logging techniques are used depending on the input:
        "$FormattedDate - $Level - $Message" | Out-File
        $InputObject | Out-File
    .EXAMPLE
        $loggingParameters = @{
            LogDirectory = "$installPackagePath"
            LogLevel = 'INFO'
        }
        Write-EPRInstallLog -Message "-- Installation start --" @loggingParameters
    .PARAMETER Message
        Used for string input and will be written to log file as: DATE TIME - LEVEL - MESSAGE
    .PARAMETER InputObject
        Used for object input and will be written to log file as: 'DATE TIME - LEVEL - $InputObject.Exception' OR 'DATE TIME - LEVEL - $InputObject.ToString()' followed by 'DATE TIME - LEVEL - $InputObject'
    .PARAMETER Level
        What level the message should be written as. Default level is INFO.
        Each level uses the corresponding Write-XX cmdlet to output data to the correct stream.
        Ex. INFO = Write-Information, VERBOSE = Write-Verbose, WARN = Write-Warning.
    .PARAMETER LogName
        Name of log written to.
    .PARAMETER LogDirectory
        Directory to write log file in.
    .OUTPUTS
        None. This cmdlet returns no output.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline,ParameterSetName='string',Position=0)]
        [string]$Message,
        [Parameter(ValueFromPipeline,ParameterSetName='object')]
        [object]$InputObject,
        [Parameter()]
        [string]$Level = 'INFO',
        [Parameter()]
        [string]$LogName = 'EPRInstall',
        [Parameter()]
        [string]$LogDirectory
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        if ($((Get-PSCallStack)[1].Command) -ne 'New-EPRInstallation') {
            Write-Warning "This function should only be used (by 'New-EPRInstallation') when installing a new instance of ProcessRunner. Please use 'Write-CustomLog' instead."
        }
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $today = Get-Date -Format "yyyyMMdd"
        $LogName = "${LogName}_${today}.log"
        $LogPath = Join-Path -Path "$LogDirectory" -ChildPath "$LogName"
        if ($InputObject -and $Level -eq 'ERROR') {
            $Message = $InputObject.Exception
        }
        if ($InputObject -and $Level -ne 'ERROR') {
            $Message = $InputObject.ToString()
        }
        "$FormattedDate - $Level - $Message" | Out-File -FilePath "$LogPath" -Encoding UTF8 -Append -NoClobber
        if ($InputObject) {
            $InputObject | Out-File -FilePath "$LogPath" -Encoding UTF8 -Append -NoClobber
        }
        $Message = "$FormattedDate - $Message"
        # Write message to error, warning, or verbose pipeline
        if ($Level -eq 'ERROR') {
            Write-Error "$Message" -ErrorAction Continue
        } elseif ($Level -eq 'WARN') {
            Write-Warning "$Message" -WarningAction Continue
        } elseif ($Level -eq 'INFO') {
            Write-Information "$Message" -InformationAction Continue
        } else {
            ## Nothin to do
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}