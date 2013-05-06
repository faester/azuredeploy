@echo off
:: Leave things as they are if this is already set
if not "%ServiceHostingSDKInstallPath%" == "" (
   goto :eof
)

:: Set up paths and environment variables
:setup
set WindowsAzureEmulatorInstallPath=
for /f "usebackq tokens=2,*" %%p in (`"reg query "HKLM\SOFTWARE\Microsoft\Windows Azure Emulator" /v InstallPath /s 2>NUL | find "InstallPath""`) do (
 set WindowsAzureEmulatorInstallPath=%%q
)

if "%WindowsAzureEmulatorInstallPath%" == "" (
  echo The Windows Azure Emulator is not installed.
) else (
  call :setemulatorpath
) 
call :setroot "%~dp0..\"
goto :chatter


:: Display some information
:chatter
if not '%1'=='/quiet' (
 echo Windows Azure SDK Shell
 title Windows Azure SDK Environment
 cd /D %ServiceHostingSDKInstallPath%
)
goto :eof

:: Get fully qualified path without the ..
:setroot
   set ServiceHostingSDKInstallPath=%~fp1
   path %ServiceHostingSDKInstallPath%\bin;%PATH%
goto :eof

:setemulatorpath
path %WindowsAzureEmulatorInstallPath%emulator;%WindowsAzureEmulatorInstallPath%emulator\devstore;%PATH%
goto :eof