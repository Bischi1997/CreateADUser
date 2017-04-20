# CreateADUser
Creates AD User with the help of a Simple HTML/PHP Website and a Powershell Script.

## Attention: ##
- User PID must contain an "s" as admin and an "a" as user. External Employees must have an "u" in PID

## Webserver: ##
- Apache or Nginx
- PHP enabled
- index.html, styles.css, create_csv.php and users.csv in same directory

## Powershell: ##
Modules:
- Active Directory Module
- If SfB is used: Skype for Business Module

### Additional Information must be filled in, or the script won't work: ###

|Variable                       | Description|
|-------------                  | -------------|
|$temp                          | add the path, where the script and users.csv file is stored|
|$Global:UserCSV                | this is the name and path of the users.csv file|
|$Global:Homedrive              | Here you can change the homedrive pathletter (e.g. H:)|
|$Global:HomedirectoryDefault   | here you can add the Homedrivepath for each user (e.g. \\example.com\homedrives\%username%)|
|$Global:ProfileDefault         | here you can add the profilepath for each user (e.g. \\example.com\profiles\%username%)|
|$Global:SmartcardLogonRequired | Valid Values are $true or $False|
|$Password                      | Here you can change the default password for the created users|
|$Global:CompanyName            | Here you can add the name of your Company (must be the same you fill in for internal users on the website!)|
|$OUAdminsInt                   | Here you can change the Organizational Unit for "s"-users who are internals
|$OUEmployeeInt                 | Here you can change the Organizational Unit for "a"-users
|$OUAdminsExt                   | Here you can change the Organizational Unit for "s"-users who are externals
|$OUEmployeeExt                 | Here you can change the Organizational Unit for "u"-users
|$Global:UPNSuffix              | Here you change your UPNSuffix (e.g. "@example.com")|
|$Global:SIPDomain              | here you have to add the SIP-Domain of your SfB installation|
|$Global:UMMailboxPolicy        | This is different in every Company, you as administrator should know this.|
|$LogFile                       | Here you can change the path of your logfile (e.g. "$temp\log.txt")|
|$Global:EmailLog               | Here you can add an email-account (e.g. createaduser@example.com)|
|$Global:SMTPServer             | Here you have to add your smtp server (e.g. smtp.example.com)|
|$Global:ADServer               | This must be your Active Directory Server (e.g. srv-001.example.com)|
|$Global:SfBServer              | This must be your Skype for Business Server (e.g. srv-002.example.com)|
|$Global:ExchangeServer         | This must be your Exchange Server (e.g. srv-003.example.com)|
