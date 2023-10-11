---
external help file: EPR.GlobalFunctions-help.xml
Module Name: EPR.GlobalFunctions
online version:
schema: 2.0.0
---

# Convert-OUString

## SYNOPSIS
Converts a DN string to a PSCustomObject or hashtable.

## SYNTAX

```
Convert-OUString [-OUString] <String> [-AsPSCustomObject] [<CommonParameters>]
```

## DESCRIPTION
The *Convert-OUString* function takes a string and splits it according to the specification of an LDAP DN as contained in RFC 4514.
Each RDN (name-value pair) is added to the returning object with nameNumber as name and value as the value.

The DN 'uid=johnDoe,ou=People,dc=example,dc=com' will result in a PSCustomObject or hashtable with following properties and values.

- dc1 : com
- dc2 : example
- ou1 : People
- uid1 : johnDoe
- OUPath : ou=People,dc=example,dc=com

The *Convert-OUString* function also adds a property named 'OUPath' with the full DN up to the last (when reading from right to left) RDN.

## EXAMPLES

### EXAMPLE 1
```
Convert-OUString -OUString "uid=john.doe,ou=People,dc=example,dc=com"
Name                           Value
----                           -----
OUPath                         ou=People,dc=example,dc=com
dc1                            com
dc2                            example
ou1                            People
uid1                           john.doe
```

In this example we are converting a DN to a hashtable.

### EXAMPLE 2
```
Convert-OUString -OUString "uid=john.doe,ou=People,dc=example,dc=com" -AsPSCustomObject
OUPath : ou=People,dc=example,dc=com
dc1    : com
dc2    : example
ou1    : People
uid1   : john.doe
```

In this example we are converting a DN to a PSCustomObject.

## PARAMETERS

### -OUString
String to convert

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

### -AsPSCustomObject
Tells the function to return a PSCustomObject instead of a hashtable

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

### None. You cannot pipe objects to Convert-OUString.
## OUTPUTS

### [PSCustomObject]
### [hashtable]
## NOTES

## RELATED LINKS
