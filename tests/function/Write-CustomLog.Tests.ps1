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
Describe "Write-CustomLog" -Tag 'function','public' {
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
    It 'and accepts a string' {
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
    It 'should have a parameter named OutputLevel' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter OutputLevel
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter OutputLevel -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter OutputLevel -Type String
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
    It 'should have a parameter named RotationInterval' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter RotationInterval
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter RotationInterval -Not -Mandatory
    }
    It 'and accepts an int' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter RotationInterval -Type Int
    }
    It 'should have a parameter named Rotate' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Rotate
    }
    It 'that is not mandatory' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Rotate -Not -Mandatory
    }
    It 'and accepts an int' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Rotate -Type Switch
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
    It 'should throw with invalid input' {
        {Write-CustomLog} | Should -Throw
    }
    It 'should not throw with valid input' {
        {Write-CustomLog -Message "test" -LogName 'testLog' -LogDirectory (Join-Path -Path $envSettings.ProjectDirectory -ChildPath 'logs')} | Should -Not -Throw
    }
    It 'should produce a log file' {
        {Get-ChildItem -Path (Join-Path -Path $envSettings.ProjectDirectory -ChildPath 'logs') -Recurse -Filter 'testLog*'} | Should -Not -BeNullOrEmpty
    }
}
AfterAll {
    try {
        Get-ChildItem -Path (Join-Path -Path $envSettings.ProjectDirectory -ChildPath 'logs') -Recurse -Filter 'testLog*' | Remove-Item -Confirm:$false
    } catch {
        throw $_
    }
}