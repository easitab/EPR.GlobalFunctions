function Set-EPRDirectoryPermission {
    <#
    .SYNOPSIS
        Adds a access fule for an account to a directory.
    .DESCRIPTION
        **Set-EPRDirectoryPermission** adds a access rule to the specified directory. By default the access rule added has the following settings:

        - FileSystemRights = Modify
        - InheritanceFlags = ContainerInherit,ObjectInherit
        - PropagationFlags = None
        - AccessControlType = Allow
    .EXAMPLE
        Set-EPRDirectoryPermission -Account 'Domain\User' -Path 'D:\Easit\EPR-Test'
    .PARAMETER Account
        The name of a user account.
    .PARAMETER Path
        Path to directory that the access rule should be added for.
    .PARAMETER Access
        Specifies the type of operation associated with the access rule
    .PARAMETER InheritanceFlags
        Specifies how access masks are propagated to child objects.
    .PARAMETER PropagationFlags
        Specifies how Access Control Entries (ACEs) are propagated to child objects.
    .PARAMETER AccessControlType
        Specifies whether to allow or deny the operation.
    .INPUTS
        None - You cannot pipe objects to this function
    .OUTPUTS
        None - This function does not produce any output
    #>
    [CmdletBinding(HelpUri='https://docs.easitgo.com/techspace/psmodules/eprglobalfunctions/functions/seteprdirectorypermission/')]
    [OutputType()]
    param (
        [Parameter(Mandatory)]
        [String]$Account,
        [Parameter(Mandatory)]
        [String]$Path,
        [Parameter()]
        [String]$Access = 'Modify',
        [Parameter()]
        [String]$InheritanceFlags = 'ContainerInherit,ObjectInherit',
        [Parameter()]
        [String]$PropagationFlags = 'None',
        [Parameter()]
        [String]$AccessControlType = 'Allow'
    )
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) start"
    }
    process {
        if (Test-Path -Path $Path) {
            try {
                $accessControlLists = Get-Acl $Path -ErrorAction Stop
            } catch {
                throw $_
            }
        } else {
            throw "$Path does not exist"
        }
        if ($null -eq $accessControlLists) {
            throw "Could not get access control lists"
        }
        try {
            $fileSystemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$Account", "$Access", "$InheritanceFlags", "$PropagationFlags", "$AccessControlType") -ErrorAction Stop
        } catch {
            throw $_
        }
        if ($null -eq $fileSystemAccessRule) {
            throw "Unable to create new access rule"
        }
        try {
            $accessControlLists.SetAccessRule($fileSystemAccessRule)
            Set-Acl $Path $accessControlLists -ErrorAction Stop
        } catch {
            throw $_
        }
    }
    end {
        Write-Verbose "$($MyInvocation.MyCommand) end"
    }
}