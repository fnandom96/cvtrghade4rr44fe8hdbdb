$groupName = "Administradores"
$group = ([ADSI]"LDAP://CN=$groupName,OU=Grupos,DC=caixagalicia,DC=cg")
$groupSid = New-Object System.Security.Principal.SecurityIdentifier($group.objectSID[0], 0)

$computers = New-Object DirectoryServices.DirectorySearcher
$computers.Filter = "(objectClass=computer)"
$computers.PropertiesToLoad.Add("name") | Out-Null
$computerList = $computers.FindAll() | ForEach-Object { $_.Properties.name[0] }

foreach ($computer in $computerList) {
    try {
        $admins = [ADSI]"WinNT://$computer/Administrators,group"
        $members = @($admins.psbase.Invoke("Members")) | ForEach-Object {
            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        }
        if ($members -contains $groupName) {
            Write-Host "$groupName es miembro de $computer\Administradores"
        }
    } catch {
        Write-Warning "No se pudo consultar $computer"
    }
}
