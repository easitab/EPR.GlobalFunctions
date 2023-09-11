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
    function Write-CustomLog {
        [CmdletBinding()]
        Param (
            [Parameter(ValueFromPipeline,ParameterSetName='string')]
            [string]$Message,
            [Parameter(ValueFromPipeline,ParameterSetName='object')]
            [object]$InputObject,
            [Parameter()]
            [string]$Level
        )
    }
    try {
        $settings = Get-SettingsFromFile -Filename 'Get-SettingsFromFile' -Path $envSettings.TestDataDirectory
    } catch {
        throw $_
    }
}
Describe "Get-SettingsFromFile" -Tag 'function','public' {
    It 'should have a parameter named Filename' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Filename
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Filename -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Filename -Type String
    }
    It 'should have a parameter named Path' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Path
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Path -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Path -Type String
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
    It 'should return a PSCustomObjec' {
        Get-SettingsFromFile -Filename 'Get-SettingsFromFile' -Path $envSettings.TestDataDirectory | Should -BeOfType PSCustomObject
    }
    It "property value for LogOutputLevel should be 'VERBOSE'" {
        $settings.LogOutputLevel | Should -BeExactly 'VERBOSE'
    }
    It "property value for setting2 should be 'globalValueDetermined by template'" {
        $settings.setting2 | Should -BeExactly 'globalValueDetermined by template'
    }
    It "property value for setting6 should be null" {
        $settings.setting6 | Should -BeNullOrEmpty
    }
    It "property value for setting7 should be 'scriptValue7'" {
        $settings.setting7 | Should -BeExactly 'scriptValue7'
    }
}