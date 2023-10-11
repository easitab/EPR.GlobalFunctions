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
    It 'should return a PSCustomObject (base64)' {
        Convert-EasitGOExportString -InputString $base64String | Should -BeOfType [PSCustomObject]
    }
}