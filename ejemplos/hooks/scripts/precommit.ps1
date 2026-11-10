# Hook PreToolUse (Bash, solo "git commit ..."): pasa pre-commit antes de dejar hacer el commit.
# Si falla, sale con codigo 2: el commit no se hace y Claude recibe el error (stderr) para
# corregirlo y volver a intentarlo. Si no hay pre-commit o configuracion, deja pasar.

[Console]::InputEncoding = [System.Text.Encoding]::UTF8   # Claude Code envia el JSON en UTF-8
$null = [Console]::In.ReadToEnd()   # la entrada no hace falta: el filtro "if" ya ha elegido

$raiz = git rev-parse --show-toplevel 2>$null
if (-not $raiz) { exit 0 }
if (-not (Test-Path (Join-Path $raiz ".pre-commit-config.yaml"))) { exit 0 }
if (-not (Get-Command pre-commit -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("precommit: pre-commit no esta instalado (uv tool install pre-commit); commit sin revisar")
    exit 0
}

Push-Location $raiz
# El hook corre ANTES del comando entero: con "git add -A && git commit" aun no hay nada
# preparado. Por eso se revisan los ficheros preparados, los modificados y los nuevos.
$ficheros = @(git diff --name-only --cached) + @(git diff --name-only) + @(git ls-files --others --exclude-standard) |
    Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Sort-Object -Unique
if ($ficheros.Count -eq 0) { Pop-Location; exit 0 }
$salida = pre-commit run --files @ficheros 2>&1 | Out-String
$codigo = $LASTEXITCODE
Pop-Location

if ($codigo -ne 0) {
    [Console]::Error.WriteLine("pre-commit ha fallado; el commit NO se ha hecho. Corrige esto, vuelve a hacer git add y repite el commit:`n$salida")
    exit 2
}
exit 0
