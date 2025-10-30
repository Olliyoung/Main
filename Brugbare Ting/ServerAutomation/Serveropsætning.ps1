# - Vagn Tøttrup ---------------------------------------------------------------
# function Vis-Menu
# 
# 'Vis-Menu' er en funktion der skriver en menu tekst ud på skærmen og 
# afventer at der bliver indtastet et nummer for det ønskede valg på menuen.
# Afhængig af det indtastede nummer, kaldes en funktion der udfører
# den ønskede opgave.
# funktionen Vis-Menu kaldes som den sidste kommando i dette script.
# ------------------------------------------------------------------------------
function Vis-Menu() 
{
    Do
    {
        Clear-Host
        # Renser skærmen før menuen skrives ud. 
        # Bemærk, at resutatet af sidste menuvalg dermed fjernes fra skærmen.
        Write-Host @"
#---------------------------------------------------------------------------#
#                                                                           #
#                                                                           #
#          ▒█████   ██▓     ██▓ ██▒   █▓▓█████  ██▀███      ██▓             #
#         ▒██▒  ██▒▓██▒    ▓██▒▓██░   █▒▓█   ▀ ▓██ ▒ ██▒   ▓██▒             #
#         ▒██░  ██▒▒██░    ▒██▒ ▓██  █▒░▒███   ▓██ ░▄█ ▒   ▒██░             #
#         ▒██   ██░▒██░    ░██░  ▒██ █░░▒▓█  ▄ ▒██▀▀█▄     ▒██░             #
#         ░ ████▓▒░░██████▒░██░   ▒▀█░  ░▒████▒░██▓ ▒██▒   ░██████▒         #
#         ░ ▒░▒░▒░ ░ ▒░▓  ░░▓     ░ ▐░  ░░ ▒░ ░░ ▒▓ ░▒▓░   ░ ▒░▓  ░         #
#         ░ ▒ ▒░ ░ ░ ▒  ░ ▒ ░   ░ ░░   ░ ░  ░  ░▒ ░ ▒░   ░ ░ ▒  ░           #
#         ░ ░ ░ ▒    ░ ░    ▒ ░     ░░     ░     ░░   ░      ░ ░            #
#             ░ ░      ░  ░ ░        ░     ░  ░   ░            ░  ░         #
#                                                                           #
#                             Server Opsætning                              #
#                                                                           #
#     1. Operativ system info                                               #
#     2. Patchlevel/Hotfixes                                                #
#     3. IPv4 adresser, Subnet maske, Default gateway, DNS server.          #
#                                                                           #
#     4. Alle shares med rettigheder i alfabetisk orden.                    #
#     5. Liste over alle services som starter automatisk i Windows.         #
#     6. Dato og klokkeslæt for sidste genstart af serveren.                #
#                                                                           #
#     7. PowerShell versionen                                               #
#                                                                           #
#     0. Slut                                                               #
#                                                                           #
#---------------------------------------------------------------------------#
"@  -ForegroundColor Red -BackgroundColor Black

        $hovedmenu = Read-Host "Indtast valgmulighed" 
        # Read-Host afventer indtastning fra bruger. 
        # $hovedmenu vil efterfølgende indeholde de indtastede tegn.

        Switch ($hovedmenu)
        {
            1 {System-Info}
            2 {Hotfixes}
            3 {Networking-Info}

            4 {ShareOgRettigheder}
            5 {StartServices}
            6 {DateAndTimeRestartServer}

            7 {Find-PSVersion}
              # function PSVersion er fuld funktionsdygtig.


            0 {Luk-Meny}
            #hvis forkert valg starter man forfra til hovedmenu funktion
            default 
            {
                Write-Host -ForegroundColor red "Forkert valgmulighed"
                Start-sleep 1
            }
        }
        # Switch vælger (selektion) på basis af den indtastede værdi af 
        # $hovedmenu hvilken blok der skal udføres.
        # I dette eksempel kaldes forskellige funktioner.
    } Until ($hovedmenu -eq 0)
    # Do Until er en løkke der gennemløbes indtil betingelsen 
    # ($hovedmenu -eq 0) er sand. 
    # Det vil sige, at løkken gennemløbes så længe betingelsen er falsk.
}


#  1. Generel system information
function System-Info
{
    $info = Get-ComputerInfo
    [PSCustomObject]@{
        ComputerName        = $info.CsName
        Manufacturer        = $info.CsManufacturer
        Model               = $info.CsModel
        BIOS_Manufacturer   = $info.BiosManufacturer
       BIOS_Version        = $info.BiosSMBIOSBIOSVersion
       BIOS_ReleaseDate    = ($info.BiosReleaseDate).ToShortDateString()
       OS_Name             = $info.OsName
       OS_Version          = $info.OsVersion
       OS_Build            = $info.OsBuildNumber
       Installed_RAM_GB    = [math]::Round($info.CsTotalPhysicalMemory / 1GB, 2)
       Last_Boot_Time      = $info.OsLastBootUpTime
}   | Format-List
   
     Write-Host `n'System Info - Tast Enter for at Komme tilbage' -NoNewline
         Read-Host
}


# 2. Hotfixes
function Hotfixes
{
    Get-HotFix | Sort-Object Description
    Write-Host `n'HotFixDesc - Tast enter for at Komme tilbage' -NoNewline
    Read-Host
}


# 3. Networking Info
function Networking-Info
{
    Get-NetIPConfiguration |
    Where-Object {$_.IPv4Address -ne $null} |
    Select-Object `
    InterfaceAlias,
     @{Name='IPv4_Address';Expression={$_.IPv4Address.IPAddress}},
     @{Name='Prefix';Expression={$_.IPv4Address.PrefixLength}},
      @{Name='Default_Gateway';Expression={$_.IPv4DefaultGateway.NextHop}},
     @{Name='DNS_Servers';Expression={$_.DnsServer.ServerAddresses -join ', '}} |
        Format-List

    Write-Host `n'Networking Info - Tast enter for at Komme tilbage' -NoNewline
     Read-Host
}


# 4. Finder Alle Network Shares Og Rettigheder
function ShareOgRettigheder
{
# Get all shares
    Get-SmbShare |
    Where-Object {$_.ShareType -eq 'FileSystem'} |
    ForEach-Object {
        $share = $_

    # Get the share permissions
    Get-SmbShareAccess -Name $share.Name | ForEach-Object {
        [PSCustomObject]@{
            ShareName  = $share.Name
            Path       = $share.Path
            Account    = $_.AccountName
            Access     = $_.AccessControlType
            Permission = $_.AccessRight
        }
    }
} |
    Sort-Object ShareName, Account |
    Format-Table -AutoSize

    Write-Host `n'Network Shares - Tast enter for at Komme tilbage' -NoNewline
      Read-Host
   
}

#Viser alle programmer som starter automatisk
function StartServices
{
    Get-Service |
    Where-Object {$_.StartType -eq 'Automatic'} |
    Select-Object Name, DisplayName, Status |
    Sort-Object Name |
    Format-Table -AutoSize

    Write-Host `n'Start Services - Tast enter for at Komme tilbage' -NoNewline
      Read-Host
}



# 6. Last Boot Up Time
function DateAndTimeRestartServer
{
    # Get the last boot time of the system
    Get-CimInstance -ClassName Win32_OperatingSystem |
    Select-Object @{Name='LastBootUpTime';Expression={$_.LastBootUpTime}} |
    Format-Table -AutoSize

    Write-Host `n'Last Boot Up TIme - Tast enter for at Komme tilbage' -NoNewline
        Read-Host
}


# 7. PowerShell versionen
function Find-PSVersion
{
    Write-Host ""

  
   # Kommandoen viser din powershell version, på en meget nem måde  
   "PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) (Build $($PSVersionTable.PSVersion.Build))"


    Write-Host `n'Start Services - Tast enter for at Komme tilbage' -NoNewline
        Read-Host
}

# 0. Slut
function Luk-Meny
{
    Write-Host 'Ses næste gang... (┬┬﹏┬┬))' 
    Start-Sleep 0 
}


# Her kaldes funktionen Vis-Menu.
Vis-Menu