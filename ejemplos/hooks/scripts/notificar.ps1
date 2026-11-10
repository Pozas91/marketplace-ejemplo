# Hook Notification: aviso de Windows cuando Claude necesita que hagas algo (un permiso,
# una pregunta o que lleva rato esperando). Lee el texto del aviso de la entrada estandar.

[Console]::InputEncoding = [System.Text.Encoding]::UTF8   # Claude Code envia el JSON en UTF-8
try { $entrada = [Console]::In.ReadToEnd() | ConvertFrom-Json } catch { $entrada = $null }
$titulo = "Claude Code"
$texto = if ($entrada.message) { [string]$entrada.message } else { "Claude necesita tu atencion" }
$carpeta = if ($entrada.cwd) { Split-Path $entrada.cwd -Leaf } else { "" }
if ($carpeta) { $titulo = "Claude Code - $carpeta" }

function Escapar([string]$s) { [System.Security.SecurityElement]::Escape($s) }

try {
    # Notificacion nativa de Windows 10/11 (la de la esquina), sin instalar nada
    $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml("<toast><visual><binding template='ToastGeneric'><text>$(Escapar $titulo)</text><text>$(Escapar $texto)</text></binding></visual></toast>")
    # Se muestra a nombre de PowerShell, que ya esta registrado en Windows
    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show(
        [Windows.UI.Notifications.ToastNotification]::new($xml))
}
catch {
    # Plan B: globo en la bandeja del sistema
    Add-Type -AssemblyName System.Windows.Forms
    $icono = New-Object System.Windows.Forms.NotifyIcon
    $icono.Icon = [System.Drawing.SystemIcons]::Information
    $icono.Visible = $true
    $icono.ShowBalloonTip(5000, $titulo, $texto, "Info")
    Start-Sleep -Seconds 5
    $icono.Dispose()
}
exit 0
