function New-PostBody {
    <#
    .SYNOPSIS
        Function to create a "Easit GO" formatted body for web requests.
    .DESCRIPTION
        This functions takes a "settings object" as input and uses the settings there to create a json body that can be used with Invoke-RestMethod.
    .EXAMPLE
        New-PostBody -InstallerSettings $installerSettings
        {
            "importHandlerIdentifier": "",
            "itemToImport": [
                {
                    "property": [
                        {
                            "name": "Property1",
                            "content": null
                        },
                        {
                            "name": "Property2",
                            "content": null
                        }
                    ],
                    "id": "b04cf69223604fa58a03500a3d78002f",
                    "uid": "b04cf69223604fa58a03500a3d78002f"
                }
            ]
        }
    .EXAMPLE
        $body = New-PostBody -InstallerSettings $installerSettings
        $restParams = @{
            Method = 'POST'
            Uri = 'https://urltoEasitGO.com/integration-api/items'
            Body = $body
            TimeoutSec = 30
            ContentType = "application/json"
            Headers = $headers
        }
        Invoke-RestMethod @restParams
    .PARAMETER InstallerSettings
        Settings object holding a FeedbackSettings.postBody property with an array of properties and a importHandlerIdentifier.
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
        if ($PSCmdlet.MyInvocation.MyCommand.Name -ne 'New-EPRInstallation') {
            Write-Warning "This function should only be used (by 'New-EPRInstallation') when installing a new instance of ProcessRunner. Please use 'Easit.GO.Webservice' for posting data to Easit GO."
        }
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
