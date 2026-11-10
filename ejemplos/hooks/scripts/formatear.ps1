# Hook PostToolUse (Edit|Write): formatea con ruff el fichero Python que Claude acaba de escribir.
# Claude Code le pasa por la entrada estandar un JSON con, entre otros, tool_input.file_path.
# Salida 0 siempre: formatear es una ayuda, no debe parar a Claude si ruff no esta.

[Console]::InputEncoding = [System.Text.Encoding]::UTF8   # Claude Code envia el JSON en UTF-8
$entrada = [Console]::In.ReadToEnd() | ConvertFrom-Json
$fichero = $entrada.tool_input.file_path

if (-not $fichero -or $fichero -notmatch '\.(py|pyi)$') { exit 0 }

if (-not (Get-Command ruff -ErrorAction SilentlyContinue)) {
    # A stderr: aparece en el log de depuracion, no molesta a Claude
    [Console]::Error.WriteLine("formatear: ruff no esta instalado (uv tool install ruff)")
    exit 0
}

ruff format --quiet -- "$fichero"
exit 0
