[CmdletBinding()]
param (
    [string]$tag
)

begin {
    
}

process {
    Write-Host "tag = $tag"
    $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    Write-Host "repoRoot = $repoRoot"
    $sourceRoot = Join-Path $repoRoot -ChildPath 'source'
    Write-Host "sourceRoot = $sourceRoot"
}

end {
    
}