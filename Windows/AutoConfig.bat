@echo off
echo Setting up password policies
net accounts /minpwlen:7 /maxpwage:30 /minpwage:10 /uniquepw:1 /forcelogoff:no /lockoutduration:30 /lockoutthreshold:7 
echo Password Policies:
echo Length: 7
echo Max Age: 30 Days
echo Min Age: 10 Days
echo Times Password can be resused: 1
echo Force Logoff: no
echo Lockout Duration: 30 Minutes
echo Lockout Threshold: 7
secedit.exe /export /cfg C:\secconfig.cfg
REM secedit.exe /configure /db %windir%\securitynew.sdb /cfg C:\secconfig.cfg /areas SECURITYPOLICY
