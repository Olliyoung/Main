#Opgave B+C - Switch + Løkke
do {
    Clear-Host

    Write-Host  "Indlæser frugter..." -ForegroundColor White
    Start-Sleep -Milliseconds 400
    Write-Host " 🍎 🍌 🍇 🍉 🍒 🍋 " -ForegroundColor $randomcolor
    Start-Sleep -Milliseconds 500
    Clear-Host

    
    Write-Host "=================================" -ForegroundColor $randomcolor
    Write-Host "|       🍎  FRUGT-MENU 🍌       |"    -ForegroundColor White
    Write-Host "=================================" -ForegroundColor $randomcolor
    Write-Host ""

    # Frugt menu
    Write-Host "┌───────────────────────────────┐" -ForegroundColor $randomcolor
    Write-Host "│     $  Vælg din frugt!  $     |" -ForegroundColor White
    Write-Host "├───────────────────────────────┤" -ForegroundColor $randomcolor
    Write-Host "│ 1. Æble     │ 6.  Vindrue     │" -ForegroundColor $randomcolor
    Write-Host "│ 2. Pære     │ 7.  Mango       │" -ForegroundColor $randomcolor
    Write-Host "│ 3. Banan    │ 8.  Blomme      │" -ForegroundColor $randomcolor
    Write-Host "│ 4. Melon    │ 9.  Appelsin    │" -ForegroundColor $randomcolor
    Write-Host "│ 5. Tomat    │ 10. Citron      │" -ForegroundColor $randomcolor
    Write-Host "└───────────────────────────────┘" -ForegroundColor $randomcolor
    Write-Host ""

   
    $valg = Read-Host "Dit valg (1-10 eller q for at afslutte)"

    
    if ($valg -eq 'q' -or $valg -eq 'exit') {
        Clear-Host
        Write-Host "  ========================================" -ForegroundColor $randomcolor
        Write-Host "  | 🍏 Tak fordi du brugte mit script 🍏 |" -ForegroundColor White
        Write-Host "  =======================================" -ForegroundColor $randomcolor
        break
    }

    # Definer farver
    $colors = "Green","Yellow","Cyan","Magenta","Red","DarkYellow"
    $randomColor = Get-Random $colors  # tilfældig farve for sjov

    # Skriver hvad brugeren har valgt
    switch ($valg) {
        '1'  { Write-Host "✅ Du valgte: Æble" -ForegroundColor $randomColor } 
        '2'  { Write-Host "✅ Du valgte: Pære" -ForegroundColor $randomColor }
        '3'  { Write-Host "✅ Du valgte: Banan" -ForegroundColor $randomColor }
        '4'  { Write-Host "✅ Du valgte: Melon" -ForegroundColor $randomColor }
        '5'  { Write-Host "✅ Du valgte: Tomat" -ForegroundColor $randomColor }
        '6'  { Write-Host "✅ Du valgte: Vindrue" -ForegroundColor $randomColor }
        '7'  { Write-Host "✅ Du valgte: Mango" -ForegroundColor $randomColor }
        '8'  { Write-Host "✅ Du valgte: Blomme" -ForegroundColor $randomColor }
        '9'  { Write-Host "✅ Du valgte: Appelsin" -ForegroundColor $randomColor }
        '10' { Write-Host "✅ Du valgte: Citron" -ForegroundColor $randomColor }

        default { Write-Host "❌ Ugyldigt valg - prøv igen (1-10)" -ForegroundColor Red }
    }

    Write-Host ""
    Read-Host "Tryk ENTER for at vende tilbage til menuen"

} while ($true)
# Jeg har valgt Do While loop fordi det skal køre mindst en gang og så gentage indtil brugeren vælger at afslutte. Det er det jeg synes er nemmest at forstå og implementere i dette tilfælde.