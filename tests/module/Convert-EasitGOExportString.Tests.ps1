BeforeAll {
    try {
        $getEnvSetPath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent) -ChildPath 'getEnvironmentSetting.ps1'
        . $getEnvSetPath
        $envSettings = Get-EnvironmentSetting -Path $PSCommandPath
    } catch {
        throw $_
    }
    if (Test-Path $envSettings.CodeFilePath) {
        foreach ($privateFunction in Get-ChildItem -Path (Join-Path -Path $envSettings.SourceDirectory -ChildPath 'private') -Recurse -File) {
            . $privateFunction.FullName
        }
        foreach ($publicFunction in Get-ChildItem -Path (Join-Path -Path $envSettings.SourceDirectory -ChildPath 'public') -Recurse -File) {
            . $publicFunction.FullName
        }
        $exportString = Get-Content -Path (Join-Path -Path $envSettings.TestDataDirectory -ChildPath 'exportExample.json') -Raw
        $base64String = Get-Content -Path (Join-Path -Path $envSettings.TestDataDirectory -ChildPath 'exportExampleBase64.txt') -Raw
    } else {
        Write-Output "Unable to locate code file ($($envSettings.CodeFilePath)) to test against!" -ForegroundColor Red
    }
}
Describe "Convert-EasitGOExportString" -Tag 'module' {
    It 'should return a PSCustomObject (json)' {
        Convert-EasitGOExportString -InputString $exportString | Should -BeOfType [PSCustomObject]
    }
    It '$returnedObject.PropertyObjects.Count should be 3 (json)' {
        (Convert-EasitGOExportString -InputString $exportString).PropertyObjects.Count | Should -BeExactly 3
    }
    It '$returnedObject.assetCollection should be Arbetsstation bärbar avancerad (json)' {
        (Convert-EasitGOExportString -InputString $exportString).assetCollection | Should -BeExactly 'Arbetsstation bärbar avancerad'
    }
    It '$returnedObject.samAccountName should be klåra (json)' {
        (Convert-EasitGOExportString -InputString $exportString).samAccountName | Should -BeExactly 'klåra'
    }
    It '$returnedObject.dn should be CN=testsson\, test,OU=Users,DC=company,DC=com (json)' {
        (Convert-EasitGOExportString -InputString $exportString).dn | Should -BeExactly 'CN=testsson\, test,OU=Users,DC=company,DC=com'
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
    It '$returnedObject.PropertyObjects.Count should be 3 (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).PropertyObjects.Count | Should -BeExactly 3
    }
    It '$returnedObject.assetCollection should be Arbetsstation bärbar avancerad (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).assetCollection | Should -BeExactly 'Arbetsstation bärbar avancerad'
    }
    It '$returnedObject.samAccountName should be klåra (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).samAccountName | Should -BeExactly 'klåra'
    }
    It '$returnedObject.dn should be CN=testsson\, test,OU=Users,DC=company,DC=com (base64)' {
        (Convert-EasitGOExportString -InputString $base64String).dn | Should -BeExactly 'CN=testsson\, test,OU=Users,DC=company,DC=com'
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