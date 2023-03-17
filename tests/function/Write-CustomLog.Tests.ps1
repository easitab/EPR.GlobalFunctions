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
Describe "Write-CustomLog" -Tag 'function' {
    It 'should have a parameter named Message' {
        Get-Command "$commandName" | Should -HaveParameter Message
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter Message -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter Message -Type String
    }
    It 'should have a parameter named InputObject' {
        Get-Command "$commandName" | Should -HaveParameter InputObject
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter InputObject -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter InputObject -Type Object
    }
    It 'should have a parameter named Level' {
        Get-Command "$commandName" | Should -HaveParameter Level
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter Level -Not -Mandatory
    }
    It 'it accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter Level -Type String
    }
    It 'and have a default value = INFO' {
        Get-Command "$commandName" | Should -HaveParameter Level -DefaultValue INFO
    }
    It 'should have a parameter named OutputLevel' {
        Get-Command "$commandName" | Should -HaveParameter OutputLevel
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter OutputLevel -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter OutputLevel -Type String
    }
    It 'should have a parameter named LogName' {
        Get-Command "$commandName" | Should -HaveParameter LogName
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter LogName -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter LogName -Type String
    }
    It 'should have a parameter named LogDirectory' {
        Get-Command "$commandName" | Should -HaveParameter LogDirectory
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter LogDirectory -Not -Mandatory
    }
    It 'and accepts a string' {
        Get-Command "$commandName" | Should -HaveParameter LogDirectory -Type String
    }
    It 'should have a parameter named RotationInterval' {
        Get-Command "$commandName" | Should -HaveParameter RotationInterval
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter RotationInterval -Not -Mandatory
    }
    It 'and accepts an int' {
        Get-Command "$commandName" | Should -HaveParameter RotationInterval -Type Int
    }
    It 'should have a parameter named Rotate' {
        Get-Command "$commandName" | Should -HaveParameter Rotate
    }
    It 'that is not mandatory' {
        Get-Command "$commandName" | Should -HaveParameter Rotate -Not -Mandatory
    }
    It 'and accepts an int' {
        Get-Command "$commandName" | Should -HaveParameter Rotate -Type Switch
    }
}