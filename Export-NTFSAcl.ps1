############################################################################################
############################################################################################
###																						 ###
###							SCRIPT PARA EXPORTAÇÃO DE ACLS NFTS							 ###
### 05/03/2020														Lauan Roberto Coelho ###
############################################################################################
############################################################################################
#
# Utilização:
#	Export-NtfsAcl.ps1 -SearchPath D:\Arquivos\Financeiro -OutputFile C:\logs\acls.csv -LogFile C:\logs\exportaacl.log
#
#
# -SearchPath:
#	Caminho base da pesquisa no formato D:\pasta1\pasta2
#	ATENÇÃO!!! Todos os arquivos abaixo desse diretório serão pesquisado!!
#
#
# -OutputFile:
#	Caminho do arquivo de saída com o conteúdo da coleta no formato C:\pasta\log.csv
#	ATENÇÃO!!! O arquivo deve ser exportado no formato CSV.
#
#
# -LogFile:
#	Caminho para o arquivo de logs no formato C:\pasta\log.log
#
#
param(
	[Parameter(Mandatory=$true)][String]$SearchPath,
	[Parameter(Mandatory=$true)][String]$OutputFile,
	[Parameter(Mandatory=$true)][String]$LogFile
)

Function Log {
    param(
        [Parameter(Mandatory=$true)][String]$msg
    )
	$datalog = Get-Date -Format ddMMyyyy
    Add-Content $logfile $msg
}

$dirs = Get-ChildItem $searchPath -Recurse -Directory -ErrorVariable +erros -ErrorAction SilentlyContinue

if ($null -ne $erros) {
	foreach ($erro in $erros) {
		Write-Warning "Um erro do tipo $($erro.CategoryInfo.Reason) foi encontrado. Verifique os logs para mais detalhes."
		Log "ERRO: O erro $($erro.categoryinfo.reason) foi disparado no item $($erro.categoryinfo.targetname)"
	}
}

if ($null -eq $files) {Write-Verbose "Nenhum arquivo atende aos criterios da pesquisa."}

$tab = New-Object system.Data.DataTable "Permissions"
$col1 = New-Object system.Data.DataColumn path,([string])
$col2 = New-Object system.Data.DataColumn acl,([string])
$tab.columns.add($col1)
$tab.columns.add($col2)

foreach ($dir in $dirs) {
	$path = $dir.fullname
	try{
		$acl = Get-ACL $dir.fullname -ErrorAction Stop | Select-Object -ExpandProperty AccessToString
	} catch {
		$falha = $error[0].exception
		Write-Warning "Falha na verificacao da pasta $($dir.fullname)."
		Log "Falha na verificacao da pasta $($dir.fullname) com o erro $falha."
	}
	$row = $tab.NewRow()
	$row.path = $path
	$row.acl = $acl
	$tab.rows.add($row)
}

$tab | Export-csv -UseCulture -NoTypeInformation $OutputFile