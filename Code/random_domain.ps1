param([Parameter(Mandatory = $true)] $OutputJSONFile)

# Get plain text content (no file metadata)
$group_names = Get-Content "data/group_names.txt" | ForEach-Object { $_.Trim() }
$first_names = Get-Content "data/first_names.txt" | ForEach-Object { $_.Trim() }
$last_names  = Get-Content "data/last_names.txt"  | ForEach-Object { $_.Trim() }
$passwords   = Get-Content "data/passwords.txt"   | ForEach-Object { $_.Trim() }

# Pick 10 random groups
$rgroups = Get-Random -Count 10 -InputObject $group_names

# Convert groups to hashtables
$hgroups = foreach ($group in $rgroups) {
    @{ "name" = $group }
}

$users = @()
$num_users = 100

for ($i = 0; $i -lt $num_users; $i++) {
    $first_name = Get-Random -InputObject $first_names
    $last_name  = Get-Random -InputObject $last_names
    $password   = Get-Random -InputObject $passwords
    $num_groups = Get-Random -Minimum 1 -Maximum 5
    # Always array format for groups
    $groups = @(Get-Random -Count $num_groups -InputObject $hgroups | ForEach-Object {$_.name})

    $new_user = [ordered]@{
        "name"     = "$first_name $last_name"
        "password" = $password
        "groups"   = $groups
    }

    $users += $new_user

    # Remove used data to avoid duplicate users
    $first_names = $first_names | Where-Object { $_ -ne $first_name }
    $last_names  = $last_names  | Where-Object { $_ -ne $last_name }
    $passwords   = $passwords   | Where-Object { $_ -ne $password }
}

# Final JSON object
$data = [ordered]@{
    "domain" = "xyz.com"
    "groups" = $hgroups
    "users"  = $users
}

# Write formatted JSON output
ConvertTo-Json -InputObject $data -Depth 4 | Out-File $OutputJSONFile -Encoding utf8

