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
        Write-Host "
            #----------------------------------------------------------# 
            #                 Enkle cmdlet opgaver                     #
            #                                                          #
            #                                                          #
            #   1. Serienummeret på disken på maskinen                 #
            #   2. De ti største/længste filer på maskinen             #
            #   3. Find de ti ældste dll filer på maskinen             #
            #                                                          #
            #   4. HotFix’es på maskinen sorteret efter Description    #
            #   5. Ledig fysisk hukommelse                             #
            #   6. Ledig virtuel hukommelse                            #
            #                                                          #
            #   7. PowerShell versionen                                #
            #                                                          #
            #   0. Slut                                                #
            #                                                          #
            #   67. ???                                                #
            #----------------------------------------------------------#
            "

        $hovedmenu = Read-Host "Indtast valgmulighed"
        # Read-Host afventer indtastning fra bruger. 
        # $hovedmenu vil efterfølgende indeholde de indtastede tegn.

        Switch ($hovedmenu)
        {
            1 {Find-SerieNummer}
            2 {Find-TiStoerste}
            3 {Find-Aeldste}

            4 {Find-HotFixDesc}
            5 {Find-LedigFysiskHukommelse}
            6 {Find-LedigVirtuelHukommelse}

            7 {Find-PSVersion}
              # function PSVersion er fuld funktionsdygtig.

            67 {???}

            0 {Luk-Meny}
            #hvis forkert valg starter man forfra til hovedmenu funktion
            default 
            {
                Write-Host -ForegroundColor red "Forkert valgmulighed"
                Start-sleep 2
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


#  1. Serienummeret på disken på maskinen 
function Find-SerieNummer
{
    # Der findes flere mulige løsninger, både med hensyn til cmdlet
    # og med hensyn til hvilket 'nummer' der menes.
    # Get-WmiObject er en mulig cmdlet. 
    Get-WmiObject Win32_bios | Select-Object SerialNumber
    Write-Host 'SerieNummer - Tast Enter' -NoNewline
    Read-Host
}


# 2. De ti største/længste filer på maskinen
function Find-TiStoerste
{
    # Denne opgave bør løses i en række step. Bemærk, at alle filer
    # på disken skal undersøges så det tager lang tid, så start i en
    # velvalgt folder, og vent til alt andet er på plads inden
    # søgningen udvides til alle filer på disken.
    # Step 1: find alle filer på disken (aktuel folder). Get-ChildItem
    # Step 2: Pipeline videre og sorter objekterne. Sort-Object
    # Step 3: Pipeline videre og udvælg de 10 første. Select-Object
    # Step 4: Pipeline videre og afslut med at formatere i tabelform. Format-Table
    # Step 5: Tilføj filer i undermapper. Get-ChildItem parameter
    # Step 6: Vælg c:\ som start-path. Get-ChildItem parameter / Husk Ctrl-C  ;-)
    # Step 7: Der kan komme røde fejltekst pga. manglende adgang. -ErrorAction

    # Sig til brugeren, at vi lige går i gang og det kan tage lidt tid
    Write-Host 'Vent Et Øjeblik Finder De 10 Største Filer...'

    # Find alle filer på C:\ (inklusive undermapper), men spring filer over, vi ikke har adgang til
    $files = Get-ChildItem -Path C:\ -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First 10 -Property Name, Length

    # Vis resultatet i et overskueligt tabel-format
    $files | Format-Table -AutoSize

    # Fortæl brugeren, at programmet venter på, at der trykkes enter
    Write-Host 'TiStoerste - Tast enter' -NoNewline
    Read-Host
}


# 3. Find de ti ældste dll filer på maskinen
function Find-Aeldste
{
    # Repetiton i forhold til TiStoerste
    Write-Host 'Finder de 10 ældeste DLL filer...'
    Get-ChildItem -Path C:\ -Recurse -File -Filter "*.dll" -ErrorAction SilentlyContinue | Sort-Object CreationTime | Select-Object -First 10 | Select-Object name, CreationTime | Format-Table -AutoSize
    Write-Host 'Aeldste - Tast enter' -NoNewline
    Read-Host
}


# 4. HotFix’es på maskinen sorteret efter Description
function Find-HotFixDesc
{
    # Get-HotFix
    Get-HotFix | Sort-Object Description
    Write-Host `n 'HotFixDesc - Tast enter' -NoNewline
    Read-Host
}


function Find-LedigFysiskHukommelse
{
    Write-Host 'Skriv drevbogstav for den virtuelle disk (fx E) ' -NoNewline
    $driveLetter = Read-Host

    # Hent info om drevet
    $drive = Get-PSDrive $driveLetter

    if ($drive) {
        $freeMB = [math]::Round($drive.Free / 1MB, 2)
        $freeGB = [math]::Round($drive.Free / 1GB, 2)
        Write-Host "Der er $freeMB MB ($freeGB GB) ledig plads på drev $driveLetter`:"
    }
    else {
        Write-Host "Drevet blev ikke fundet."
    }

    Write-Host 'Tryk enter for at afslutte...' -NoNewline
    Read-Host
}



# 6. Ledig virtuel hukommelse
function Find-LedigVirtuelHukommelse
{
    Import-Module Hyper-V

$path = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
Get-ChildItem -Path $path -File | Format-Table Name, CreationTime -AutoSize

$valg = Read-Host "Skriv filnavnet"

$vhd = Get-VHD -Path (Join-Path $path $valg)

if ($vhd) {
    $maxSizeBytes = $vhd.FileSize # actual file size on disk (used space)
    $virtualDiskSizeBytes = $vhd.Size # virtual disk max size (capacity)

    $freeBytes = $virtualDiskSizeBytes - $maxSizeBytes

    $enhed = Read-Host "Vil du se størrelsen i MB, GB eller %? Skriv 'MB', 'GB' eller '%'"

    switch ($enhed) {
        "MB" { 
            Write-Host "Ledig plads: $([math]::Round($freeBytes / 1MB, 2)) MB"
            Write-Host "Brugt plads: $([math]::Round($maxSizeBytes / 1MB, 2)) MB"
            Write-Host "Total størrelse: $([math]::Round($virtualDiskSizeBytes / 1MB, 2)) MB"
        }
        "GB" { 
            Write-Host "Ledig plads: $([math]::Round($freeBytes / 1GB, 2)) GB"
            Write-Host "Brugt plads: $([math]::Round($maxSizeBytes / 1GB, 2)) GB"
            Write-Host "Total størrelse: $([math]::Round($virtualDiskSizeBytes / 1GB, 2)) GB"
        }
        "%" { 
            $pctFree = [math]::Round(($freeBytes / $virtualDiskSizeBytes) * 100, 2)
            $pctUsed = [math]::Round(($maxSizeBytes / $virtualDiskSizeBytes) * 100, 2)
            Write-Host "Ledig plads: $pctFree %"
            Write-Host "Brugt plads: $pctUsed %"
        }
        default {
            Write-Host "Ugyldigt valg."
        }
    }
}
else {
    Write-Host "Filen blev ikke fundet eller er ikke en gyldig VHD-fil."
}


    Write-Host 'LedigVirtuelHukommelse - Tast enter' -NoNewline
    Read-Host
}


# 7. PowerShell versionen
function Find-PSVersion
{
    $PSVersionTable.PSVersion
    Write-Host `n 'Tast enter' -NoNewline
    Read-Host
}

# 67. ???
function ???
{

'⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣴⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣦⣤⣤⣤⣀⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⢿⣟⣛⣭⡽⠶⠶⠶⠮⠭⠭⣭⣭⣭⣭⣭⣭⣭⣿⣿⣯⣭⣥⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⢟⣫⣶⠿⣫⣭⣶⠿⠿⣿⣿⣿⠿⢿⣷⣶⣮⣭⣭⣭⣭⣭⣷⣶⣶⣶⣾⣽⣿⣷⣦⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣫⣾⣟⣩⣞⣫⣵⣿⣿⣿⣿⣿⣿⣿⣯⢻⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣶⣍⡻⣿⣿⣿⣷⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣵⣿⡿⠿⠛⠛⠛⠛⠿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣣⣿⣿⣿⣿⠿⢿⣿⣷⣼⣿⣿⣿⣇⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣚⣯⣽⣿⣿⣿⣿⢻⣿⣏⡅⠀⠀⠀⠀⠀⠠⣿⣷⣯⡛⣿⣿⣿⣿⣿⣿⡿⠟⠉⠁⠐⣿⣿⣶⣽⣿⣟⣛⡻⠿⣦⡀⠀⠀
⠀⢀⣴⣞⣯⣷⠶⣒⣛⣛⡻⢿⣷⣿⣷⣾⣶⣾⢟⣿⣿⣿⣶⣯⣟⣫⣿⣿⣿⣿⣿⣍⠀⣀⣤⣤⣬⣭⣽⣿⣿⣿⣿⣿⣿⣟⢶⡝⣦⠀
⠀⣿⡿⣾⣿⣵⣿⣿⣿⣿⣿⣷⣾⣭⣽⣿⣭⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⡿⠿⢟⣫⣭⣭⣽⣿⣷⣿⢸⠀
⠀⣿⡇⣿⣿⣿⡿⠿⢟⣴⣬⣛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣷⣝⣛⢿⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⢟⣿⢸⠀
⠀⢿⣧⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣷⣮⢙⡻⠿⣿⣿⣯⣭⣾⡇⣿⣿⣟⣭⣻⣿⣿⣿⣿⣿⡿⣸⣿⠿⢿⣿⣿⡿⡁⢹⣿⣷⢿⣱⠇⠀
⠀⠀⠻⢷⣝⣿⣿⣿⣿⣧⠉⠻⢿⣿⣿⢸⣿⣿⣷⣶⣭⣝⢛⠿⢿⣿⣿⣿⣿⣿⣯⣙⣛⣭⣾⣿⣿⣿⣿⠿⡋⣾⣿⡈⣿⣿⣿⡏⠀⠀
⠀⠀⠀⠀⠸⣽⣿⣿⣿⣿⣷⡽⣿⣷⣆⢘⠿⣿⣿⣿⣿⣿⢸⣿⣿⣶⣶⣶⡎⣭⣭⣭⣭⡩⣭⣭⣽⣦⣰⣿⣧⢿⣿⡇⣿⣿⣿⠀⠀⠀
⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣮⣻⣏⣿⣿⣾⣯⣍⠛⠋⠻⢿⣿⣿⣿⣿⡇⣿⣿⣿⣿⡇⣿⣿⣿⣿⡟⣿⠟⠈⠉⠀⣿⣿⡏⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣾⡿⣿⣿⣿⣿⣿⢦⣴⣦⣬⣍⡛⠛⠈⠛⠛⠛⠛⠁⠙⠛⠛⠉⠀⠀⠀⠀⢠⡆⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣮⣿⡻⣿⢏⣾⣿⣿⣿⣿⣿⣷⣶⣾⣷⣶⣄⣴⣶⣤⡤⣶⣶⡆⣾⡿⡸⣱⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣷⣝⡻⢶⣽⣻⢿⣿⣷⣭⣝⣻⣿⡿⠿⠿⠏⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⡿⠱⣿⣃⣵⣿⣿⣿⣧⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣶⣝⡻⢷⣮⣝⡻⢿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⣿⡿⣿⣿⣿⣿⣿⡄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠿⢷⣮⣝⡻⢿⣷⣮⣭⣛⣻⠿⠿⣿⣶⣶⣶⣶⣿⣿⣿⠿⢿⣛⣽⣾⣿⡿⣹⣿⣿⡇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣾⣶⣭⣽⣛⣛⠿⠿⠶⢶⣶⣶⣶⣶⡿⠿⠿⢟⣛⣭⣷⣿⣿⣿⣿⠇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠛⠛⠛⠛⠿⠿⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀'
Write-Host 'Tast enter' -NoNewline
Read-Host

}

# 0. Slut
function Luk-Meny
{
    Write-Host 'Så lukker vi bixen ;-)' 
    Start-Sleep 3  
}


# Her kaldes funktionen Vis-Menu.
Vis-Menu    
