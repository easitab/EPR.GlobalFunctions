[CmdletBinding()]
param (
    [Parameter()]
    [string]$ModuleName = 'Easit.ProcessRunner.GlobalFunctions',
    [Parameter(Mandatory)]
    [string]$Tag
)
begin {
    $InformationPreference = 'Continue'
    Write-Information "Script start"
}
process {
    try {
        Install-Module -Name 'platyPS' -Scope CurrentUser -Force -ErrorAction Stop
        Import-Module 'platyPS' -Force -ErrorAction Stop
    } catch {
        throw $_
    }
    $repoDirectory = Split-Path -Path $PSScriptRoot -Parent
    $sourceDirectory = Join-Path -Path $repoDirectory -ChildPath 'source'
    $sourcePrivateDirectory = Join-Path -Path $sourceDirectory -ChildPath 'private'
    $sourcePublicDirectory = Join-Path -Path $sourceDirectory -ChildPath 'public'
    $publishedModulesDirectory = Join-Path -Path $repoDirectory -ChildPath 'publishedModules'
    if (Test-Path -Path $publishedModulesDirectory) {
        Write-Information "$publishedModulesDirectory already exist"
    } else {
        $null = New-Item -Path $repoDirectory -Name 'publishedModules' -ItemType Directory
        Write-Information "Created $publishedModulesDirectory"
    }
    $publishedModuleTagDirectory = Join-Path -Path $publishedModulesDirectory -ChildPath $Tag
    if (Test-Path -Path $publishedModuleTagDirectory) {
        try {
            Write-Information "Cleaning files in $publishedModuleTagDirectory"
            Get-ChildItem -Path $publishedModuleTagDirectory -Recurse -File -Force | Remove-Item -Confirm:$false -Force
            Write-Information "Cleaning folders in $publishedModuleTagDirectory"
            Get-ChildItem -Path $publishedModuleTagDirectory -Recurse -Directory | Remove-Item -Confirm:$false
        } catch {
            throw $_
        }
    } else {
        try {
            $null = New-Item -Path $publishedModulesDirectory -Name $Tag -ItemType Directory
        } catch {
            throw $_
        }
    }
    try {
        Write-Information "Saving module $ModuleName (Version: $Tag) to $publishedModulesDirectory"
        $null = Save-Module -Name $ModuleName -MinimumVersion $Tag -Path $publishedModulesDirectory -ErrorAction Stop
    } catch {
        throw $_
    }
    if (Test-Path -Path $publishedModulesDirectory) {
        try {
            Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
            Write-Information "Importing module to session"
            Import-Module -Name (Join-Path -Path $publishedModulesDirectory -ChildPath $ModuleName) -MinimumVersion $Tag -Force -ErrorAction Stop
        } catch {
            throw $_
        }
    } else {
        throw "$publishedModulesDirectory does not exists"
    }
    $docsDirectory = Join-Path -Path $repoDirectory -ChildPath 'docs'
    if (Test-Path -Path $docsDirectory) {
        Write-Information "$docsDirectory already exist"
    } else {
        try {
            Write-Information "Creating $docsDirectory"
            $null = New-Item -Path $repoDirectory -Name 'docs' -ItemType Directory
        } catch {
            throw $_
        }
    }
    $tagDocsDirectory = Join-Path -Path $docsDirectory -ChildPath $Tag
    if (Test-Path -Path $tagDocsDirectory) {
        try {
            Write-Information "Cleaning files in $tagDocsDirectory"
            Get-ChildItem -Path $tagDocsDirectory -Recurse -File | Remove-Item -Confirm:$false
            Write-Information "Cleaning folders in $tagDocsDirectory"
            Get-ChildItem -Path $tagDocsDirectory -Recurse -Directory | Remove-Item -Confirm:$false
        } catch {
            Write-Warning "Unable to clean $tagDocsDirectory"
            throw $_
        }
    }
    try {
        Write-Information "Generating markdown help for module $ModuleName to $tagDocsDirectory"
        $nmh = @{
            Module = $ModuleName
            OutputFolder = $tagDocsDirectory
            Force = $true
            NoMetadata = $true
            AlphabeticParamsOrder = $true
        }
        $null = New-MarkdownHelp @nmh
    } catch {
        throw $_
    }
    $privateFunctions = Get-ChildItem -Path $sourcePrivateDirectory -Recurse -File
    $nmh.Remove('Module')
    $nmh.Add('Command',$null)
    foreach ($privateFunction in $privateFunctions) {
        $nmh.Command = $privateFunction.BaseName
        try {
            $null = New-MarkdownHelp @nmh
        } catch {
            throw $_
        }
    }
    $privateDocsDirectory = Join-Path -Path $tagDocsDirectory -ChildPath 'private'
    if (Test-Path -Path $privateDocsDirectory) {
        Get-ChildItem -Path $privateDocsDirectory -Recurse -File | Remove-Item -Confirm:$false
    } else {
        $null = New-Item -Path $tagDocsDirectory -Name 'private' -ItemType Directory
    }
    Write-Information "Moving markdown files from $tagDocsDirectory to $privateDocsDirectory"
    foreach ($privateFunction in $privateFunctions) {
        $privateMDFile = Get-ChildItem -Path $tagDocsDirectory -Recurse -Include "$($privateFunction.BaseName).md"
        if ($privateMDFile) {
            try {
                Move-Item -Path $privateMDFile.FullName -Destination $privateDocsDirectory
            } catch {
                throw $_
            }
        } else {
            Write-Warning "Unable to find $($privateFunction.BaseName).md"
        }
    }
    $publicDocsDirectory = Join-Path -Path $tagDocsDirectory -ChildPath 'public'
    if (Test-Path -Path $publicDocsDirectory) {
        Get-ChildItem -Path $publicDocsDirectory -Recurse -File | Remove-Item -Confirm:$false
    } else {
        $null = New-Item -Path $tagDocsDirectory -Name 'public' -ItemType Directory
    }
    $publicFunctions = Get-ChildItem -Path $sourcePublicDirectory -Recurse -File
    Write-Information "Moving markdown files from $tagDocsDirectory to $publicDocsDirectory"
    foreach ($publicFunction in $publicFunctions) {
        $publicMDFile = Get-ChildItem -Path $tagDocsDirectory -Recurse -Include "$($publicFunction.BaseName).md"
        if ($publicMDFile) {
            try {
                Move-Item -Path $publicMDFile.FullName -Destination $publicDocsDirectory
            } catch {
                throw $_
            }
        } else {
            Write-Warning "Unable to find $($publicFunction.BaseName).md"
        }
    }
    $savedModulePath = Join-Path -Path $publishedModulesDirectory -ChildPath $ModuleName
    $savedVersionModulePath = Join-Path -Path $savedModulePath -ChildPath $Tag
    try {
        Get-ChildItem -Path $savedVersionModulePath -Recurse -File -Force | Copy-Item -Destination $publishedModuleTagDirectory -Force
    } catch {
        throw $_
    }
    try {
        Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $savedModulePath -Confirm:$false -Recurse -Force
    } catch {
        throw $_
    }
    Write-Information "Module documentation for release complete"
}
end {
    Write-Information "Script end"
}