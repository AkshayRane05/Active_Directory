param([Parameter(Mandatory=$true)]$JSONFile)

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
    param ([Parameter(Mandatory=$true)]$userObject)

    $name = $userObject.name
    $password = $userObject.password

    $firstname, $lastname = $userObject.name -split ' '
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username
    $principalName = $username

    # Create the AD user
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue)) {

        New-ADUser -Name $name -GivenName $firstname -Surname $lastname -UserPrincipalName $principalName@$Global:domain -SamAccountName $samAccountName -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

        # Add user to each group
        foreach ($group_name in $userObject.groups) {
            try {
                Get-ADGroup -Identity "$group_name"
                Add-ADGroupMember -Identity $group_name -Members $username
            }
            catch [Microsoft.ActiveDirectory.Management.ADGroupNotFoundException] {
                Write-Warning "Group '$group_name' not found"
            }
        }

    }
    
}

$json = Get-Content -Path $JSONFile | ConvertFrom-Json

$Global:domain = $json.domain

foreach ($group in $json.groups) {
    CreateADGroup $group
}

foreach ($user in $json.users) {
    CreateADUser $user
}