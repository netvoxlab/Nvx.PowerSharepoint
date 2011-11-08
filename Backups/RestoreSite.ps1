###############################################################################################################
# Скрипт развертывания бекапа
# Скрипт рассылает оповещения через e-mail о начале и завершении процесса
# (С) NetVoxLab 2011
###############################################################################################################
## ПАРАМЕТРЫ ЗАПУСКА
$srvName="localhost"					# Заменить на имя хоста (без http:\\)
$backupLocation="E:\bkp"        		# Расположение бекапов
$file="aismrr_07112011_2115.bak"		# Имя развертываемого бекапа
## ПАРАМЕТРЫ ОПОВЕЩЕНИЙ
$SMTPServer = "$srvName"				# Почтовый сервер
$EmailFrom = "notifications@$srvName"	# От имени кого отправляется сообщение
$EmailTo = "admin@$srvName" 			# Кому приходят оповещения
###############################################################################################################

Add-PsSnapin Microsoft.SharePoint.PowerShell
 
Start-SPAssignment -Global            		
$mySite="http://$srvName"            		      			
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25) 
$SMTPClient.UseDefaultCredentials = $true     

    
$startTime=Get-Date
$path="$backupLocation\$file";

$Subject = "[Notification]$mySite начало развертывания бекапа $file" 
$Body = "Начато развертывание бекапа $path на сервере $mySite. Дата начала: $startTime" 
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
    
write-Host "Начало развертки $startTime"
try{
	Restore-SPSite -Identity $mySite -Path $path -force
	$endTime=Get-Date
	$ts = $endTime - $startTime;
	
	$Subject = "[Notification]$mySite Бекап развернут" 
	$Body = "Бекап $path развернут на сервере $mySite. Заняло времени: $ts" 
	
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)		
}
catch{
	$endTime=Get-Date
	$ts = $endTime - $startTime;
	
	
	$Subject = "[NVX][Notification][Error]$mySite Ошибка развертывания бекапа" 
	$Body = "Бекап $path не развернут на сервере $mySite.  Заняло времени: $ts. Ошибка: $_" 
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)	
}




write-Host $ts
Stop-SPAssignment -Global
 
Remove-PsSnapin Microsoft.SharePoint.PowerShell
 
write-Host "Finished script."