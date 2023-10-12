# Write-EPRInstallLog

## SYNOPSIS
Easit custom Powershell logger.

## SYNTAX

### string
```
Write-EPRInstallLog [[-Message] <String>] [-Level <String>] [-LogName <String>] [-LogDirectory <String>]
 [-LogLevel <String>] [<CommonParameters>]
```

### object
```
Write-EPRInstallLog [-InputObject <Object>] [-Level <String>] [-LogName <String>] [-LogDirectory <String>]
 [-LogLevel <String>] [<CommonParameters>]
```

## DESCRIPTION
Easit custom Powershell logger works similar to log4j that is used with Java applications.

Two different logging techniques are used depending on the input:
"$FormattedDate - $Level - $Message" | Out-File
$InputObject | Out-File

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -InputObject
Used for object input and will be written to log file as: 'DATE TIME - LEVEL - $InputObject.Exception' OR 'DATE TIME - LEVEL - $InputObject.ToString()' followed by 'DATE TIME - LEVEL - $InputObject'

```yaml
Type: Object
Parameter Sets: object
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Level
What level the message should be written as.
Default level is INFO.
Each level uses the corresponding Write-XX cmdlet to output data to the correct stream.
Ex.
INFO = Write-Information, VERBOSE = Write-Verbose, WARN = Write-Warning.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: INFO
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogDirectory
Directory to write log file in.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogLevel
What level the logger should output entries on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: INFO
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogName
Name of log written to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: EPRInstall
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Used for string input and will be written to log file as: DATE TIME - LEVEL - MESSAGE

```yaml
Type: String
Parameter Sets: string
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None. This cmdlet returns no output.
## NOTES

## RELATED LINKS
