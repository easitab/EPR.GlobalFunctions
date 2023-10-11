function Convert-EasitGOExportString {
    <#
    .SYNOPSIS
        Converts a string to a PSCustomObject
    .DESCRIPTION
        The **Convert-EasitGOExportString** function can be used to convert the exported payload from Easit GO to a PSCustomObject.
        The function starts by checking if the input is a json string or not, and if not is assumes that the input is a base64 string.

        By using *ConvertFrom-Json* the string is converted to a PSCustomObject.

        If -Raw is used, the object is returned.
        If -Raw is NOT used, *[New-FlatReturnObject](https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/newflatreturnobject/)* is called to "flatten" the object.
    .EXAMPLE
        Convert-EasitGOExportString -InputString $Base64StringFromStdIn
    .EXAMPLE
        Convert-EasitGOExportString -InputString $Base64StringFromStdIn -Raw
    .EXAMPLE
        Convert-EasitGOExportString -InputString $jsonString
    .EXAMPLE
        Convert-EasitGOExportString -InputString $jsonString -Raw
    .PARAMETER InputString
        String to convert to a PSCustomObject
    .PARAMETER Raw
        Specifies if the PSCustomObject should be "flatten" before returned
    .INPUTS
        None - You cannot pipe objects to this function
    .OUTPUTS
        [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
    #>
    [CmdletBinding(HelpUri='https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/converteasitgoexportstring/')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [String]$InputString,
        [Parameter()]
        [Switch]$Raw
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        if ($InputString -match '^\{') {
            try {
                $decodedString = $InputString
            } catch {
                throw $_
            }
        } else {
            try {
                $decodedString = ConvertFrom-Base64 -InputString $InputString
            } catch {
                throw $_
            }
        }
        try {
            $rawEasitGOObject = $decodedString | ConvertFrom-Json
        } catch {
            throw $_
        }
        if ($Raw) {
            return $rawEasitGOObject
        } else {
            try {
                New-FlatReturnObject -Object $rawEasitGOObject.itemToImport[0]
            } catch {
                throw $_
            }
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}