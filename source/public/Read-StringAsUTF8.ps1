function Read-StringAsUTF8 {
    <#
    .SYNOPSIS
        Read a string and return it decoded as UTF-8.
    .DESCRIPTION
        *Read-StringAsUTF8* uses the UTF8Encoding class to return a string decoded in UTF8.
        The function uses UTF8Encoding.GetBytes to encode the input string into a sequence of bytes and then UTF8Encoding.GetString to decodes the byte array into a string.
    .EXAMPLE
        $decodedStringInput = Read-StringAsUTF8 -InputString $StringInput
        $exportObject = $decodedStringInput | ConvertFrom-Json
        $EasitGOItem = $exportObject.itemToImport[0]
        $EasitGOItem.property
        content                                       name            rawValue
        -------                                       ----            --------
        Jane                                          givenName
        jado                                          samAccountName
        CN=Doe\, Jane,OU=Users,DC=company,DC=net      dn
    .PARAMETER InputString
        String to decode as UTF8
    .OUTPUTS
        [System.String](https://learn.microsoft.com/en-us/dotnet/api/system.string)
    #>
    [CmdletBinding(HelpUri='https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/readstringasutf8/')]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory,Position=0)]
        [String]$InputString
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) start"
    }
    process {
        $enc = [System.Text.Encoding]::UTF8
        try {
            $stringBytes = $enc.GetBytes($InputString)
        } catch {
            throw $_
        }
        try {
            [System.Text.Encoding]::UTF8.GetString($stringBytes)
        } catch {
            throw $_
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}