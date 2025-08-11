# Installing Worksation PC

* Cloned Windows 11 workstation
* Changed the DNS of workstation to DC's IP address 

# Joining the Workstaion to Domain Controller

```
Add-Computer -DomainName xyz.com -Credential xyz\Administrator -Force -Restart
``` 