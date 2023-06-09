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
    function Write-CustomLog {
        [CmdletBinding()]
        Param (
            [Parameter(ValueFromPipeline,ParameterSetName='string')]
            [string]$Message,
            [Parameter(ValueFromPipeline,ParameterSetName='object')]
            [object]$InputObject,
            [Parameter()]
            [string]$Level
        )
    }
    if (Test-Path $codeFile) {
        . $codeFile
    } else {
        Write-Output "Unable to locate code file ($codeFileName) to test against!" -ForegroundColor Red
    }
}
Describe "Get-SettingsFromFile" -Tag 'function' {
    It 'should have a parameter named Filename' {
        Get-Command "$commandName" | Should -HaveParameter Filename
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter Filename -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter Filename -Type String
    }
    It 'should have a parameter named Path' {
        Get-Command "$commandName" | Should -HaveParameter Path
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter Path -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter Path -Type String
    }
    It 'should return a PSCustomObjec' {
        Get-SettingsFromFile -Filename 'Get-SettingsFromFile' -Path $testDataRoot | Should -BeOfType PSCustomObject
    }
}