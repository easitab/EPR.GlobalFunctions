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
        $tempScriptsDirectoryPath = Join-Path -Path $envSettings.ProjectDirectory -ChildPath 'scripts'
        $tempHelpersDirectoryPath = Join-Path -Path $tempScriptsDirectoryPath -ChildPath 'helpers'
    } catch {
        throw $_
    }
    if (Test-Path -Path $tempScriptsDirectoryPath) {
        throw "scripts already exist, please remove it and its content"
    }
    try {
        $null = New-Item -Path $envSettings.ProjectDirectory -Name 'scripts' -ItemType Directory
        $null = New-Item -Path $tempScriptsDirectoryPath -Name 'helpers' -ItemType Directory
        $null = New-Item -Path $tempHelpersDirectoryPath -Name 'modules' -ItemType Directory
        $null = New-Item -Path $tempHelpersDirectoryPath -Name 'customModules' -ItemType Directory
    } catch {
        throw $_
    }
    function Import-Module {
        [CmdletBinding()]
        param (
            $Input
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
    It 'should not throw when not input is provided' {
        {Set-EPREnvironment} | Should -Not -Throw
    }
    It "should create variable 'epr_Directory' and it should not be null or empty" {
        Get-Variable -Name 'epr_Directory' | Should -Not -BeNullOrEmpty
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
        Remove-Item -Path $tempScriptsDirectoryPath -Confirm:$false
    } catch {
        throw $_
    }
}