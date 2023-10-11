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
    function ConvertFrom-Base64 {
        param (
            $InputString
        )
        $byteArray = [System.Convert]::FromBase64String($InputString)
        [System.Text.Encoding]::UTF8.GetString($byteArray)
    }
    function New-FlatReturnObject {
        param (
            $Object
        )
        [PSCustomObject]@{
            DatabaseId = $Object.id
            ObjectId = $Object.uid
            PropertyObjects = [System.Collections.Generic.List[PSCustomObject]]::new()
            Attachments = [System.Collections.Generic.List[PSCustomObject]]::new()
        }
    }
    $exportString = Get-Content -Path (Join-Path -Path $envSettings.TestDataDirectory -ChildPath 'exportExample.json') -Raw
    $base64String = 'eyJpbXBvcnRoYW5kbGVyIjoibXlTY3JpcHQucHMxIiwiaXRlbVRvSW1wb3J0Ijp7InByb3BlcnR5IjpbeyJwcm9wZXJ0eTEiOiJzcGVjaWFsQ2hhcmFjdGVycyJ9XX19'
}
Describe "Convert-EasitGOExportString" -Tag 'function','public' {
    It 'should have a parameter named InputString that accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InputString -Mandatory -Type [String]
    }
    It 'should have a parameter named Raw that is a switch' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Raw -Type [Switch]
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
    It 'should return a PSCustomObject (json)' {
        Convert-EasitGOExportString -InputString $exportString | Should -BeOfType [PSCustomObject]
    }
    It 'should return a PSCustomObject (base64)' {
        Convert-EasitGOExportString -InputString $base64String | Should -BeOfType [PSCustomObject]
    }
}