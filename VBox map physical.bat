set VBOX_DIR="C:\Program Files\Oracle\VirtualBox"



@echo off
NET SESSION
IF %ERRORLEVEL% NEQ 0 GOTO ELEVATE
GOTO ADMINTASKS
EXIT
:ELEVATE
CD /d %~dp0
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '', '', 'runas', 1);close();"
EXIT

:ADMINTASKS
cd "%VBOX_DIR%"
IF NOT EXIST VBoxManage.exe GOTO FIND_VBOX
IF EXIST .\DIRECT_DRIVE (
	ECHO "WARNING! THE FOLLOWING FILES WILL BE DELEATED/REPLACED"
	DIR /B .\DIRECT_DRIVE
	PAUSE
	RMDIR /S /Q .\DIRECT_DRIVE
)
IF NOT EXIST .\DIRECT_DRIVE mkdir .\DIRECT_DRIVE
FOR /L %%d IN (0,1,26) DO (
	VBoxManage internalcommands createrawvmdk -filename .\DIRECT_DRIVE\%%d.vmdk -rawdisk \\.\PHYSICALDRIVE%%d
)
cls
echo "Done"
echo "In order to use physical drives VirtualBox must be started as admin"
explorer.exe %VBOX_DIR%\DIRECT_DRIVE
EXIT

:FIND_VBOX

ECHO "VirtualBox not found, atempting to locate"
FOR %%D IN (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) DO (
	IF EXIST "%%D:\Program Files\Oracle\VirtualBox\VBoxManage.exe" set VBOX_DRIVE=%%D&(
		SET VBOX_DIR="%VBOX_DRIVE%:\Program Files\Oracle\VirtualBox"
		GOTO ADMINTASKS
	)
		IF EXIST "%%D:\Program Files (x86)\Oracle\VirtualBox\VBoxManage.exe" set VBOX_DRIVE=%%D&(
		SET VBOX_DIR="%VBOX_DRIVE%:\Program Files (x86)\Oracle\VirtualBox"
		GOTO ADMINTASKS
	)
)
:FIND_VBOX_IN_REGISTRY
REM Fallback if manual method fails... i hate accessing the registry to do this
FOR /F "tokens=2* skip=2" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Oracle\VirtualBox" /v "InstallDir"') do SET VBOX_DIR=%%b
IF EXIST "%VBOX_DIR%\VBoxManage.exe" GOTO ADMINTASKS
:NOT_FOUND
echo "Was unable to find VirtualBox. Is it installed?"
echo "Please edit this file and change line 1 to where your virtualbox is installed"
pause
start notepad.exe "%~f0"
exit