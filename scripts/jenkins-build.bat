@echo off
setlocal

if not defined JAVA_HOME set JAVA_HOME=C:\Program Files\Java\jdk-25.0.4
if not defined MAVEN_HOME set MAVEN_HOME=C:\Program Files\apache-maven-3.9.16
set PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%

call "%MAVEN_HOME%\bin\mvn.cmd" -B clean test
set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% neq 0 (
  set MSG=🚨 **%JOB_NAME%** build **#%BUILD_NUMBER%** FAILED`nIreland / Nations League tickets detected!`n%BUILD_URL%
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0send-alert.ps1" -Message "%MSG%"
)

exit /b %EXIT_CODE%
