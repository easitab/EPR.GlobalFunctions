function ConvertTo-Hashtable {
    <#
    .SYNOPSIS
        Creates a hashtable from a PSCustomObject
    .DESCRIPTION
        The **ConvertTo-Hashtable** function creates a hashtable containing all members of type *\*Property* from a PSCustomObject.
    .EXAMPLE
        $myPSObject = [pscustomobject]@{property1="value1";property2="value2"}
        $myPSObject | ConvertTo-Hashtable
        Name                           Value
        ----                           -----
        property1                      value1
        property2                      value2
    .EXAMPLE
        $myPSObject = [pscustomobject]@{property1="value1";property2="value2"}
        ($myPSObject | ConvertTo-Hashtable).GetType()
        IsPublic IsSerial Name                                     BaseType
        -------- -------- ----                                     --------
        True     True     Hashtable                                System.Object
    .PARAMETER InputObject
        Object to create a hashtable from
    .INPUTS
        [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
    .OUTPUTS
        [Hashtable](https://learn.microsoft.com/en-us/dotnet/api/system.collections.hashtable)
    #>
    [CmdletBinding(HelpUri='https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/converttohashtable/')]
    [OutputType([Hashtable])]
    [Alias('Convert-ObjectToHashTable')]
    param (
        [Alias('Object')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$InputObject
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        $hashTable = @{}
        $objectMembers = Get-Member -InputObject $InputObject -MemberType *Property
        foreach ($member in $objectMembers) {
            $hashTable.$($member.Name) = $InputObject.$($member.Name)
        }
        return $hashTable
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}