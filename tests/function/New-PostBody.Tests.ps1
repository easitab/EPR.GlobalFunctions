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
    $installerSettings = [PSCustomObject]@{
        FeedbackSettings = @{
            postBody = @{
                importHandlerIdentifier = ""
                properties = @(
                    "Property1",
                    "Property2"
                )
            }
        }
    }
    try {
        $return = New-PostBody -InstallerSettings $installerSettings
    } catch {
        throw $_
    }
}
Describe "New-PostBody" -Tag 'function','private' {
    It 'should have a parameter named InstallerSettings that is mandatory and accepts a PSCustomObject.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InstallerSettings -Mandatory -Type PSCustomObject
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
    It 'should not throw with valid input' {
        {New-PostBody -InstallerSettings $installerSettings} | Should -Not -Throw
    }
    It 'should return a string' {
        $return | Should -BeOfType [System.String]
    }
    It 'should return a string with a length greater than 350 (non Windows)' {
        $return.Length | Should -BeGreaterThan 350
    }
    It 'should return a string with a length less than 371' {
        $return.Length | Should -BeLessThan 371
    }
}