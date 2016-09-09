@echo off
set log=fs_rescan_svc.log
set fs=NTFS
set volumes=volumes.tmp

:main
goto %1

:help
echo FusionStorm Drive Rescan Service Installation - 4/25/2008 - v1.10
echo Usage:  fs_rescan_svc.bat [install] [uninstall] [checkfs]
echo help - prints this help text
echo install - installs the fs_rescan_service
echo uninstall - uninstalls the fs_rescan_service
echo checkfs - scans diskpart for volume with no drive letter and/or label
echo 
echo
goto :end


:install
echo _ >> %log%
echo _ >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...Setting default scripting host to CScript...>> %log%
echo ************************************************************************ >> %log%
cscript //H:CScript
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...Completed setting default scripting host to CScript...>> %log%
echo ************************************************************************ >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...Installing FS Rescan Service...>> %log%
echo ************************************************************************ >> %log%
C:\FS_Services\tools\instsrv "FS Rescan Service" "C:\FS_Services\tools\srvany.exe" >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...FS Rescan Service Install Complete... >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...Modifying FS Rescan Service Registry Key... >> %log%
echo ************************************************************************ >> %log%
regedit /s .fs_rescan_svc.reg
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...FS Rescan Service Registry Key complete... >> %log%
echo ************************************************************************ >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...FS Rescan Service Install Complete...>> %log%
echo ************************************************************************ >> %log%
echo ************************************************************************ >> %log%
goto :end

:uninstall
echo _ >> %log%
echo _ >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...Stopping FS Rescan Service... >> %log%
echo ************************************************************************ >> %log%
net stop /y "FS Rescan Service"
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...FS Rescan Service Stoped... >> %log%
echo ************************************************************************ >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...Uninstalling FS Rescan Service... >> %log%
echo ************************************************************************ >> %log%
C:\FS_Services\tools\instsrv "FS Rescan Service" remove >> %log%
echo ************************************************************************ >> %log%
echo %TIME% %DATE% ...FS Rescan Service Removed... >> %log%
echo ************************************************************************ >> %log%
goto :end

:checkfs
echo _ >> %log%
echo _ >> %log%
echo ...displaying volumes from diskpart... >> %log%
echo _ >> %log%
@for /f "tokens=1,2,3,4*" %%A in ('echo list volume ^| diskpart ^| findstr /i "\<%fs%\>"') do (
	if %%C == NTFS @echo select %%A %%B >> %volumes% 2>> %log%
	echo %%A %%B %%C %%D >> %log%
)
echo _ >> %log%
echo _ >> %log%
goto :end

:diskpart_list
echo _ >> %log%
echo _ >> %log%
echo ...displaying volumes from diskpart... >> %log%
echo _ >> %log%
@for /f "tokens=1,2,3,4*" %%A in ('echo list volume ^| diskpart ^| findstr /i "\<%fs%\>"') do (
	echo %%A %%B %%C %%D >> %log%
)
echo _ >> %log%
echo _ >> %log%
goto :end

:end