param([Parameter(Mandatory=$true)]$JSONFile)

function RemoveADGroup(){
    param([Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$false
}

function WeakenPasswordPolicy(){
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

function CreateADGroup {
    param ([Parameter(Mandatory=$true)]$groupObject)

    $name = $groupObject.name

    # Check if group exists
    if (-not (Get-ADGroup -Filter "Name -eq '$name'" -ErrorAction SilentlyContinue)) {
        # Create the AD group
        New-ADGroup -Name $name -GroupScope Global
    }
}

function CreateADUser {
    param ([Parameter(Mandatory=$true)] $userObject)

    $name = $userObject.name
    $password = $userObject.password

    $firstname, $lastname = $userObject.name -split ' '
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username
    $principalName = $username

    # Create the AD user
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue)) {

        New-ADUser -Name $name -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) | Enable-ADAccount

        # Add user to each group
        foreach ($group_name in $userObject.groups) {
            try {
                Get-ADGroup -Identity "$group_name"
                Add-ADGroupMember -Identity $group_name -Members $username
            }
            catch {
                Write-Warning "Group '$group_name' not found"
            }
        }
    }
}

WeakenPasswordPolicy

$json = Get-Content -Path $JSONFile | ConvertFrom-Json

$Global:domain = $json.domain

foreach ($group in $json.groups) {
    CreateADGroup $group
}

foreach ($user in $json.users) {
    CreateADUser $user
}