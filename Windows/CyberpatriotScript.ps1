#-----------------------------------------------------------------------------------------------------------------
#
#Sets security policies (Password stuff, and auditing)
#Verified Operating Systems: Windows 7
#Expected Operating Systems: XP and beyond, Server 2003 and beyond
#TO-DO: I need to make it export secpol.cfg to a more secure file, rather than just exporting it to C:
#-----------------------------------------------------------------------------------------------------------------
#OLD VERSION. It only sets them correctly if the computer is on default security policies
#secedit /export /cfg c:\secpol.cfg /areas SECURITYPOLICY
#(gc C:\secpol.cfg) -replace ("MinimumPasswordLength = 0", "MinimumPasswordLength = 8") -replace ("PasswordComplexity = 0", "PasswordComplexity = 1") -replace ("MinimumPasswordAge = 0", "MinimumPasswordAge = 10") -replace ("MaximumPasswordAge = 42", "MaximumPasswordAge = 30") -replace ("PasswordHistorySize = 0", "PasswordHistorySize = 5") -replace ("ClearTextPassword = 1", "ClearTextPassword = 0") -replace ("LockoutBadCount = 0", "LockoutBadCount = 3")| Out-File C:\secpol.cfg
#secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
#rm -force c:\secpol.cfg

#NEW VERSION. Sets them on any computer regardless of if they have been altered previously
secedit /export /cfg c:\secpol.cfg /areas SECURITYPOLICY
$SecurityPolicyArray = @('MinimumPasswordLength', 'PasswordComplexity', 'MinimumPasswordAge', 'MaximumPasswordAge', 'PasswordHistorySize', 'LockoutBadCount', 'AuditSystemEvents', 'AuditLogonEvents', 'AuditObjectAccess', 'AuditPrivilegeUse', 'AuditPolicyChange', 'AuditAccountManage', 'AuditProcessTracking', 'AuditDSAccess', 'AuditAccountLogon')
$SecurityPolicyValues = @(8, 1, 10, 30, 5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3)
$ivalue = 0
for ($i = 0; $i -ne 15; $i++){
   [String]$PolicyLine = Select-String -Path "c:\secpol.cfg" -Pattern $SecurityPolicyArray[$i]
   $PolicyValueChar = $PolicyLine.IndexOf('=')
   [String]$PolicyValue = $PolicyLine.Substring($PolicyValueChar+2)
   if ($i -eq 3){
      [String]$PolicyValue = $PolicyValue.Substring(0, ($PolicyValue.IndexOf('C:\secpol.cfg:83')) - 1)
   }else{
   }
   [String]$StringSecurityPolicyArray = $SecurityPolicyArray[$i]
   [String]$StringSecurityPolicyValues = $SecurityPolicyValues[$ivalue]
   [String]$OldPolicy = ($StringSecurityPolicyArray + " = " + $PolicyValue)
   [String]$NewPolicy = ($StringSecurityPolicyArray + " = " + $StringSecurityPolicyValues)
   (gc C:\secpol.cfg) -replace ($OldPolicy), ($NewPolicy)| Out-File C:\secpol.cfg
   $ivalue++
}
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
(gc C:\secpol.cfg)
rm -force c:\secpol.cfg

#-----------------------------------------------------------------------------------------------------------------
#
#Creates secure passwords for all accounts
#Demotes unapproved admins down to standard users
#Promotes approved admins to admins
#Verified Operating Systems: Windows 7
#-----------------------------------------------------------------------------------------------------------------
Function generatePasswords([String]$theirname){
   $a = $theirname
   $b = $a.Substring(0,1)
   $b = $b.ToUpper()
   $b = $b.Replace("3", "Thr33")
   $b = $b.Replace("0", "Z3r0")
   $b = $b.Replace("1", "0n3")
   $b = $b.Replace("2", "Tw0")
   $b = $b.Replace("4", "F0ur")
   $b = $b.Replace("5", "Fiv3")
   $b = $b.Replace("6", "Six")
   $b = $b.Replace("7", "S3v3n")
   $b = $b.Replace("8", "Eight")
   $b = $b.Replace("9", "Nin3")
   $c = $a.Substring(1)
   $c = $c.Replace("a", "4")
   $c = $c.Replace("A", "4")
   $c = $c.Replace("e", "3")
   $c = $c.Replace("E", "3")
   $c = $c.Replace("s", "5")
   $c = $c.Replace("S", "5")
   $c = $c.Replace("b", "8")
   $c = $c.Replace("B", "8")
   $c = $c.Replace("l", "1")
   $c = $c.Replace("L", "1")
   $c = $c.Replace("o", "0")
   $c = $c.Replace("O", "0")
   $c = $c.Replace("z", "2")
   $c = $c.Replace("Z", "2")
   $c = $c.replace(" ", "")
   $d = $b + $c + "R0ck5!"
   [String]$theirpassword = $d
   Write-Host($theirpassword)
   return [String]$theirpassword
}

[String]$MainDude = $env:UserName
$userslist = Get-WmiObject win32_useraccount

$loopnumber = 0
while ($loopnumber -ne 1){
   Write-Host("Aside from you, are there other admins? y/n")
   $otheradmins = Read-Host
   if($otheradmins -eq "y"){
      Write-Host("How many other admins are there? Give a number.")
      $admincount = Read-Host
      $arraything = @(0) * $admincount
      For($i=0; $i -ne $admincount; $i++){
         Write-Host("Give me the name")
         $arraything[$i] = Read-Host
      }
      $loopnumber = 1
   }
   if($otheradmins -eq "n"){
      $loopnumber = 1
   }
   if($otheradmins -ne "y" -and $otheradmins -ne "n"){
      Write-Host("That is neither a y or n")
   }
}
$userslist | Foreach-Object {
   if($_.name -Contains $arraything){
      $group = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/administrators,group")
      $group.add("WinNT://"+$_.name+",user")
   }
   if($_.name -NotContains $MainDude -and $_.name -NotContains $arraything){
      $group = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/administrators,group")
      $group.remove("WinNT://"+$_.name+",user")
   }
   if($_.name -NotContains $MainDude){
      Write-Host($_.caption)
      ([adsi](“WinNT://”+$_.caption).replace(“\”,”/”)).SetPassword((generatePasswords($_.name)))
   }
}
#-----------------------------------------------------------------------------------------------------------------
#
#Disables local Guest and Administrator accounts
#Verified Operating Systems: Windows 7
#-----------------------------------------------------------------------------------------------------------------
$localguest = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/Guest")
$localguest.userflags.value = $guest.UserFlags.value -BOR 2
$localguest.SetInfo()
$localadministrator = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/Administrator")
$localadministrator.userflags.value = $localadministrator.UserFlags.value -BOR 2
$localadministrator.SetInfo()
#-----------------------------------------------------------------------------------------------------------------
#
#Removes unwanted users
#Verified Operating Systems: Windows 7
#-----------------------------------------------------------------------------------------------------------------
$loopnumber = 0
while ($loopnumber -ne 1){
   Write-Host("")
   Write-Host("Users")
   Write-Host("-------------")
   $userslist = Get-WmiObject win32_useraccount
   $userslist | Foreach-Object {
      $enableduser = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/"+$_.name)
      if([boolean]($enableduser.UserFlags.value  -BAND "2")){
      }else{
         Write-Host($_.name)
      }
   }
   Write-Host("")
   Write-Host("Should any of these users be removed? y/n")
   $badusers = Read-Host
   if($badusers -eq "y"){
      Write-Host("Give me the name")
      $baddude = Read-Host
      $userslist | Foreach-Object {
         if($_.name -Contains $baddude){
            $ADSIComp = [ADSI]("WinNT://"+$env:COMPUTERNAME)
            $ADSIComp.Delete('User',$_.name)
            Write-Host($_.name+" has been removed")
         }else{
         }
      }
   }
   if($badusers -eq "n"){
      $loopnumber = 1
   }
   if($badusers -ne "y" -and $badusers -ne "n"){
      Write-Host("That is neither a y or n")
   }
}
#-----------------------------------------------------------------------------------------------------------------
#
#Starts the Windows Firewall
#Verified Operating Systems: Windows 7
#-----------------------------------------------------------------------------------------------------------------
Set-Service MpsSvc -StartupType Automatic -Status Running

#For starting services
#Set-Service <servicename> -StartupType Automatic -Status Running

#For stopping services
#Set-Service <servicename> -StartupType Disabled -Status Stopped