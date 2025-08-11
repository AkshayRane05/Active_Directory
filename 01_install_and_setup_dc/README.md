# 01 Installing the Domain Controller

1. Use `sconfig` to:
    - Change the hostname
    - Change IP address to static
    - Change the DNS Server to our own IP-address

2. Install the Active Directory Windows Feature

```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

```
import-Module ADDSDeployment
```

```
Install-ADDSForest
```

```
Get-NetIPAddress -IPAddress {DC-IPAddress}
```

```
Get-DNSClientServerAddress
```

```
Set-DNSClientServerAddress -IntefaceIndex 5 -ServerAddresses {DC-IPAddress}
```