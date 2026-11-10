# Monta un repo de demo con los tres hooks de ejemplo, listo para abrir Claude Code dentro.
#
# Uso (desde cualquier carpeta, sin descargar nada antes):
#   irm https://raw.githubusercontent.com/Pozas91/marketplace-ejemplo/main/ejemplos/hooks/instalar-demo.ps1 | iex
# o, con el repo clonado:
#   powershell -ExecutionPolicy Bypass -File ejemplos\hooks\instalar-demo.ps1 [-Destino ruta]
#
# Crea <Destino> (por defecto .\demo-hooks): git init, .claude\hooks\*.ps1, .claude\settings.json,
# .pre-commit-config.yaml y demo-malo.py (con un import sin usar, para que pre-commit falle).
# Volver a ejecutarlo deja la demo como al principio.

param([string]$Destino = "demo-hooks")

$ErrorActionPreference = "Stop"
$base = "https://raw.githubusercontent.com/Pozas91/marketplace-ejemplo/main/ejemplos/hooks"
$ficheros = @{
    ".claude/hooks/formatear.ps1"  = "scripts/formatear.ps1"
    ".claude/hooks/precommit.ps1"  = "scripts/precommit.ps1"
    ".claude/hooks/notificar.ps1"  = "scripts/notificar.ps1"
    ".claude/settings.json"        = "settings.json"
    ".pre-commit-config.yaml"      = ".pre-commit-config.yaml"
}

foreach ($herramienta in @("git", "ruff", "pre-commit")) {
    if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) {
        Write-Host "AVISO: falta $herramienta. ruff y pre-commit: uv tool install ruff ; uv tool install pre-commit"
    }
}

if (Test-Path $Destino) { Remove-Item -Recurse -Force $Destino }
New-Item -ItemType Directory -Path "$Destino/.claude/hooks" -Force | Out-Null
Push-Location $Destino
try {
    # Si el script se lanza desde el repo clonado, copia; si no, descarga de GitHub
    $local = if ($PSScriptRoot) { $PSScriptRoot } else { $null }
    foreach ($destinoRel in $ficheros.Keys) {
        $origenRel = $ficheros[$destinoRel]
        if ($local -and (Test-Path (Join-Path $local $origenRel))) {
            Copy-Item (Join-Path $local $origenRel) $destinoRel
        } else {
            Invoke-WebRequest -UseBasicParsing -Uri "$base/$origenRel" -OutFile $destinoRel
        }
    }
    Set-Content -Path ".gitignore" -Value "__pycache__/" -Encoding ascii
    git init -q
    git add -A
    git -c user.name=demo -c user.email=demo@demo commit -q -m "Demo de hooks" --no-verify
    # Fichero con fallos a proposito: import sin usar y espacios al final de linea
    Set-Content -Path "demo-malo.py" -Value "import os`n`n`ndef doble(x):   `n    return x * 2" -Encoding ascii
    if (Get-Command pre-commit -ErrorAction SilentlyContinue) { pre-commit install-hooks | Out-Null }
    Write-Host ""
    Write-Host "Demo lista en $(Get-Location)"
    Write-Host "  1. claude          (en modo normal, para que salga el aviso de permiso)"
    Write-Host "  2. /hooks          -> los tres"
    Write-Host "  3. 'Crea calculo.py con def suma( xs ):  return sum( xs ), tal cual'  -> ruff lo formatea"
    Write-Host "  4. 'Haz git add de todo y un commit'  -> pre-commit lo bloquea, Claude lo arregla"
    Write-Host "  5. 'Ejecuta python calculo.py'        -> aviso de Windows"
}
finally { Pop-Location }
