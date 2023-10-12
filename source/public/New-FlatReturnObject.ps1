function New-FlatReturnObject {
    <#
    .SYNOPSIS
        Creates an new PSCustomObject from a Easit GO exported item.
    .DESCRIPTION
        **New-FlatReturnObject** creates a new "flat" PSCustomObject with all properties as members directly to the object.
        Non "flat" PSCustomObject: $myObject.property.GetEnumerator() | | Where-Object -Property Name -EQ -Value 'wantedProperty'
        "Flat" PSCustomObject: $myObject.wantedProperty

        "Hidden" properties added to the returned PSCustomObject are:

        * ObjectId
        * DatabaseId
        * PropertyObjects
        * propertyName_rawValue (one for each property)

        If a property occurs more than one time, the property value will be an array of all values with that name.
    .EXAMPLE
        try {
            New-FlatReturnObject -Object $exportObject.itemToImport[0]
        } catch {
            throw $_
        }
    .PARAMETER Object
        Object to be "flatten".
    .INPUTS
        None - You cannot pipe objects to this function
    .OUTPUTS
        [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
    #>
    [CmdletBinding(HelpUri='https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/newflatreturnobject/')]
    [OutputType([PSCustomObject])]
    [Alias('New-FlatGetItemsReturnObject')]
    param (
        [Parameter(Mandatory)]
        [Alias('Item')]
        [PSCustomObject]$Object
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        $tempHash = @{
            DatabaseId = $Object.id
            ObjectId = $Object.uid
            PropertyObjects = [System.Collections.Generic.List[PSCustomObject]]::new()
            Attachments = [System.Collections.Generic.List[PSCustomObject]]::new()
        }
        foreach ($property in $Object.property.GetEnumerator()){
            try {
                $tempHash.PropertyObjects.Add($property)
            } catch {
                throw $_
            }
            if ($tempHash."$($property.name)") {
                Write-Debug "Property $($property.name) already handled"
                continue
            } else {
                [string[]]$visible += $property.Name
            }
            try {
                $properties = $Object.property | Where-Object -Property Name -EQ -Value $property.name
            } catch {
                throw $_
            }
            if ($properties.Count -eq 1) {
                try {
                    $tempHash.Add($property.name,$property.content)
                    $tempHash.Add("$($property.name)_rawValue",$property.rawValue)
                } catch {
                    throw $_
                }
            }
            if ($properties.Count -gt 1) {
                $tempContentList = [System.Collections.Generic.List[String]]::new()
                $tempRawValueList = [System.Collections.Generic.List[String]]::new()
                foreach ($prop in $properties) {
                    try {
                        $tempContentList.Add("$($prop.content)")
                    } catch {
                        Write-Warning "Failed to add value for $($property.name) list"
                        continue
                    }
                    try {
                        $tempRawValueList.Add("$($prop.rawValue)")
                    } catch {
                        Write-Warning "Failed to add rawValue for $($property.name) list"
                        continue
                    }
                }
                try {
                    $tempHash.Add($property.name,$tempContentList)
                    $tempHash.Add("$($property.name)_rawValue",$tempRawValueList)
                } catch {
                    throw $_
                }
            }
        }
        foreach ($attachment in $Object.attachment.GetEnumerator()) {
            try {
                $tempHash.Attachments.Add($attachment)
            } catch {
                throw $_
            }
        }
        try {
            $returnObject = [pscustomobject]$tempHash
        } catch {
            throw $_
        }
        try {
            $type = 'DefaultDisplayPropertySet'
            [Management.Automation.PSMemberInfo[]]$info = New-Object System.Management.Automation.PSPropertySet($type,$visible)
            Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $info -InputObject $returnObject
        } catch {
            throw $_
        }
        $returnObject
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}