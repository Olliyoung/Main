# Import the Active Directory module
Import-Module ActiveDirectory

# Import the user CSV file
$users = Import-Csv -Path "C:\Users\Administrator\Downloads\userscsv.csv" -Delimiter ";"

# Define base OU where job role OUs will be created
$baseOU = "OU=Employees,DC=data,DC=local"
$domain = "data.local"  
$password = "Password1"  # Default password

# ✅ Ensure the base "Employees" OU exists
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Employees'" -SearchBase "DC=data,DC=local" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Employees" -Path "DC=data,DC=local" -ProtectedFromAccidentalDeletion $false
    Write-Host "Created base OU: Employees" -ForegroundColor Green
}

# ✅ Function to create an OU if it doesn't exist
function Ensure-OUExists {
    param ($OUName)
    $ouPath = "OU=$OUName,$baseOU"

    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'" -SearchBase $baseOU -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $OUName -Path $baseOU -ProtectedFromAccidentalDeletion $false
        Write-Host "Created OU: $ouPath" -ForegroundColor Green
    }

    return $ouPath
}

# ✅ Function to create an AD Group if it doesn't exist
function Ensure-GroupExists {
    param ($GroupName, $OUPath)
    if (-not (Get-ADGroup -Filter { Name -eq $GroupName } -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupCategory Security -GroupScope Global -Path $OUPath
        Write-Host "Created Group: $GroupName in $OUPath" -ForegroundColor Green
    }
}

# ✅ Loop through each user in the CSV file
foreach ($user in $users) {
    try {
        # Extract details from CSV
        $username = $user.Username
        $fullname = "$($user.Firstname) $($user.Lastname)"
        $upn = $user.Email
        $jobRole = $user.JobRole
        $privileges = $user.Privileges  # user/admin

        # ✅ Ensure OU exists for the job role
        $ouPath = Ensure-OUExists -OUName $jobRole

        # ✅ Ensure AD group for the job role exists
        Ensure-GroupExists -GroupName $jobRole -OUPath $ouPath

        # ✅ Define user parameters
        $userParameters = @{
            SamAccountName       = $username
            UserPrincipalName    = "$username@$domain"
            Name                = $fullname
            GivenName           = $user.Firstname
            Surname             = $user.Lastname
            Initials            = $user.Initials
            Title               = $jobRole
            Enabled             = $true
            DisplayName         = $fullname
            Path                = $ouPath
            EmailAddress        = $upn
            AccountPassword     = (ConvertTo-SecureString $password -AsPlainText -Force)
            PasswordNeverExpires = $false
            ChangePasswordAtLogon = $true
        }

        # ✅ Check if the user already exists
        if (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue) {
            Write-Host "User $username already exists." -ForegroundColor Yellow
        } else {
            # ✅ Create the user in the correct OU
            New-ADUser @userParameters
            Write-Host "Created user: $username in OU: $jobRole" -ForegroundColor Green

            # ✅ Add user to the Job Role group
            Add-ADGroupMember -Identity $jobRole -Members $username
            Write-Host "Added $fullname to group: $jobRole" -ForegroundColor Green

            # ✅ If the user has 'admin' privileges, add them to Domain Admins
            if ($privileges -eq "admin") {
                Add-ADGroupMember -Identity "Domain Admins" -Members $username
                Write-Host "Added $fullname to Domain Admins" -ForegroundColor Cyan
            }
        }

    } catch {
        Write-Host "Failed to create user $fullname. Error: $_" -ForegroundColor Red
    }
}
