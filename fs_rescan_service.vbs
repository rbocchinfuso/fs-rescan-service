'Drive letter assignment script
'v1.10
'FSPS - RJB - rbocchinfuso@fusionstorm.com

On Error Resume Next

WScript.Sleep(60000)


'Constants
Const ForAppending = 8

'Vars
logpath = "c:\fs_services\fs_rescan_service\fs_rescan_svc.log"
voltmp = "c:\fs_services\fs_rescan_service\volumes.tmp"
voltxt = "c:\fs_services\fs_rescan_service\volumes.txt"
batfile = "c:\fs_services\fs_rescan_service\fs_rescan_svc.bat"
datalabel = "EMCData"
loglabel = "EMCLogs"
dataletter = "G:"
logletter = "F:"


'Main

'open fs_rescan_svc.log
	  Set logfso = CreateObject("Scripting.FileSystemObject")
	  Set logfile = logfso.CreateTextFile(logpath)
	  logfile.WriteLine (Date & " " & Time)
	  logfile.WriteBlankLines(1)
logfile.Close


Dim arg
arg = WScript.Arguments.Item(0)
select case arg
  Case "-h"
    Call Help()
  Case "-scan"
    Set logfile = logfso.OpenTextFile(logpath, ForAppending)  
    logfile.WriteLine "...Checking partitions and writing volumes.tmp..."
	logfile.WriteLine "...Starting diskpart..."
    logfile.Close
    WScript.Sleep(1000) 'wait for logfile to close
      Call CheckFS(batfile)
      WScript.Sleep(5000)
    Set logfile = logfso.OpenTextFile(logpath, ForAppending)
    logfile.WriteLine "...Writing volumes.txt diskpart script ..."
      Call volumes(voltmp,voltxt)
      WScript.Sleep(5000)
    logfile.WriteLine "...Assinging drive letters with diskpart..."
      Call diskpart_assign(voltxt)
      WScript.Sleep(5000)
    logfile.WriteLine "...Checking to see if drive f: or g: is in use... If yes volumes being assigned null..."
      Call CheckDriveLetters(datalabel,dataletter,loglabel,logletter)
    logfile.WriteLine "...Assign EMCData drive F: and EMCLogs drive G:..."
      Call AssignDriveLetters(datalabel,dataletter,loglabel,logletter)
    logfile.WriteLine "...Starting MS SQL Server Service..."
      Call StartSQL()
	  WScript.Sleep(1000)
	logfile.WriteLine "...Starting MS SQL Server Agent Service..."
      Call StartSQLSERVERAGENT()
    logfile.WriteLine "...Cleaning up volumes.tmp and volumes.txt files..."
      Call cleanup(voltmp,voltxt)
    logfile.Close
	  Call diskpart_list(batfile)
  Case "-install"
    Set logfile = logfso.OpenTextFile(logpath, ForAppending)
    logfile.WriteLine "...Installing FS Rescan Service..."
    logfile.Close
    WScript.Sleep(1000)
      Call InstallService(batfile)    	
  Case "-uninstall"
    Set logfile = logfso.OpenTextFile(logpath, ForAppending)
    logfile.WriteLine "...Uninstalling FS Rescan Service..."
    logfile.Close
    WScript.Sleep(1000) 'wait for logfile to close
      Call UninstallService(batfile)
  Case "-checkfs"
    Set logfile = logfso.OpenTextFile(logpath, ForAppending)
    logfile.WriteLine "...checkfs running... for debugging purposes only..."
    logfile.Close
    WScript.Sleep(1000)	
      Call CheckFS(batfile)
      WScript.Sleep(5000)
      Set logfile = logfso.OpenTextFile(logpath, ForAppending)
      logfile.WriteLine "...Writing volumes.txt diskpart script ..."
      Call volumes(voltmp,voltxt)
      WScript.Sleep(5000)
      logfile.WriteLine "...Assinging drive letters with diskpart..."
      call diskpart_assign(voltxt)
      logfile.Close
	  Call diskpart_list(batfile)	
  Case "-debug"
    Set logfile = logfso.OpenTextFile(logpath, ForAppending)
    logfile.WriteLine "...debug only..."
    logfile.Close
      Call Debugsub(batfile)
  Case "-clean"
  Set logfile = logfso.OpenTextFile(logpath, ForAppending)
    logfile.WriteLine "...deleting volumes.tmp and volumes.txt..."
      Call cleanup(voltmp,voltxt)
    logfile.Close
  Case Else
    msgbox "Unrecognized command! Use -h for help.",64,"Warning!"
End select


Sub Help()
	Wscript.Echo "FusionStorm Drive Rescan Service - 4/25/2008 - v1.10"
	Wscript.Echo ""
	Wscript.Echo "Usage:  fs_rescan_service.vbs [-h] [-install] [-uninstall] [-scan]"
	Wscript.Echo ""
	Wscript.Echo "   -h - prints this help text"
	Wscript.Echo "   -install - installs the fs_rescan_service"
	Wscript.Echo "   -uninstall - uninstalls the fs_rescan_service"
	Wscript.Echo "   -scan - manually rescans and assigns drive"
	Wscript.Echo "   letters (this can also be accomplished by restarting"
	Wscript.Echo "    the service if it is installed)"	
	Wscript.Echo ""
	Wscript.Echo "   install.bat file installs the fs_rescan_service"
	Wscript.Echo "    (this is the preferred method for initial installation)"
End Sub

Sub InstallService(batfile)
	Dim wShell, oExec
	Set wShell = CreateObject("WScript.Shell")
	wShell.Exec(batfile & " install")
End Sub

Sub UninstallService(batfile)
	Dim wShell, oExec
	Set wShell = CreateObject("WScript.Shell")
	wShell.Exec(batfile & " uninstall")
End Sub

Sub Debugsub(batfile)
  'Debug Check filesystems with diskpart
    Dim oShell
    Set oShell = WScript.CreateObject ("WSCript.shell")
    oShell.run "cmd /K " & batfile & " checkfs"
    Set oShell = Nothing
End Sub

Sub CheckFS(batfile)
  'Check filesystems with diskpart
    Dim wShell, oExec
		Set wShell = CreateObject("WScript.Shell")
		wShell.Exec(batfile & " checkfs")
End Sub

Sub diskpart_list(batfile)
  'Log volumes from diskpart
    Dim wShell, oExec
		Set wShell = CreateObject("WScript.Shell")
		wShell.Exec(batfile & " diskpart_list")
End Sub


Sub volumes(voltmp,voltxt)
  'read volumes.tmp
    Set objFSOtmp = CreateObject("Scripting.FileSystemObject")
    Set objTMP = objFSOtmp.OpenTextFile(voltmp, ForReading)

    Const ForReading = 1

    Dim arrFileLines()
    i = 0
    Do Until objTMP.AtEndOfStream
    Redim Preserve arrFileLines(i)
    arrFileLines(i) = objTMP.ReadLine
    i = i + 1
    Loop
    objTMP.Close

  'write volumes.txt
	  Set fso = CreateObject("Scripting.FileSystemObject")
	  Set txtfile = fso.CreateTextFile(voltxt)
	  	For Each strLine in arrFileLines
	    	txtfile.WriteLine strLine
	    	txtfile.WriteLine "assign"
	    next
	txtfile.WriteLine "EXIT"
	txtfile.Close
End Sub	
	
Sub diskpart_assign(voltxt)
	'Assign drive letters with diskpart
		Dim wShell, oExec
		Set wShell = CreateObject("WScript.Shell")
		wShell.Exec("diskpart /s " & voltxt)
End Sub

sub cleanup(voltmp,voltxt)
  'delete volumes.tmp
    Set filesys = CreateObject("Scripting.FileSystemObject")
    filesys.DeleteFile (voltmp)
  'delete volumes.txt
    Set filesys = CreateObject("Scripting.FileSystemObject")
    filesys.DeleteFile (voltxt)
End Sub

Sub CheckDriveLetters(datalabel,dataletter,loglabel,logletter)

	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" _
	    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
   
	'Reassign letters g: & f: if already in use
	
		Set colVolumes = objWMIService.ExecQuery _
		    ("Select * from Win32_Volume Where DriveLetter = '"&dataletter&"' AND Label <> '"&datalabel&"'")
		
			For Each objVolume in colVolumes
				objVolume.DriveLetter = null
			    objVolume.Put_
			Next
		
		Set colVolumes = objWMIService.ExecQuery _
		    ("Select * from Win32_Volume Where DriveLetter = '"&logletter&"' AND Label <> '"&loglabel&"'")
		
			For Each objVolume in colVolumes
				objVolume.DriveLetter = null
			    objVolume.Put_
			Next
End Sub

Sub AssignDriveLetters(datalabel,dataletter,loglabel,logletter)
	
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" _
	    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	
	'Assign EMCData voluem drive letter g:
	
		Set colVolumes = objWMIService.ExecQuery _
		    ("Select * from Win32_Volume Where Label = '"&datalabel&"'")
	
			For Each objVolume in colVolumes
				objVolume.DriveLetter = dataletter
			    objVolume.Put_
			Next
	
	'Assign EMCData voluem drive letter f:
	
		Set colVolumes = objWMIService.ExecQuery _
		    ("Select * from Win32_Volume Where Label = '"&loglabel&"'")
	
			For Each objVolume in colVolumes
			    objVolume.DriveLetter = logletter
			    objVolume.Put_
			Next
End Sub	



Sub StartSQL()
	'Start MSSQLSERVER Service
	strServiceName = "MSSQLSERVER"
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set colListOfServices = objWMIService.ExecQuery ("Select * from Win32_Service Where Name ='" & strServiceName & "'")
		For Each objService in colListOfServices
		    objService.StartService()
		Next
End Sub

Sub StartSQLSERVERAGENT()
	'Start SQLSERVERAGENT Service
	strServiceName = "SQLSERVERAGENT"
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set colListOfServices = objWMIService.ExecQuery ("Select * from Win32_Service Where Name ='" & strServiceName & "'")
		For Each objService in colListOfServices
		    objService.StartService()
		Next
End Sub