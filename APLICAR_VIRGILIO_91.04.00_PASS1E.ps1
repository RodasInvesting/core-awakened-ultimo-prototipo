$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

try {
    Write-Host ""
    Write-Host "=== CORE AWAKENED 91.04.00 PASS 1E - VIRGILIO INSTALLER FIX ===" -ForegroundColor Cyan
    Write-Host "Completa solamente el ajuste pendiente de main.gd." -ForegroundColor DarkGray
    Write-Host "No toca Fighter, rollback, NetworkManager ni PerfectBlock." -ForegroundColor DarkGray

    $mainPath = Join-Path $Root 'scripts\main.gd'
    if (!(Test-Path -LiteralPath $mainPath)) {
        throw 'No encuentro scripts\main.gd. Copia este ROOT en la raiz del proyecto.'
    }

    $c = [IO.File]::ReadAllText($mainPath, [Text.Encoding]::UTF8)

    # La integración de Virgilio debe existir previamente.
    if ($c -notmatch 'SND_VIRGILIO_AMBIENTE') {
        throw 'main.gd no contiene la integracion de Virgilio. No abras Godot y manda captura.'
    }

    # Ajuste exclusivo de volumen del escenario de Virgilio.
    $pattern = '(?ms)(^\s*"Virgilio":\s*\r?\n\s*audio_ambiente_escenario\.stream\s*=\s*SND_VIRGILIO_AMBIENTE\s*\r?\n\s*audio_ambiente_escenario\.volume_db\s*=\s*)-(?:10|5)\.0'
    if ($c -match $pattern) {
        $c = [regex]::Replace($c, $pattern, '${1}-3.0', 1)
    }
    elseif ($c -match '(?ms)^\s*"Virgilio":\s*\r?\n\s*audio_ambiente_escenario\.stream\s*=\s*SND_VIRGILIO_AMBIENTE\s*\r?\n\s*audio_ambiente_escenario\.volume_db\s*=\s*-3\.0') {
        Write-Host '[OK] Musica Virgilio ya estaba en -3 dB' -ForegroundColor Green
    }
    else {
        throw 'No pude localizar el bloque de musica de Virgilio en main.gd.'
    }

    $enc = New-Object Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($mainPath, $c, $enc)

    # Verificación final.
    $verify = [IO.File]::ReadAllText($mainPath, [Text.Encoding]::UTF8)
    if ($verify -notmatch '(?ms)^\s*"Virgilio":\s*\r?\n\s*audio_ambiente_escenario\.stream\s*=\s*SND_VIRGILIO_AMBIENTE\s*\r?\n\s*audio_ambiente_escenario\.volume_db\s*=\s*-3\.0') {
        throw 'Verificacion final fallo: el volumen de Virgilio no quedo en -3 dB.'
    }

    Write-Host '[OK] Musica Virgilio = -3 dB' -ForegroundColor Green
    Write-Host '[OK] PASS 1D visual ya queda completo' -ForegroundColor Green
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host " VIRGILIO - 91.04.00 PASS 1E OK" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ""
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
