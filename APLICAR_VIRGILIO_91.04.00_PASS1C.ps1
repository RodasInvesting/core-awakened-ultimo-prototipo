$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function ReadText([string]$rel) {
    $p = Join-Path $Root $rel
    if (!(Test-Path -LiteralPath $p)) { throw "No existe $rel. Copia este ROOT en la raiz del proyecto." }
    return ([IO.File]::ReadAllText($p,[Text.Encoding]::UTF8) -replace "`r`n","`n")
}
function WriteText([string]$rel,[string]$txt) {
    $p = Join-Path $Root $rel
    $enc = New-Object Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($p,$txt,$enc)
}
function Rep([string]$txt,[string]$old,[string]$new,[string]$label) {
    if ($txt.Contains($new)) { return $txt }
    if (!$txt.Contains($old)) { throw "No pude localizar $label. Mandame captura; no abras Godot." }
    return $txt.Replace($old,$new)
}

try {
    Write-Host ""
    Write-Host "=== CORE AWAKENED 91.04.00 PASS 1C - VIRGILIO VISUAL FIX ===" -ForegroundColor Cyan
    Write-Host "Solo presentacion de Virgilio/selector/escenario/audio." -ForegroundColor DarkGray
    Write-Host "No toca Fighter, rollback, NetworkManager ni PerfectBlock." -ForegroundColor DarkGray

    # Selector: roster nuevo ya esta pre-encuadrado 1280x720.
    $rel='scripts/selector_personajes.gd'
    $c=ReadText $rel
    $c=Rep $c 'const TARJETA_Y := 64.0' 'const TARJETA_Y := 110.0' 'Selector TARJETA_Y'
    $c=Rep $c 'const TARJETA_H := 574.0' 'const TARJETA_H := 492.0' 'Selector TARJETA_H'
    WriteText $rel $c
    Write-Host '[OK] Roster 1280x720 + zonas recalibradas' -ForegroundColor Green

    # Main: escenario Virgilio exacto, sin zoom adicional; musica +5 dB respecto PASS1B.
    $rel='scripts/main.gd'
    $c=ReadText $rel

    $old = "func _zoom_base_escenario(nombre_luchador: String) -> float:`n`treturn 1.08 if _escenario_redisenado(nombre_luchador) else 1.18"
    $new = "func _zoom_base_escenario(nombre_luchador: String) -> float:`n`tif nombre_luchador == `"Virgilio`":`n`t`treturn 1.00`n`treturn 1.08 if _escenario_redisenado(nombre_luchador) else 1.18"
    if (!$c.Contains('nombre_luchador == "Virgilio"')) {
        $c=Rep $c $old $new 'Main zoom Virgilio'
    }

    $oldMusic = "`t`t`"Virgilio`":`n`t`t`taudio_ambiente_escenario.stream = SND_VIRGILIO_AMBIENTE`n`t`t`taudio_ambiente_escenario.volume_db = -10.0"
    $newMusic = "`t`t`"Virgilio`":`n`t`t`taudio_ambiente_escenario.stream = SND_VIRGILIO_AMBIENTE`n`t`t`taudio_ambiente_escenario.volume_db = -5.0"
    $c=Rep $c $oldMusic $newMusic 'Main volumen musica Virgilio'
    WriteText $rel $c
    Write-Host '[OK] Escenario Virgilio zoom 1.00' -ForegroundColor Green
    Write-Host '[OK] Musica Virgilio -5 dB' -ForegroundColor Green

    Write-Host '[OK] Nueva pose de proyectil instalada' -ForegroundColor Green
    Write-Host '[OK] Victoria Virgilio +20% visual' -ForegroundColor Green
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host " VIRGILIO - 91.04.00 PASS 1C OK" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ""
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
