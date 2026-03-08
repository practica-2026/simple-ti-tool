# ============================================================
#  modules/red.ps1
#  Pagina: Diagnostico de Red
#  Categorias colapsables de comandos + consola de output
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ============================================================
#  CATALOGO DE COMANDOS POR CATEGORÍA
#  Cada comando tiene:
#    Name   — texto visible en la tarjeta
#    Desc   — descripcion corta
#    Cmd    — scriptblock que escribe en $netOutput
# ============================================================
$script:netCatalog = [ordered]@{

    "IP y Adaptadores" = @{
        Color = [System.Drawing.Color]::FromArgb(99, 102, 241)   # Indigo
        Cmds  = @(
            @{
                Name = "ipconfig /all"
                Desc = "Muestra toda la configuracion IP de los adaptadores"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /all`r`n")
                    $r = ipconfig /all 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "ipconfig /release"
                Desc = "Libera la direccion IP del adaptador DHCP"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /release`r`n")
                    $r = ipconfig /release 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "ipconfig /renew"
                Desc = "Solicita una nueva direccion IP al servidor DHCP"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /renew`r`n")
                    $r = ipconfig /renew 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Release + Renew (ciclo completo)"
                Desc = "Libera y renueva la IP en una sola operacion"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /release`r`n")
                    ipconfig /release 2>&1 | Out-Null
                    $script:netOut.AppendText(">> ipconfig /renew`r`n")
                    $r = ipconfig /renew 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Mostrar adaptadores de red"
                Desc = "Lista adaptadores con Get-NetAdapter (estado, velocidad, MAC)"
                Cmd  = {
                    $script:netOut.AppendText(">> Get-NetAdapter`r`n")
                    $r = Get-NetAdapter | Format-Table Name, Status, LinkSpeed, MacAddress -AutoSize 2>&1 | Out-String
                    $script:netOut.AppendText($r + "`r`n")
                }
            }
            @{
                Name = "Mostrar IPs asignadas"
                Desc = "Lista todas las IPs configuradas con Get-NetIPAddress"
                Cmd  = {
                    $script:netOut.AppendText(">> Get-NetIPAddress`r`n")
                    $r = Get-NetIPAddress | Where-Object { $_.AddressFamily -ne "IPv6" -or $_.PrefixOrigin -ne "WellKnown" } |
                         Format-Table InterfaceAlias, IPAddress, PrefixLength, AddressFamily -AutoSize 2>&1 | Out-String
                    $script:netOut.AppendText($r + "`r`n")
                }
            }
        )
    }

    "DNS" = @{
        Color = [System.Drawing.Color]::FromArgb(20, 184, 166)   # Teal
        Cmds  = @(
            @{
                Name = "ipconfig /flushdns"
                Desc = "Limpia la cache de resolucion DNS del sistema"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /flushdns`r`n")
                    $r = ipconfig /flushdns 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "ipconfig /displaydns"
                Desc = "Muestra el contenido actual de la cache DNS"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /displaydns`r`n")
                    $r = ipconfig /displaydns 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Consultar DNS (nslookup)"
                Desc = "Resuelve google.com contra el servidor DNS configurado"
                Cmd  = {
                    $script:netOut.AppendText(">> nslookup google.com`r`n")
                    $r = nslookup google.com 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Mostrar servidores DNS activos"
                Desc = "Lista los servidores DNS configurados por adaptador"
                Cmd  = {
                    $script:netOut.AppendText(">> Get-DnsClientServerAddress`r`n")
                    $r = Get-DnsClientServerAddress -AddressFamily IPv4 |
                         Where-Object { $_.ServerAddresses } |
                         Format-Table InterfaceAlias, ServerAddresses -AutoSize 2>&1 | Out-String
                    $script:netOut.AppendText($r + "`r`n")
                }
            }
            @{
                Name = "Registrar DNS (ipconfig /registerdns)"
                Desc = "Fuerza el registro dinamico del nombre del equipo en DNS"
                Cmd  = {
                    $script:netOut.AppendText(">> ipconfig /registerdns`r`n")
                    $r = ipconfig /registerdns 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
        )
    }

    "Conectividad y Diagnostico" = @{
        Color = [System.Drawing.Color]::FromArgb(34, 197, 94)    # Verde
        Cmds  = @(
            @{
                Name = "Ping a Gateway"
                Desc = "Verifica conectividad con la puerta de enlace local"
                Cmd  = {
                    try {
                        $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1).NextHop
                        if (-not $gw) { throw "No se encontro gateway" }
                        $script:netOut.AppendText(">> ping $gw (Gateway)`r`n")
                        $r = ping $gw -n 4 2>&1
                        $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                    } catch {
                        $script:netOut.AppendText("Error: $_`r`n`r`n")
                    }
                }
            }
            @{
                Name = "Ping a 8.8.8.8 (Internet)"
                Desc = "Verifica salida a internet via Google DNS"
                Cmd  = {
                    $script:netOut.AppendText(">> ping 8.8.8.8 -n 4`r`n")
                    $r = ping 8.8.8.8 -n 4 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Ping a 1.1.1.1 (Cloudflare)"
                Desc = "Test alternativo de salida a internet via Cloudflare"
                Cmd  = {
                    $script:netOut.AppendText(">> ping 1.1.1.1 -n 4`r`n")
                    $r = ping 1.1.1.1 -n 4 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Traceroute a 8.8.8.8"
                Desc = "Muestra la ruta de saltos hasta Google DNS"
                Cmd  = {
                    $script:netOut.AppendText(">> tracert 8.8.8.8`r`n")
                    $r = tracert 8.8.8.8 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Test-NetConnection (ping PS)"
                Desc = "Prueba conectividad avanzada con PowerShell"
                Cmd  = {
                    $script:netOut.AppendText(">> Test-NetConnection 8.8.8.8 -Port 53`r`n")
                    $r = Test-NetConnection -ComputerName 8.8.8.8 -Port 53 -InformationLevel Detailed 2>&1 | Out-String
                    $script:netOut.AppendText($r + "`r`n")
                }
            }
            @{
                Name = "Tabla de rutas (route print)"
                Desc = "Muestra la tabla de enrutamiento IPv4 del sistema"
                Cmd  = {
                    $script:netOut.AppendText(">> route print`r`n")
                    $r = route print 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "ARP table (arp -a)"
                Desc = "Muestra la tabla ARP: IPs y MACs conocidas"
                Cmd  = {
                    $script:netOut.AppendText(">> arp -a`r`n")
                    $r = arp -a 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
        )
    }

    "Conexiones Activas" = @{
        Color = [System.Drawing.Color]::FromArgb(234, 179, 8)    # Amarillo
        Cmds  = @(
            @{
                Name = "netstat -an"
                Desc = "Lista todas las conexiones TCP/UDP activas y puertos en escucha"
                Cmd  = {
                    $script:netOut.AppendText(">> netstat -an`r`n")
                    $r = netstat -an 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "netstat -b (procesos)"
                Desc = "Muestra el ejecutable responsable de cada conexion (requiere admin)"
                Cmd  = {
                    $script:netOut.AppendText(">> netstat -b`r`n")
                    $r = netstat -b 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Conexiones establecidas"
                Desc = "Filtra solo las conexiones en estado ESTABLISHED"
                Cmd  = {
                    $script:netOut.AppendText(">> netstat -an | findstr ESTABLISHED`r`n")
                    $r = netstat -an 2>&1 | Select-String "ESTABLISHED"
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Puertos en escucha"
                Desc = "Muestra solo los puertos en estado LISTENING"
                Cmd  = {
                    $script:netOut.AppendText(">> netstat -an | findstr LISTENING`r`n")
                    $r = netstat -an 2>&1 | Select-String "LISTENING"
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Estadisticas de red (netstat -s)"
                Desc = "Muestra estadisticas por protocolo: TCP, UDP, IP, ICMP"
                Cmd  = {
                    $script:netOut.AppendText(">> netstat -s`r`n")
                    $r = netstat -s 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
        )
    }

    "Winsock y Pila de Red" = @{
        Color = [System.Drawing.Color]::FromArgb(239, 68, 68)    # Rojo
        Cmds  = @(
            @{
                Name = "netsh winsock reset"
                Desc = "Restablece el catalogo Winsock a su estado predeterminado"
                Cmd  = {
                    $script:netOut.AppendText(">> netsh winsock reset`r`n")
                    $r = netsh winsock reset 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n")
                    $script:netOut.AppendText("NOTA: Se recomienda reiniciar el equipo.`r`n`r`n")
                }
            }
            @{
                Name = "netsh int ip reset"
                Desc = "Restablece la pila TCP/IP a su configuracion de fabrica"
                Cmd  = {
                    $script:netOut.AppendText(">> netsh int ip reset`r`n")
                    $r = netsh int ip reset 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n")
                    $script:netOut.AppendText("NOTA: Se recomienda reiniciar el equipo.`r`n`r`n")
                }
            }
            @{
                Name = "Mostrar config Winsock"
                Desc = "Lista el catalogo actual de proveedores Winsock"
                Cmd  = {
                    $script:netOut.AppendText(">> netsh winsock show catalog`r`n")
                    $r = netsh winsock show catalog 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Habilitar / deshabilitar adaptador"
                Desc = "Lista adaptadores para desactivar y reactivar el principal"
                Cmd  = {
                    try {
                        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
                        if (-not $adapter) { throw "No se encontro adaptador activo" }
                        $script:netOut.AppendText(">> Reiniciando adaptador: $($adapter.Name)`r`n")
                        Disable-NetAdapter -Name $adapter.Name -Confirm:$false
                        Start-Sleep -Seconds 2
                        Enable-NetAdapter  -Name $adapter.Name -Confirm:$false
                        $script:netOut.AppendText("Adaptador $($adapter.Name) reiniciado.`r`n`r`n")
                    } catch {
                        $script:netOut.AppendText("Error: $_`r`n`r`n")
                    }
                }
            }
        )
    }

    "Politicas de Grupo (GPO)" = @{
        Color = [System.Drawing.Color]::FromArgb(168, 85, 247)   # Purpura
        Cmds  = @(
            @{
                Name = "gpupdate /force"
                Desc = "Fuerza la actualizacion inmediata de todas las politicas de grupo"
                Cmd  = {
                    $script:netOut.AppendText(">> gpupdate /force`r`n")
                    $r = gpupdate /force 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "gpupdate /sync"
                Desc = "Actualiza GPO de forma sincrona (espera confirmacion)"
                Cmd  = {
                    $script:netOut.AppendText(">> gpupdate /sync`r`n")
                    $r = gpupdate /sync 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "gpresult /r"
                Desc = "Resumen de las politicas de grupo aplicadas al usuario actual"
                Cmd  = {
                    $script:netOut.AppendText(">> gpresult /r`r`n")
                    $r = gpresult /r 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "gpresult /z"
                Desc = "Reporte detallado y verbose de todas las GPO aplicadas"
                Cmd  = {
                    $script:netOut.AppendText(">> gpresult /z (esto puede tardar...)`r`n")
                    [System.Windows.Forms.Application]::DoEvents()
                    $r = gpresult /z 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "gpresult /h (reporte HTML)"
                Desc = "Genera un informe HTML de GPO y lo abre en el navegador"
                Cmd  = {
                    $outFile = "$env:TEMP\gpresult_report.html"
                    $script:netOut.AppendText(">> gpresult /h $outFile`r`n")
                    gpresult /h $outFile /f 2>&1 | Out-Null
                    if (Test-Path $outFile) {
                        Start-Process $outFile
                        $script:netOut.AppendText("Reporte generado y abierto: $outFile`r`n`r`n")
                    } else {
                        $script:netOut.AppendText("Error: no se pudo generar el reporte.`r`n`r`n")
                    }
                }
            }
        )
    }

    "Kerberos y Autenticacion" = @{
        Color = [System.Drawing.Color]::FromArgb(251, 146, 60)   # Naranja
        Cmds  = @(
            @{
                Name = "klist purge"
                Desc = "Elimina todos los tickets Kerberos del usuario actual"
                Cmd  = {
                    $script:netOut.AppendText(">> klist purge`r`n")
                    $r = klist purge 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "klist (ver tickets)"
                Desc = "Lista los tickets Kerberos activos del usuario actual"
                Cmd  = {
                    $script:netOut.AppendText(">> klist`r`n")
                    $r = klist 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "klist tgt"
                Desc = "Muestra el Ticket Granting Ticket actual del usuario"
                Cmd  = {
                    $script:netOut.AppendText(">> klist tgt`r`n")
                    $r = klist tgt 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Verificar sesion de dominio"
                Desc = "Muestra informacion del usuario y su sesion en el dominio"
                Cmd  = {
                    $script:netOut.AppendText(">> whoami /all`r`n")
                    $r = whoami /all 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "nltest /dsgetdc (controlador de dominio)"
                Desc = "Consulta el controlador de dominio asignado al equipo"
                Cmd  = {
                    $script:netOut.AppendText(">> nltest /dsgetdc:$env:USERDOMAIN`r`n")
                    $r = nltest /dsgetdc:$env:USERDOMAIN 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
        )
    }

    "Integridad del Sistema" = @{
        Color = [System.Drawing.Color]::FromArgb(59, 130, 246)   # Azul
        Cmds  = @(
            @{
                Name = "sfc /scannow"
                Desc = "Escanea y repara archivos protegidos del sistema (requiere admin)"
                Cmd  = {
                    $script:netOut.AppendText(">> sfc /scannow (esto puede tardar varios minutos...)`r`n")
                    [System.Windows.Forms.Application]::DoEvents()
                    $r = sfc /scannow 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "DISM /CheckHealth"
                Desc = "Comprueba si hay corrupcion en la imagen de Windows"
                Cmd  = {
                    $script:netOut.AppendText(">> DISM /Online /Cleanup-Image /CheckHealth`r`n")
                    [System.Windows.Forms.Application]::DoEvents()
                    $r = Dism.exe /Online /Cleanup-Image /CheckHealth 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "DISM /ScanHealth"
                Desc = "Detecta problemas en la imagen del sistema (mas profundo)"
                Cmd  = {
                    $script:netOut.AppendText(">> DISM /Online /Cleanup-Image /ScanHealth (puede tardar...)`r`n")
                    [System.Windows.Forms.Application]::DoEvents()
                    $r = Dism.exe /Online /Cleanup-Image /ScanHealth 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "DISM /RestoreHealth"
                Desc = "Repara la imagen de Windows usando Windows Update"
                Cmd  = {
                    $script:netOut.AppendText(">> DISM /Online /Cleanup-Image /RestoreHealth (puede tardar...)`r`n")
                    [System.Windows.Forms.Application]::DoEvents()
                    $r = Dism.exe /Online /Cleanup-Image /RestoreHealth 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "chkdsk C: /scan"
                Desc = "Escanea el disco C: en busca de errores sin reiniciar"
                Cmd  = {
                    $script:netOut.AppendText(">> chkdsk C: /scan`r`n")
                    [System.Windows.Forms.Application]::DoEvents()
                    $r = chkdsk C: /scan 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
        )
    }

    "Compartidos y Firewall" = @{
        Color = [System.Drawing.Color]::FromArgb(236, 72, 153)   # Rosa
        Cmds  = @(
            @{
                Name = "net view (recursos de red)"
                Desc = "Lista los equipos y recursos compartidos en la red local"
                Cmd  = {
                    $script:netOut.AppendText(">> net view`r`n")
                    $r = net view 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "net use (unidades mapeadas)"
                Desc = "Muestra las conexiones a unidades de red mapeadas"
                Cmd  = {
                    $script:netOut.AppendText(">> net use`r`n")
                    $r = net use 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "net session (sesiones activas)"
                Desc = "Lista las sesiones de red activas en el equipo"
                Cmd  = {
                    $script:netOut.AppendText(">> net session`r`n")
                    $r = net session 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Estado del Firewall"
                Desc = "Muestra el perfil activo y estado del Firewall de Windows"
                Cmd  = {
                    $script:netOut.AppendText(">> netsh advfirewall show currentprofile`r`n")
                    $r = netsh advfirewall show currentprofile 2>&1
                    $script:netOut.AppendText(($r -join "`r`n") + "`r`n`r`n")
                }
            }
            @{
                Name = "Reglas de Firewall activas"
                Desc = "Lista las reglas de entrada del Firewall habilitadas"
                Cmd  = {
                    $script:netOut.AppendText(">> Get-NetFirewallRule (habilitadas, entrada)`r`n")
                    $r = Get-NetFirewallRule -Direction Inbound -Enabled True |
                         Format-Table DisplayName, Profile, Action -AutoSize 2>&1 | Out-String
                    $script:netOut.AppendText($r + "`r`n")
                }
            }
        )
    }
}

# ============================================================
# ============================================================
#  PÁGINA PRINCIPAL
#
#  Layout con dos contenedores independientes y altura fija:
#
#  $pageRed  (Fill)
#    ├─ $netTopPanel    — categorías con scroll manual (Fill)
#    │    ├─ $netVBar   — scrollbar derecho
#    │    └─ $netInner  — panel interior desplazable
#    └─ $netBottomPanel — consola fija (altura $consoleTotalH)
#         ├─ toolbar (Limpiar / Copiar)
#         ├─ separador
#         └─ RichTextBox
#
#  $netBottomPanel tiene altura fija y se ancla abajo.
#  $netTopPanel ocupa todo el espacio restante.
#  Ninguno usa Dock — se posicionan con Location + Size
#  y se reposicionan en el resize de $pageRed.
# ============================================================
$pageRed = New-Object System.Windows.Forms.Panel
$pageRed.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageRed.BackColor = $script:clrBackground
$pageRed.Visible   = $false

# ── Altura fija del panel inferior ──────────────────────────
$consoleH      = 200   # RichTextBox
$consoleSepH   = 1     # línea separadora
$consoleBarH   = 30    # toolbar
$consoleTotalH = $consoleH + $consoleSepH + $consoleBarH

# ============================================================
#  PANEL INFERIOR — CONSOLA (altura fija)
# ============================================================
$netBottomPanel = New-Object System.Windows.Forms.Panel
$netBottomPanel.BackColor = [System.Drawing.Color]::FromArgb(13, 17, 30)
$netBottomPanel.Height    = $consoleTotalH
$netBottomPanel.Location  = New-Object System.Drawing.Point(0, 0)   # Reflow lo ajusta

# Toolbar (parte superior del panel inferior)
$consoleToolbar = New-Object System.Windows.Forms.Panel
$consoleToolbar.BackColor = [System.Drawing.Color]::FromArgb(20, 25, 40)
$consoleToolbar.Height    = $consoleBarH
$consoleToolbar.Location  = New-Object System.Drawing.Point(0, 0)
$consoleToolbar.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                            [System.Windows.Forms.AnchorStyles]::Left -bor
                            [System.Windows.Forms.AnchorStyles]::Right

$consoleLbl = New-Object System.Windows.Forms.Label
$consoleLbl.Text      = "  Consola de salida"
$consoleLbl.Font      = $script:fontSidebarBold
$consoleLbl.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
$consoleLbl.AutoSize  = $true
$consoleLbl.Location  = New-Object System.Drawing.Point(2, 7)
$consoleLbl.BackColor = [System.Drawing.Color]::Transparent

$btnClearConsole = New-RoundedButton `
    -Text    "Limpiar" `
    -Location (New-Object System.Drawing.Point(0, 3)) `
    -Size    (New-Object System.Drawing.Size(68, 24)) `
    -BgColor ([System.Drawing.Color]::FromArgb(40, 50, 70)) `
    -FgColor ([System.Drawing.Color]::FromArgb(134, 239, 172))
$btnClearConsole.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$btnClearConsole.Font   = $script:fontSmall

$btnCopyConsole = New-RoundedButton `
    -Text    "Copiar" `
    -Location (New-Object System.Drawing.Point(0, 3)) `
    -Size    (New-Object System.Drawing.Size(68, 24)) `
    -BgColor ([System.Drawing.Color]::FromArgb(40, 50, 70)) `
    -FgColor ([System.Drawing.Color]::FromArgb(134, 239, 172))
$btnCopyConsole.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$btnCopyConsole.Font   = $script:fontSmall

$consoleToolbar.Controls.AddRange(@($consoleLbl, $btnClearConsole, $btnCopyConsole))
$consoleToolbar.Add_Resize({
    $btnClearConsole.Location = New-Object System.Drawing.Point(($this.Width - 74), 3)
    $btnCopyConsole.Location  = New-Object System.Drawing.Point(($this.Width - 148), 3)
})

$btnClearConsole.Add_Click({
    $script:netOut.Clear()
    $script:netOut.Text       = "-- Consola limpiada --`r`n"
    $script:statusLabel.Text      = "Consola limpiada"
    $script:statusLabel.ForeColor = $script:clrTextMuted
})
$btnCopyConsole.Add_Click({
    if ($script:netOut.Text.Trim() -ne "") {
        [System.Windows.Forms.Clipboard]::SetText($script:netOut.Text)
        $script:statusLabel.Text      = "Contenido copiado al portapapeles"
        $script:statusLabel.ForeColor = $script:clrSuccess
    }
})

# Separador visual
$consoleSep = New-Object System.Windows.Forms.Panel
$consoleSep.BackColor = [System.Drawing.Color]::FromArgb(40, 50, 70)
$consoleSep.Height    = $consoleSepH
$consoleSep.Location  = New-Object System.Drawing.Point(0, $consoleBarH)
$consoleSep.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                        [System.Windows.Forms.AnchorStyles]::Left -bor
                        [System.Windows.Forms.AnchorStyles]::Right

# RichTextBox
$script:netOut = New-Object System.Windows.Forms.RichTextBox
$script:netOut.BackColor   = [System.Drawing.Color]::FromArgb(13, 17, 30)
$script:netOut.ForeColor   = [System.Drawing.Color]::FromArgb(134, 239, 172)
$script:netOut.Font        = New-Object System.Drawing.Font("Consolas", 8)
$script:netOut.ReadOnly    = $true
$script:netOut.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$script:netOut.ScrollBars  = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$script:netOut.Text        = "-- Consola de red lista. Selecciona una categoria y ejecuta un comando. --`r`n"
$script:netOut.Location    = New-Object System.Drawing.Point(0, ($consoleBarH + $consoleSepH))
$script:netOut.Height      = $consoleH
$script:netOut.Anchor      = [System.Windows.Forms.AnchorStyles]::Top -bor
                             [System.Windows.Forms.AnchorStyles]::Left -bor
                             [System.Windows.Forms.AnchorStyles]::Right

$netBottomPanel.Controls.AddRange(@($consoleToolbar, $consoleSep, $script:netOut))

# Propagar ancho a los hijos del panel inferior
$netBottomPanel.Add_Resize({
    $w = $this.Width
    $consoleToolbar.Width  = $w
    $consoleSep.Width      = $w
    $script:netOut.Width   = $w
})

# ============================================================
#  PANEL SUPERIOR — CATEGORÍAS CON SCROLL MANUAL
# ============================================================
$netTopPanel = New-Object System.Windows.Forms.Panel
$netTopPanel.BackColor  = $script:clrBackground
$netTopPanel.Location   = New-Object System.Drawing.Point(0, 0)   # Reflow lo ajusta
$netTopPanel.AutoScroll = $false

$netVBar = New-Object System.Windows.Forms.VScrollBar
$netVBar.Dock        = [System.Windows.Forms.DockStyle]::Right
$netVBar.SmallChange = 20
$netVBar.LargeChange = 80

$netInner = New-Object System.Windows.Forms.Panel
$netInner.BackColor = $script:clrBackground
$netInner.Location  = New-Object System.Drawing.Point(0, 0)
$netInner.AutoSize  = $false

function Update-NetScrollBar {
    $contentH  = $netInner.Height
    $viewportH = $netTopPanel.ClientSize.Height
    $innerW    = $netTopPanel.ClientSize.Width - $netVBar.Width
    if ($netInner.Width -ne $innerW -and $innerW -gt 0) {
        $netInner.Width = $innerW
        foreach ($sp in $script:netSecPanels) { $sp.Width = $innerW }
    }
    if ($contentH -le $viewportH) {
        $netVBar.Enabled = $false
        $netVBar.Value   = 0
        $netInner.Top    = 0
    } else {
        $netVBar.Enabled = $true
        $range           = $contentH - $viewportH
        $netVBar.Maximum = $range + $netVBar.LargeChange - 1
        if ($netVBar.Value -gt $range) { $netVBar.Value = $range }
        $netInner.Top    = -$netVBar.Value
    }
}

function Reflow-NetSections {
    $gap = 6
    $y   = 8
    foreach ($sp in $script:netSecPanels) {
        $sp.Location = New-Object System.Drawing.Point(0, $y)
        $y += $sp.Height + $gap
    }
    $netInner.Height = $y + 8
    Update-NetScrollBar
}

$netVBar.Add_Scroll({ $netInner.Top = -$netVBar.Value })

$netWheelHandler = {
    if (-not $netVBar.Enabled) { return }
    $delta  = [int]($_.Delta / 120) * $netVBar.SmallChange * 3
    $newVal = $netVBar.Value - $delta
    $maxVal = $netVBar.Maximum - $netVBar.LargeChange + 1
    if ($newVal -lt 0)       { $newVal = 0 }
    if ($newVal -gt $maxVal) { $newVal = $maxVal }
    $netVBar.Value = $newVal
    $netInner.Top  = -$newVal
}
$netTopPanel.Add_MouseWheel($netWheelHandler)
$netInner.Add_MouseWheel($netWheelHandler)

$netTopPanel.Add_Resize({ Update-NetScrollBar })
$netTopPanel.Controls.Add($netVBar)
$netTopPanel.Controls.Add($netInner)

# ============================================================
#  REFLOW DEL PAGEРЕД — posiciona los dos paneles
#  Top ocupa todo excepto los últimos $consoleTotalH px.
#  Bottom ocupa exactamente $consoleTotalH px abajo.
# ============================================================
function Reflow-RedPage {
    $w  = $pageRed.ClientSize.Width
    $h  = $pageRed.ClientSize.Height
    $bH = $consoleTotalH

    $netTopPanel.Location    = New-Object System.Drawing.Point(0, 0)
    $netTopPanel.Size        = New-Object System.Drawing.Size($w, ($h - $bH))

    $netBottomPanel.Location = New-Object System.Drawing.Point(0, ($h - $bH))
    $netBottomPanel.Size     = New-Object System.Drawing.Size($w, $bH)
}

$pageRed.Add_Resize({ Reflow-RedPage })

$pageRed.Controls.Add($netTopPanel)
$pageRed.Controls.Add($netBottomPanel)

# ============================================================
#  CONSTRUIR CATEGORÍAS COLAPSABLES
# ============================================================
$cardH   = 44
$cardGap = 5

$script:netSecPanels = @()

foreach ($catName in $script:netCatalog.Keys) {
    $catData  = $script:netCatalog[$catName]
    $catColor = $catData.Color
    $catCmds  = $catData.Cmds

    $headerH    = 40
    $finalBodyH = ($catCmds.Count * ($cardH + $cardGap)) + 8
    $expandedH  = $headerH + $finalBodyH
    $collapsedH = $headerH

    $secPanel = New-Object System.Windows.Forms.Panel
    $secPanel.BackColor = $script:clrBackground
    $secPanel.Width     = $netInner.Width
    $secPanel.Height    = $collapsedH
    $secPanel.Tag       = "collapsed"

    $secHdr = New-Object System.Windows.Forms.Panel
    $secHdr.BackColor = $catColor
    $secHdr.Size      = New-Object System.Drawing.Size($secPanel.Width, $headerH)
    $secHdr.Location  = New-Object System.Drawing.Point(0, 0)
    $secHdr.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                        [System.Windows.Forms.AnchorStyles]::Left -bor
                        [System.Windows.Forms.AnchorStyles]::Right
    $secHdr.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $lblCatName = New-Object System.Windows.Forms.Label
    $lblCatName.Text      = $catName
    $lblCatName.Font      = $script:fontButton
    $lblCatName.ForeColor = [System.Drawing.Color]::White
    $lblCatName.AutoSize  = $true
    $lblCatName.Location  = New-Object System.Drawing.Point(14, 12)
    $lblCatName.BackColor = [System.Drawing.Color]::Transparent
    $lblCatName.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $lblCatCount = New-Object System.Windows.Forms.Label
    $lblCatCount.Text      = "$($catCmds.Count) comandos"
    $lblCatCount.Font      = $script:fontSmall
    $lblCatCount.ForeColor = [System.Drawing.Color]::FromArgb(200, 255, 255, 255)
    $lblCatCount.AutoSize  = $true
    $lblCatCount.BackColor = [System.Drawing.Color]::Transparent
    $lblCatCount.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $lblCatCount.Location  = New-Object System.Drawing.Point(0, 14)

    $lblChevron = New-Object System.Windows.Forms.Label
    $lblChevron.Text      = "v"
    $lblChevron.Font      = $script:fontSidebarBold
    $lblChevron.ForeColor = [System.Drawing.Color]::White
    $lblChevron.AutoSize  = $true
    $lblChevron.BackColor = [System.Drawing.Color]::Transparent
    $lblChevron.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $lblChevron.Location  = New-Object System.Drawing.Point(0, 13)

    $secHdr.Controls.AddRange(@($lblCatName, $lblCatCount, $lblChevron))

    $secHdr.Add_Resize({
        $r    = $this.Width - 10
        $chev = $this.Controls | Where-Object { $_.Text -eq "v" -or $_.Text -eq "^" } | Select-Object -First 1
        $cnt  = $this.Controls | Where-Object { $_.Text -match "comandos" }            | Select-Object -First 1
        if ($chev -and $chev.Width -gt 0) {
            $chev.Location = New-Object System.Drawing.Point(($r - $chev.Width), $chev.Location.Y)
        }
        if ($cnt -and $cnt.Width -gt 0 -and $chev -and $chev.Width -gt 0) {
            $cnt.Location = New-Object System.Drawing.Point(($r - $chev.Width - $cnt.Width - 10), $cnt.Location.Y)
        }
    })

    $secBody = New-Object System.Windows.Forms.Panel
    $secBody.BackColor = $script:clrBackground
    $secBody.Location  = New-Object System.Drawing.Point(0, $headerH)
    $secBody.Size      = New-Object System.Drawing.Size($secPanel.Width, $finalBodyH)
    $secBody.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                         [System.Windows.Forms.AnchorStyles]::Left -bor
                         [System.Windows.Forms.AnchorStyles]::Right
    $secBody.Visible   = $false

    $secBody.Add_Resize({
        foreach ($ctrl in $this.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width - 2 }
        }
    })

    $bodyY = 4
    foreach ($cmd in $catCmds) {
        $cmdName   = $cmd.Name
        $cmdDesc   = $cmd.Desc
        $cmdScript = $cmd.Cmd

        $card = New-Object System.Windows.Forms.Panel
        $card.BackColor = $script:clrCard
        $card.Size      = New-Object System.Drawing.Size(($secBody.Width - 2), $cardH)
        $card.Location  = New-Object System.Drawing.Point(1, $bodyY)
        $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                          [System.Windows.Forms.AnchorStyles]::Left -bor
                          [System.Windows.Forms.AnchorStyles]::Right

        $stripe = New-Object System.Windows.Forms.Panel
        $stripe.BackColor = $catColor
        $stripe.Size      = New-Object System.Drawing.Size(3, $cardH)
        $stripe.Location  = New-Object System.Drawing.Point(0, 0)

        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text      = $cmdName
        $lblName.Font      = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Bold)
        $lblName.ForeColor = $script:clrTextPrimary
        $lblName.AutoSize  = $true
        $lblName.Location  = New-Object System.Drawing.Point(12, 6)

        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text      = $cmdDesc
        $lblDesc.Font      = $script:fontSmall
        $lblDesc.ForeColor = $script:clrTextMuted
        $lblDesc.AutoSize  = $true
        $lblDesc.Location  = New-Object System.Drawing.Point(12, 26)

        $btn = New-RoundedButton `
            -Text    "Ejecutar" `
            -Location (New-Object System.Drawing.Point(0, 8)) `
            -Size    (New-Object System.Drawing.Size(74, 28)) `
            -BgColor $catColor
        $btn.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
        $btn.Font   = $script:fontSmall

        $scriptRef = $cmdScript
        $nameRef   = $cmdName

        $btn.Add_Click({
            $script:statusLabel.Text      = "Ejecutando: $nameRef..."
            $script:statusLabel.ForeColor = $script:clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            try {
                & $scriptRef
                $script:statusLabel.Text      = "Completado: $nameRef"
                $script:statusLabel.ForeColor = $script:clrSuccess
            } catch {
                $script:netOut.AppendText("Error: $_`r`n`r`n")
                $script:statusLabel.Text      = "Error en: $nameRef"
                $script:statusLabel.ForeColor = $script:clrDanger
            }
            $script:netOut.ScrollToCaret()
        }.GetNewClosure())

        $card.Add_Resize({
            $b = $this.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] } | Select-Object -First 1
            if ($b) { $b.Location = New-Object System.Drawing.Point(($this.Width - 82), 8) }
        })

        $card.Controls.AddRange(@($stripe, $lblName, $lblDesc, $btn))
        $secBody.Controls.Add($card)
        $bodyY += $cardH + $cardGap
    }

    $secPanelRef = $secPanel
    $secBodyRef  = $secBody
    $chevRef     = $lblChevron
    $expH        = $expandedH
    $collH       = $collapsedH

    $toggleAction = {
        if ($secPanelRef.Tag -eq "collapsed") {
            $secPanelRef.Tag    = "expanded"
            $secPanelRef.Height = $expH
            $secBodyRef.Visible = $true
            $secBodyRef.Width   = $secPanelRef.Width - 2
            $chevRef.Text       = "^"
        } else {
            $secPanelRef.Tag    = "collapsed"
            $secPanelRef.Height = $collH
            $secBodyRef.Visible = $false
            $chevRef.Text       = "v"
        }
        Reflow-NetSections
    }.GetNewClosure()

    $secHdr.Add_Click($toggleAction)
    $lblCatName.Add_Click($toggleAction)

    $secPanel.Controls.Add($secHdr)
    $secPanel.Controls.Add($secBody)

    $secPanel.Add_Resize({
        $secHdr.Width  = $this.Width
        $secBody.Width = $this.Width - 2
        foreach ($ctrl in $secBody.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $secBody.Width - 2 }
        }
    })

    $netInner.Controls.Add($secPanel)
    $script:netSecPanels += $secPanel
}

# Layout inicial
Reflow-NetSections
Reflow-RedPage

$script:pages["Red"] = $pageRed
