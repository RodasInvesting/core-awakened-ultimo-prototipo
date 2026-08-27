$ErrorActionPreference = 'Stop'

$PatchDir = $PSScriptRoot
$ProjectRoot = $PatchDir
if (-not (Test-Path (Join-Path $ProjectRoot 'project.godot'))) {
    $ProjectRoot = Split-Path $PatchDir -Parent
}
if (-not (Test-Path (Join-Path $ProjectRoot 'project.godot'))) {
    throw "No encontre project.godot. Coloca esta carpeta dentro de la raiz de CORE AWAKENED y vuelve a ejecutar."
}

Write-Host "CORE AWAKENED - Integracion XENOID V2" -ForegroundColor Cyan
Write-Host "Proyecto: $ProjectRoot"

$Backup = Join-Path $ProjectRoot ("backup_pre_xenoid_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Force -Path $Backup | Out-Null
foreach ($rel in @('scripts/main.gd','scripts/presentacion_vs.gd','scripts/resultado.gd','scripts/game_state.gd','scripts/selector_personajes.gd')) {
    $src = Join-Path $ProjectRoot $rel
    if (Test-Path $src) {
        $dst = Join-Path $Backup $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
        Copy-Item $src $dst -Force
    }
}

# Copia assets + scripts completos del payload.
Copy-Item (Join-Path $PatchDir 'patch_payload/assets/*') (Join-Path $ProjectRoot 'assets') -Recurse -Force
Copy-Item (Join-Path $PatchDir 'patch_payload/scripts/xenoid.gd') (Join-Path $ProjectRoot 'scripts/xenoid.gd') -Force
Copy-Item (Join-Path $PatchDir 'patch_payload/scripts/game_state.gd') (Join-Path $ProjectRoot 'scripts/game_state.gd') -Force
Copy-Item (Join-Path $PatchDir 'patch_payload/scripts/selector_personajes.gd') (Join-Path $ProjectRoot 'scripts/selector_personajes.gd') -Force

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$NL = "`n"

function Replace-Literal([string]$Path, [string]$Old, [string]$New, [string]$Label) {
    $txt = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
    if ($txt.Contains($New)) {
        Write-Host "[OK] $Label ya estaba aplicado" -ForegroundColor DarkGreen
        return
    }
    if (-not $txt.Contains($Old)) {
        Write-Warning "No encontre bloque para: $Label (se deja sin tocar)"
        return
    }
    $txt = $txt.Replace($Old, $New)
    [IO.File]::WriteAllText($Path, $txt, $Utf8NoBom)
    Write-Host "[OK] $Label" -ForegroundColor Green
}

$main = Join-Path $ProjectRoot 'scripts/main.gd'

$old = "`t`"Jester`": Color(0.85, 0.25, 0.85),"
$new = $old + $NL + "`t`"Xenoid`": Color(0.42, 1.0, 0.08),"
Replace-Literal $main $old $new 'Color ambiente Xenoid'

$old = "`t`"Helena`": `"res://assets/fondos/helena.jpg`"," 
$new = $old + $NL + "`t# Temporal: hasta crear arena propia de Xenoid." + $NL + "`t`"Xenoid`": `"res://assets/fondos/cibor-x.jpg`"," 
Replace-Literal $main $old $new 'Fondo temporal Xenoid'

$old = "`t`t`"Jester`": return Jester.new()" + $NL + "`t`t`"Varkhos`": return Varkhos.new()"
$new = "`t`t`"Jester`": return Jester.new()" + $NL + "`t`t`"Xenoid`": return Xenoid.new()" + $NL + "`t`t`"Varkhos`": return Varkhos.new()"
Replace-Literal $main $old $new 'Factory Xenoid'

$old = "`t`t`"Cibor-X`":" + $NL + "`t`t`taudio_ambiente_escenario.stream = SND_CIBOR_AMBIENTE" + $NL + "`t`t`taudio_ambiente_escenario.volume_db = -13.0" + $NL + "`t`t`"Magnus`":"
$new = "`t`t`"Cibor-X`":" + $NL + "`t`t`taudio_ambiente_escenario.stream = SND_CIBOR_AMBIENTE" + $NL + "`t`t`taudio_ambiente_escenario.volume_db = -13.0" + $NL + "`t`t`"Xenoid`":" + $NL + "`t`t`taudio_ambiente_escenario.stream = SND_CIBOR_AMBIENTE" + $NL + "`t`t`taudio_ambiente_escenario.volume_db = -14.0" + $NL + "`t`t`"Magnus`":"
Replace-Literal $main $old $new 'Audio temporal Xenoid'

$old = "`t`t`"Jester`": return `"veneno`"" + $NL + "`t`t_: return `"oscuro`""
$new = "`t`t`"Jester`": return `"veneno`"" + $NL + "`t`t`"Xenoid`": return `"electrico`"" + $NL + "`t`t_: return `"oscuro`""
Replace-Literal $main $old $new 'Tipo escenario Xenoid'

Replace-Literal $main 'Rival: 1 Fang  2 Cibor-X  3 Kali  4 Aethel  5 Magnus  6 Helena  7 Jester  8 Varkhos' 'Rival: 1 Fang  2 Cibor-X  3 Kali  4 Aethel  5 Magnus  6 Helena  7 Jester  8 Varkhos  9 Xenoid' 'Ayuda debug rival Xenoid'
Replace-Literal $main 'J1: Q Kai  W Fang  E Cibor-X  R Kali  T Aethel  Y Magnus  U Helena  I Jester' 'J1: Q Kai  W Fang  E Cibor-X  R Kali  T Aethel  Y Magnus  U Helena  I Jester  O Xenoid' 'Ayuda debug jugador Xenoid'

$old = "`t`t`tKEY_8:" + $NL + "`t`t`t`t_cambiar_rival(Varkhos.new())" + $NL + "`t`t`tKEY_Q:"
$new = "`t`t`tKEY_8:" + $NL + "`t`t`t`t_cambiar_rival(Varkhos.new())" + $NL + "`t`t`tKEY_9:" + $NL + "`t`t`t`t_cambiar_rival(Xenoid.new())" + $NL + "`t`t`tKEY_Q:"
Replace-Literal $main $old $new 'Tecla debug rival Xenoid'

$old = "`t`t`tKEY_I:" + $NL + "`t`t`t`t_cambiar_jugador(_crear_luchador(`"Jester`"))"
$new = $old + $NL + "`t`t`tKEY_O:" + $NL + "`t`t`t`t_cambiar_jugador(_crear_luchador(`"Xenoid`"))"
Replace-Literal $main $old $new 'Tecla debug jugador Xenoid'

$vs = Join-Path $ProjectRoot 'scripts/presentacion_vs.gd'
$old = "`t`"Jester`": `"jester_vs.png`"," + $NL + "`t# Varkhos"
$new = "`t`"Jester`": `"jester_vs.png`"," + $NL + "`t`"Xenoid`": `"xenoid_vs.png`"," + $NL + "`t# Varkhos"
Replace-Literal $vs $old $new 'Poster VS Xenoid'

$old = "`t`"Jester`": 0.80," + $NL + "`t`"Varkhos`": 0.78"
$new = "`t`"Jester`": 0.80," + $NL + "`t`"Xenoid`": 0.84," + $NL + "`t`"Varkhos`": 0.78"
Replace-Literal $vs $old $new 'Escala VS Xenoid'

$old = "`t`"Helena`": Vector2(-6.0, 0.0)" + $NL + "}"
$new = "`t`"Helena`": Vector2(-6.0, 0.0)," + $NL + "`t`"Xenoid`": Vector2(0.0, 0.0)" + $NL + "}"
Replace-Literal $vs $old $new 'Offset VS Xenoid'

$resultado = Join-Path $ProjectRoot 'scripts/resultado.gd'
Replace-Literal $resultado '"Aethel":"aethel.jpg", "Magnus":"magnus.jpg", "Helena":"helena.jpg"' '"Aethel":"aethel.jpg", "Magnus":"magnus.jpg", "Helena":"helena.jpg", "Xenoid":"cibor-x.jpg"' 'Fondo resultado Xenoid'

Write-Host ""
Write-Host "LISTO. Backup creado en: $Backup" -ForegroundColor Yellow
Write-Host "Abri Godot y deja que importe los PNG nuevos. Varkhos sigue bloqueado y fuera del ROSTER." -ForegroundColor Cyan
