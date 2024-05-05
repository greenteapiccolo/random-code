# Besides the Microsoft regex pattern exclusion, it will skip TrustedInstaller folders, folders that did not originally have a modifying permissions for authenticated (or not) users groups
$excludePattern = 'Microsoft', "Windows" -join '|'

$trustedInstallerGroup = 'NT SERVICE\TrustedInstaller'
$authenticatedUsersGroup = 'NT AUTHORITY\Authenticated Users'
$usersGroup = 'BUILTIN\Users'
$writingPermissions = @('AppendData', 'ChangePermissions', 'CreateDirectories', 'CreateFiles', 'Delete', 'DeleteSubdirectoriesAndFiles','FullControl','Modify','TakeOwnership', 'Write','WriteAttributes','WriteData' , 'WriteExtendedAttributes')
$readAndExecutePermission = 'ReadAndExecute'
$modifyPermission = 'Modify'

function Check-Writing-Permissions($Rights) {
    $hasWritingPermission = $false
    Foreach($right in $Rights -split ", ") {
        If($writingPermissions -ccontains $right) {
            $hasWritingPermission = $true
            return $hasWritingPermission
        }
    }
    return $hasWritingPermission
}

function Update-ACL($DirectoryPath, $WithInheritance) {
    "Handling $directoryPath"

    try {
        $accessControl = (Get-Item $directoryPath).GetAccessControl('Access')
    }
    catch {
        "Could not list item?"
         return
    }

    $inheritFlags = If ($WithInheritance) {@('ContainerInherit','ObjectInherit')} Else {'None'} 
    $propagationFlags = 'None'
    
    # Cleaning existing ACL
    $accessEntriesToRemove = $accessControl.Access | ?{ $_.IsInherited -eq $false -and ($_.IdentityReference -eq $usersGroup -or $_.IdentityReference -eq $authenticatedUsersGroup)} | Where-Object {(Check-Writing-Permissions -Rights $_.FileSystemRights) -eq $true}
    
    Foreach($rule in $accessEntriesToRemove) {
        try {
         $accessControl.RemoveAccessRule($rule)
        }
        catch {
          "Could not remove (completely?) $rule"
          break
        }
    }

    # Adding new ACL rules if needed
    If($accessEntriesToRemove.Count -gt 0) {
        Write-Host "Backup-ing ACL..."
        $aclFileName = $directoryPath -replace ':|\\'
        $aclFileDestination = "$env:USERPROFILE\AclBackups\$aclFileName"
        Invoke-Expression -Command:"icacls '$($directoryPath)' /save '$($aclFileDestination)'"

        Write-Host "Updating ACL..."        
        $newGroupRule = New-Object System.Security.AccessControl.FileSystemAccessRule($usersGroup, $readAndExecutePermission, $inheritFlags, $propagationFlags, 'Allow')
        $accessControl.AddAccessRule($newGroupRule)
        $newLocalRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, $modifyPermission, $inheritFlags, $propagationFlags, 'Allow')
        $accessControl.SetAccessRule($newLocalRule)
        
        # Undo this when you are READY!
        #Set-Acl -AclObject $accessControl $directoryPath
    }
}

function Get-All-Children($DirectoryPath) {
$directories = @(Get-Item -Path "$DirectoryPath" -Force -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer -eq $true -and $_.FullName -inotmatch $excludePattern -and $_.GetAccessControl().Owner -ne $trustedInstallerGroup}) 
    Foreach ($directory in $directories) {
       Foreach ($subDirectory in @(Get-Item -Path $directory.fullName -ErrorAction SilentlyContinue; Get-ChildItem -Path $directory.fullName -ErrorAction SilentlyContinue -Recurse -Force -Directory | Where-Object {$_.FullName -inotmatch $excludePattern -and $_.GetAccessControl().Owner -ne $trustedInstallerGroup})) {
           Update-ACL -DirectoryPath $subDirectory.FullName -WithInheritance $true
       }
    }
}


# Program Files
Get-All-Children -DirectoryPath "$env:systemdrive\Program Files\*"

# Program Files (x86)
Get-All-Children -DirectoryPath "$env:systemdrive\Program Files (x86)\*"

# ProgramData
Get-All-Children -DirectoryPath "$env:systemdrive\ProgramData\*"
