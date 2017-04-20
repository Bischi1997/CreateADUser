# CreateADUser
Creates AD User with the help of a Simple HTML/PHP Website and a Powershell Script.

Powershell:
- Modules:
  - Active Directory Module
  - If SfB is used: Skype for Business Module
- Additional Information must be filled in, or the script won't work:
  - $temp: add the path, where the script and users.csv file is stored
  - $Global:UserCSV: this is the name and path of the users.csv file
  - $Global:Homedrive: here you can change the homedrive pathletter (e.g. H:)
  - $Global:HomedirectoryDefault: here you can add the Homedrivepath for each user (e.g. \\example.com\homedrives\%username%)
  - $Global:ProfileDefault: here you can add the profilepath for each user (e.g. \\example.com\profiles\%username%)
  - $Global:SmartcardLogonRequired: Valid Values are $true or $False
  - $Password: Here you can change the default password for the created users
  - User PID must contain an "s" as admin and an "a" as user. External Employees must have an "u" in PID
    - $OUAdminsInt: Here you can change the Organizational Unit for "s"-users
    - $OUEmployeeInt = "OU=Users,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"
    $OUAdminsExt = "OU=Admins,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"
    $OUEmployeeExt = "OU=Externe,OU=Users,OU=UserAccounts,OU=Persons,OU=example,DC=example,DC=com"

    #Suffix for User Principal Name
    $Global:UPNSuffix "@example.com"

#SfB Information
    $Global:SIPDomain = ""
    $Global:UMMailboxPolicy = ""
    
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

  
Webserver:
- Apache or Nginx
- PHP enabled
- index.html, styles.css, create_csv.php and users.csv in same directory
