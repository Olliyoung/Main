Clear-Host

# Filsti
$filePath = "C:\PWSH\LØKKELØKKE.txt"

# Læs fil og konverter til små bogstaver
$text = (Get-Content $filePath -Raw).ToLower()

# Definer vokaler
$vokalerArray = 'a','e','i','o','u','y','æ','ø','å'

# Initialiser tællere
$vokaler = 0
$konsonanter = 0
$andre = 0

# Ydre løkke: 'for' gennem hvert tegn i teksten
for ($i = 0; $i -lt $text.Length; $i++) {

    $char = $text[$i]
    $erVokal = $false

    # Indre løkke: 'foreach' gennem vokalerne
    foreach ($vokal in $vokalerArray) {
        if ($char -eq $vokal) {
            $vokaler++
            $erVokal = $true
            break  # Stop indre løkke når vokal fundet
        }
    }

    # Hvis det ikke er vokal, tæl konsonant eller andet tegn
    if (-not $erVokal) {
        if ($char -match '[a-zæøå]') {
            $konsonanter++
        } else {
            $andre++
        }
    }
}

# Udskriv resultatet
Write-Output "Vokaler: $vokaler"
Write-Output "Konsonanter: $konsonanter"
Write-Output "Andre tegn: $andre"
Write-Host "Total tegn i filen: $($text.Length)"
Write-Host "
      |\      _,,,---,,_
ZZZzz /,`.-'`'    -.  ;-;;,_
     |,4-  ) )-,_. ,\ (  `'-'
    '---''(_/--'  `-'\_) 
"
# Jeg har valgt en kombination af 'for' og 'foreach' løkker for at effektivt gennemgå hvert tegn i teksten og sammenligne det med en liste af vokaler. 'For' løkken giver mig kontrol over indekset, mens 'foreach' løkken gør det nemt at tjekke hvert vokal. Dette gør koden både læsbar og effektiv.
