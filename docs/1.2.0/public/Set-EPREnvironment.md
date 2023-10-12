# Set-EPREnvironment

## SYNOPSIS
Sets a number of new variables in the script scope.

## SYNTAX

```
Set-EPREnvironment [[-Modules] <String[]>] [[-CustomModules] <String[]>] [-IncludeOldVariableNames]
 [<CommonParameters>]
```

## DESCRIPTION
By running this function in the beginning of your script the following variables will be made available:

- epr_Directory
- epr_logsDirectory
- epr_scriptsDirectory
- epr_scriptSettingsDirectory
- epr_scriptHelpersDirectory
- epr_modulesDirectory
- epr_customModulesDirectory
- epr_customFunctionsDirectory
- ScriptLogName
- LoggerSettings

## EXAMPLES

### EXAMPLE 1
```
Set-EPREnvironment
```

### EXAMPLE 2
```
Set-EPREnvironment -IncludeOldVariableNames
```

In this example we want to get the old variable names along with the new names.

### EXAMPLE 3
```
Set-EPREnvironment -CustomModules "MyModule","AnotherModule"
```

In this example we also import the modules 'MyModule' and 'AnotherModule' located in the directory *\[NameOfEPRInstall\]/scripts/helpers/customModules*.

### EXAMPLE 4
```
Set-EPREnvironment -Modules "MyOfficialModule","AnotherModuleAsAnExample"
```

In this example we also import the modules 'MyOfficialModule' and 'AnotherModuleAsAnExample' located in the directory *\[NameOfEPRInstall\]/scripts/helpers/modules*.

## PARAMETERS

### -CustomModules
Name of modules to import from *\[NameOfEPRInstall\]/scripts/helpers/customModules*

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeOldVariableNames
Specifies if the old variable names should be set in the script scope.

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

### -Modules
Name of modules to import from *\[NameOfEPRInstall\]/scripts/helpers/modules*

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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

### This function do not produce any output
## NOTES

## RELATED LINKS
