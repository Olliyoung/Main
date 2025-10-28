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
            #                             Windows Multi-Tool                            #
            #                                                                           #
            #     1. Serienummeret på disken på maskinen                                #
            #     2. De ti største/længste filer på maskinen                            #
            #     3. Find de ti ældste dll filer på maskinen                            #
            #                                                                           #
            #     4. HotFix’es på maskinen sorteret efter Description                   #
            #     5. Ledig fysisk hukommelse                                            #
            #     6. Ledig virtuel hukommelse                                           #
            #                                                                           #
            #     7. PowerShell versionen                                               #
            #                                                                           #
            #     0. Slut                                                               #
            #                                                                           #
            #     67. ???                                                               #
            #                                                                           #
            #---------------------------------------------------------------------------#
            " -ForegroundColor Magenta

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
 
}


# 2. De ti største/længste filer på maskinen
function Find-TiStoerste
{

}


# 3. Find de ti ældste dll filer på maskinen
function Find-Aeldste
{
    
}


# 4. HotFix’es på maskinen sorteret efter Description
function Find-HotFixDesc
{

}


function Find-LedigFysiskHukommelse
{

}



# 6. Ledig virtuel hukommelse
function Find-LedigVirtuelHukommelse
{

}


# 7. PowerShell versionen
function Find-PSVersion
{

}

# 67. ???
function ???
{
    
}
# 0. Slut
function Luk-Meny
{
    Write-Host 'Så lukker vi bixen ;-)' 
    Start-Sleep 3  
}


# Her kaldes funktionen Vis-Menu.
Vis-Menu    
