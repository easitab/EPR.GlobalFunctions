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
Describe "Convert-OUString" -Tag 'function' {
    It 'should have a parameter named OUString that is mandatory and accepts a string.' {
        Get-Command "$commandName" | Should -HaveParameter OUString -Mandatory -Type String
    }
    It 'should have a parameter named AsPSCustomObject that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter AsPSCustomObject -Not -Mandatory
    }
    It 'and is a switch.' {
        Get-Command "$commandName" | Should -HaveParameter AsPSCustomObject -Type 'Switch'
    }
    It 'should return a OrderedDictionary (ordered hashtable) by default.' {
        Convert-OUString -OUString 'uid=johnDoe,ou=People,dc=example,dc=com' | Should -BeOfType 'System.Collections.Specialized.OrderedDictionary'
    }
    It 'should return a AsPSCustomObject when switch is provided.' {
        Convert-OUString -OUString 'uid=johnDoe,ou=People,dc=example,dc=com' -AsPSCustomObject | Should -BeOfType PSCustomObject
    }
}