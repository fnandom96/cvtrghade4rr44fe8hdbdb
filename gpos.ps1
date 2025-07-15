# Ruta LDAP de la OU (no del grupo)
$ouDN = "OU=Administradores,OU=Grupos,DC=caixagalicia,DC=cg"
$ou = [ADSI]("LDAP://$ouDN")
$gplink = $ou.gPLink

# Extraer los GUIDs de las GPOs aplicadas
$gpoGuids = Select-String -InputObject $gplink -Pattern 'cn=\{.*?\}' -AllMatches |
    ForEach-Object { $_.Matches.Value -replace 'cn=|\{|\}' }

# Buscar GPOs por GUID
foreach ($guid in $gpoGuids) {
    $searcher = New-Object DirectoryServices.DirectorySearcher
    $searcher.SearchRoot = "LDAP://CN=Policies,CN=System,DC=caixagalicia,DC=cg"
    $searcher.Filter = "(&(objectClass=groupPolicyContainer)(name=$guid))"
    $result = $searcher.FindOne()

    if ($result) {
        $gpoName = $result.Properties.displayname
        Write-Output "GPO aplicada: $gpoName (GUID: $guid)"
    }
}
