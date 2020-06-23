############################################################################################
############################################################################################
###																						 ###
###					SCRIPT PARA TESTE DE REPLICAÇÃO SYSVOL (DFSR)						 ###
### 12/05/2020														Lauan Roberto Coelho ###
############################################################################################
############################################################################################
#
# Pré-requisitos:
#	Executáveis de gerenciamento DFSR (dfsrdiag.exe).
#	A instalação do módulo DFSR abaixo possui todos os arquivos necessários:
#	"Install-module Install-WindowsFeature FS-DFS-Replication -IncludeManagementTools"
#
#
# Utilização:
#	Execução do script sem argumentos.
#	- O retorno "0" representa sucesso no teste de replicação da pasta SYSVOL
#	- O retorno "1" representa erro na replicação da pasta SYSVOL para algum parceiro
#
#
# Compatibilidade:
#	- Powershell 2.0+
#
#
# Permissões:
#   - O script pode ser executado no Domain Controller pelo usuário SYSTEM.
#
############################################################################################

#Loading AD Module

Import-Module activedirectory

#Collecting data

$hostname = $env:computername
$domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
$fqdn = "$hostname.$domain"
$random = Get-Random -Minimum 10000 -Maximum 99999
$dcs = Get-ADDomain | Select-Object -ExpandProperty ReplicaDirectoryServers
$dcs += Get-ADDomain | Select-Object -ExpandProperty ReadOnlyReplicaDirectoryServers
$localpath = "\\$fqdn\sysvol\$domain\_DFSR_ZABBIX_TEST_FOLDER_"

#Creationg propagation test file
$prepcheck = Test-Path -Path $localpath
if (!$prepcheck){
	$newfolder = New-Item -Path $localpath -ItemType Dir
	$newfolder.Attributes = "Hidden"
}

$testfile = New-Item -Path "$localpath\$random" -ItemType File

#Waiting a few seconds for sync
Start-Sleep 10

#Geting propagation test results
$fail = $false
Foreach ($dc in $dcs){
	$check = Test-Path -Path "\\$dc\sysvol\$domain\_DFSR_ZABBIX_TEST_FOLDER_\$random"
	if (!$check){
		$fail = $true
		break
	}
}

#Cleaning test file
Remove-Item -Path $testfile.fullname -force

#Results
if ($fail){
	Write-Host "1"
} else {
	Write-Host "0"
}