#Opgave A - If Statement
$vokaler = "aeiouyæøå"
$bogstav = (Read-Host "Skriv et bogstav").ToLower()

if ($bogstav -match '^[a-zæøå]$') {
    if ($vokaler -match $bogstav) {
        "$bogstav er en vokal"
    }
    else {
        "$bogstav er en konsonant"
    }
}
else {
    "'$bogstav' er ikke et bogstav"
}
