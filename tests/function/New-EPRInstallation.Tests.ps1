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
    function Write-EPRInstallLog {
        [CmdletBinding()]
        param (
            [Parameter(ValueFromPipeline,ParameterSetName='string',Position=0)]
            [string]$Message,
            [Parameter(ValueFromPipeline,ParameterSetName='object')]
            [object]$InputObject,
            [Parameter()]
            [string]$Level = 'INFO',
            [Parameter()]
            [string]$LogName = 'EPRInstall',
            [Parameter()]
            [string]$LogDirectory
        )
    }
    try {
        $tempInstallDirectoryPath = Join-Path -Path $envSettings.ProjectDirectory -ChildPath 'installTemp'
    } catch {
        throw $_
    }
    if (Test-Path -Path $tempInstallDirectoryPath) {
        throw "installTemp already exist, please remove it and its content"
    }
    try {
        #$tempInstallDirectory = New-Item -Path $envSettings.ProjectDirectory -Name 'installTemp' -ItemType Directory
    } catch {
        throw $_
    }
}
Describe "New-EPRInstallation" -Tag 'function','public' {
    It 'should have a parameter named InstanceID that is mandatory and accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InstanceID -Mandatory -Type String
    }
    It 'should have a parameter named FromDirectory that is mandatory and accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter FromDirectory -Mandatory -Type String
    }
    It 'should have a parameter named InstallLocation that accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter InstallLocation -Type String
    }
    It 'should have a parameter named SystemName that accepts a string.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter SystemName -Type String
    }
    It 'should have a parameter named Port that accepts a number.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter Port -Type Int
    }
    It 'should have a parameter named TomcatXmx that accepts a number.' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter TomcatXmx -Type Int
    }
    It 'should have a parameter named IgnoreDirectoryStructure that is a switch' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter IgnoreDirectoryStructure -Type Switch
    }
    It 'should have a parameter named DoNotSendInstallationDetailsToEasit that is a switch' {
        Get-Command "$($envSettings.CommandName)" | Should -HaveParameter DoNotSendInstallationDetailsToEasit -Type Switch
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
}
AfterAll {
    try {
        #Get-ChildItem -Path $tempInstallDirectoryPath -Recurse -File | Remove-Item -Force -Confirm:$false
        #Get-ChildItem -Path $tempInstallDirectoryPath -Recurse -Directory | Remove-Item -Force -Confirm:$false
        #Remove-Item -Path $tempInstallDirectoryPath -Force -Confirm:$false
    } catch {
        throw $_
    }
}