function New-PostBody {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$InstallerSettings
    )
    
    begin {
        
    }
    
    process {
        $items = @()
        $propertiesArray = @()
        foreach ($prop in $InstallerSettings.FeedbackSettings.postBody.properties) {
            $propObject = [PSCustomObject]@{
                name = "$prop"
                content = $InstallerSettings."$prop"
            }
            $propertiesArray += $propObject
        }
        $itemObject = [PSCustomObject]@{
            property = $propertiesArray
        }
        $items += $itemObject
        $bodyObject = [PSCustomObject]@{
            importHandlerIdentifier = $InstallerSettings.FeedbackSettings.postBody.importHandlerIdentifier
            itemToImportObject = $items
        }
        try {
            $bodyObject | ConvertTo-Json -Depth 4
        } catch {
            throw $_
        }
    }
    
    end {
        
    }
}