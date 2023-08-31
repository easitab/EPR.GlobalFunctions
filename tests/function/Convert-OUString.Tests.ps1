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
Describe "Convert-OUString" -Tag 'function' {
    It 'should have a parameter named OUString that is mandatory and accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter OUString -Mandatory -Type String
    }
    It 'should have a parameter named AsPSCustomObject that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter AsPSCustomObject -Not -Mandatory
    }
    It 'and is a switch.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter AsPSCustomObject -Type 'Switch'
    }
    It 'should return a OrderedDictionary (ordered hashtable) by default.' {
        Convert-OUString -OUString 'uid=johnDoe,ou=People,dc=example,dc=com' | Should -BeOfType 'System.Collections.Specialized.OrderedDictionary'
    }
    It 'should return a AsPSCustomObject when switch is provided.' {
        Convert-OUString -OUString 'uid=johnDoe,ou=People,dc=example,dc=com' -AsPSCustomObject | Should -BeOfType PSCustomObject
    }
}