@echo off
echo Setting up password policies
net accounts /minpwlen:7 /maxpwage:30 /minpwage:10 /uniquepw:1 /forcelogoff:no /lockoutduration:30 /lockoutthreshold:7 
echo Password Policies:
echo Length: 7
echo Max Age: 30
secedit.exe /export /cfg C:\secconfig.cfg
REM secedit.exe /configure /db %windir%\securitynew.sdb /cfg C:\secconfig.cfg /areas SECURITYPOLICY

auditpol
