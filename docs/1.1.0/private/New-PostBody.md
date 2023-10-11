---
external help file: Easit.ProcessRunner.GlobalFunctions-help.xml
Module Name: Easit.ProcessRunner.GlobalFunctions
online version:
schema: 2.0.0
---

# New-PostBody

## SYNOPSIS
Function to create a "Easit GO" formatted body for web requests.

## SYNTAX

```
New-PostBody [-InstallerSettings] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
This functions takes a "settings object" as input and uses the settings there to create a json body that can be used with Invoke-RestMethod.

## EXAMPLES

### EXAMPLE 1
```
New-PostBody -InstallerSettings $installerSettings
{
    "importHandlerIdentifier": "",
    "itemToImport": [
        {
            "property": [
                {
                    "name": "Property1",
                    "content": null
                },
                {
                    "name": "Property2",
                    "content": null
                }
            ],
            "id": "b04cf69223604fa58a03500a3d78002f",
            "uid": "b04cf69223604fa58a03500a3d78002f"
        }
    ]
}
```

### EXAMPLE 2
```
$body = New-PostBody -InstallerSettings $installerSettings
$restParams = @{
    Method = 'POST'
    Uri = 'https://urltoEasitGO.com/integration-api/items'
    Body = $body
    TimeoutSec = 30
    ContentType = "application/json"
    Headers = $headers
}
Invoke-RestMethod @restParams
```

## PARAMETERS

### -InstallerSettings
Settings object holding a FeedbackSettings.postBody property with an array of properties and a importHandlerIdentifier.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### JSON formatted string.
## NOTES

## RELATED LINKS
