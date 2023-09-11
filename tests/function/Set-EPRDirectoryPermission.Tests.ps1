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
Describe "Set-EPRDirectoryPermission" -Tag 'function','public' {
    It 'should have a parameter named Account that is mandatory and accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Account -Mandatory -Type [System.String]
    }
    It 'should have a parameter named Path that is mandatory and accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Path -Mandatory -Type [System.String]
    }
    It 'should have a parameter named Access that accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Access -Type [System.String]
    }
    It 'should have a parameter named InheritanceFlags that accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InheritanceFlags -Type [System.String]
    }
    It 'should have a parameter named PropagationFlags that accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter PropagationFlags -Type [System.String]
    }
    It 'should have a parameter named AccessControlType that accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter AccessControlType -Type [System.String]
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