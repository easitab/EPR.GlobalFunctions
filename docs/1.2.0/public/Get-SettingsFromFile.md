# Get-SettingsFromFile

## SYNOPSIS
Get settings for script

## SYNTAX

```
Get-SettingsFromFile [[-Filename] <String>] [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
The *Get-SettingsFromFile* function looks for a file named *globalSettings.json*, a file named *scriptName.json* and for a object in *globalSettings.json* with same name as the scriptfile invoking the function and returns a PSCustomObject with the combined settings.

If the same setting is found in multiple places the following priority is used:
1.
Scriptnamed object in *globalSettings.json*.
2.
*scriptName.json*.
3.
Global object in *globalSettings.json*.

Before returning the PSCustomObject all settings values are matched against the string '__globalValue__'.
If there is a match the value for the global settings with the same name will be used.

## EXAMPLES

### EXAMPLE 1
```
Get-SettingsFromFile
```

In this example we are using the function in a scriptfile named testService.ps1.
All settings from 'testService.json' (if exist) and the testService object in 'globalSettings' will be added to the returning PSCustomObject.

## PARAMETERS

### -Filename
Name of file containing script specific settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to directory where settings files are located.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-SettingsFromFile
## OUTPUTS

### [PSCustomObject](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pscustomobject)
## NOTES

## RELATED LINKS
