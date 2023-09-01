[CmdletBinding()]
param (
    [Parameter()]
    [string]$ModuleName = 'Easit.ProcessRunner.GlobalFunctions',
    [Parameter()]
    [string]$Tag = '9.9.9'
)
begin {
    $InformationPreference = 'Continue'
    Write-Information "Script start"
}
process {
    try {
        Write-Information "Installing and importing required modules"
        Install-Module -Name 'platyPS' -Scope CurrentUser -Force -ErrorAction Stop
        Import-Module 'platyPS' -Force -ErrorAction Stop
    } catch {
        throw $_
    }
    try {
        $repoDirectory = Split-Path -Path $PSScriptRoot -Parent
    } catch {
        Write-Warning "Unable to set repoDirectory"
        throw $_
    }
    try {
        $sourceDirectory = Join-Path -Path $repoDirectory -ChildPath 'source'
    } catch {
        Write-Warning "Unable to set sourceDirectory"
        throw $_
    }
    if (!(Test-Path -Path $sourceDirectory)) {
        throw "Cannot find $sourceDirectory"
    }
    try {
        $tempBuildDirectory = Join-Path $repoDirectory -ChildPath 'local_temp'
    } catch {
        Write-Warning "Unable to set tempBuildDirectory"
        throw $_
    }
    if (Test-Path -Path $tempBuildDirectory) {
        try {
            Write-Information "Cleaning $tempBuildDirectory"
            Get-ChildItem -Path $tempBuildDirectory -Recurse -ErrorAction Stop | Remove-Item -Confirm:$false -Recurse -ErrorAction Stop
        } catch {
            Write-Warning "Unable to clean $tempBuildDirectory"
            throw $_
        }
    } else {
        try {
            Write-Information "Creating $tempBuildDirectory"
            $null = New-Item -Path $repoDirectory -Name 'temp' -ItemType Directory
        } catch {
            throw $_
        }
    }
    try {
        $privateFunctions = Get-ChildItem -Path (Join-Path -Path "$sourceDirectory" -ChildPath 'private') -Filter "*.ps1" -Recurse -ErrorAction Stop
        $publicFunctions = Get-ChildItem -Path (Join-Path -Path "$sourceDirectory" -ChildPath 'public') -Filter "*.ps1" -Recurse -ErrorAction Stop
    } catch {
        Write-Warning "Unable to get all classes and functions"
        throw $_
    }
    if (!$privateFunctions -and $publicFunctions) {
        throw "No functions or classes found"
    }
    try {
        $moduleRoot = New-Item -Path $tempBuildDirectory -Name $ModuleName -ItemType Directory
        $psm1 = New-Item -Path $moduleRoot -Name "$ModuleName.psm1" -ItemType File
    } catch {
        throw $_
    }
    Write-Information "Generating new psm1"
    foreach ($privateFunction in $privateFunctions) {
        $fileContent = $null
        try {
            $fileContent = Get-Content -Path $privateFunction.FullName -Raw
        } catch {
            Write-Warning "Failed to get content from $($privateFunction.FullName)"
            throw $_
        }
        try {
            Add-Content -Path $psm1 -Value $fileContent
        } catch {
            Write-Warning "Failed to add content to $($psm1.FullName)"
            throw $_
        }
    }
    foreach ($publicFunction in $publicFunctions) {
        $fileContent = $null
        try {
            $fileContent = Get-Content -Path $publicFunction.FullName -Raw
        } catch {
            Write-Warning "Failed to get content from $($publicFunction.FullName)"
            throw $_
        }
        try {
            Add-Content -Path $psm1 -Value $fileContent
        } catch {
            Write-Warning "Failed to add content to $($psm1.FullName)"
            throw $_
        }
    }
    Write-Information "New psm1 generated"
}
end {
    Write-Information "Script end"
}