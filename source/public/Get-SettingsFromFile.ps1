function Get-SettingsFromFile {
    <#
    .SYNOPSIS
        Get settings for script
    .DESCRIPTION
        The *Get-SettingsFromFile* function looks for a file named *globalSettings.json*, a file named *scriptName.json* and for a object in *globalSettings.json* with same name as the scriptfile invoking the function and returns a PSCustomObject with the combined settings.

        If the same setting is found in multiple places the following priority is used:

        1. Scriptnamed object in *globalSettings.json*.
        2. *scriptName.json*.
        3. Global object in *globalSettings.json*.

        Before returning the PSCustomObject all settings values are matched against the string '__globalValue__'. If there is a match the value for the global settings with the same name will be used.
    .PARAMETER Filename
        Name of file containing script specific settings.
    .PARAMETER Path
        Path to directory where settings files are located.
    .EXAMPLE
        PS> Get-SettingsFromFile

        In this example we are using the function in a scriptfile named testService.ps1. All settings from 'testService.json' (if exist) and the testService object in 'globalSettings' will be added to the returning PSCustomObject.
    .INPUTS
        None. You cannot pipe objects to Get-SettingsFromFile.
    .OUTPUTS
        [PSCustomObject]
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter()]
        [string]$Filename,
        [Parameter()]
        [string]$Path
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        if ([string]::IsNullOrEmpty($Filename)) {
            $callStack = Get-PSCallStack
            $Filename = $callStack[1].Command.TrimEnd('\.ps1')
        }
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = $epr_scriptSettingsDirectory
        }
        if (!(Test-Path -Path $Path)) {
            throw "Unable to find $Path"
        }
        try {
            $globalSettingsFile = Get-ChildItem -Path $Path -Recurse -Include "globalSettings.json"
        } catch {
            throw $_
        }
        if ($globalSettingsFile.Count -eq 1) {
            try {
                $globalSettings = Get-Content -Path "$($globalSettingsFile.FullName)" -Raw | ConvertFrom-Json
                $globalSettingsObject = $globalSettings.global
            } catch {
                Write-CustomLog -InputObject $_ -Level WARN
            }
            if ($globalSettings."$FileName") {
                try {
                    $globalScriptSettingsObject = $globalSettings."$FileName"
                } catch {
                    Write-CustomLog -InputObject $_ -Level WARN
                }
            }
        }
        if ($globalSettingsFile.Count -gt 1) {
            Write-CustomLog -Message "Multiple global settings file found, skipping.." -Level WARN
        }
        if (!($globalSettingsFile)) {
            Write-CustomLog -Message "No global settings file found, skipping.." -Level WARN
        }
        try {
            $settingsFile = Get-ChildItem -Path $Path -Recurse -Include "${Filename}.json"
        } catch {
            throw $_
        }
        if (!($settingsFile)) {
            Write-CustomLog -Message "No script specific settings file found" -Level WARN
        }
        if ($settingsFile.Count -eq 1) {
            try {
                $scriptSettingsObject = Get-Content -Path "$($settingsFile.FullName)" -Raw | ConvertFrom-Json
            } catch {
                throw $_
            }
        }
        if ($settingsFile.Count -gt 1) {
            throw "Multiple setting files found"
        }
        if ($globalSettingsObject -or $globalScriptSettingsObject -or $scriptSettingsObject) {
            Write-CustomLog -Message "Settings have been found"
        } else {
            throw "Unable to find any settings for script"
        }
        $returnObject = New-Object PSCustomObject
        if ($globalScriptSettingsObject) {
            foreach ($setting in $globalScriptSettingsObject.PSObject.Properties) {
                $settingName = $setting.Name
                $settingValue = $setting.Value
                if ($returnObject."$settingName") {
                    $returnObject."$settingName" = $settingValue
                } else {
                    try {
                        $returnObject | Add-Member -MemberType NoteProperty -Name "$settingName" -Value $settingValue
                    } catch {
                        Write-CustomLog -Message "Failed to add property $settingName" -Level WARN
                    }
                }
            }
        }
        if ($scriptSettingsObject) {
            foreach ($setting in $scriptSettingsObject.PSObject.Properties) {
                $settingName = $setting.Name
                $settingValue = $setting.Value
                if ($returnObject."$settingName") {
                    $returnObject."$settingName" = $settingValue
                } else {
                    try {
                        $returnObject | Add-Member -MemberType NoteProperty -Name "$settingName" -Value $settingValue
                    } catch {
                        Write-CustomLog -Message "Failed to add property $settingName" -Level WARN
                    }
                }
            }
        }
        foreach ($setting in $returnObject.PSObject.Properties) {
            $settingName = $setting.Name
            $settingValue = $setting.Value
            if ("$settingValue" -eq '__globalValue__') {
                $returnObject."$settingName" = $globalSettingsObject."$settingName"
            }
        }
        $returnObject
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}