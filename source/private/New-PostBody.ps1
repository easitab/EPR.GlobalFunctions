function New-PostBody {
    <#
    .SYNOPSIS
        Function to create a "Easit GO" formatted body for web requests.
    .DESCRIPTION
        This functions takes a "settings object" as input and uses the settings there to create a json body that can be used with Invoke-RestMethod.
    .EXAMPLE
        PS> $body = New-PostBody -InstallerSettings $installerSettings
    .PARAMETER InstallerSettings
        Settings object holding a FeedbackSettings.postBody property with an array of properties and a importHandlerIdentifier.

        ```json
            "FeedbackSettings":{
                "postBody":{
                    "importHandlerIdentifier":"",
                    "properties":["Property1","Property2"]
                }
            }
        ```
    .INPUTS
        [PSCustomObject]
    .OUTPUTS
        JSON formatted string.
    #>
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$InstallerSettings
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
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
        $guid = (New-Guid) -replace '-',''
        $itemObject = [PSCustomObject]@{
            property = $propertiesArray
            id = $guid
            uid = $guid
        }
        $items += $itemObject
        $bodyObject = [PSCustomObject]@{
            importHandlerIdentifier = $InstallerSettings.FeedbackSettings.postBody.importHandlerIdentifier
            itemToImport = $items
        }
        try {
            $bodyObject | ConvertTo-Json -Depth 4
        } catch {
            throw $_
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}
