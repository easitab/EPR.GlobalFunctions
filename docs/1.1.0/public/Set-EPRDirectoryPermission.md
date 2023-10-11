---
external help file: Easit.ProcessRunner.GlobalFunctions-help.xml
Module Name: Easit.ProcessRunner.GlobalFunctions
online version:
schema: 2.0.0
---

# Set-EPRDirectoryPermission

## SYNOPSIS
Adds a access fule for an account to a directory.

## SYNTAX

```
Set-EPRDirectoryPermission [-Account] <String> [-Path] <String> [[-Access] <String>]
 [[-InheritanceFlags] <String>] [[-PropagationFlags] <String>] [[-AccessControlType] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
**Set-EPRDirectoryPermission** adds a access rule to the specified directory.
By default the access rule added has the following settings
- FileSystemRights = Modify
- InheritanceFlags = ContainerInherit,ObjectInherit
- PropagationFlags = None
- AccessControlType = Allow

## EXAMPLES

### EXAMPLE 1
```
Set-EPRDirectoryPermission -Account 'Domain\User' -Path 'D:\Easit\EPR-Test'
```

## PARAMETERS

### -Account
The name of a user account.

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

### -Path
Path to directory that the access rule should be added for.

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

### -Access
Specifies the type of operation associated with the access rule

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Modify
Accept pipeline input: False
Accept wildcard characters: False
```

### -InheritanceFlags
Specifies how access masks are propagated to child objects.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: ContainerInherit,ObjectInherit
Accept pipeline input: False
Accept wildcard characters: False
```

### -PropagationFlags
Specifies how Access Control Entries (ACEs) are propagated to child objects.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessControlType
Specifies whether to allow or deny the operation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Allow
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
