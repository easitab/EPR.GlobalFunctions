# Convert-EasitGOExportString

## SYNOPSIS
Converts a string to a PSCustomObject

## SYNTAX

```
Convert-EasitGOExportString [-InputString] <String> [-Raw] [<CommonParameters>]
```

## DESCRIPTION
The **Convert-EasitGOExportString** function can be used to convert the exported payload from Easit GO to a PSCustomObject.
The function starts by checking if the input is a json string or not, and if not is assumes that the input is a base64 string.

By using *ConvertFrom-Json* the string is converted to a PSCustomObject.

If -Raw is used, the object is returned.
If -Raw is NOT used, *\[New-FlatReturnObject\](https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/newflatreturnobject/)* is called to "flatten" the object.

## EXAMPLES

### EXAMPLE 1
```
Convert-EasitGOExportString -InputString $Base64StringFromStdIn
```

### EXAMPLE 2
```
Convert-EasitGOExportString -InputString $Base64StringFromStdIn -Raw
```

### EXAMPLE 3
```
Convert-EasitGOExportString -InputString $jsonString
```

### EXAMPLE 4
```
Convert-EasitGOExportString -InputString $jsonString -Raw
```

## PARAMETERS

### -InputString
String to convert to a PSCustomObject

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

### -Raw
Specifies if the PSCustomObject should be "flatten" before returned

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None - You cannot pipe objects to this function
## OUTPUTS

### [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
## NOTES

## RELATED LINKS
