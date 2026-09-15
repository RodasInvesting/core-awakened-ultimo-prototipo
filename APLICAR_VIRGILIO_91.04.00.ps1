$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$NL = "`n"
$T = "`t"

function Read-Text([string]$Rel) {
    $Path = Join-Path $Root $Rel
    if (-not (Test-Path -LiteralPath $Path)) {
        throw ('No existe: ' + $Rel + '. Copia este ROOT en la raiz del proyecto.')
    }
    $Text = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    return ($Text -replace "`r`n", "`n")
}

function Write-Text([string]$Rel, [string]$Text) {
    $Path = Join-Path $Root $Rel
    $Enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $Enc)
}

function Replace-Required([string]$Text, [string]$Old, [string]$New, [string]$Label) {
    if ($Text.Contains($New)) { return $Text }
    if (-not $Text.Contains($Old)) {
        throw ('No pude localizar: ' + $Label + '. Base distinta o cambio ya parcial.')
    }
    return $Text.Replace($Old, $New)
}

try {
    Write-Host ''
    Write-Host '=== CORE AWAKENED 91.04.00 PASS 1B - VIRGILIO ===' -ForegroundColor Cyan
    Write-Host 'Integracion aditiva sobre 91.03.00 RC1.' -ForegroundColor DarkGray
    Write-Host 'No toca Fighter, rollback, NetworkManager ni PerfectBlock.' -ForegroundColor DarkGray
    Write-Host ''

    # GAME STATE
    $Rel = 'scripts/game_state.gd'
    $C = Read-Text $Rel
    $C = Replace-Required $C '"Dax", "Krovan", "Nekhar"]' '"Dax", "Krovan", "Nekhar", "Virgilio"]' 'GameState.ROSTER'
    $C = Replace-Required $C '"Krovan", "Nekhar", "Varkhos"' '"Krovan", "Nekhar", "Virgilio", "Varkhos"' 'GameState.ESCENARIOS_VERSUS'
    Write-Text $Rel $C
    Write-Host '[OK] GameState' -ForegroundColor Green

    # SELECTOR PERSONAJES
    $Rel = 'scripts/selector_personajes.gd'
    $C = Read-Text $Rel
    $C = Replace-Required $C '"Krovan", "Nekhar", "Varkhos"' '"Krovan", "Nekhar", "Virgilio", "Varkhos"' 'SelectorPersonajes.ROSTER'
    if (-not $C.Contains('Color(0.72, 0.76, 0.58)')) {
        $Old = $T + 'Color(1.0, 0.78, 0.15),' + $NL + $T + 'Color(0.95, 0.10, 0.16),'
        $New = $T + 'Color(1.0, 0.78, 0.15),' + $NL + $T + 'Color(0.72, 0.76, 0.58),' + $NL + $T + 'Color(0.95, 0.10, 0.16),'
        $C = Replace-Required $C $Old $New 'SelectorPersonajes.COLORES'
    }
    $OldBorders = 'const X_BORDES := [9.95, 120.96, 229.67, 322.30, 410.34, 499.90, 589.47, 680.57, 769.38, 855.89, 946.22, 1037.32, 1154.45, 1268.52]'
    $NewBorders = 'const X_BORDES := [8.39, 112.31, 212.37, 296.28, 376.96, 461.52, 544.15, 625.48, 705.52, 785.56, 866.24, 970.17, 1044.40, 1158.65, 1265.80]'
    $C = Replace-Required $C $OldBorders $NewBorders 'SelectorPersonajes.X_BORDES'
    $C = $C.Replace('selector definitivo de 13 personajes', 'selector definitivo de 14 personajes con Virgilio')
    Write-Text $Rel $C
    Write-Host '[OK] Selector personajes' -ForegroundColor Green

    # SELECTOR ESCENARIOS
    $Rel = 'scripts/selector_escenarios.gd'
    $C = Read-Text $Rel
    if (-not $C.Contains('"Virgilio"')) {
        $C = Replace-Required $C '"Helena", "Jester", "Xenoid", "Dax", "Varkhos", "Krovan", "Nekhar"' '"Helena", "Jester", "Xenoid", "Dax", "Varkhos", "Krovan", "Nekhar", "Virgilio"' 'SelectorEscenarios.ESCENARIOS'
        $Old = $T + '"Nekhar": "SEPULCRO DE KHEMET",'
        $New = $Old + $NL + $T + '"Virgilio": "CHACO PARAGUAYO",'
        $C = Replace-Required $C $Old $New 'SelectorEscenarios.NOMBRES'
        $Old = $T + '"Nekhar": "res://assets/fondos/nekhar.png",'
        $New = $Old + $NL + $T + '"Virgilio": "res://assets/fondos/virgilio_chaco_paraguayo.png",'
        $C = Replace-Required $C $Old $New 'SelectorEscenarios.RUTAS'
        $Old = $T + '"Nekhar": Color(1.0, 0.38, 0.08),'
        $New = $Old + $NL + $T + '"Virgilio": Color(0.72, 0.76, 0.58),'
        $C = Replace-Required $C $Old $New 'SelectorEscenarios.COLORES'
        $C = $C.Replace('["Krovan", "Nekhar"]', '["Krovan", "Nekhar", "Virgilio"]')
    }
    Write-Text $Rel $C
    Write-Host '[OK] Selector escenarios' -ForegroundColor Green

    # PRESENTACION VS
    $Rel = 'scripts/presentacion_vs.gd'
    $C = Read-Text $Rel
    if (-not $C.Contains('"Virgilio"')) {
        $Old = $T + '"Nekhar": "gigantografias/nekhar_core_vs_910207.png",'
        $New = $Old + $NL + $T + '"Virgilio": "gigantografias/virgilio_vs.png",'
        $C = Replace-Required $C $Old $New 'PresentacionVS.POSTERS'
        $Old = $T + '"Nekhar": 1.24,'
        $New = $Old + $NL + $T + '"Virgilio": 1.12,'
        $C = Replace-Required $C $Old $New 'PresentacionVS.SCALE'
        $Old = $T + '"Nekhar": Vector2(22.0, 12.0),'
        $New = $Old + $NL + $T + '"Virgilio": Vector2(26.0, 4.0),'
        $C = Replace-Required $C $Old $New 'PresentacionVS.OFFSET'
    }
    Write-Text $Rel $C
    Write-Host '[OK] Presentacion VS' -ForegroundColor Green

    # RESULTADO
    $Rel = 'scripts/resultado.gd'
    $C = Read-Text $Rel
    if (-not $C.Contains('"Virgilio"')) {
        $C = Replace-Required $C '"Krovan":"krovan.png", "Nekhar":"nekhar.png", "Varkhos":"varkhos.png"' '"Krovan":"krovan.png", "Nekhar":"nekhar.png", "Virgilio":"virgilio_chaco_paraguayo.png", "Varkhos":"varkhos.png"' 'Resultado.FONDOS'
    }
    Write-Text $Rel $C
    Write-Host '[OK] Resultado' -ForegroundColor Green

    # MAIN - solo registros aditivos
    $Rel = 'scripts/main.gd'
    $C = Read-Text $Rel
    if (-not $C.Contains('"Virgilio": return Virgilio.new()')) {
        $Old = $T + $T + '"Nekhar": return Nekhar.new()' + $NL + $T + $T + '"Varkhos": return Varkhos.new()'
        $New = $T + $T + '"Nekhar": return Nekhar.new()' + $NL + $T + $T + '"Virgilio": return Virgilio.new()' + $NL + $T + $T + '"Varkhos": return Varkhos.new()'
        $C = Replace-Required $C $Old $New 'Main fabrica luchadores'
    }
    if (-not $C.Contains('res://assets/fondos/virgilio_chaco_paraguayo.png')) {
        $Old = $T + '"Nekhar": "res://assets/fondos/nekhar.png",' + $NL + $T + '"Varkhos": "res://assets/fondos/varkhos.png",'
        $New = $T + '"Nekhar": "res://assets/fondos/nekhar.png",' + $NL + $T + '"Virgilio": "res://assets/fondos/virgilio_chaco_paraguayo.png",' + $NL + $T + '"Varkhos": "res://assets/fondos/varkhos.png",'
        $C = Replace-Required $C $Old $New 'Main FONDOS'
    }
    if (-not $C.Contains('"Virgilio": Color(0.72, 0.76, 0.58)')) {
        $Old = $T + '"Nekhar": Color(1.0, 0.38, 0.08),' + $NL + $T + '# 90.11.15'
        $New = $T + '"Nekhar": Color(1.0, 0.38, 0.08),' + $NL + $T + '"Virgilio": Color(0.72, 0.76, 0.58),' + $NL + $T + '# 90.11.15'
        $C = Replace-Required $C $Old $New 'Main color escenario'
    }
    if (-not $C.Contains('SND_VIRGILIO_AMBIENTE')) {
        $Old = 'const SND_NEKHAR_AMBIENTE := preload("res://assets/sonidos/escenarios/nekhar.mp3")'
        $New = $Old + $NL + 'const SND_VIRGILIO_AMBIENTE := preload("res://assets/sonidos/escenarios/virgilio_chaco_paraguayo.mp3")'
        $C = Replace-Required $C $Old $New 'Main musica Virgilio const'
        $Old = $T + $T + $T + 'audio_ambiente_escenario.volume_db = -8.5' + $NL + $T + $T + '"Magnus":'
        $New = $T + $T + $T + 'audio_ambiente_escenario.volume_db = -8.5' + $NL + $T + $T + '"Virgilio":' + $NL + $T + $T + $T + 'audio_ambiente_escenario.stream = SND_VIRGILIO_AMBIENTE' + $NL + $T + $T + $T + 'audio_ambiente_escenario.volume_db = -10.0' + $NL + $T + $T + '"Magnus":'
        $C = Replace-Required $C $Old $New 'Main musica Virgilio match'
    }
    $C = $C.Replace('["Varkhos", "Aethel", "Cibor-X", "Helena", "Kali", "Krovan", "Nekhar"]', '["Varkhos", "Aethel", "Cibor-X", "Helena", "Kali", "Krovan", "Nekhar", "Virgilio"]')
    $C = $C.Replace('"Krovan", "Nekhar", "Varkhos"', '"Krovan", "Nekhar", "Virgilio", "Varkhos"')
    Write-Text $Rel $C
    Write-Host '[OK] Main' -ForegroundColor Green

    # VERIFICACION
    $Checks = @(
        @('scripts/game_state.gd','Virgilio'),
        @('scripts/selector_personajes.gd','Virgilio'),
        @('scripts/selector_escenarios.gd','Virgilio'),
        @('scripts/presentacion_vs.gd','Virgilio'),
        @('scripts/resultado.gd','Virgilio'),
        @('scripts/main.gd','Virgilio.new()'),
        @('scripts/virgilio.gd','class_name Virgilio')
    )
    foreach ($Pair in $Checks) {
        $Txt = Read-Text $Pair[0]
        if (-not $Txt.Contains($Pair[1])) {
            throw ('Verificacion final fallo: ' + $Pair[0] + ' -> ' + $Pair[1])
        }
    }

    Write-Host ''
    Write-Host '===============================================' -ForegroundColor Green
    Write-Host ' VIRGILIO INTEGRADO - 91.04.00 PASS 1B OK' -ForegroundColor Green
    Write-Host '===============================================' -ForegroundColor Green
    Write-Host 'Ahora si: abre project.godot y espera la importacion.' -ForegroundColor Yellow
    exit 0
}
catch {
    Write-Host ''
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
