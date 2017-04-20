#MODULES
###########################################################################################
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
Import-Module SkypeForBusiness -ErrorAction SilentlyContinue

#VARIABLES
###########################################################################################
#Credentials
    $Global:Credentials = Get-Credential

#Paths
    #Put in work dir path
    $temp = ""

#User Information
    $Global:UserCSV = "$temp\users.csv"
    $Global:Homedrive = "H:"
    $Global:HomedirectoryDefault = ""
    $Global:ProfileDefault = ""
    $Global:SmartcardLogonRequired = $true
    $Password = "" | ConvertTo-SecureString -AsPlainText -Force
    $Global:AccountPassword = $Password
    $Global:CompanyName = ""

    #OU Information, for adding in Active Directory
    $OUAdminsInt = "OU=Admins,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"
    $OUEmployeeInt = "OU=Users,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"
    $OUAdminsExt = "OU=Admins,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"
    $OUEmployeeExt = "OU=Externe,OU=Users,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"

    #Suffix for User Principal Name
    $Global:UPNSuffix "@example.com"

#SfB Information
    $Global:SIPDomain = ""
    $Global:UMMailboxPolicy = ""

#Errorhandling
    #ADUser creation
    $NumberofUsers = 0
    $NumberofErrors = 0
    #SfBUser creation
    $NumberofSfBUsers = 0
    $NumberofSfBErrors = 0

#Logging
    $LogFile = "$temp\log.txt"

#Email for Logging
    $Global:EmailLog = ""
    $Global:SMTPServer = ""

#Server
    #eg: srv-001.example.com
    $Global:ADServer = ""
    $Global:SfBServer = ""
    $Global:ExchangeServer = ""

#FUNCTIONS
###########################################################################################
Function Write-Log ($string){
    $(get-date -format "hh:mm:ss : ") + $string | out-file -Filepath $LogFile -append
    write-host $string
}

Function Show-ScriptUser {
    $ScriptUser = ([Environment]::UserDomainName + "\" + [Environment]::UserName)
    Write-Log "The Script was started with the User $ScriptUser"
}

Function Delete-OldLogs {
    $LogCheck = Test-Path $LogFile
    if($LogCheck -eq $true){
        Remove-Item $LogFile
        Write-Log "Old Logfile was found and deleted."
    }
}

Function Check-CSV{
    $CSVCheck = Test-Path $Global:UserCSV
    if($CSVCheck -eq $false){
        $NumberofErrors++
        Write-Log "ERROR $NumberofErrors# The CSV File was not found at $Global:UserCSV."
        Exit
    }
}

Function Set-OUPath{
    $Users = Import-Csv -Path $Global:UserCSV
    #No Employee info
    if($Company -eq ""){
        Write-Log "There is no Company mentioned. Please check your CSV entry under 'Company'."
        exit
    }
    #Internal Employees
    if($Company -like "$Global:CompanyName*"){
        if($UserPID -like "s*"){
            $Global:Path = $OUAdminsInt
            Write-Log "$UserPID will be added in OU $Global:Path"
        }
        if($UserPID -like "a*"){
            $Global:Path = $OUEmployeeInt
            Write-Log "$UserPID will be added in OU $Global:Path"
        }
        else{
            Write-Log "The OU could not be applied because of a wrong Prefix in the PID"
            exit
        }
    }
    #External Employees
    if($Company -notlike "$Global:CompanyName*"){
        if($UserPID -like "s*"){
            $Global:Path = $OUAdminsExt
            Write-Log "$UserPID will be added in OU $Global:Path"
        }
        if($UserPID -like "u*"){
            $Global:Path = $OUEmployeeExt
            Write-Log "$UserPID will be added in OU $Global:Path"
        }
        else{
            Write-Log "The OU could not be applied because of a wrong Prefix in the PID"
            exit
        }
    }
}

Function Create-ADUser{
    Delete-OldLogs
    Show-ScriptUser
    Check-CSV
    
    $Users = Import-Csv -Path $Global:UserCSV -Delimiter ";"

    foreach($User in $Users){
        $UserPID = $User.PID
        $UserPrincipalName = $UserPID + $Global:UPNSuffix
        $SAM = $UserPID
        $Firstname = $User.Firstname
        $Lastname = $User.Lastname
        $DisplayName = $Firstname + " " + $Lastname
        $Name = $DisplayName
        $OfficePhone = $User.OfficePhone
        $Fullname = $Lastname + " " + $Firstname
        
        $Global:Profile = $Global:ProfileDefault + $UserPID
        $Global:Homedirectory = $Global:HomedirectoryDefault + $UserPID

        $Department = $User.Department
        $Company = $User.Company

        $Enabled = $true
        
        Set-OUPath

        try{
            New-ADUser -Server $Global:ADServer -Path $Global:Path -Name $Fullname -UserPrincipalName $UserPrincipalName -SamAccountName $SAM -DisplayName $DisplayName -GivenName $Firstname -Surname $Lastname -OfficePhone $OfficePhone -Department $Department -Company $Company -SmartcardLogonRequired $Global:SmartcardLogonRequired -Enabled $Enabled -ProfilePath $Global:Profile -HomeDrive $Global:Homedrive -HomeDirectory $Global:Homedirectory -AccountPassword $Global:AccountPassword -ErrorAction SilentlyContinue
            #log for each User creation
            $NumberofUsers++
            Write-Log "$NumberofUsers# $DisplayName in Active Directory created"
        }
        catch{
            #log for each Error within User creation
            $NumberofErrors++
            Write-Log "ERROR $NumberofErrors# An Error occured with User $DisplayName."
        }
    }
    #Status Prints if Errors happened
    if($NumberofErrors -gt "0"){
        $CreatedUsers = $NumberofUsers - $NumberofErrors
        if($CreatedUsers -lt 0){
            Write-Log "There were 0 Users created"
        }
        else{
            Write-Log "There were $CreatedUsers Users created"
        }
        if($NumberofErrors -eq 1){
            Write-Log "Script finished with 1 Error"
        }
        else{
            Write-Log "Script finished with $NumberofErrors Errors"
        }
        
    }
    #Status Prints when no Errors happened
    if($NumberofErrors -eq "0"){
        if($NumberofUsers -eq 1){
        Write-Log "There was 1 User created"
        }
        else{
        Write-Log "There were $NumberofUsers Users created"
        }
        Write-Log "There were no Errors"
    }
}


Function Create-SfBAccount{
    $Users = Import-Csv -Path $Global:UserCSV -Delimiter ";"
    foreach($User in $Users){
        $UserPID = $User.PID
        $UserPrincipalName = $UserPID + $Global:UPNSuffix
        $Firstname = $User.Firstname
        $Lastname = $User.Lastname
        $DisplayName = $Firstname + " " + $Lastname
        $SipAddress = $Firstname + "." + $Lastname
        $SfBPhone = $User.OfficePhone
        $PhoneExtSfb = $SfBPhone | % {$_.substring($_.length-7)}
        $SfB = $User.SfB
        $eVoice = $User.eVoice

        if($SfB -like "No"){
            Write-Log "The User $DisplayName does not need a SfB Account."
            exit
        }

        if($SfB -like "Yes"){
            $NumberofSfBUsers ++
            if($eVoice -like "Yes"){
                try{
                    #Enable User on SfB 2015
                    Enable-CsUser -RegistrarPool $Global:SfBServer -Identity $DisplayName -SipAddress "sip:$SipAddress@$Global:SIPDomain"
                    Set-CsUser -Identity $DisplayName -EnterpriseVoiceEnabled $true -LineURI "tel:+$SfBPhone;ext=$PhoneExtSfb"
                    Write-Log "SfB Enterprise Voice Account enabled for User $DisplayName"

                    #Import Module from Exchange Server (https://thoughtsofanidlemind.com/2010/09/29/connecting-to-exchange-2010-with-powershell/)
                    $ExSession = New-PSSession –ConfigurationName Microsoft.Exchange –ConnectionUri "http://$Global:ExchangeServer/PowerShell/?SerializationLevel=Full" -Credential $Global:Credentials –Authentication Kerberos
                    Import-PSSession $ExSession
                        $MailboxStatus = [bool](Get-Mailbox $UserPID)
                        if($MailboxStatus -eq "True"){
                            #Enable UM Mailbox for User
                            Enable-UMMail -Identity $UserPID -UMMailboxPolicy $Global:UMMailboxPolicy -Extensions $PhoneExtSfb -PINExpired $false
                            Remove-PSSession $ExSession
                            Write-Log "UM Mailbox for User $DisplayName enabled."
                        }
                        if($MailboxStatus -eq "False"){
                            #If Mailbox for User doesn't exist, give Errormessage
                            Remove-PSSession $ExSession
                            Write-Log "ERROR: It seems like the Mailbox of the User $DisplayName is missing. Please create it."
                            $NumberofSfBErrors ++
                        }
                }
                catch{
                    Remove-PSSession $ExSession
                    Write-Log "ERROR: The script failed to Enable SfB Enterprise Voice for $DisplayName"
                    $NumberofSfBErrors ++
                }
            }
            else{
                try{
                    Enable-CsUser -RegistrarPool $Global:SfBServer -Identity $DisplayName -SipAddress "sip:$SipAddress@$Global:SIPDomain"
                    Write-Log "SfB PC-to-PC Account enabled for User $DisplayName"
                }
                catch{
                    Write-Log "ERROR: SfB PC-to-PC failed to enable User $DisplayName"
                    $NumberofSfBErrors ++
                }
            }
        }
    }
    #Status Prints if Errors happened
    if($NumberofSfBErrors -gt "0"){
        if($NumberofSfBErrors -eq 1){
            Write-Log "Script finished with 1 Error."
        }
        else{
            Write-Log "Script finished with $NumberofSfBErrors Errors."
        }
        
    }
    #Status Prints when no Errors happened
    if($NumberofErrors -eq "0"){
        if($NumberofUsers -eq 1){
        Write-Log "There was 1 User enabled"
        }
        else{
            Write-Log "There were $NumberofSfBUsers Users enabled for SfB."
        }
        Write-Log "There were no Errors."
    }
}

Function Send-Email{
    $Users = Import-Csv -Path $Global:UserCSV -Delimiter ";"
    foreach($User in $Users){
        $UserCreator = $User.Creator
        $Firstname = $User.Firstname
        $Lastname = $User.Lastname
        $DisplayName = $Firstname + " " + $Lastname

        Write-Log "$UserCreator created the user $DisplayName"
        
        Send-MailMessage -To $Global:EmailLog -From $Global:EmailLog -Subject "User $DisplayName was created over the Website with User $UserCreator" -Attachments $LogFile -SmtpServer $Global:SMTPServer
    }
}

#Start Skript
###########################################################################################
Create-ADUser
Create-SfBAccount
Send-Email
