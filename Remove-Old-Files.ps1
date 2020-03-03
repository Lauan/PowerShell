############################################################################################
############################################################################################
###																						 ###
###					SCRIPT PARA EXCLUSÃO DE ARQUIVOS ANTIGOS							 ###
### 02/03/2020														Lauan Roberto Coelho ###
############################################################################################
############################################################################################
#
# Utilização:
#	Remove-Old-Files.ps1 -Acao LogOnly -SearchPath D:\Arquivos\Financeiro -LogPath C:\logs\removearquivos.log
#
#
# -Acao:
#	Ação a ser executada pelo script. Duas opções possíveis:
#		"LogOnly" - Apenas gera log com os arquivos que serão excluídos
#		"Remove" - Remove os arquivos e gera o log com as execuções
#
# -SearchPath:
#	Caminho base da pesquisa no formato D:\pasta1\pasta2
#	ATENÇÃO!!! Todos os arquivos abaixo desse diretório serão afetados!!
#
#
# -LogPath (Opcional):
#	Caminho para o arquivo de logs no formato C:\pasta\log.log
#
#
#	NOTA: A opção -Verbose pode ser ativada para maiores detalhes durante a execução
#
param(
	[Parameter(Mandatory=$true)][ValidateSet("Remove","LogOnly")][String]$Acao,
	[Parameter(Mandatory=$true)][String]$SearchPath,
	[Parameter(Mandatory=$false)][String]$LogPath
)

#Define a função de Log
Function Log {
    param(
        [Parameter(Mandatory=$true)][String]$msg
    )
	$datalog = Get-Date -Format ddMMyyyy
	if ($logPath -eq $null){
		$logPath = "C:\LimpaArquivos\$datalog-limpaArquivos.log"
	}
    Add-Content $logPath $msg
}

#Define o período de exclusão dos arquivos para mais de 5 anos
$ano = (Get-Date -Format yyyy)-5
$data = Get-Date -Year $ano

#Lista todos os arquivos que se encaixam no critério
Write-Verbose "Gerando lista de arquivos."
$erros = $null
$files = Get-ChildItem $searchPath -Recurse -ErrorVariable +erros -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -lt $data -and $_.LastAccessTime -lt $data}

if ($erros -ne $null) {
	foreach ($erro in $erros) {
		Write-Warning "Um erro do tipo $($erro.CategoryInfo.Reason) foi encontrado. Verifique os logs para mais detalhes."
		Log "ERRO: O erro $($erro.categoryinfo.reason) foi disparado no item $($erro.categoryinfo.targetname)"
	}
}

if ($files -eq $null) {Write-Verbose "Nenhum arquivo atende aos criterios da pesquisa."}

#Executa a ação nos arquivos
foreach ($file in $files) {
	if ($acao -eq "LogOnly"){
		Write-Verbose "O arquivo: $($file.fullname) sera excluido se a opcao 'Remove' for utilizada."
		Log "O arquivo: $($file.fullname) sera excluido se a opcao 'Remove' for utilizada."
	}
	elseif ($acao -eq "Remove"){
		Write-Verbose "O arquivo: $($file.fullname) esta sendo excluido."
		try{
			Remove-Item $file.fullname -ErrorAction Stop
		} catch{
			$falha = $error[0].exception
			Write-Warning "Falha na exclusao do arquivo $($file.fullname)."
			Log "Falha na exclusao do arquivo $($file.fullname) com o erro $falha."
			break
		}
		Write-Verbose "Arquivo $($file.fullname) excluido."
		Log "Arquivo $($file.fullname) excluido."
	}
}
Write-Verbose "Encerrando execução."