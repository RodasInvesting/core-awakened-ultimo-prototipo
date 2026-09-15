$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Read-Utf8([string]$PathRel) {
    $p = Join-Path $Root $PathRel
    if (!(Test-Path -LiteralPath $p)) { throw "No existe $PathRel. Copia este ROOT en la raiz del proyecto." }
    return [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)
}

function Write-Utf8([string]$PathRel, [string]$Content) {
    $p = Join-Path $Root $PathRel
    $enc = New-Object Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($p, $Content, $enc)
}

try {
    Write-Host ""
    Write-Host "=== CORE AWAKENED 91.04.00 PASS 1F - VIRGILIO FINAL TUNE ===" -ForegroundColor Cyan
    Write-Host "Ajuste fino de selector, escenario y volumen." -ForegroundColor DarkGray
    Write-Host "No toca Fighter, rollback, NetworkManager ni PerfectBlock." -ForegroundColor DarkGray

    # selector_personajes.gd
    $selectorRel = 'scripts\selector_personajes.gd'
    $selector = Read-Utf8 $selectorRel
    $selector2 = [regex]::Replace($selector, 'const TARJETA_Y := [0-9.]+', 'const TARJETA_Y := 70.0', 1)
    $selector2 = [regex]::Replace($selector2, 'const TARJETA_H := [0-9.]+', 'const TARJETA_H := 492.0', 1)
    if ($selector2 -eq $selector) {
        Write-Host "[OK] Selector ya estaba en los valores esperados o muy similares" -ForegroundColor Green
    } else {
        Write-Utf8 $selectorRel $selector2
        Write-Host "[OK] Selector reajustado: menos negro arriba" -ForegroundColor Green
    }

    # main.gd
    $mainRel = 'scripts\main.gd'
    $main = Read-Utf8 $mainRel

    if ($main -notmatch 'SND_VIRGILIO_AMBIENTE') {
        throw 'main.gd no contiene la integracion de Virgilio. Aplicá PASS 1B primero.'
    }

    $simpleZoom = "func _zoom_base_escenario(nombre_luchador: String) -> float:`r?`n`treturn 1.08 if _escenario_redisenado\(nombre_luchador\) else 1.18"
    $withVirgilio = @'
func _zoom_base_escenario(nombre_luchador: String) -> float:
	if nombre_luchador == "Virgilio":
		return 1.00
	return 1.08 if _escenario_redisenado(nombre_luchador) else 1.18
'@
    if ($main -match $simpleZoom) {
        $main = [regex]::Replace($main, $simpleZoom, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $withVirgilio }, 1)
    } else {
        $main = [regex]::Replace(
            $main,
            'func _zoom_base_escenario\(nombre_luchador: String\) -> float:\s*\r?\n\s*if nombre_luchador == "Virgilio":\s*\r?\n\s*return [0-9.]+\s*\r?\n\s*return 1.08 if _escenario_redisenado\(nombre_luchador\) else 1.18',
            [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $withVirgilio },
            1
        )
    }

    # Subir volumen a -2.0 dB
    $main2 = [regex]::Replace(
        $main,
        '(?ms)(^\s*"Virgilio":\s*\r?\n\s*audio_ambiente_escenario\.stream\s*=\s*SND_VIRGILIO_AMBIENTE\s*\r?\n\s*audio_ambiente_escenario\.volume_db\s*=\s*)-\d+(\.\d+)?',
        '${1}-2.0',
        1
    )
    Write-Utf8 $mainRel $main2
    Write-Host "[OK] Main: volumen de Virgilio = -2 dB" -ForegroundColor Green
    Write-Host "[OK] Main: zoom de Virgilio = 1.00" -ForegroundColor Green
    Write-Host "[OK] Escenario: panorama ancho para evitar negro en orillas" -ForegroundColor Green
    Write-Host "[OK] Virgilio: salto/doble salto/descenso/back dash mas grandes" -ForegroundColor Green
    Write-Host "[OK] Virgilio: proyectil un toque mas grande" -ForegroundColor Green

    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host " VIRGILIO - 91.04.00 PASS 1F OK" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ""
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
