function ConvertFrom-Base64 {
    <#
    .SYNOPSIS
        Converts a base64 string to a UTF8 string
    .DESCRIPTION
        The **ConvertFrom-Base64** function converts a base64 string to a UTF8 string with the help of [System.Convert]::FromBase64String and [System.Text.Encoding]::UTF8.GetString.
    .EXAMPLE
        $string = '{"importhandler":"myScript.ps1","itemToImport":{"property":[{"property1":"specialCharacters"}]}}'
        $enc = [System.Text.Encoding]::UTF8
        $stringBytes = $enc.GetBytes($string)
        $base64String = [System.Convert]::ToBase64String($stringBytes)
        ConvertFrom-Base64 -InputString $base64String
        {"importhandler":"myScript.ps1","itemToImport":{"property":[{"property1":"specialCharacters"}]}}
    .PARAMETER InputString
        Base64 string to convert
    .INPUTS
        None - You cannot pipe objects to this function
    .OUTPUTS
        [System.String](https://learn.microsoft.com/en-us/dotnet/api/system.string)
    #>
    [CmdletBinding(HelpUri = 'https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/convertfrombase64/')]
    [Alias('Convert-FromBase64ToUtf8')]
    param (
        [Parameter(Mandatory)]
        [String]$InputString
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) begin"
    }
    process {
        if ([String]::IsNullOrWhiteSpace($InputString) -or [String]::IsNullOrEmpty($InputString)) {
            throw "InputString is null, empty or whitespace"
        }
        try {
            $byteArray = [System.Convert]::FromBase64String($InputString)
        } catch {
            throw $_
        }
        if ($byteArray) {
            try {
                $ut8String = [System.Text.Encoding]::UTF8.GetString($byteArray)
            } catch {
                throw $_
            }
        } else {
            throw "Failed to convert base64 string to byte array"
        }
        if ($ut8String) {
            return $ut8String
        } else {
            throw "Failed to get UTF8 string from byte array"
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}