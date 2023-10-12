---
external help file: Easit.ProcessRunner.GlobalFunctions-help.xml
Module Name: Easit.ProcessRunner.GlobalFunctions
online version:
schema: 2.0.0
---

# New-EPRInstallation

## SYNOPSIS
Function for installing Easit Process Runner.

## SYNTAX

```
New-EPRInstallation [-InstanceID] <String> [-FromDirectory] <String> [[-InstallLocation] <String>]
 [[-SystemName] <String>] [[-Port] <Int32>] [[-TomcatXmx] <Int32>] [-IgnoreDirectoryStructure]
 [-DoNotSendInstallationDetailsToEasit] [<CommonParameters>]
```

## DESCRIPTION
Function for installing a new instance of Easit Process Runner.
This function will first look for settings in *.\lib\installerSettings.json* relative to path provided as *FromDirectory*.
The settings in this file will be replaced in memory with any input provided with *InstallLocation*, *SystemName*, *Port* and *TomcatXmx*.
Settings provided via a parameter will be used over settings in *installerSettings.json*

## EXAMPLES

### EXAMPLE 1
```
New-EPRInstallation -InstanceID ABC123 -FromDirectory '.\EPRInstaller-1.0.0'
```

### EXAMPLE 2
```
New-EPRInstallation -InstanceID ABC123 -FromDirectory '.\EPRInstaller-1.0.0' -InstallLocation 'E:\'
```

### EXAMPLE 3
```
New-EPRInstallation -InstanceID ABC123 -FromDirectory '.\EPRInstaller-1.0.0' -InstallLocation 'F:\' -Port 9005
```

## PARAMETERS

### -InstanceID
ID from Easit AB representing the customers instance.

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

### -FromDirectory
Path to the directory of expanded install archive containing the directories 'archives' and 'lib'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InstallLocation
Path to where EPR should be installed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemName
The input for SystemName will be combined with 'EPR-'.
This will then be used to name the Tomcat service and *SystemRoot*.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
Specifies the port EPR will listen on for incomming requests.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TomcatXmx
Specifies how mush memory the Tomcat service will able to use.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoreDirectoryStructure
Specifies if the installer should add 'Easit' or not to the *InstallLocation*.
With *IgnoreDirectoryStructure* omitted: D:\Easit\EPR-\[SystemName\]
With *IgnoreDirectoryStructure* provided: D:\EPR-\[SystemName\]

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

### -DoNotSendInstallationDetailsToEasit
Specifies if the installer should NOT try to send server and installations details to Easit upon completed installation.

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

## OUTPUTS

### Along with some feedback information this function produce a txt file with post install instructions.
## NOTES

## RELATED LINKS
