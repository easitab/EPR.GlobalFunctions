# Read-StringAsUTF8

## SYNOPSIS
Read a string and return it decoded as UTF-8.

## SYNTAX

```
Read-StringAsUTF8 [-InputString] <String> [<CommonParameters>]
```

## DESCRIPTION
**Read-StringAsUTF8** uses the UTF8Encoding class to return a string decoded in UTF8.
The function uses UTF8Encoding.GetBytes to encode the input string into a sequence of bytes and then UTF8Encoding.GetString to decodes the byte array into a string.

## EXAMPLES

### EXAMPLE 1
```
$decodedStringInput = Read-StringAsUTF8 -InputString $StringInput
$exportObject = $decodedStringInput | ConvertFrom-Json
$EasitGOItem = $exportObject.itemToImport[0]
$EasitGOItem.property
content                                       name            rawValue
-------                                       ----            --------
Jane                                          givenName
jado                                          samAccountName
CN=Doe\, Jane,OU=Users,DC=company,DC=net      dn
```

## PARAMETERS

### -InputString
String to decode as UTF8

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
