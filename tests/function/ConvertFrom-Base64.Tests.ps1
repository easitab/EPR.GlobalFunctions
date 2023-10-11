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
    $base64String = 'e2ltcG9ydGhhbmRsZXI6Im15U2NyaXB0LnBzMSIsZXhwb3J0ZWRJdGVtOntwcm9wZXJ0eTE9IsOlw7bDpCJ9fQ=='
}
Describe "ConvertFrom-Base64" -Tag 'function','public' {
    It 'should have a parameter named InputString that accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter -Mandatory InputString -Type [String]
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
    It 'should return a string' {
        ConvertFrom-Base64 -InputString $base64String | Should -BeOfType [String]
    }
    It 'should throw if input is empty, null or whitespace' {
        {ConvertFrom-Base64 -InputString ""} | Should -Throw
        {ConvertFrom-Base64 -InputString $null} | Should -Throw
        {ConvertFrom-Base64 -InputString " "} | Should -Throw
    }
}