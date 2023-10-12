# ConvertFrom-Base64

## SYNOPSIS
Converts a base64 string to a UTF8 string

## SYNTAX

```
ConvertFrom-Base64 [-InputString] <String> [<CommonParameters>]
```

## DESCRIPTION
The **ConvertFrom-Base64** function converts a base64 string to a UTF8 string with the help of \[System.Convert\]::FromBase64String and \[System.Text.Encoding\]::UTF8.GetString.

## EXAMPLES

### EXAMPLE 1
```
$string = '{"importhandler":"myScript.ps1","itemToImport":{"property":[{"property1":"specialCharacters"}]}}'
$enc = [System.Text.Encoding]::UTF8
$stringBytes = $enc.GetBytes($string)
$base64String = [System.Convert]::ToBase64String($stringBytes)
ConvertFrom-Base64 -InputString $base64String
{"importhandler":"myScript.ps1","itemToImport":{"property":[{"property1":"specialCharacters"}]}}
```

## PARAMETERS

### -InputString
Base64 string to convert

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None - You cannot pipe objects to this function
## OUTPUTS

### [System.String](https://learn.microsoft.com/en-us/dotnet/api/system.string)
## NOTES

## RELATED LINKS
