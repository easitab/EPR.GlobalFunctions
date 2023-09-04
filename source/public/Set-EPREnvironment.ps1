function Set-EPREnvironment {
    <#
    .SYNOPSIS
        Sets a number of new variables in the script scope.
    .DESCRIPTION
        By running this function in the beginning of your script the following variables will be made available:

        - epr_Directory
        - epr_logsDirectory
        - epr_scriptsDirectory
        - epr_scriptSettingsDirectory
        - epr_scriptHelpersDirectory
        - epr_modulesDirectory
        - epr_customModulesDirectory
        - epr_customFunctionsDirectory
        - ScriptLogName
        - LoggerSettings
    .EXAMPLE
        Set-EPREnvironment
    .EXAMPLE
        Set-EPREnvironment -IncludeOldVariableNames

        In this example we want to get the old variable names along with the new names.
    .EXAMPLE
        Set-EPREnvironment -CustomModules "MyModule","AnotherModule"

        In this example we also import the modules 'MyModule' and 'AnotherModule' located in the directory *[NameOfEPRInstall]/scripts/helpers/customModules*.
    .EXAMPLE
        Set-EPREnvironment -Modules "MyOfficialModule","AnotherModuleAsAnExample"

        In this example we also import the modules 'MyOfficialModule' and 'AnotherModuleAsAnExample' located in the directory *[NameOfEPRInstall]/scripts/helpers/modules*.
    .PARAMETER Modules
        Name of modules to import from *[NameOfEPRInstall]/scripts/helpers/modules*
    .PARAMETER CustomModules
        Name of modules to import from *[NameOfEPRInstall]/scripts/helpers/customModules*
    .PARAMETER IncludeOldVariableNames
        Specifies if the old variable names should be set in the script scope.
    .OUTPUTS
        This function do not produce any output.
    #>
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter()]
        [string[]]$Modules,
        [Parameter()]
        [string[]]$CustomModules,
        [Parameter()]
        [switch]$IncludeOldVariableNames
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        $callStack = Get-PSCallStack
        $ScriptName = $callStack[1].Command.TrimEnd('\.ps1')
        $newVarParams = @{
            Option = 'ReadOnly'
            Scope = 'Script'
            Force = $true
        }
        try {
            New-Variable -Name 'epr_Directory' -Value (Split-Path -Path (Split-Path -Path $PSScriptRoot) -Parent) @newVarParams
            New-Variable -Name 'epr_logsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'logs') @newVarParams
            New-Variable -Name 'epr_scriptsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'scripts') @newVarParams
            New-Variable -Name 'epr_scriptSettingsDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'scriptSettings') @newVarParams
            New-Variable -Name 'epr_scriptHelpersDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'helpers') @newVarParams
            New-Variable -Name 'epr_modulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'modules') @newVarParams
            New-Variable -Name 'epr_customModulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'customModules') @newVarParams
            New-Variable -Name 'ScriptLogName' -Value $ScriptName @newVarParams
        } catch {
            Write-Warning "Failed to set EPR variables"
            throw $_
        }
        $tempHash = @{
            LogName = $ScriptLogName
            LogDirectory = "$epr_logsDirectory"
            OutputLevel = 'INFO'
            RotationInterval = 30
        }
        try {
            New-Variable -Name 'epr_LoggerSettings' -Value $tempHash -Scope Global -Force
        } catch {
            throw $_
        }
        if ($IncludeOldVariableNames) {
            Write-Warning "You are using the old environment setup, please consider moving to the new environment setup!"
            try {
                New-Variable -Name 'easitPRDirectory' -Value (Split-Path -Path (Split-Path -Path $PSScriptRoot) -Parent) @newVarParams
                New-Variable -Name 'easitPRlogsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'logs') @newVarParams
                New-Variable -Name 'easitPRscriptsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'scripts') @newVarParams
                New-Variable -Name 'easitPRscriptSettingsDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'scriptSettings') @newVarParams
                New-Variable -Name 'easitPRscriptHelpersDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'helpers') @newVarParams
                New-Variable -Name 'easitPRmodulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'modules') @newVarParams
                New-Variable -Name 'easitPRcustomModulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'customModules') @newVarParams
                New-Variable -Name 'ScriptLogName' -Value $ScriptName @newVarParams
            } catch {
                Write-Warning "Failed to set old variable names"
                throw $_
            }
            try {
                New-Variable -Name 'LoggerSettings' -Value $tempHash -Scope Global -Force
            } catch {
                throw $_
            }
        }
        if (!($null -eq $Modules)) {
            if (Test-Path $epr_modulesDirectory) {
                if ($Modules -ge 1 -and !($Modules -eq 'ALL')) {
                    foreach ($module in $modules) {
                        $modulName = $module.Trim()
                        $modulePath = Join-Path $epr_modulesDirectory -ChildPath "$modulName"
                        try {
                            Write-Verbose "Importing $modulePath"
                            Import-Module "$modulePath"
                        } catch {
                            Write-Warning $_
                        }
                    }
                } elseif ($Modules -eq 'ALL') {
                    $modules = Get-ChildItem -Path $epr_modulesDirectory -Directory
                    foreach ($module in $modules) {
                        try {
                            Write-Verbose "Importing $module"
                            Import-Module "$module"
                        } catch {
                            Write-Warning $_
                        }
                    }
                } else {
                    Write-Warning "Unknown parameter input for Modules"
                }
            } else {
                Write-Warning "Unable to find epr_modulesDirectory ($epr_modulesDirectory)"
            }
        }
        if (!($null -eq $CustomModules)) {
            if (Test-Path $epr_customModulesDirectory) {
                if ($CustomModules -ge 1 -and !($CustomModules -eq 'ALL')) {
                    foreach ($customModule in $CustomModules) {
                        $customModuleName = $customModule.Trim()
                        $customModulePath = Join-Path $epr_customModulesDirectory -ChildPath "${customModuleName}.psm1"
                        try {
                            Write-Verbose "Importing $customModulePath"
                            Import-Module "$customModulePath"
                        } catch {
                            Write-Warning $_
                        }
                    }
                } elseif ($CustomModules -eq 'ALL') {
                    $CustomModules = Get-ChildItem -Path $epr_customModulesDirectory -Recurse -Include '*.psm1'
                    foreach ($customModule in $CustomModules) {
                        try {
                            Write-Verbose "Importing $customModule"
                            Import-Module "$customModule"
                        } catch {
                            Write-Warning $_
                        }
                    }
                } else {
                    Write-Warning "Unknown parameter input for CustomModules"
                }
            } else {
                Write-Warning "Unable to find epr_customModulesDirectory ($epr_customModulesDirectory)"
            }
        }
        Write-Verbose "Environment setup complete"
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}