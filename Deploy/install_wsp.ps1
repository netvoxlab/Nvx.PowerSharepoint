###############################################################################################################
# Скрипт развертывание WSP пакета
# (С) NetVoxLab 2011
###############################################################################################################
## ПАРАМЕТРЫ ЗАПУСКА
$solutionName="Solution.wsp"		# Имя пакета
$webUrl="http://localhost/"			# Адрес сайта где активировать пакет
###############################################################################################################
Add-PsSnapin Microsoft.SharePoint.PowerShell 
Start-SPAssignment -Global 
 
$solutionPath="$solutionName.wsp"
 
$web = Get-SPWeb $webUrl;   #Получить объект сайта 

Uninstall-SPSolution -Identity "$solutionName"      #Извлечь пакет
Remove-SPSolution -Identity "$solutionName" -Force  #Удалить пакет
Add-SPSolution -LiteralPath "$solutionPath"         #Добавить пакет
Install-SPSolution -Identity "$solutionName" -AllWebApplications -Force -GACDeployment -Local   #Установить пакет

$sol = Get-SPSolution -Identity "$solutionName"
Get-SPFeature –Web $web -Limit ALL | foreach { if($_.SolutionId -eq $sol.SolutionId) Enable-SPFeature –Identity $_ -URL $web} } #Активировать все Features из Пакета
 
Stop-SPAssignment -Global  
Remove-PsSnapin Microsoft.SharePoint.PowerShell
  
write-Host "Конец"