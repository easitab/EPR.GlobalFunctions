function Set-EPREnvironment {
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
        if ($IncludeOldVariableNames) {
            Write-Warning "You are using the old environment setup, please consider moving to the new environment setup!"
            try {
                New-Variable -Name 'easitPRDirectory' -Value (Split-Path -Path (Split-Path -Path $PSScriptRoot) -Parent) -Option ReadOnly -Scope Global
                New-Variable -Name 'easitPRlogsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'logs') -Option ReadOnly -Scope Global
                New-Variable -Name 'easitPRscriptsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'scripts') -Option ReadOnly -Scope Global
                New-Variable -Name 'easitPRscriptSettingsDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'scriptSettings') -Option ReadOnly -Scope Global
                New-Variable -Name 'easitPRscriptHelpersDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'helpers') -Option ReadOnly -Scope Global
                New-Variable -Name 'easitPRmodulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'modules') -Option ReadOnly -Scope Global
                New-Variable -Name 'easitPRcustomModulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'customModules') -Option ReadOnly -Scope Global
                New-Variable -Name 'ScriptLogName' -Value $ScriptName -Option ReadOnly -Scope Global
            } catch {
                Write-Warning "Failed to set old variable names"
                throw $_
            }
        }
        try {
            New-Variable -Name 'epr_Directory' -Value (Split-Path -Path (Split-Path -Path $PSScriptRoot) -Parent) -Option ReadOnly -Scope Global
            New-Variable -Name 'epr_logsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'logs') -Option ReadOnly -Scope Global
            New-Variable -Name 'epr_scriptsDirectory' -Value (Join-Path -Path "$epr_Directory" -ChildPath 'scripts') -Option ReadOnly -Scope Global
            New-Variable -Name 'epr_scriptSettingsDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'scriptSettings') -Option ReadOnly -Scope Global
            New-Variable -Name 'epr_scriptHelpersDirectory' -Value (Join-Path -Path "$epr_scriptsDirectory" -ChildPath 'helpers') -Option ReadOnly -Scope Global
            New-Variable -Name 'epr_modulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'modules') -Option ReadOnly -Scope Global
            New-Variable -Name 'epr_customModulesDirectory' -Value (Join-Path -Path "$epr_scriptHelpersDirectory" -ChildPath 'customModules') -Option ReadOnly -Scope Global
            New-Variable -Name 'ScriptLogName' -Value $ScriptName -Option ReadOnly -Scope Global
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
        if ($IncludeOldVariableNames) {
            try {
                New-Variable -Name 'LoggerSettings' -Value $tempHash -Scope Global
            } catch {
                throw $_
            }
        }
        try {
            New-Variable -Name 'epr_LoggerSettings' -Value $tempHash -Scope Global
        } catch {
            throw $_
        }
        if (Test-Path $epr_modulesDirectory) {
            if ($Modules -ge 1 -and !($Modules -eq 'ALL')) {
                foreach ($module in $modules) {
                    $modulName = $module.Trim()
                    $modulePath = Join-Path $epr_modulesDirectory -ChildPath "$modulName"
                    try {
                        Write-Information "Importing $modulePath" -InformationAction Continue
                        Import-Module "$modulePath"
                    } catch {
                        Write-Warning $_
                    }
                }
            } elseif ($Modules -eq 'ALL') {
                $modules = Get-ChildItem -Path $epr_modulesDirectory -Directory
                foreach ($module in $modules) {
                    try {
                        Write-Information "Importing $module" -InformationAction Continue
                        Import-Module "$module"
                    } catch {
                        Write-Warning $_
                    }
                }
            } elseif ($null -eq $Modules) {
                Write-Information "No input for parameter Modules" -InformationAction Continue
            }else {
                Write-Warning "Unknown parameter input for Modules"
            }
        } else {
            Write-Warning "Unable to find epr_modulesDirectory ($epr_modulesDirectory)"
        }
        if (Test-Path $epr_customModulesDirectory) {
            if ($CustomModules -ge 1 -and !($CustomModules -eq 'ALL')) {
                foreach ($customModule in $CustomModules) {
                    $customModuleName = $customModule.Trim()
                    $customModulePath = Join-Path $epr_customModulesDirectory -ChildPath "${customModuleName}.psm1"
                    try {
                        Write-Information "Importing $customModulePath" -InformationAction Continue
                        Import-Module "$customModulePath"
                    } catch {
                        Write-Warning $_
                    }
                }
            } elseif ($CustomModules -eq 'ALL') {
                $CustomModules = Get-ChildItem -Path $epr_customModulesDirectory -Recurse -Include '*.psm1'
                foreach ($customModule in $CustomModules) {
                    try {
                        Write-Information "Importing $customModule" -InformationAction Continue
                        Import-Module "$customModule"
                    } catch {
                        Write-Warning $_
                    }
                }
            } elseif ($null -eq $CustomModules) {
                Write-Information "No input for parameter CustomModules" -InformationAction Continue
            }else {
                Write-Warning "Unknown parameter input for CustomModules"
            }
        } else {
            Write-Warning "Unable to find epr_customModulesDirectory ($epr_customModulesDirectory)"
        }
        Write-Information "Environment setup complete" -InformationAction Continue
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}