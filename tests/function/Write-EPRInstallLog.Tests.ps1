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
}
Describe "Write-EPRInstallLog" -Tag 'function','private' {
    It 'should have a parameter named Message' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Message
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Message -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Message -Type String
    }
    It 'should have a parameter named InputObject' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InputObject
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InputObject -Not -Mandatory
    }
    It 'and accepts a Object' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InputObject -Type Object
    }
    It 'should have a parameter named Level' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Level
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Level -Not -Mandatory
    }
    It 'it accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Level -Type String
    }
    It 'and have a default value = INFO' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Level -DefaultValue INFO
    }
    It 'should have a parameter named LogName' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter LogName
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter LogName -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter LogName -Type String
    }
    It 'should have a parameter named LogDirectory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter LogDirectory
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter LogDirectory -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter LogDirectory -Type String
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
}