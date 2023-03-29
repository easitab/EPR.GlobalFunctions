BeforeAll {
    $testFilePath = $PSCommandPath.Replace('.Tests.ps1','.ps1')
    $codeFileName = Split-Path -Path $testFilePath -Leaf
    $commandName = ((Split-Path -Leaf $PSCommandPath) -replace '.ps1','') -replace '.Tests', ''
    $testFunctionRoot = Split-Path -Path $PSCommandPath -Parent
    $testRoot = Split-Path -Path $testFunctionRoot -Parent
    $testDataRoot = Join-Path -Path "$testRoot" -ChildPath "data"
    $projectRoot = Split-Path -Path $testRoot -Parent
    $sourceRoot = Join-Path -Path "$projectRoot" -ChildPath "source"
    $codeFile = Get-ChildItem -Path "$sourceRoot" -Include "$codeFileName" -Recurse
    if (Test-Path $codeFile) {
        . $codeFile
    } else {
        Write-Output "Unable to locate code file ($codeFileName) to test against!" -ForegroundColor Red
    }
}
Describe "New-EPRInstallation" -Tag 'function' {
    It 'should have a parameter named InstanceID that is mandatory and accepts a string.' {
        Get-Command "$commandName" | Should -HaveParameter InstanceID -Mandatory -Type String
    }
    It 'should have a parameter named FromDirectory that is mandatory and accepts a string.' {
        Get-Command "$commandName" | Should -HaveParameter FromDirectory -Mandatory -Type String
    }
    It 'should have a parameter named InstallLocation that accepts a string.' {
        Get-Command "$commandName" | Should -HaveParameter InstallLocation -Type String
    }
    It 'should have a parameter named SystemName that accepts a string.' {
        Get-Command "$commandName" | Should -HaveParameter SystemName -Type String
    }
    It 'should have a parameter named Port that accepts a number.' {
        Get-Command "$commandName" | Should -HaveParameter Port -Type Int
    }
    It 'should have a parameter named TomcatXmx that accepts a number.' {
        Get-Command "$commandName" | Should -HaveParameter TomcatXmx -Type Int
    }
    It 'should have a parameter named IgnoreDirectoryStructure that is a switch' {
        Get-Command "$commandName" | Should -HaveParameter IgnoreDirectoryStructure -Type Switch
    }
    It 'should have a parameter named DoNotSendInstallationDetailsToEasit that is a switch' {
        Get-Command "$commandName" | Should -HaveParameter DoNotSendInstallationDetailsToEasit -Type Switch
    }
}