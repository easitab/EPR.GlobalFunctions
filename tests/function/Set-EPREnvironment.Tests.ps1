BeforeAll {
    try {
        $getEnvSetPath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent) -ChildPath 'getEnvironmentSetting.ps1'
        . $getEnvSetPath
        $envSettings = Get-EnvironmentSetting -Path $PSCommandPath
    } catch {
        throw $_
    }
    if (Test-Path $envSettings.CodeFilePath) {
        . $envSettings.CodeFilePath
    } else {
        Write-Output "Unable to locate code file ($($envSettings.CodeFilePath)) to test against!" -ForegroundColor Red
    }
    try {
        $tempDirectoryName = (New-Guid) -replace '-',''
        $tempProjectRootDirectoryPath = Join-Path -Path $envSettings.ProjectDirectory -ChildPath "$tempDirectoryName"
        $tempScriptsDirectoryPath = Join-Path -Path $tempProjectRootDirectoryPath -ChildPath 'scripts'
        $tempLogsDirectoryPath = Join-Path -Path $tempProjectRootDirectoryPath -ChildPath 'logs'
        $tempHelpersDirectoryPath = Join-Path -Path $tempScriptsDirectoryPath -ChildPath 'helpers'
        $tempScriptSettingsDirectoryPath = Join-Path -Path $tempScriptsDirectoryPath -ChildPath 'scriptSettings'
        $tempModulesDirectoryPath = Join-Path -Path $tempHelpersDirectoryPath -ChildPath 'modules'
        $tempCustomModulesDirectoryPath = Join-Path -Path $tempHelpersDirectoryPath -ChildPath 'customModules'
    } catch {
        throw $_
    }
    if (Test-Path -Path $tempProjectRootDirectoryPath) {
        throw "scripts already exist, please remove it and its content"
    } else {
        $null = New-Item -Path $envSettings.ProjectDirectory -Name "$tempDirectoryName" -ItemType Directory
    }
    try {
        $null = New-Item -Path $tempProjectRootDirectoryPath -Name 'scripts' -ItemType Directory
        $null = New-Item -Path $tempProjectRootDirectoryPath -Name 'logs' -ItemType Directory
        $null = New-Item -Path $tempScriptsDirectoryPath -Name 'helpers' -ItemType Directory
        $null = New-Item -Path $tempScriptsDirectoryPath -Name 'scriptSettings' -ItemType Directory
        $null = New-Item -Path $tempHelpersDirectoryPath -Name 'modules' -ItemType Directory
        $null = New-Item -Path $tempHelpersDirectoryPath -Name 'customModules' -ItemType Directory
    } catch {
        throw $_
    }
    $directories = @{
        epr_Directory = $tempProjectRootDirectoryPath
        epr_logsDirectory = $tempLogsDirectoryPath
        epr_scriptsDirectory = $tempScriptsDirectoryPath
        epr_scriptSettingsDirectory = $tempScriptSettingsDirectoryPath
        epr_scriptHelpersDirectory = $tempHelpersDirectoryPath
        epr_modulesDirectory = $tempModulesDirectoryPath
        epr_customModulesDirectory = $tempCustomModulesDirectoryPath
        ScriptLogName = ($envSettings.CodeFileName -replace '\.ps1','')
    }
    function Get-Location {
        param (
            
        )
        return [PSCustomObject]@{
            Path = $tempScriptsDirectoryPath
        }
    }
    function Import-Module {
        [CmdletBinding()]
        param (
            $MyInput,
            $Global,
            $Force
        )
    }
}
Describe "Set-EPREnvironment" -Tag 'function','public' {
    It 'should have a parameter named Modules that accepts an array of strings.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Modules -Type [System.String[]]
    }
    It 'should have a parameter named CustomModules that accepts an array of strings.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter CustomModules -Type [System.String[]]
    }
    It 'should have a parameter named IncludeOldVariableNames that is of type Switch.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter IncludeOldVariableNames -Type [Switch]
    }
    It 'help section should have a SYNOPSIS' {
        ((Get-Help "$($envSettings.CommandName)" -Full).SYNOPSIS).Length | Should -BeGreaterThan 0
    }
    It 'help section should have a DESCRIPTION' {
        ((Get-Help "$($envSettings.CommandName)" -Full).DESCRIPTION).Length | Should -BeGreaterThan 0
    }
    It 'help section should have EXAMPLES' {
        ((Get-Help "$($envSettings.CommandName)" -Full).EXAMPLES).Length | Should -BeGreaterThan 0
    }
    It 'should have a HelpUri' {
        ((Get-Command "$($envSettings.CommandName)").HelpUri).Length | Should -BeGreaterThan 0
    }
    It 'all parameters should have a description' {
        $commonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters
        $optionalCommonParameters = [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
        foreach ($param in (Get-Help -Name "$($envSettings.CommandName)" -Full).parameters.parameter) {
            if ($commonParameters -notcontains $param.name -and $optionalCommonParameters -notcontains $param.name) {
                ($param.description.Text).Length | Should -BeGreaterThan 0
            }
        }
    }
    It 'should not throw when not input is provided' {
        {Set-EPREnvironment} | Should -Not -Throw
    }
    It "should create variable 'epr_Directory' and it should not be null or empty" {
        Get-Variable -Name 'epr_Directory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_Directory' should be $($directories.epr_Directory)" {
        Get-Variable -Name 'epr_Directory' -ValueOnly | Should -BeExactly "$($directories.epr_Directory)"
    }
    It "should create variable 'epr_logsDirectory' and it should not be null or empty" {
        Get-Variable -Name 'epr_logsDirectory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_logsDirectory' should be $($directories.epr_logsDirectory)" {
        Get-Variable -Name 'epr_logsDirectory' -ValueOnly | Should -BeExactly "$($directories.epr_logsDirectory)"
    }
    It "should create variable 'epr_scriptsDirectory' and it should not be null or empty" {
        Get-Variable -Name 'epr_scriptsDirectory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_scriptsDirectory' should be $($directories.epr_scriptsDirectory)" {
        Get-Variable -Name 'epr_scriptsDirectory' -ValueOnly | Should -BeExactly "$($directories.epr_scriptsDirectory)"
    }
    It "should create variable 'epr_scriptsDirectory' and it should not be null or empty" {
        Get-Variable -Name 'epr_scriptsDirectory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_scriptSettingsDirectory' should be $($directories.epr_scriptSettingsDirectory)" {
        Get-Variable -Name 'epr_scriptSettingsDirectory' -ValueOnly | Should -BeExactly "$($directories.epr_scriptSettingsDirectory)"
    }
    It "should create variable 'epr_scriptsDirectory' and it should not be null or empty" {
        Get-Variable -Name 'epr_scriptsDirectory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_scriptHelpersDirectory' should be $($directories.epr_scriptHelpersDirectory)" {
        Get-Variable -Name 'epr_scriptHelpersDirectory' -ValueOnly | Should -BeExactly "$($directories.epr_scriptHelpersDirectory)"
    }
    It "should create variable 'epr_scriptsDirectory' and it should not be null or empty" {
        Get-Variable -Name 'epr_scriptsDirectory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_modulesDirectory' should be $($directories.epr_modulesDirectory)" {
        Get-Variable -Name 'epr_modulesDirectory' -ValueOnly | Should -BeExactly "$($directories.epr_modulesDirectory)"
    }
    It "should create variable 'epr_customModulesDirectory' and it should not be null or empty" {
        Get-Variable -Name 'epr_customModulesDirectory' | Should -Not -BeNullOrEmpty
    }
    It "variable 'epr_customModulesDirectory' should be $($directories.epr_customModulesDirectory)" {
        Get-Variable -Name 'epr_customModulesDirectory' -ValueOnly | Should -BeExactly "$($directories.epr_customModulesDirectory)"
    }
    It "should create variable 'epr_LoggerSettings' and it should not be null or empty" {
        Get-Variable -Name 'epr_LoggerSettings' | Should -Not -BeNullOrEmpty
    }
    It "should create variable 'epr_LoggerSettings' value and it should be a hashtable" {
        Get-Variable -Name 'epr_LoggerSettings' -ValueOnly | Should -BeOfType [Hashtable]
    }
    It 'should not throw with Modules input' {
        {Set-EPREnvironment -Modules "myModule"} | Should -Not -Throw
    }
    It 'should not throw with CustomModules input' {
        {Set-EPREnvironment -CustomModules "myCustomModule"} | Should -Not -Throw
    }
    It 'should not throw with both Modules and CustomModules input' {
        {Set-EPREnvironment -Modules "myModule","MyModule2" -CustomModules "myCustomModule","myCustomModule2"} | Should -Not -Throw
    }
}
AfterAll {
    try {
        Get-ChildItem -Path $tempScriptsDirectoryPath -Recurse -File | Remove-Item -Force -Confirm:$false
        Get-ChildItem -Path $tempHelpersDirectoryPath -Recurse -Directory | Remove-Item -Force -Confirm:$false
        Get-ChildItem -Path $tempScriptsDirectoryPath -Recurse -Directory | Remove-Item -Force -Confirm:$false
        Remove-Item -Path $tempProjectRootDirectoryPath -Confirm:$false -Recurse
    } catch {
        throw $_
    }
}