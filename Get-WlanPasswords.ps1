
<#PSScriptInfo

.VERSION 1.1

.GUID cb19eb4b-062a-410b-aafc-9e1d455892c6

.AUTHOR CBlais

.COMPANYNAME Vertikal6

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

.DESCRIPTION "Gets the saved SSIDs and passwords" 

#> 


##Get and cleanProfiles 
$Netsh = netsh.exe wlan show profiles
$profileRows = $Netsh | Select-String -Pattern 'All User Profile'

#For each profile name get the SSID and password
$RawProfiles = Foreach ($Row in $profileRows) {$Row -split ":" | ? {$_ -notlike "*All User Profile*"}}
$RawPasswords = Foreach ($Profile in $RawProfiles.trim()) {
##Catch errors resulting from 802.1x SSIDs
if (netsh.exe wlan show profiles name="$Profile" key=clear | Select-String -SimpleMatch "802.1X") {Write-Output "802.1X"}
Else {(netsh.exe wlan show profiles name="$Profile" key=clear | Select-String -Pattern 'Key Content').ToString().Split(":")[1].Trim()}} 

##Create hash table of SSID/Password values
$Count = 0
$HashTable = @{}
While ($Count -lt $RawProfiles.Count) {
$HashTable.Add($RawProfiles.GetEnumerator().trim()[$Count],$RawPasswords[$Count])
$Count +=1
}

##Output
$HashTable.GetEnumerator() | Sort-Object -Property Name



