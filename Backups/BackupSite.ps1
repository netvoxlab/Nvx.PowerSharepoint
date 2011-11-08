###############################################################################################################
# Скрипт снятия бекапа и автоматического архивирования
# Скрипт рассылает оповещения через e-mail о начале и завершении процесса
# Внимание скрипту требуется установленные 7zip и SMTP сервер
# Для запука из Task Sheduler используйте backup.cmd
# (С) NetVoxLab 2011
###############################################################################################################
## ПАРАМЕТРЫ ЗАПУСКА
$srvName="localhost"					# Заменить на имя хоста (без http:\\)
$backupLocation="E:\bkp"        		# Расположение бекапов
$zip = "c:\Program Files\7-Zip\7z.exe"	# Расположение рахиватора 7zip
## ПАРАМЕТРЫ ОПОВЕЩЕНИЙ
$SMTPServer = "$srvName"				# Почтовый сервер
$EmailFrom = "notifications@$srvName"	# От имени кого отправляется сообщение
$EmailTo = "admin@$srvName" 			# Кому приходят оповещения
###############################################################################################################

Add-PsSnapin Microsoft.SharePoint.PowerShell
 
Start-SPAssignment -Global           
$mySite="http://$srvName"            
$logFile="$backupLocation\BackupLog.log"    
$today=Get-Date -format "ddMMyyyy_HHmm"    
$today="$srvName"+"_"+"$today"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25) 
$SMTPClient.UseDefaultCredentials = $true      
    
$Subject = "[Notification]$mySite Начало бекапа $today" 
$Body = "$today    $mySite будет снят бекап и построен архив. $path.zip"
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body) 
    
write-Host Start backing up $mySite to $backupLocation
try
{
    Backup-SPSite -Identity $mySite -Path $backupLocation\$today.bak -force -ea Stop
    write-Host Backup succeeded.
    
	$path = "$backupLocation\$today"	
	&$zip a -y "$path.zip" "$path.bak" 
	
	write "$today    $mySite successfully backed up and archived. $path.zip">>$logFile   

	$Subject = "[Notification]$mySite Бекап снят" 
	$Body = "$today    $mySite снят бекап и построен архив. $path.zip"
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
	
    Remove-Item $backupLocation\$today.bak    
}
catch       
{
    write-Host Backup failed. See $logFile for more information.
 
    write "$today    Error: $_">>$logFile
	
	$Subject = "[Notification][Error]$mySite Ошибка снятия бекапа" 
	$Body = "Ошибка снятия бекапа $mySite.  Ошибка: $_" 
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)	
}    
 
Stop-SPAssignment -Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell 
write-Host "Finished script."