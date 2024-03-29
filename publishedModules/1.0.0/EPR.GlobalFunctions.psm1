function Convert-OUString {
    <#
    .SYNOPSIS
        Converts a DN string to a PSCustomObject or hashtable.
    .DESCRIPTION
        The *Convert-OUString* function takes a string and splits it according to the specification of an LDAP DN as contained in RFC 4514.
        Each RDN (name-value pair) is added to the returning object with nameNumber as name and value as the value.

        The DN 'uid=johnDoe,ou=People,dc=example,dc=com' will result in a PSCustomObject or hashtable with following properties and values.

        - dc1 : com
        - dc2 : example
        - ou1 : People
        - uid1 : johnDoe
        - OUPath : ou=People,dc=example,dc=com

        The *Convert-OUString* function also adds a property named 'OUPath' with the full DN up to the last (when reading from right to left) RDN.
    .PARAMETER OUString
        String to convert
    .PARAMETER AsPSCustomObject
        Tells the function to return a PSCustomObject instead of a hashtable
    .EXAMPLE
        PS> Convert-OUString -OUString "uid=john.doe,ou=People,dc=example,dc=com"
        Name                           Value
        ----                           -----
        OUPath                         ou=People,dc=example,dc=com
        dc1                            com
        dc2                            example
        ou1                            People
        uid1                           john.doe

        In this example we are converting a DN to a hashtable.
    .EXAMPLE
        PS> Convert-OUString -OUString "uid=john.doe,ou=People,dc=example,dc=com" -AsPSCustomObject
        OUPath : ou=People,dc=example,dc=com
        dc1    : com
        dc2    : example
        ou1    : People
        uid1   : john.doe
        
        In this example we are converting a DN to a PSCustomObject.
    .INPUTS
        None. You cannot pipe objects to Convert-OUString.
    .OUTPUTS
        [PSCustomObject]

        [hashtable]
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject],[hashtable])]
    param (
        [Parameter(Mandatory)]
        [string]$OUString,
        [Parameter()]
        [switch]$AsPSCustomObject
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        $returnHashtable = [ordered]@{}
        $fullOU = $OUString -replace '^.+?(?<!\\),',''
        $returnHashtable.Add("OUPath","$fullOU")
        if ($OUString -match '\\,') {
            $OUString = $OUString -replace '\\,',''
            $escapeCharacterInCN = $true
        }
        do {
            $Matches = $null
            $null = $OUString -match ',?([A-Za-z]{2,3})=([a-zA-Z0-9-_\.\s]*)$'
            try {
                $levelName = $Matches[1]
                $levelValue = $Matches[2]
            } catch{
                throw $_
            }
            if ($levelName -eq 'CN' -or $levelName -eq 'uid') {
                if ($escapeCharacterInCN) {
                    $newLevelValue = $levelValue -replace ' ','\, '
                } else {
                    $newLevelValue = $levelValue
                }
            }
            $level = 1
            $levelKeyName = "${levelName}${level}"
            if ($returnHashTable."$levelKeyName") {
                do {
                    $level++
                    $levelKeyName = "${levelName}${level}"
                } while ($returnHashTable."$levelKeyName")
            }
            if ($levelName -eq 'CN') {
                $returnHashtable.Add("$levelKeyName","$newLevelValue")
            } else {
                $returnHashtable.Add("$levelKeyName","$levelValue")
            }
            $OUString = $OUString -replace "${levelName}=${levelValue}",""
            $OUString = $OUString.TrimEnd(",")
        } while (!([string]::IsNullOrEmpty($OUString)))
        if ($AsPSCustomObject) {
            [pscustomobject]$returnHashtable
        } else {
            $returnHashtable
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}
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
            $Path = $easitPRscriptSettingsDirectory
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
function New-EPRInstallation {
    <#
    .SYNOPSIS
        Function for installing Easit Process Runner.
    .DESCRIPTION
        Function for installing a new instance of Easit Process Runner.
        This function will first look for settings in *.\lib\installerSettings.json* relative to path provided as *FromDirectory*.
        The settings in this file will be replaced in memory with any input provided with *InstallLocation*, *SystemName*, *Port* and *TomcatXmx*.
        Settings provided via a parameter will be used over settings in *installerSettings.json*
    .PARAMETER InstanceID
        ID from Easit AB representing the customers instance.
    .PARAMETER FromDirectory
        Path to the directory of expanded install archive containing the directories 'archives' and 'lib'.
    .PARAMETER InstallLocation
        Path to where EPR should be installed.
    .PARAMETER SystemName
        The input for SystemName will be combined with 'EPR-'. This will then be used to name the Tomcat service and *SystemRoot*.
    .PARAMETER Port
        Specifies the port EPR will listen on for incomming requests.
    .PARAMETER TomcatXmx
        Specifies how mush memory the Tomcat service will able to use.
    .PARAMETER IgnoreDirectoryStructure
        Specifies if the installer should add 'Easit' or not to the *InstallLocation*.
        With *IgnoreDirectoryStructure* omitted: D:\Easit\EPR-[SystemName]
        With *IgnoreDirectoryStructure* provided: D:\EPR-[SystemName]
    .PARAMETER DoNotSendInstallationDetailsToEasit
        Specifies if the installer should NOT try to send server and installations details to Easit upon completed installation.
    .EXAMPLE
        PS> New-EPRInstallation -InstanceID ABC123 -FromDirectory '.\EPRInstaller-1.0.0'
    .EXAMPLE
        PS> New-EPRInstallation -InstanceID ABC123 -FromDirectory '.\EPRInstaller-1.0.0' -InstallLocation 'E:\'
    .EXAMPLE
        PS> New-EPRInstallation -InstanceID ABC123 -FromDirectory '.\EPRInstaller-1.0.0' -InstallLocation 'F:\' -Port 9005
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$InstanceID,
        [Parameter(Mandatory)]
        [string]$FromDirectory,
        [Parameter()]
        [string]$InstallLocation,
        [Parameter()]
        [String]$SystemName,
        [Parameter()]
        [int]$Port,
        [Parameter()]
        [int]$TomcatXmx,
        [Parameter()]
        [Switch]$IgnoreDirectoryStructure,
        [Parameter()]
        [Switch]$DoNotSendInstallationDetailsToEasit
    )
    
    begin {
        $InformationPreference = 'Continue'
        $script:ProgressPreference = 'SilentlyContinue'
        $startingDirectory = Get-Location
    }
    
    process {
        if (!($DoNotSendInstallationDetailsToEasit) -and !($UseSettingsFromFile)) {
            Write-Host "" -ForegroundColor DarkGreen
            Write-Host "     ----------------------------------------------- Disclaimer -------------------------------------------------" -ForegroundColor DarkGreen
            Write-Host "     Easit would like to collect and send information about this installation for statistics and analyzes" -ForegroundColor DarkGreen
            Write-Host "     such as SystemRootDirectory, TomcatRootDirectory, TomcatVersion, JavaVersion, ServiceName. If you DO NOT want" -ForegroundColor DarkGreen
            Write-Host "     to send this information to Easit, please enter 'n' or 'false' below and press enter. Otherwise, just press enter." -ForegroundColor DarkGreen
            Write-Host "" -ForegroundColor DarkGreen
            $promptInput = Read-Host -Prompt "SendDetailsToEasit"
            if ([string]::IsNullOrEmpty($promptInput) -or $null -eq $promptInput) {
                $SendInstallationDetailsToEasit = $true
            } else {
                $SendInstallationDetailsToEasit = $false
            }
        }
        try {
            $installPackagePath = Resolve-Path $FromDirectory -ErrorAction Stop
        } catch {
            throw $_
        }
        if (Test-Path -Path $installPackagePath) {
            $script:loggingParameters = @{
                LogDirectory = "$installPackagePath"
                LogLevel = 'INFO'
            }
            Set-Location $installPackagePath
            Write-EPRInstallLog -Message "-- Installation start --" @loggingParameters
            Write-EPRInstallLog -Message "Using install package $installPackagePath" @loggingParameters
        } else {
            throw "Unable to find $installPackagePath"
        }
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $loggingParameters.LogLevel = 'VERBOSE'
        } 
        if ($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent) {
            $loggingParameters.LogLevel = 'DEBUG'
        }
        try {
            $script:installerArchivesDirectory = (Get-ChildItem -Path $installPackagePath -Recurse -Include 'archives' -Directory -ErrorAction Stop).FullName
            $script:installerLibDirectory = (Get-ChildItem -Path $installPackagePath -Recurse -Include 'lib' -Directory -ErrorAction Stop).FullName
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level 'ERROR' @loggingParameters
            return
        }
        try {
            $jsonSettings = Get-Content -Path (Join-Path $installerLibDirectory -ChildPath 'installerSettings.json') -Raw -ErrorAction Stop
            $jsonSchema = Get-Content -Path (Join-Path -Path $installerLibDirectory -ChildPath 'installerSettings.schema.json') -Raw -ErrorAction Stop
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level 'ERROR' @loggingParameters
            return
        }
        try {
            $null = Test-Json -Json $jsonSettings -Schema $jsonSchema -ErrorAction Stop
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level 'ERROR' @loggingParameters
            return
        }
        try {
            $installerSettings = $jsonSettings | ConvertFrom-Json -ErrorAction Stop
            $installerSettings | Add-Member -MemberType NoteProperty -Name 'InstanceID' -Value "$InstanceID"
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level 'ERROR' @loggingParameters
            return
        }
        foreach ($parameter in $installerSettings.Parameters.psobject.properties) {
            if (Get-Variable -Name $parameter.Name -ValueOnly) {
                $installerSettings.Parameters."$($parameter.Name)" = (Get-Variable -Name $parameter.Name -ValueOnly)
                Write-EPRInstallLog -Message "Parameter $($parameter.Name) returns $($parameter.Value)" -Level DEBUG @loggingParameters
            } else {
                Write-EPRInstallLog -Message "Parameter $($parameter.Name) returns nothing, using value from settings file ($($installerSettings.Parameters."$($parameter.Name)"))" -Level DEBUG @loggingParameters
            }
            $paramValue = $installerSettings.Parameters."$($parameter.Name)"
            if ([string]::IsNullOrEmpty("$paramValue")) {
                Write-EPRInstallLog -Message "$($parameter.Name) is null, please provide a value either with parameter or settings file" -Level ERROR @loggingParameters
                return
            }
        }
        Write-EPRInstallLog -Message "Installer settings to be used" -Level VERBOSE @loggingParameters
        Write-EPRInstallLog -InputObject $installerSettings.Parameters -Level VERBOSE @loggingParameters
        if (!(Test-Path -Path $installerSettings.Parameters.InstallLocation)) {
            Write-EPRInstallLog -Message "Install location ($($installerSettings.Parameters.InstallLocation)) does not exist" -Level ERROR @loggingParameters
            return
        }
        if ("$($installerSettings.Parameters.IgnoreDirectoryStructure)" -eq 'true') {
            try {
                $installerSettings | Add-Member -MemberType NoteProperty -Name 'EasitRootDirectory' -Value "$($installerSettings.Parameters.InstallLocation)"
            } catch {
                Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
                return
            }
        } else {
            try {
                $installerSettings | Add-Member -MemberType NoteProperty -Name 'EasitRootDirectory' -Value (Join-Path -Path "$($installerSettings.Parameters.InstallLocation)" -ChildPath $installerSettings.easitRootDirectoryName)
            } catch {
                Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
                return
            }
        }
        try {
            $installerSettings | Add-Member -MemberType NoteProperty -Name 'ServiceName' -Value "EPR-$($installerSettings.Parameters.SystemName)"
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        try {
            $installerSettings | Add-Member -MemberType NoteProperty -Name 'SystemRootDirectory' -Value (Join-Path -Path "$($installerSettings.EasitRootDirectory)" -ChildPath "$($installerSettings.ServiceName)")
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        #region Sanity check vs. create EasitRootDirectory
    if (Test-Path -Path $installerSettings.EasitRootDirectory) {
        Write-EPRInstallLog -Message "$($installerSettings.EasitRootDirectory) already exist" -Level VERBOSE @loggingParameters
    } else {
        Write-EPRInstallLog -Message "Creating $($installerSettings.EasitRootDirectory)" @loggingParameters
        try {
            $installerSettings.EasitRootDirectory = (New-Item -Path $installerSettings.Parameters.InstallLocation -Name "$($installerSettings.EasitRootDirectoryName)" -ItemType Directory).FullName
        } catch {
            Write-EPRInstallLog "Failed to create directory "$($installerSettings.EasitRootDirectoryName)" in $($installerSettings.InstallLocation)" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
    }
    #endregion
    #region Sanity check vs. create SystemRootDirectory
    if (Test-Path -Path $installerSettings.SystemRootDirectory) {
        throw "$($installerSettings.SystemRootDirectory) already exist, please remove $($installerSettings.SystemRootDirectory), all subdirectories and run installation again"
    } else {
        Write-EPRInstallLog -Message "Adding $($installerSettings.SystemRootDirectory) to easitSubFolders" -Level VERBOSE @loggingParameters
        try {
            $installerSettings.easitSubFolders += $installerSettings.ServiceName
        } catch {
            Write-EPRInstallLog "Failed to add system name to variable installerSettings.easitSubFolders" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
    }
    #endregion
    #region Service sanity check
    if (Get-Service -Name "$($installerSettings.ServiceName)" -ErrorAction 'SilentlyContinue'){
        throw "A Tomcat service named Tomcat service $($installerSettings.ServiceName) is already installed."
    } else {
        Write-EPRInstallLog -Message "No service named $($installerSettings.ServiceName) was found" -Level DEBUG @loggingParameters
    }
    #endregion
    #region easitSubFolder
    Write-EPRInstallLog -Message "Looping thru easitSubFolder" -Level DEBUG @loggingParameters
    foreach ($easitSubFolder in $installerSettings.easitSubFolders) {
        Write-EPRInstallLog -Message "easitSubFolder = $easitSubFolder" -Level DEBUG @loggingParameters
        $easitSubFolderPath = Join-Path -Path $installerSettings.EasitRootDirectory -ChildPath "$easitSubFolder"
        if (!(Test-Path -Path "$easitSubFolderPath")) {
            Write-EPRInstallLog -Message "Creating $easitSubFolderPath" @loggingParameters
            try {
                $null = New-Item -Path $installerSettings.EasitRootDirectory -Name "$easitSubFolder" -ItemType Directory
            } catch {
                Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
                continue
            }
        } else {
            Write-EPRInstallLog -Message "$easitSubFolderPath already exist" -Level VERBOSE @loggingParameters
        }
    }
    #endregion
    #region systemSubFolders
    Write-EPRInstallLog -Message "Looping thru systemSubFolders" -Level VERBOSE @loggingParameters
    foreach ($systemSubFolder in $installerSettings.systemSubFolders) {
        $systemSubFolderPath = Join-Path -Path $installerSettings.SystemRootDirectory -ChildPath "$systemSubFolder"
        if ($systemSubFolder -in $installerSettings.systemSubFoldersFromArchive) {
            $archive = Get-ChildItem -Path $installerArchivesDirectory -Recurse -Include "$systemSubFolder.zip"
            if ($archive) {
                Write-EPRInstallLog -Message "Expanding $($archive.FullName) to $($installerSettings.SystemRootDirectory)" @loggingParameters
                try {
                    Expand-Archive -Path "$($archive.FullName)" -DestinationPath $installerSettings.SystemRootDirectory -Force -ErrorAction Stop
                } catch {
                    Write-EPRInstallLog -Message $_.Exception -Level WARN @loggingParameters
                    throw "Unable to expand $($archive.FullName) to $($installerSettings.SystemRootDirectory)"
                }
            } else {
                Write-EPRInstallLog -Message "Unable to find $systemSubFolder.zip in $installerArchivesDirectory" -Level WARN @loggingParameters
                continue
            }
        } else {
            if (!(Test-Path $systemSubFolderPath)) {
                Write-EPRInstallLog -Message "Creating $systemSubFolderPath" @loggingParameters
                try {
                    $null = New-Item -Path $installerSettings.SystemRootDirectory -Name "$systemSubFolder" -ItemType Directory
                } catch {
                    Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
                    continue
                }
            } else {
                Write-EPRInstallLog -Message "$systemSubFolderPath already exist" -Level WARN @loggingParameters
                continue
            }
        }
    }
    #endregion
    #region tomcatSubFolders
    try {
        $installerSettings | Add-Member -MemberType NoteProperty -Name 'TomcatRootDirectory' -Value (Join-Path -Path $installerSettings.SystemRootDirectory -ChildPath 'Tomcat')
    } catch {
        Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
        return
    }
    if (!(Test-Path -Path $installerSettings.TomcatRootDirectory)) {
        Write-EPRInstallLog -Message "Unable to find Tomcat directory in $($installerSettings.SystemRootDirectory)" -Level ERROR @loggingParameters
        return
    }
    Write-EPRInstallLog -Message "Looping thru tomcatSubFolders" -Level VERBOSE @loggingParameters
    foreach ($tomcatSubFolder in $installerSettings.tomcatSubFolders) {
        $tomcatSubFolderPath = Join-Path -Path $installerSettings.TomcatRootDirectory -ChildPath "$tomcatSubFolder"
        if ($tomcatSubFolder -in $installerSettings.tomcatSubFoldersFromArchive) {
            $archive = Get-ChildItem -Path $installerArchivesDirectory -Recurse -Include "$tomcatSubFolder.zip"
            if ($archive) {
                Write-EPRInstallLog -Message "Expanding $($archive.FullName) to $($installerSettings.TomcatRootDirectory)" @loggingParameters
                try {
                    Expand-Archive -Path "$($archive.FullName)" -DestinationPath $installerSettings.TomcatRootDirectory -Force -ErrorAction Stop
                } catch {
                    Write-EPRInstallLog -Message $_.Exception -Level WARN @loggingParameters
                    throw "Unable to expand $($archive.FullName) to $($installerSettings.TomcatRootDirectory)"
                }
            } else {
                Write-EPRInstallLog -Message "Unable to find $tomcatSubFolder.zip in $installerArchivesDirectory" -Level WARN @loggingParameters
                continue
            }
        } else {
            if (!(Test-Path $tomcatSubFolderPath)) {
                Write-EPRInstallLog -Message "Creating $tomcatSubFolderPath" @loggingParameters
                try {
                    $null = New-Item -Path $installerSettings.TomcatRootDirectory -Name "$tomcatSubFolder" -ItemType Directory
                } catch {
                    Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
                    continue
                }
            } else {
                Write-EPRInstallLog -Message "$tomcatSubFolderPath already exist" -Level WARN @loggingParameters
                continue
            }
        }
    }
    #endregion
    #region setting tomcat variables
    $tomcatWebappsRoot = Join-Path -Path $installerSettings.TomcatRootDirectory -ChildPath 'webapps'
    if (Test-Path -Path $tomcatWebappsRoot) {
        Write-EPRInstallLog -Message "tomcatWebappsRoot = $tomcatWebappsRoot" -Level VERBOSE @loggingParameters
    } else {
        Write-EPRInstallLog -Message "Unable to find $tomcatWebappsRoot" -Level ERROR @loggingParameters
        return
    }
    $tomcatBinRoot = Join-Path -Path $installerSettings.TomcatRootDirectory -ChildPath 'bin'
    if (Test-Path -Path $tomcatBinRoot) {
        Write-EPRInstallLog -Message "tomcatBinRoot = $tomcatBinRoot" -Level VERBOSE @loggingParameters
    } else {
        Write-EPRInstallLog -Message "Unable to find $tomcatBinRoot" -Level ERROR @loggingParameters
        return
    }
    $tomcatConfRoot = Join-Path -Path $installerSettings.TomcatRootDirectory -ChildPath 'conf'
    if (Test-Path -Path $tomcatConfRoot) {
        Write-EPRInstallLog -Message "tomcatConfRoot = $tomcatConfRoot" -Level VERBOSE @loggingParameters
    } else {
        Write-EPRInstallLog -Message "Unable to find $tomcatConfRoot" -Level ERROR @loggingParameters
        return
    }
    #endregion
    #region copy new war to webapps
    $easitGOWar = Get-ChildItem -Path $installerArchivesDirectory -Recurse -Include '*.war'
    #$doNotStartTomcat = $false
    if ([string]::IsNullOrEmpty($easitGOWar)) {
        Write-EPRInstallLog -Message "easitGOWar is not set" -Level WARN @loggingParameters
        #$doNotStartTomcat = $true
    } else {
        Write-EPRInstallLog -Message "easitGOWar = $($easitGOWar.FullName)" -Level VERBOSE @loggingParameters
        try {
            Write-EPRInstallLog -Message "Copying $($easitGOWar.FullName) to $tomcatWebappsRoot and renaming to ROOT.war" @loggingParameters
            Copy-Item -Path "$($easitGOWar.FullName)" -Destination "$tomcatWebappsRoot" -ErrorAction Stop
            Get-ChildItem -Path "${tomcatWebappsRoot}\*.war" | Rename-Item -NewName 'ROOT.war' -ErrorAction Stop
            Write-EPRInstallLog -Message "Succesfully copied $($easitGOWar.FullName) to $tomcatWebappsRoot and renamed to ROOT.war" @loggingParameters
        } catch {
            Write-EPRInstallLog -Message "Unable to copy $($easitGOWar.FullName) to $tomcatWebappsRoot" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
    }
    #endregion
    #region filesToReplaceSystemPortIn
    Write-EPRInstallLog -Message "Looping thru filesToReplaceSystemPortIn" -Level DEBUG @loggingParameters
    foreach ($tomcatFileToReplaceSystemPortIn in $installerSettings.tomcatFilesToReplaceSystemPortIn) {
        try {
            $file = Get-ChildItem -Path "$tomcatConfRoot" -Recurse -Include "$tomcatFileToReplaceSystemPortIn"
        } catch {

        }
        try {
            $fileContent = Get-Content -Path $file.FullName -Raw
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        try {
            $fileContent = $fileContent -replace '\$\{SystemPort\}',"$($installerSettings.Parameters.Port)"
        } catch {
            Write-EPRInstallLog -Message "Unable to update SystemPort in $File" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
        try {
            $fileContent | Set-Content -Path $file.FullName
        } catch {
            Write-EPRInstallLog -Message "Unable to set content of $File" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
    }
    #endregion
    #region configFilesToReplaceSystemRootIn
    Write-EPRInstallLog -Message "Looping thru configFilesToReplaceSystemRootIn" -Level DEBUG @loggingParameters
    try {
        $systemConfigRoot = Join-Path -Path $installerSettings.SystemRootDirectory -ChildPath 'config'
    } catch {
        Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
        return
    }
    if (!(Test-Path -Path $systemConfigRoot)) {
        Write-EPRInstallLog -Message "Unable to find config directory in $($installerSettings.SystemRootDirectory)" -Level ERROR @loggingParameters
        return
    }
    foreach ($configFileToReplaceSystemRootIn in $installerSettings.configFilesToReplaceSystemRootIn) {
        try {
            $file = Get-ChildItem -Path "$systemConfigRoot" -Recurse -Include "$configFileToReplaceSystemRootIn"
        } catch {

        }
        try {
            $fileContent = Get-Content -Path $file.FullName -Raw
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        $systemRootForwardSlash = $installerSettings.SystemRootDirectory -replace '\\','/'
        try {
            $fileContent = $fileContent -replace '\$\{SystemRoot\}',"$systemRootForwardSlash"
        } catch {
            Write-EPRInstallLog -Message "Unable to update SystemPort in $File" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
        try {
            $fileContent | Set-Content -Path $file.FullName
        } catch {
            Write-EPRInstallLog -Message "Unable to set content of $File" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
    }
    #endregion
    #region configFilesToReplacepwshExecutableIn
    foreach ($configFilesToReplacepwshExecutableIn in $installerSettings.configFilesToReplacepwshExecutableIn) {
        try {
            $file = Get-ChildItem -Path "$systemConfigRoot" -Recurse -Include "$configFilesToReplacepwshExecutableIn"
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        try {
            $fileContent = Get-Content -Path $file.FullName -Raw
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        $pwshExecutable = $null
        $pwshExecutable = (Get-ChildItem -Path (Get-Variable pshome).value  -Recurse -Include 'pwsh.exe').FullName
        "pwshExecutable = $pwshExecutable"
        if (!($pwshExecutable)) {
            Write-EPRInstallLog -Message "Unable to find pwsh.exe" -Level WARN @loggingParameters
        } else {
            $pwshExecutable = $pwshExecutable -replace '\\','/'
            try {
                $fileContent = $fileContent -replace '\$\{pwshExecutable\}',"$pwshExecutable"
            } catch {
                Write-EPRInstallLog -Message "Unable to update SystemPort in $File" -Level WARN @loggingParameters
                Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
            }
            try {
                $fileContent | Set-Content -Path $file.FullName
            } catch {
                Write-EPRInstallLog -Message "Unable to set content of $File" -Level WARN @loggingParameters
                Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
            }
        }
    }
    #region configFilesToReplacePasswordIn
    try {
        $guid = (New-Guid) -replace '-',''
    } catch {
        Write-EPRInstallLog -InputObject $_ -Level WARN @loggingParameters
    }
    Write-EPRInstallLog -Message "Looping thru configFilesToReplacePasswordIn" -Level DEBUG @loggingParameters
    foreach ($configFileToReplacePasswordIn in $installerSettings.configFilesToReplacePasswordIn) {
        try {
            $file = Get-ChildItem -Path "$systemConfigRoot" -Recurse -Include "$configFileToReplacePasswordIn"
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        try {
            $fileContent = Get-Content -Path $file.FullName -Raw
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
            return
        }
        try {
            $fileContent = $fileContent -replace '\$\{generatedPassword\}',"$guid"
        } catch {
            Write-EPRInstallLog -Message "Unable to update SystemPort in $File" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
        try {
            $fileContent | Set-Content -Path $file.FullName
        } catch {
            Write-EPRInstallLog -Message "Unable to set content of $File" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
    }
    #endregion
    #region Tomcat installation
    $addTomcatBatFile = Get-ChildItem -Path $tomcatBinRoot -Recurse -Include 'Add*.bat'
    if (!($addTomcatBatFile)) {
        Write-EPRInstallLog -Message "Unable to find bat file for installation of Tomcat service" -Level ERROR @loggingParameters
        return
    }
    if ($addTomcatBatFile.count -gt 1) {
        Write-EPRInstallLog -Message "Multiple bat files for installation of Tomcat service found" -Level ERROR @loggingParameters
        return
    }
    $processParameters = @{
        FilePath = "$($addTomcatBatFile.FullName)"
        PassThru = $true
        NoNewWindow = $true
        Wait = $true
    }
    Write-EPRInstallLog -Message "Installing Tomcat service" @loggingParameters
    try {
        $process = Start-Process @processParameters -ArgumentList $installerSettings.ServiceName,$installerSettings.SystemRootDirectory,$installerSettings.TomcatRootDirectory,$installerSettings.Parameters.TomcatXmx
    } catch {
        Write-EPRInstallLog -InputObject $_ -Level ERROR @loggingParameters
    }
    if ($process) {
        if ($process.ExitCode -gt 0){
            Write-EPRInstallLog -Message "Unable to install Tomcat service, please log for more details" -Level WARN @loggingParameters
            Write-EPRInstallLog -InputObject $process -Level VERBOSE @loggingParameters
        }
        if ($process.ExitCode -eq 0) {
            Write-EPRInstallLog -Message "Tomcat service installed" @loggingParameters
            $javaExe = (Get-ChildItem -Path $installerSettings.TomcatRootDirectory -Recurse -Include 'java.exe').FullName
            $catalinaJar = (Get-ChildItem -Path $installerSettings.TomcatRootDirectory -Recurse -Include 'catalina.jar').FullName
            $processServerInfo = @{
                FilePath = "$javaExe"
                PassThru = $true
                NoNewWindow = $true
                Wait = $true
            }
            $serverProcess = Start-Process @processServerInfo -ArgumentList '-cp',$catalinaJar,'org.apache.catalina.util.ServerInfo' -RedirectStandardOutput serverInfo
            if ($serverProcess) {
                $serverInfoArray = Get-Content -Path '.\serverInfo' | ConvertFrom-Csv -Delimiter ':' -Header 'Name','Value'
                try {
                    $installerSettings | Add-Member -MemberType NoteProperty -Name 'OSVersion' -Value ($serverInfoArray | Where-Object Name -EQ 'OS Name').Value
                    $installerSettings | Add-Member -MemberType NoteProperty -Name 'TomcatVersion' -Value ($serverInfoArray | Where-Object Name -EQ 'Server number').Value
                    $installerSettings | Add-Member -MemberType NoteProperty -Name 'JavaVersion' -Value ($serverInfoArray | Where-Object Name -EQ 'JVM Version').Value
                } catch {
                    Write-EPRInstallLog -Message "Failed to get server info details" -Level VERBOSE @loggingParameters
                    Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
                }
                try {
                    Remove-Item -Path '.\serverInfo' -Force -Confirm:$false
                } catch {
                    Write-EPRInstallLog -Message "Unable to remove serverInfo" -Level VERBOSE @loggingParameters
                }
            }
        }
    } else {
        Write-EPRInstallLog -Message "Unable to evaluate result of installing Tomcat service" -Level WARN @loggingParameters
    }
    #endregion

    #region Send details to Easit
    try {
        $body = New-PostBody -InstallerSettings $installerSettings
    } catch {
        Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
    }
    if (!($null = $SendInstallationDetailsToEasit)) {
        $installerSettings.Parameters.SendInstallationDetailsToEasit = "$SendInstallationDetailsToEasit"
    }
    if (($installerSettings.Parameters.SendInstallationDetailsToEasit -eq 'True') -and $body) {
        try {
            $apikey = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($installerSettings.FeedbackSettings.apikey))
            $pair = "${apikey}: "
            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
            $basicAuthValue = "Basic $encodedCreds"
            $headers = @{SOAPAction = ""; Authorization = $basicAuthValue }
        } catch {
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
        try {
            $restParams = @{
                Method = 'POST'
                Uri = $installerSettings.FeedbackSettings.url
                Body = $body
                TimeoutSec = 30
                ErrorAction = 'Stop'
                ContentType = "application/json"
                Headers = $headers
            }
            $null = Invoke-RestMethod @restParams
            $wassenttoeasit = "These details were sent to Easit"
        } catch {
            $wassenttoeasit = "Please provide these installation details to Easit as they will be used for statistics and documentation. You can simply send them to support@easit.com"
            Write-EPRInstallLog -InputObject $_ -Level VERBOSE @loggingParameters
        }
    } else {
        $wassenttoeasit = "Please provide these installation details to Easit as they will be used for statistics and documentation. You can simply send them to support@easit.com"
    }
    #endregion
    #region Create post install instructions
    try {
        $postInstallInstructionsMD = Join-Path -Path $installerLibDirectory -ChildPath 'postInstallInstructions.md'
        $markdownContent = Get-Content -Path $postInstallInstructionsMD -Raw
        $markdownContent = $markdownContent -replace '\$\{SystemRoot\}',"$($installerSettings.SystemRootDirectory)"
        $markdownContent = $markdownContent -replace '\$\{TomcatBinRoot\}',"$tomcatBinRoot"
        $markdownContent = $markdownContent -replace '\$\{ServiceName\}',"$($installerSettings.ServiceName)"
        $markdownContent = $markdownContent -replace '\$\{Port\}',"$Port"
        $markdownContent = $markdownContent -replace '\$\{Username\}','go_user'
        $markdownContent = $markdownContent -replace '\$\{Password\}',"$guid"
        $markdownContent = $markdownContent -replace '\$\{wassenttoeasit\}',"$wassenttoeasit"
        $markdownContent = $markdownContent -replace '\$\{postbody\}',"$body"
        $md = $markdownContent | ConvertFrom-Markdown
        $postInstallInstructionsHTML = Join-Path -Path $installerSettings.SystemRootDirectory -ChildPath 'postInstallInstructions.html'
        $md.Html | Out-File $postInstallInstructionsHTML
        Start-Process "file:///${postInstallInstructionsHTML}"
    } catch {
        Write-EPRInstallLog -Message "Unable to create post install instructions" -Level WARN @loggingParameters
        Write-EPRInstallLog -Message "Please advice raw post install instructions at $installerLibDirectory\postInstallInstructions.md" -Level WARN @loggingParameters
        Write-EPRInstallLog -InputObject $process -Level VERBOSE @loggingParameters
    }
    #endregion
    Write-EPRInstallLog -Message "Thank you for installing Easit Process Runner" @loggingParameters
    }
    
    end {
        Set-Location -Path $startingDirectory
    }
}

function Write-CustomLog {
    <#
    .SYNOPSIS
        Writes input to file and a output stream.
    .DESCRIPTION
        This function provide the option to log output and / or progress in scripts.
        While there are functions like *Start-Transcript* and *Out-File*, *Write-CustomLog* also
        handles log rotation and naming of log history.

        *Write-CustomLog* will always append *_date* to the logname and remove logs older than the value
        of *RotationInterval*.

        *Write-CustomLog* uses *Out-File* for writing output to a file and then redirects either *Message*
        or *InputObject* to the stream corresponding with the value of *Level*.

        If no input is provided for *-LogName*, *-LogDirectory* nor *-RotationInterval* the function will look for a variable named LoggerSettings in the global scope with a property or key with the same name and use that value. 
        
        If no input is provided for *-LogName*, the name of the caller script is used as input.
        
        If no input is provided for *-LogDirectory*, logs will be written to $pwd.
        
        If no input is provided for *-RotationInterval*, 30 will used as value.
    .PARAMETER Message
        String that will be written to file and stream.
    .PARAMETER InputObject
        The object that will be written to file and stream.
    .PARAMETER Level
        What stream should the input be redirected to.
    .PARAMETER OutputLevel
        What level of input should be written to file and stream.
    .PARAMETER LogName
        Name of logfile.
    .PARAMETER LogDirectory
        In what directory should logs be saved.
    .PARAMETER RotationInterval
        For how many days should logs be kept on disk.
    .PARAMETER Rotate
        Tells the function to rotate logs. If this is always included with *Write-CustomLog* it will always try to rotate logs each time *Write-CustomLog* is invoked.
    .EXAMPLE
        Write-CustomLog -Message "Staring script"

        In this example we write the string *Starting script* as a log entry with the level of INFO.
        It will also use Write-Information to output it to the correct stream.
    .EXAMPLE
        Write-CustomLog -InputObject $_ -Level ERROR

        In this example we write the current objekt to as a log entry with the level of ERROR.
        It will also use Write-Error to output it to the correct stream.
    .EXAMPLE
        Write-CustomLog -Message "Rotating logs" -Level VERBOSE -Rotate

        In this example we write the string *Starting script* as a log entry with the level of INFO.
        It will also use Write-Information to output it to the correct stream.
        Since we specify *-Rotate* the function will try to remove files older than set by *RotationInterval*.
    .EXAMPLE
        Write-CustomLog -Message "Starting script and rotating logs" -Rotate
        Write-CustomLog -Message "Trying something" -Level VERBOSE
        try {
            try-something
        } catch {
            Write-CustomLog -InputObject $_ -Level ERROR
            return
        }
        Write-CustomLog -Message "Script end"

        Basic *real world* example of how to use *Write-CustomLog* in a script.
    .INPUTS
        [string]

        [object]
    .OUTPUTS
        None. This cmdlet returns no output.
    #>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline,ParameterSetName='string')]
        [string]$Message,
		[Parameter(ValueFromPipeline,ParameterSetName='object')]
        [object]$InputObject,
		[Parameter()]
        [ValidateSet('ERROR','WARN','INFO','VERBOSE','DEBUG')]
		[string]$Level = 'INFO',
        [Parameter()]
        [ValidateSet('ERROR','WARN','INFO','VERBOSE','DEBUG')]
		[string]$OutputLevel,
		[Parameter()]
		[string]$LogName,
		[Parameter()]
		[string]$LogDirectory,
		[Parameter()]
		[int]$RotationInterval,
        [Parameter()]
        [switch]$Rotate
	)
    $globalLoggerSettings = $global:LoggerSettings
	if ([string]::IsNullOrWhiteSpace($LogName)) {
        if (!([string]::IsNullOrWhiteSpace($globalLoggerSettings.LogName))) {
            $LogName = $globalLoggerSettings.LogName
        } else {
            $callStack = Get-PSCallStack
            $LogName = $callStack[1].Command.TrimEnd('\.ps1')
        }
	}
    if ([string]::IsNullOrWhiteSpace($OutputLevel)) {
        if (!([string]::IsNullOrWhiteSpace($globalLoggerSettings.OutputLevel))) {
            $OutputLevel = $globalLoggerSettings.OutputLevel
        } else {
            $OutputLevel = 'INFO'
        }
	}
	if ([string]::IsNullOrWhiteSpace($Level)) {
        $Level = 'INFO'
	}
	if ([string]::IsNullOrWhiteSpace($LogDirectory)) {
        if (!([string]::IsNullOrWhiteSpace($globalLoggerSettings.LogDirectory))) {
            $LogDirectory = $globalLoggerSettings.LogDirectory
        } else {
            $LogDirectory = $easitPRlogsDirectory
        }
    }
	if ([string]::IsNullOrWhiteSpace("$RotationInterval")) {
        if (!([string]::IsNullOrWhiteSpace("$($globalLoggerSettings.RotationInterval)"))) {
            $LogDirectory = $globalLoggerSettings.RotationInterval
        } else {
            $RotationInterval = 30
        }
	}
	$LogLevelTable = @{
        ERROR = 1
        WARN = 2
        INFO = 3
        VERBOSE = 4
        DEBUG = 5
    }
	$today = Get-Date -Format "yyyyMMdd"
	$LogName = "${LogName}_${today}.log"
	$logOutputPath = Join-Path -Path "$LogDirectory" -ChildPath "$LogName"
    if ($Rotate) {
        $logArchiveFiles = Get-ChildItem -Path "$LogDirectory" -Recurse  -Include "*${logname}*.log"
        foreach ($logArchiveFile in $logArchiveFiles) {
            if ($logArchiveFile.CreationTime -lt ((Get-Date).AddDays(-$RotationInterval))) {
                "$($logArchiveFile.Name) is older than $RotationInterval days, removing.." | Out-File -FilePath "$logOutputPath" -Encoding UTF8 -Append -NoClobber
				try {
					Remove-Item "$($logArchiveFile.FullName)" -Force
				} catch {
					Write-Error $_
					exit
				}
                "$FormattedDate - INFO - Removed $($logArchiveFile.Name)" | Out-File -FilePath "$logOutputPath" -Encoding UTF8 -Append -NoClobber
            }
        }
    }
    if ($LogLevelTable."$Level" -le $LogLevelTable."$OutputLevel") {
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $PSStyle.OutputRendering = 'PlainText'
        if (!(Test-Path $logOutputPath)) {
            $NewLogFile = New-Item "$logOutputPath" -Force -ItemType File
            "$FormattedDate - INFO - Created $NewLogFile" | Out-File -FilePath "$logOutputPath" -Encoding UTF8 -Append -NoClobber
        }
        if ($Message) {
            "$FormattedDate - $Level - $Message" | Out-File -FilePath "$logOutputPath" -Encoding UTF8 -Append -NoClobber
        }
        if ($InputObject) {
            "$FormattedDate - $Level - InputObject" | Out-File -FilePath "$logOutputPath" -Encoding UTF8 -Append -NoClobber
            $InputObject | Out-File -FilePath "$logOutputPath" -Encoding UTF8 -Append -NoClobber
        }
    }
}
function New-PostBody {
    <#
    .SYNOPSIS
        Function to create a "Easit GO" formatted body for web requests.
    .DESCRIPTION
        This functions takes a "settings object" as input and uses the settings there to create a json body that can be used with Invoke-RestMethod.
    .EXAMPLE
        PS> $body = New-PostBody -InstallerSettings $installerSettings
    .PARAMETER InstallerSettings
        Settings object holding a FeedbackSettings.postBody property with an array of properties and a importHandlerIdentifier.

        ```json
            "FeedbackSettings":{
                "postBody":{
                    "importHandlerIdentifier":"",
                    "properties":["Property1","Property2"]
                }
            }
        ```
    .INPUTS
        [PSCustomObject]
    .OUTPUTS
        JSON formatted string.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$InstallerSettings
    )
    
    begin {
        
    }
    
    process {
        $items = @()
        $propertiesArray = @()
        foreach ($prop in $InstallerSettings.FeedbackSettings.postBody.properties) {
            $propObject = [PSCustomObject]@{
                name = "$prop"
                content = $InstallerSettings."$prop"
            }
            $propertiesArray += $propObject
        }
        $guid = (New-Guid) -replace '-',''
        $itemObject = [PSCustomObject]@{
            property = $propertiesArray
            id = $guid
            uid = $guid
            
        }
        $items += $itemObject
        $bodyObject = [PSCustomObject]@{
            importHandlerIdentifier = $InstallerSettings.FeedbackSettings.postBody.importHandlerIdentifier
            itemToImport = $items
        }
        try {
            $bodyObject | ConvertTo-Json -Depth 4
        } catch {
            throw $_
        }
    }
    
    end {
        
    }
}

function Write-EPRInstallLog {
    <#
    .SYNOPSIS
        Easit custom Powershell logger.
    .DESCRIPTION
        Easit custom Powershell logger works similar to log4j that is used with Java applications.

        Two different logging techniques are used depending on the input:
        "$FormattedDate - $Level - $Message" | Out-File
        $InputObject | Out-File
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
    .PARAMETER LogLevel
        What level the logger should output entries on.
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
        [string]$LogDirectory,
        [Parameter()]
        [string]$LogLevel = 'INFO'
    )
    
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
