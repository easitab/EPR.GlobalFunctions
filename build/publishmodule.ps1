[CmdletBinding()]
param (
    [Parameter()]
    [string]$CompanyName,
    [Parameter()]
    [string]$ModuleName,
    [Parameter()]
    [string]$Tag,
    [Parameter()]
    [string]$PSGalleryKey,
    [Parameter()]
    [string]$GitHubBaseURI,
    [Parameter()]
    [string]$TechspaceBaseURI,
    [Parameter()]
    [string]$ModuleDescription,
    [Parameter()]
    [string]$ModulePSVersion,
    [Parameter()]
    [string]$ModuleAuthor,
    [Parameter()]
    [string]$Copyright
)

begin {
    Write-Host "Publish module script start"
}

process {
    Write-Host "CompanyName = $CompanyName, ModuleName = $ModuleName"
    return
    $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    $sourceRoot = Join-Path $repoRoot -ChildPath 'source'
    $tempBuildDirectory = Join-Path $repoRoot -ChildPath 'temp'
    if (Test-Path -Path $tempBuildDirectory) {
        try {
            Get-ChildItem -Path $tempBuildDirectory -Recurse -ErrorAction Stop | Remove-Item -Confirm:$false -Recurse -ErrorAction Stop
        } catch {
            Write-Warning "Unable to clean $tempBuildDirectory"
            throw $_
        }
    }
    if (!(Test-Path -Path $sourceRoot)) {
        throw "Cannot find $sourceRoot"
    }
    try {
        $allScripts = Get-ChildItem -Path "$sourceRoot" -Filter "*.ps1" -Recurse -ErrorAction Stop
    } catch {
        throw $_
    }
    if (!$allScripts) {
        throw "No scripts or functions found"
    }
    $moduleRoot = New-Item -Path $tempBuildDirectory -Name $ModuleName -ItemType Directory
    $psm1 = New-Item -Path $moduleRoot -Name "$ModuleName.psm1" -ItemType File
    Write-Host "Generating new psm1"
    foreach ($script in $allScripts) {
        $scriptContent = $null
        try {
            $scriptContent = Get-Content -Path $script.FullName -Raw
        } catch {
            Write-Warning "Failed to get content from $($script.FullName)"
            throw $_
        }
        try {
            Add-Content -Path $psm1 -Value $scriptContent
        } catch {
            Write-Warning "Failed to add content to $($psm1.FullName)"
            throw $_
        }
    }
    $manifestFilePath = Join-Path -Path "$moduleRoot" -ChildPath "$ModuleName.psd1"
    $manifest = @{
        Path              = "$manifestFilePath"
        RootModule        = "$moduleName.psm1"
        CompanyName       = "$CompanyName"
        Author            = "$ModuleAuthor"
        ModuleVersion     = "$Tag"
        HelpInfoUri       = "$TechspaceBaseURI/easitgo/powershellmodules/intro/"
        LicenseUri        = "$GitHubBaseURI/$ModuleName/blob/main/LICENSE"
        ProjectUri        = "$GitHubBaseURI/$ModuleName"
        Description       = "$ModuleDescription"
        PowerShellVersion = "$ModulePSVersion"
        Copyright         = "$Copyright"
    }
    try {
        Write-Host "Creating new module manifest"
        New-ModuleManifest @manifest -ErrorAction Stop | Out-Null
    } catch {
        Write-Warning "Failed to create new module manifest"
        throw $_
    }
    if (Test-ModuleManifest -Path "$manifestFilePath") {
        Write-Host "Publishing module to PSGallery"
        Publish-Module -Path "$moduleRoot" -NuGetApiKey "$PSGalleryKey"
        Write-Host "Module published!"
    }
}

end {
    Write-Host "Publish module script end"
}