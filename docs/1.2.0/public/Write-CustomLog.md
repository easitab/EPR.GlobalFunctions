# Write-CustomLog

## SYNOPSIS
Writes input to file and a output stream.

## SYNTAX

### string
```
Write-CustomLog [-Message <String>] [-Level <String>] [-OutputLevel <String>] [-LogName <String>]
 [-LogDirectory <String>] [-RotationInterval <Int32>] [-Rotate] [<CommonParameters>]
```

### object
```
Write-CustomLog [-InputObject <Object>] [-Level <String>] [-OutputLevel <String>] [-LogName <String>]
 [-LogDirectory <String>] [-RotationInterval <Int32>] [-Rotate] [<CommonParameters>]
```

## DESCRIPTION
This function provide the option to log output and / or progress in scripts.
While there are functions like *Start-Transcript* and *Out-File*, *Write-CustomLog* also handles log rotation and naming of log history.

*Write-CustomLog* will always append *_date* to the logname and remove logs older than the value of *RotationInterval*.

*Write-CustomLog* uses *Out-File* for writing output to a file and then redirects either *Message* or *InputObject* to the stream corresponding with the value of *Level*.

* If no input is provided for *-LogName*, *-LogDirectory* nor *-RotationInterval* the function will look for a variable named LoggerSettings in the global scope with a property or key with the same name and use that value.
* If no input is provided for *-LogName*, the name of the caller script is used as input.
* If no input is provided for *-LogDirectory*, logs will be written to $pwd.
* If no input is provided for *-RotationInterval*, 30 will used as value.

## EXAMPLES

### EXAMPLE 1
```
Write-CustomLog -Message "Staring script"
```

In this example we write the string *Starting script* as a log entry with the level of INFO.
It will also use Write-Information to output it to the correct stream.

### EXAMPLE 2
```
Write-CustomLog -InputObject $_ -Level ERROR
```

In this example we write the current objekt to as a log entry with the level of ERROR.
It will also use Write-Error to output it to the correct stream.

### EXAMPLE 3
```
Write-CustomLog -Message "Rotating logs" -Level VERBOSE -Rotate
```

In this example we write the string *Starting script* as a log entry with the level of INFO.
It will also use Write-Information to output it to the correct stream.
Since we specify *-Rotate* the function will try to remove files older than set by *RotationInterval*.

### EXAMPLE 4
```
Write-CustomLog -Message "Starting script and rotating logs" -Rotate
Write-CustomLog -Message "Trying something" -Level VERBOSE
try {
    try-something
} catch {
    Write-CustomLog -InputObject $_ -Level ERROR
    return
}
Write-CustomLog -Message "Script end"
```

Basic *real world* example of how to use *Write-CustomLog* in a script.

## PARAMETERS

### -InputObject
The object that will be written to file and stream.

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
What stream should the input be redirected to.

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
In what directory should logs be saved.

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

### -LogName
Name of logfile.

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

### -Message
String that will be written to file and stream.

```yaml
Type: String
Parameter Sets: string
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OutputLevel
What level of input should be written to file and stream.

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

### -Rotate
Tells the function to rotate logs.
If this is always included with *Write-CustomLog* it will always try to rotate logs each time *Write-CustomLog* is invoked.

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

### -RotationInterval
For how many days should logs be kept on disk.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [System.String](https://learn.microsoft.com/en-us/dotnet/api/system.string)
### [System.Object](https://learn.microsoft.com/en-us/dotnet/api/system.object)
## OUTPUTS

### None. This cmdlet returns no output
## NOTES

## RELATED LINKS
