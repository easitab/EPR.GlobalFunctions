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
    $exportObject = Get-Content -Path (Join-Path -Path $envSettings.TestDataDirectory -ChildPath 'exportExample.json') -Raw | ConvertFrom-Json
}
Describe "New-FlatReturnObject" -Tag 'function','public' {
    It 'should have a parameter named Object that accepts a PSCustomObject' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Object -Type [PSCustomObject]
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
    It 'should return a PSCustomObject' {
        New-FlatReturnObject -Object $exportObject.itemToImport[0] | Should -BeOfType [PSCustomObject]
    }
    It 'returned object should have some base properties' {
        $returnedObject = New-FlatReturnObject -Object $exportObject.itemToImport[0]
        $returnedObject.DatabaseId | Should -BeExactly '18830:2'
        $returnedObject.ObjectId | Should -BeExactly 23468
        $returnedObject.PropertyObjects.Count | Should -BeExactly 3
        $returnedObject.Attachments.Count | Should -BeExactly 1
    }
    It 'properties should not be null or empty' {
        $returnedObject = New-FlatReturnObject -Object $exportObject.itemToImport[0]
        $returnedObject.assetCollection | Should -BeExactly 'Arbetsstation bärbar avancerad'
        $returnedObject.samAccountName | Should -BeExactly 'klåra'
        $returnedObject.dn | Should -BeExactly 'CN=testsson\, test,OU=Users,DC=company,DC=com'
        $returnedObject.Attachments[0].name | Should -BeExactly 'index.jpg'
        $returnedObject.Attachments[0].value | Should -BeExactly 'base64code'
    }
}