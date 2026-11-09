<#
Exporta la wiki (Markdown) a un manual en Word y, opcionalmente, PDF.

Lee el indice de la wiki, toma las paginas en el orden en que aparecen enlazadas y las
convierte con pandoc y el filtro manual.lua. Si Word esta instalado, actualiza el indice
del documento y, con -Pdf, guarda tambien el PDF.

Funciona en Windows PowerShell 5.1 y en PowerShell 7. Este fichero es solo ASCII a proposito
(PowerShell 5.1 lee mal los acentos de un .ps1 sin BOM).

Ejemplos:
  exportar-manual.ps1
  exportar-manual.ps1 -Wiki docs/wiki -Titulo "Manual tecnico - Almacen"
  exportar-manual.ps1 -Paginas recepcion,expedicion -Pdf
  exportar-manual.ps1 -ConCitas -Plantilla plantillas/manual.docx
#>
[CmdletBinding()]
param(
    [string]$Wiki = "docs/wiki",
    [string]$Indice = "index.md",
    [string]$Salida = "docs/manual",
    [string]$Titulo = "Manual tecnico",
    [string]$Nombre = "",
    [string[]]$Paginas = @(),
    [string]$Plantilla = "",
    [switch]$ConCitas,
    [switch]$Pdf,
    [switch]$SinWord
)

$ErrorActionPreference = "Stop"

# Con "powershell -File", "-Paginas a,b" llega como un solo texto: separarlo a mano
$Paginas = @($Paginas | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

function Salir([string]$mensaje) {
    Write-Host "ERROR: $mensaje"
    exit 1
}

# 1. pandoc
$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandoc) {
    Salir "No se encuentra pandoc. Instalar con: winget install --id JohnMacFarlane.Pandoc -e  (y abrir una terminal nueva)"
}

# 2. Indice
$wikiDir = (Resolve-Path -LiteralPath $Wiki -ErrorAction SilentlyContinue)
if (-not $wikiDir) { Salir "No existe la carpeta de la wiki: $Wiki" }
$wikiDir = $wikiDir.Path
$indicePath = Join-Path $wikiDir $Indice
if (-not (Test-Path -LiteralPath $indicePath)) { Salir "No existe el indice: $indicePath" }

$textoIndice = Get-Content -LiteralPath $indicePath -Raw -Encoding UTF8
$enlaces = [regex]::Matches($textoIndice, '\]\(\s*<?([^)\s#>]+\.md)>?(#[^)]*)?\s*\)')

$excluir = @("index.md", "log.md", "alcance.md")
$vistos = @{}
$ficheros = New-Object System.Collections.Generic.List[string]
$faltan = New-Object System.Collections.Generic.List[string]

foreach ($m in $enlaces) {
    $rel = [uri]::UnescapeDataString($m.Groups[1].Value)
    if ($rel -match '^[a-z]+://') { continue }
    $leaf = Split-Path $rel -Leaf
    if ($excluir -contains $leaf.ToLower()) { continue }
    $ruta = Join-Path $wikiDir $rel
    $clave = $ruta.ToLower()
    if ($vistos.ContainsKey($clave)) { continue }
    $vistos[$clave] = $true
    if ($Paginas.Count -gt 0) {
        $slug = [IO.Path]::GetFileNameWithoutExtension($leaf)
        if (-not ($Paginas | Where-Object { $_ -ieq $slug })) { continue }
    }
    if (Test-Path -LiteralPath $ruta) { $ficheros.Add((Resolve-Path -LiteralPath $ruta).Path) }
    else { $faltan.Add($rel) }
}

if ($faltan.Count -gt 0) {
    Write-Host "AVISO: el indice enlaza paginas que no existen:"
    $faltan | ForEach-Object { Write-Host "  - $_" }
}
if ($ficheros.Count -eq 0) {
    if ($Paginas.Count -gt 0) { Salir "Ninguna pagina del indice coincide con: $($Paginas -join ', ')" }
    Salir "El indice no enlaza ninguna pagina .md"
}

# 3. Paginas en borrador
$borradores = @()
foreach ($f in $ficheros) {
    # Solo el frontmatter: de la primera linea '---' a la siguiente, tenga la longitud que tenga
    $lineas = Get-Content -LiteralPath $f -Encoding UTF8
    if ($lineas.Count -gt 0 -and $lineas[0].Trim() -eq '---') {
        for ($i = 1; $i -lt $lineas.Count; $i++) {
            if ($lineas[$i].Trim() -eq '---') { break }
            if ($lineas[$i] -match '^\s*estado:\s*borrador') { $borradores += (Split-Path $f -Leaf); break }
        }
    }
}

# 4. Salida
if (-not (Test-Path -LiteralPath $Salida)) { New-Item -ItemType Directory -Path $Salida | Out-Null }
$salidaDir = (Resolve-Path -LiteralPath $Salida).Path
if (-not $Nombre) { $Nombre = "manual-" + (Get-Date -Format "yyyy-MM-dd") }
$docx = Join-Path $salidaDir ($Nombre + ".docx")

# 5. Plantilla corporativa
if (-not $Plantilla) {
    $porDefecto = Join-Path $wikiDir "plantilla-manual.docx"
    if (Test-Path -LiteralPath $porDefecto) { $Plantilla = $porDefecto }
}
elseif (-not (Test-Path -LiteralPath $Plantilla)) {
    Salir "No existe la plantilla: $Plantilla"
}

# 6. pandoc
$filtro = Join-Path $PSScriptRoot "manual.lua"
$argumentos = @()
$argumentos += $ficheros
$argumentos += @(
    "--from", "markdown",
    "--to", "docx",
    "--toc", "--toc-depth=2",
    "--lua-filter", $filtro,
    "--resource-path", $wikiDir,
    "--metadata", "title=$Titulo",
    "--metadata", ("date=" + (Get-Date -Format "dd/MM/yyyy")),
    "--output", $docx
)
if ($ConCitas) { $argumentos += @("--metadata", "citas=true") }
if ($Plantilla) { $argumentos += @("--reference-doc", (Resolve-Path -LiteralPath $Plantilla).Path) }

& $pandoc.Source @argumentos
if ($LASTEXITCODE -ne 0) { Salir "pandoc ha fallado (codigo $LASTEXITCODE)" }

# 7. Word: actualizar indice y, si se pide, PDF
$pdfPath = ""
$conWord = $false
if (-not $SinWord) {
    $word = $null
    try {
        $word = New-Object -ComObject Word.Application
        $word.Visible = $false
        $word.DisplayAlerts = 0
        $doc = $word.Documents.Open($docx)
        foreach ($toc in $doc.TablesOfContents) { $toc.Update() }
        $doc.Save()
        if ($Pdf) {
            $pdfPath = [IO.Path]::ChangeExtension($docx, ".pdf")
            $doc.SaveAs([ref]$pdfPath, [ref]17)   # 17 = wdFormatPDF
        }
        $doc.Close([ref]0)
        $conWord = $true
    }
    catch {
        Write-Host "AVISO: no se ha podido usar Word ($($_.Exception.Message))."
    }
    finally {
        if ($word) { $word.Quit(); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word) }
    }
}
if ($Pdf -and -not $pdfPath) {
    Write-Host "AVISO: sin Word no se genera el PDF. Abrir el .docx y guardarlo como PDF."
}

# 8. Resumen (lo lee Claude)
Write-Host "OK"
Write-Host "docx: $docx"
if ($pdfPath) { Write-Host "pdf: $pdfPath" }
Write-Host "paginas: $($ficheros.Count)"
$ficheros | ForEach-Object { Write-Host "  - $(Split-Path $_ -Leaf)" }
Write-Host ("citas: " + ($(if ($ConCitas) { "incluidas" } else { "quitadas" })))
Write-Host ("plantilla: " + ($(if ($Plantilla) { $Plantilla } else { "la de pandoc" })))
Write-Host ("indice del documento: " + ($(if ($conWord) { "actualizado con Word" } else { "sin actualizar (Word pedira actualizar campos al abrir)" })))
if ($borradores.Count -gt 0) {
    Write-Host "borradores: $($borradores.Count)"
    $borradores | ForEach-Object { Write-Host "  - $_" }
}
