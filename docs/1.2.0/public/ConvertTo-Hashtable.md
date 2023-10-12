# ConvertTo-Hashtable

## SYNOPSIS
Creates a hashtable from a PSCustomObject

## SYNTAX

```
ConvertTo-Hashtable [-InputObject] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
The **ConvertTo-Hashtable** function creates a hashtable containing all members of type *\*Property* from a PSCustomObject.

## EXAMPLES

### EXAMPLE 1
```
$myPSObject = [pscustomobject]@{property1="value1";property2="value2"}
$myPSObject | ConvertTo-Hashtable
Name                           Value
----                           -----
property1                      value1
property2                      value2
```

### EXAMPLE 2
```
$myPSObject = [pscustomobject]@{property1="value1";property2="value2"}
($myPSObject | ConvertTo-Hashtable).GetType()
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Hashtable                                System.Object
```

## PARAMETERS

### -InputObject
Object to create a hashtable from

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Object

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
## OUTPUTS

### [Hashtable](https://learn.microsoft.com/en-us/dotnet/api/system.collections.hashtable)
## NOTES

## RELATED LINKS
