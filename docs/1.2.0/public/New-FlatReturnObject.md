# New-FlatReturnObject

## SYNOPSIS
Creates an new PSCustomObject from a Easit GO exported item.

## SYNTAX

```
New-FlatReturnObject [-Object] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
**New-FlatReturnObject** creates a new "flat" PSCustomObject with all properties as members directly to the object.
Non "flat" PSCustomObject: $myObject.property.GetEnumerator() | | Where-Object -Property Name -EQ -Value 'wantedProperty'
"Flat" PSCustomObject: $myObject.wantedProperty

"Hidden" properties added to the returned PSCustomObject are:

* ObjectId
* DatabaseId
* PropertyObjects
* propertyName_rawValue (one for each property)

If a property occurs more than one time, the property value will be an array of all values with that name.

## EXAMPLES

### EXAMPLE 1
```
try {
    New-FlatReturnObject -Object $exportObject.itemToImport[0]
} catch {
    throw $_
}
```

## PARAMETERS

### -Object
Object to be "flatten".

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Item

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

### [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
## NOTES

## RELATED LINKS
