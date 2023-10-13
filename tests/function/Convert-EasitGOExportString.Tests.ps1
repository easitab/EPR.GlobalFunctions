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
    $base64String = Get-Content -Path (Join-Path -Path $envSettings.TestDataDirectory -ChildPath 'exportExampleBase64.txt') -Raw
}
Describe "Convert-EasitGOExportString" -Tag 'function','public' {
    It 'should have a parameter named InputString that accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InputString -Mandatory -Type [String]
    }
    It 'should have a parameter named Raw that is a switch' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Raw -Type [Switch]
    }
    It 'should have a parameter named Full that is a switch' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Full -Type [Switch]
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
    It '$returnedObject.ObjectId should be 23468 (json)' {
        (Convert-EasitGOExportString -InputString $exportString).ObjectId | Should -BeExactly 23468
    }
    It '$returnedObject.DatabaseId should be 18830:2 (json)' {
        (Convert-EasitGOExportString -InputString $exportString).DatabaseId | Should -BeExactly '18830:2'
    }
    It '$returnedObject.PropertyObjects.Count should be 0 (json)' {
        (Convert-EasitGOExportString -InputString $exportString).PropertyObjects.Count | Should -BeExactly 0
    }
    It '$returnedObject.Attachments.Count should be 0 (json)' {
        (Convert-EasitGOExportString -InputString $exportString).Attachments.Count | Should -BeExactly 0
    }
    It '$returnedObject.uid should be 23468 (json - raw)' {
        (Convert-EasitGOExportString -InputString $exportString -Raw).uid | Should -BeExactly 23468
    }
    It '$returnedObject.id should be 18830:2 (json - raw)' {
        (Convert-EasitGOExportString -InputString $exportString -Raw).id | Should -BeExactly '18830:2'
    }
    It '$returnedObject.property.Count should be 3 (json - raw)' {
        (Convert-EasitGOExportString -InputString $exportString -Raw).property.Count | Should -BeExactly 3
    }
    It '$returnedObject.attachment.Count should be 1 (json - raw)' {
        (Convert-EasitGOExportString -InputString $exportString -Raw).attachment.Count | Should -BeExactly 1
    }
    It 'should return a PSCustomObject (base64)' {
        Convert-EasitGOExportString -InputString $base64String | Should -BeOfType [PSCustomObject]
    }
    It '$returnedObject.ObjectId should be 23468 (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).ObjectId | Should -BeExactly 23468
    }
    It '$returnedObject.DatabaseId should be 18830:2 (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).DatabaseId | Should -BeExactly '18830:2'
    }
    It '$returnedObject.PropertyObjects.Count should be 0 (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).PropertyObjects.Count | Should -BeExactly 0
    }
    It '$returnedObject.Attachments.Count should be 0 (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).Attachments.Count | Should -BeExactly 0
    }
    It '$returnedObject.uid should be 23468 (base64 - raw)' {
        (Convert-EasitGOExportString -InputString $base64String -Raw).uid | Should -BeExactly 23468
    }
    It '$returnedObject.id should be 18830:2 (base64 - raw)' {
        (Convert-EasitGOExportString -InputString $base64String -Raw).id | Should -BeExactly '18830:2'
    }
    It '$returnedObject.property.Count should be 3 (base64 - raw)' {
        (Convert-EasitGOExportString -InputString $base64String -Raw).property.Count | Should -BeExactly 3
    }
    It '$returnedObject.attachment.Count should be 1 (base64 - raw)' {
        (Convert-EasitGOExportString -InputString $base64String -Raw).attachment.Count | Should -BeExactly 1
    }
}