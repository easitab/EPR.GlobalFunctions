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
}
Describe "Get-SettingsFromFile" -Tag 'function' {
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
    It 'should return a PSCustomObjec' {
        Get-SettingsFromFile -Filename 'Get-SettingsFromFile' -Path $envSettings.TestDataDirectory | Should -BeOfType PSCustomObject
    }
}