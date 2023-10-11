function Convert-OUString {
    <#
    .SYNOPSIS
        Converts a DN string to a PSCustomObject or hashtable.
    .DESCRIPTION
        The *Convert-OUString* function takes a string and splits it according to the specification of an LDAP DN as contained in RFC 4514.
        Each RDN (name-value pair) is added to the returning object with nameNumber as name and value as the value.

        The DN 'uid=johnDoe,ou=People,dc=example,dc=com' will result in a PSCustomObject or hashtable with following properties and values.

        - dc1 : com
        - dc2 : example
        - ou1 : People
        - uid1 : johnDoe
        - OUPath : ou=People,dc=example,dc=com

        The *Convert-OUString* function also adds a property named 'OUPath' with the full DN up to the last (when reading from right to left) RDN.
    .PARAMETER OUString
        String to convert
    .PARAMETER AsPSCustomObject
        Tells the function to return a PSCustomObject instead of a hashtable
    .EXAMPLE
        Convert-OUString -OUString "uid=john.doe,ou=People,dc=example,dc=com"
        Name                           Value
        ----                           -----
        OUPath                         ou=People,dc=example,dc=com
        dc1                            com
        dc2                            example
        ou1                            People
        uid1                           john.doe

        In this example we are converting a DN to a hashtable.
    .EXAMPLE
        Convert-OUString -OUString "uid=john.doe,ou=People,dc=example,dc=com" -AsPSCustomObject
        OUPath : ou=People,dc=example,dc=com
        dc1    : com
        dc2    : example
        ou1    : People
        uid1   : john.doe

        In this example we are converting a DN to a PSCustomObject.
    .INPUTS
        None. You cannot pipe objects to Convert-OUString.
    .OUTPUTS
        [PSCustomObject]

        [hashtable]
    #>
    [CmdletBinding(HelpUri='https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/convertoustring/')]
    [OutputType([PSCustomObject],[hashtable])]
    param (
        [Parameter(Mandatory)]
        [string]$OUString,
        [Parameter()]
        [switch]$AsPSCustomObject
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        $returnHashtable = [ordered]@{}
        $fullOU = $OUString -replace '^.+?(?<!\\),',''
        $returnHashtable.Add("OUPath","$fullOU")
        if ($OUString -match '\\,') {
            $OUString = $OUString -replace '\\,',''
            $escapeCharacterInCN = $true
        }
        do {
            #$Matches = $null
            $null = $OUString -match ',?([A-Za-z]{2,3})=([a-zA-Z0-9-_\.\s]*)$'
            try {
                $levelName = $Matches[1]
                $levelValue = $Matches[2]
            } catch{
                throw $_
            }
            if ($levelName -eq 'CN' -or $levelName -eq 'uid') {
                if ($escapeCharacterInCN) {
                    $newLevelValue = $levelValue -replace ' ','\, '
                } else {
                    $newLevelValue = $levelValue
                }
            }
            $level = 1
            $levelKeyName = "${levelName}${level}"
            if ($returnHashTable."$levelKeyName") {
                do {
                    $level++
                    $levelKeyName = "${levelName}${level}"
                } while ($returnHashTable."$levelKeyName")
            }
            if ($levelName -eq 'CN') {
                $returnHashtable.Add("$levelKeyName","$newLevelValue")
            } else {
                $returnHashtable.Add("$levelKeyName","$levelValue")
            }
            $OUString = $OUString -replace "${levelName}=${levelValue}",""
            $OUString = $OUString.TrimEnd(",")
        } while (!([string]::IsNullOrEmpty($OUString)))
        if ($AsPSCustomObject) {
            [pscustomobject]$returnHashtable
        } else {
            $returnHashtable
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}