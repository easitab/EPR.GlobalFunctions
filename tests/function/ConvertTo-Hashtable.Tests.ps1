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
    $myPSObject = [pscustomobject]@{property1="value1";property2="value2"}
}
Describe "ConvertTo-Hashtable" -Tag 'function','public' {
    It 'should have a parameter named InputObject that accepts a XXX' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InputObject -Type [PSCustomObject]
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
    It 'should no throw with valid input' {
        {$myPSObject | ConvertTo-Hashtable} | Should -Not -Throw
        {ConvertTo-Hashtable -InputObject $myPSObject} | Should -Not -Throw
    }
    It 'should return a hashtable' {
        ($myPSObject | ConvertTo-Hashtable) | Should -BeOfType [Hashtable]
    }
    It "should return a hashtable with a key named 'property1' that is not null or empty" {
        ($myPSObject | ConvertTo-Hashtable).property1 | Should -Not -BeNullOrEmpty
    }
}