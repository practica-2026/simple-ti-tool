# ============================================================
#  modules/software.ps1
#  Pagina: Instalacion de Software
#  Secciones colapsables + subcategorias + checkboxes + winget masivo
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ============================================================
#  CATALOGO COMPLETO
#  Estructura: SeccionGrande > Subcategoria > App
#  wingetId: ID exacto para winget install --id
# ============================================================
$script:swSections = [ordered]@{

    "General" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(99, 102, 241)   # Indigo
        Sub   = [ordered]@{
            "Navegadores" = @(
                @{ Name="Google Chrome";   Desc="Navegador web de Google";              Id="Google.Chrome" }
                @{ Name="Microsoft Edge";  Desc="Navegador de Microsoft basado en Chromium"; Id="Microsoft.Edge" }
                @{ Name="Mozilla Firefox"; Desc="Navegador web de Mozilla";             Id="Mozilla.Firefox" }
                @{ Name="Brave";           Desc="Navegador con bloqueador integrado";   Id="Brave.Brave" }
            )
            "Comunicacion" = @(
                @{ Name="Microsoft Teams"; Desc="Plataforma de colaboracion Microsoft"; Id="Microsoft.Teams" }
                @{ Name="Zoom";            Desc="Videoconferencias y reuniones";        Id="Zoom.Zoom" }
                @{ Name="Slack";           Desc="Mensajeria para equipos de trabajo";   Id="SlackTechnologies.Slack" }
            )
            "Utilidades esenciales" = @(
                @{ Name="7-Zip";           Desc="Compresor y descompresor de archivos"; Id="7zip.7zip" }
                @{ Name="PeaZip";          Desc="Gestor de archivos comprimidos libre"; Id="Giorgiotani.Peazip" }
                @{ Name="WinRAR";          Desc="Compresor de archivos RAR y ZIP";      Id="RARLab.WinRAR" }
                @{ Name="Everything";      Desc="Busqueda instantanea de archivos";     Id="voidtools.Everything" }
                @{ Name="PowerToys";       Desc="Utilidades avanzadas de Microsoft";    Id="Microsoft.PowerToys" }
                @{ Name="ShareX";          Desc="Captura de pantalla y grabacion";      Id="ShareX.ShareX" }
            )
            "Acceso remoto" = @(
                @{ Name="AnyDesk";               Desc="Escritorio remoto rapido y seguro";      Id="AnyDesk.AnyDesk" }
                @{ Name="TeamViewer";             Desc="Acceso y soporte remoto";                Id="TeamViewer.TeamViewer" }
                @{ Name="RustDesk";               Desc="Alternativa open-source a AnyDesk";      Id="RustDesk.RustDesk" }
                @{ Name="Chrome Remote Desktop";  Desc="Acceso remoto via cuenta Google";        Id="Google.ChromeRemoteDesktop" }
            )
            "Documentacion" = @(
                @{ Name="Adobe Acrobat Reader"; Desc="Lector de documentos PDF";           Id="Adobe.Acrobat.Reader.64-bit" }
                @{ Name="PDF24 Creator";        Desc="Suite completa para PDFs, gratuita"; Id="geeksoftwareGmbH.PDF24Creator" }
                @{ Name="Notepad++";            Desc="Editor de texto avanzado";           Id="Notepad++.Notepad++" }
                @{ Name="Obsidian";             Desc="Base de conocimiento en Markdown";   Id="Obsidian.Obsidian" }
            )
        }
    }

    "Desarrollo / DevOps" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(20, 184, 166)   # Teal
        Sub   = [ordered]@{
            "IDE / Editores" = @(
                @{ Name="Visual Studio Code";        Desc="Editor de codigo de Microsoft";         Id="Microsoft.VisualStudioCode" }
                @{ Name="Visual Studio Community";   Desc="IDE completo de Microsoft (gratuito)";  Id="Microsoft.VisualStudio.2022.Community" }
                @{ Name="JetBrains Toolbox";         Desc="Gestor de IDEs de JetBrains";           Id="JetBrains.Toolbox" }
            )
            "Lenguajes" = @(
                @{ Name="Python 3";  Desc="Lenguaje de programacion Python";       Id="Python.Python.3" }
                @{ Name="Node.js";   Desc="Entorno de ejecucion JavaScript";       Id="OpenJS.NodeJS" }
                @{ Name="OpenJDK";   Desc="Java Development Kit open source";      Id="Microsoft.OpenJDK.21" }
                @{ Name="Go";        Desc="Lenguaje de programacion de Google";    Id="GoLang.Go" }
                @{ Name="Rust";      Desc="Lenguaje de sistemas seguro y rapido";  Id="Rustlang.Rust.MSVC" }
            )
            "Control de versiones" = @(
                @{ Name="Git";              Desc="Control de versiones distribuido";  Id="Git.Git" }
                @{ Name="GitHub Desktop";   Desc="Cliente GUI oficial de GitHub";     Id="GitHub.GitHubDesktop" }
                @{ Name="GitKraken";        Desc="Cliente Git visual y potente";      Id="Axosoft.GitKraken" }
            )
            "Contenedores / DevOps" = @(
                @{ Name="Docker Desktop";  Desc="Contenedores Docker para Windows";   Id="Docker.DockerDesktop" }
                @{ Name="kubectl";         Desc="CLI de Kubernetes";                  Id="Kubernetes.kubectl" }
                @{ Name="Minikube";        Desc="Kubernetes local para desarrollo";   Id="Kubernetes.minikube" }
                @{ Name="Helm";            Desc="Gestor de paquetes para Kubernetes"; Id="Helm.Helm" }
            )
            "APIs y testing" = @(
                @{ Name="Postman";   Desc="Plataforma de desarrollo de APIs";        Id="Postman.Postman" }
                @{ Name="Insomnia";  Desc="Cliente REST/GraphQL open source";        Id="Insomnia.Insomnia" }
                @{ Name="Bruno";     Desc="Cliente API rapido y offline-first";      Id="Bruno.Bruno" }
            )
        }
    }

    "Ciberseguridad" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(239, 68, 68)    # Rojo
        Sub   = [ordered]@{
            "Escaneo de red" = @(
                @{ Name="Nmap";               Desc="Escaner de red y puertos";               Id="Nmap.Nmap" }
                @{ Name="Angry IP Scanner";   Desc="Escaner de IPs rapido y ligero";         Id="angryziber.AngryIPScanner" }
                @{ Name="Advanced IP Scanner";Desc="Escaner de red para LAN";                Id="Famatech.AdvancedIPScanner" }
            )
            "Analisis de trafico" = @(
                @{ Name="Wireshark";  Desc="Analizador de paquetes de red";                 Id="WiresharkFoundation.Wireshark" }
                @{ Name="TCPView";    Desc="Monitor de conexiones TCP/UDP (Sysinternals)";  Id="Microsoft.Sysinternals.TCPView" }
            )
            "Pentesting" = @(
                @{ Name="Burp Suite Community"; Desc="Proxy para pruebas de seguridad web";  Id="PortSwigger.BurpSuite.Community" }
                @{ Name="OWASP ZAP";            Desc="Escaner de vulnerabilidades web";      Id="OWASP.Zap" }
                @{ Name="Metasploit Framework"; Desc="Framework de explotacion (solo uso etico)"; Id="Rapid7.Metasploit" }
            )
            "Seguridad endpoint" = @(
                @{ Name="Process Explorer"; Desc="Monitor avanzado de procesos (Sysinternals)"; Id="Microsoft.Sysinternals.ProcessExplorer" }
                @{ Name="Autoruns";         Desc="Gestor de inicio del sistema (Sysinternals)"; Id="Microsoft.Sysinternals.Autoruns" }
                @{ Name="Process Monitor";  Desc="Monitor de actividad del sistema (Sysinternals)"; Id="Microsoft.Sysinternals.ProcessMonitor" }
            )
            "Criptografia" = @(
                @{ Name="Gpg4win";    Desc="Suite de cifrado GPG para Windows";  Id="GnuPG.Gpg4win" }
                @{ Name="VeraCrypt";  Desc="Cifrado de discos y volumenes";       Id="IDRIX.VeraCrypt" }
            )
        }
    }

    "Redes (LAN / WAN)" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(59, 130, 246)   # Azul
        Sub   = [ordered]@{
            "Diagnostico" = @(
                @{ Name="Wireshark";           Desc="Analizador de paquetes de red";       Id="WiresharkFoundation.Wireshark" }
                @{ Name="Nmap";                Desc="Escaner de red y puertos";             Id="Nmap.Nmap" }
                @{ Name="Advanced IP Scanner"; Desc="Escaner de red para LAN";              Id="Famatech.AdvancedIPScanner" }
                @{ Name="PingPlotter";         Desc="Diagnostico de latencia y rutas";      Id="Pingman.PingPlotter" }
            )
            "Conexiones" = @(
                @{ Name="PuTTY";       Desc="Cliente SSH y Telnet clasico";              Id="PuTTY.PuTTY" }
                @{ Name="MobaXterm";   Desc="Terminal SSH con X11 y herramientas extra"; Id="Mobatek.MobaXterm" }
                @{ Name="OpenVPN";     Desc="Cliente VPN open source";                   Id="OpenVPNTechnologies.OpenVPN" }
                @{ Name="WireGuard";   Desc="VPN moderna y rapida";                      Id="WireGuard.WireGuard" }
            )
            "Monitoreo" = @(
                @{ Name="Zabbix Agent"; Desc="Agente de monitoreo Zabbix";              Id="Zabbix.ZabbixAgent" }
                @{ Name="PingPlotter";  Desc="Monitoreo de latencia en tiempo real";    Id="Pingman.PingPlotter" }
                @{ Name="Netdata";      Desc="Monitoreo de infraestructura en tiempo real"; Id="Netdata.Netdata" }
            )
        }
    }

    "Infraestructura / SysAdmin" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(168, 85, 247)   # Purpura
        Sub   = [ordered]@{
            "Administracion remota" = @(
                @{ Name="Windows Terminal";      Desc="Terminal moderna de Microsoft";         Id="Microsoft.WindowsTerminal" }
                @{ Name="Remote Desktop Manager";Desc="Gestor centralizado de conexiones RDP"; Id="Devolutions.RemoteDesktopManager" }
                @{ Name="mRemoteNG";             Desc="Gestor de conexiones remotas open source"; Id="mRemoteNG.mRemoteNG" }
            )
            "Virtualizacion" = @(
                @{ Name="VirtualBox";              Desc="Virtualizacion gratuita de Oracle";        Id="Oracle.VirtualBox" }
                @{ Name="VMware Workstation Player";Desc="Virtualizacion de VMware (gratuita)";     Id="VMware.WorkstationPlayer" }
                @{ Name="Hyper-V Manager Tools";   Desc="Herramientas GUI para Hyper-V";           Id="Microsoft.RemoteServerAdministrationTools" }
            )
            "Infraestructura como codigo" = @(
                @{ Name="Terraform"; Desc="IaC para provision de infraestructura"; Id="Hashicorp.Terraform" }
                @{ Name="Ansible";   Desc="Automatizacion de configuraciones";     Id="RedHat.Ansible" }
                @{ Name="Packer";    Desc="Creacion de imagenes de maquina";       Id="Hashicorp.Packer" }
            )
            "Diagnostico de hardware" = @(
                @{ Name="HWMonitor";       Desc="Monitor de temperatura y voltajes";       Id="CPUID.HWMonitor" }
                @{ Name="CrystalDiskInfo"; Desc="Estado S.M.A.R.T. de discos";            Id="CrystalDewWorld.CrystalDiskInfo" }
                @{ Name="CPU-Z";           Desc="Informacion detallada del procesador";    Id="CPUID.CPU-Z" }
            )
        }
    }

    "Helpdesk Nivel 1" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(34, 197, 94)    # Verde
        Sub   = [ordered]@{
            "Acceso remoto" = @(
                @{ Name="AnyDesk";     Desc="Escritorio remoto rapido y seguro"; Id="AnyDesk.AnyDesk" }
                @{ Name="TeamViewer";  Desc="Acceso y soporte remoto";           Id="TeamViewer.TeamViewer" }
            )
            "Diagnostico basico" = @(
                @{ Name="HWInfo";          Desc="Informacion detallada del hardware";  Id="REALiX.HWiNFO" }
                @{ Name="CrystalDiskInfo"; Desc="Estado S.M.A.R.T. de discos";        Id="CrystalDewWorld.CrystalDiskInfo" }
            )
            "Utilidades" = @(
                @{ Name="7-Zip";      Desc="Compresor y descompresor de archivos"; Id="7zip.7zip" }
                @{ Name="Everything"; Desc="Busqueda instantanea de archivos";     Id="voidtools.Everything" }
                @{ Name="ShareX";     Desc="Captura de pantalla y grabacion";      Id="ShareX.ShareX" }
            )
            "Inventario" = @(
                @{ Name="Belarc Advisor"; Desc="Auditoria detallada del sistema y licencias"; Id="Belarc.BelarcAdvisor" }
                @{ Name="Speccy";         Desc="Informacion del sistema de Piriform";         Id="Piriform.Speccy" }
            )
        }
    }

    "Helpdesk Nivel 2 y 3" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(234, 179, 8)    # Amarillo
        Sub   = [ordered]@{
            "Sysinternals Suite" = @(
                @{ Name="Process Explorer"; Desc="Monitor avanzado de procesos";            Id="Microsoft.Sysinternals.ProcessExplorer" }
                @{ Name="Process Monitor";  Desc="Monitor de actividad del sistema";        Id="Microsoft.Sysinternals.ProcessMonitor" }
                @{ Name="Autoruns";         Desc="Gestor de inicio del sistema";            Id="Microsoft.Sysinternals.Autoruns" }
                @{ Name="TCPView";          Desc="Monitor de conexiones TCP/UDP activas";   Id="Microsoft.Sysinternals.TCPView" }
            )
            "Diagnostico avanzado" = @(
                @{ Name="WinDbg";          Desc="Depurador de Windows de Microsoft";       Id="Microsoft.WinDbg" }
                @{ Name="BlueScreenView";  Desc="Analisis de volcados de memoria BSOD";    Id="NirSoft.BlueScreenView" }
            )
            "Administracion" = @(
                @{ Name="RSAT Tools";              Desc="Herramientas de admin remota para Windows Server"; Id="Microsoft.RemoteServerAdministrationTools" }
                @{ Name="Active Directory Tools";  Desc="Gestion de usuarios y politicas AD";               Id="Microsoft.RSAT.ActiveDirectory" }
            )
        }
    }

    "Herramientas Cloud" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(251, 146, 60)   # Naranja
        Sub   = [ordered]@{
            "AWS" = @(
                @{ Name="AWS CLI";      Desc="Interfaz de linea de comandos de Amazon Web Services"; Id="Amazon.AWSCLI" }
                @{ Name="AWS Toolkit";  Desc="Extension y herramientas para desarrollo en AWS";      Id="Amazon.AWSToolkitForVisualStudio2022" }
            )
            "Azure" = @(
                @{ Name="Azure CLI";               Desc="CLI para gestionar recursos de Microsoft Azure"; Id="Microsoft.AzureCLI" }
                @{ Name="Azure Storage Explorer";  Desc="GUI para administrar blobs y colas Azure";       Id="Microsoft.Azure.StorageExplorer" }
            )
            "Google Cloud" = @(
                @{ Name="Google Cloud CLI"; Desc="Herramientas de linea de comandos para GCP"; Id="Google.CloudSDK" }
            )
        }
    }

    "Datos / BI" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(236, 72, 153)   # Rosa
        Sub   = [ordered]@{
            "Analisis y visualizacion" = @(
                @{ Name="Power BI Desktop"; Desc="Herramienta de BI de Microsoft";               Id="Microsoft.PowerBIDesktop" }
                @{ Name="DBeaver";          Desc="Cliente universal de bases de datos";           Id="dbeaver.dbeaver" }
                @{ Name="MySQL Workbench";  Desc="IDE oficial para MySQL";                        Id="Oracle.MySQLWorkbench" }
                @{ Name="pgAdmin 4";        Desc="Herramienta de administracion para PostgreSQL"; Id="PostgreSQL.pgAdmin" }
                @{ Name="SQLite Browser";   Desc="Visualizador y editor de bases SQLite";         Id="DBBrowserForSQLite.DBBrowserForSQLite" }
            )
        }
    }

    "Multimedia / Extra" = [ordered]@{
        Color = [System.Drawing.Color]::FromArgb(20, 184, 166)   # Teal
        Sub   = [ordered]@{
            "Multimedia" = @(
                @{ Name="VLC Media Player"; Desc="Reproductor multimedia universal";          Id="VideoLAN.VLC" }
                @{ Name="OBS Studio";       Desc="Grabacion y streaming de pantalla";         Id="OBSProject.OBSStudio" }
                @{ Name="Blender";          Desc="Suite de modelado y animacion 3D";          Id="BlenderFoundation.Blender" }
                @{ Name="HandBrake";        Desc="Conversor de video open source";            Id="HandBrake.HandBrake" }
            )
        }
    }
}

# Lista global de checkboxes { Chk, Id, Name, StatusLabel }
$script:swCheckboxes    = @()
# Lista de paneles de sección para el reflow manual
$script:swSecPanels     = @()

# ============================================================
#  PÁGINA PRINCIPAL
# ============================================================
$pageSoftware = New-Object System.Windows.Forms.Panel
$pageSoftware.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageSoftware.BackColor = $script:clrBackground
$pageSoftware.Visible   = $false

# ─── TOOLBAR ────────────────────────────────────────────────
$swToolbar = New-Object System.Windows.Forms.Panel
$swToolbar.Dock      = [System.Windows.Forms.DockStyle]::Top
$swToolbar.Height    = 44
$swToolbar.BackColor = $script:clrCard

$chkAll = New-Object System.Windows.Forms.CheckBox
$chkAll.Text       = "Seleccionar todo"
$chkAll.Font       = $script:fontLabel
$chkAll.ForeColor  = $script:clrTextPrimary
$chkAll.AutoSize   = $true
$chkAll.Location   = New-Object System.Drawing.Point(12, 13)
$chkAll.Cursor     = [System.Windows.Forms.Cursors]::Hand
$chkAll.ThreeState = $true

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text      = "0 seleccionados"
$lblCount.Font      = $script:fontSmall
$lblCount.ForeColor = $script:clrTextMuted
$lblCount.AutoSize  = $true
$lblCount.Location  = New-Object System.Drawing.Point(165, 16)

$btnInstallAll = New-RoundedButton `
    -Text    "Instalar seleccionados" `
    -Location (New-Object System.Drawing.Point(0, 8)) `
    -Size    (New-Object System.Drawing.Size(172, 28)) `
    -BgColor $script:clrAccent
$btnInstallAll.Anchor  = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$btnInstallAll.Enabled = $false

$swToolbar.Controls.AddRange(@($chkAll, $lblCount, $btnInstallAll))
$swToolbar.Add_Resize({
    $btnInstallAll.Location = New-Object System.Drawing.Point(($this.Width - 180), 8)
})

$swToolbarLine = New-Object System.Windows.Forms.Panel
$swToolbarLine.Dock      = [System.Windows.Forms.DockStyle]::Top
$swToolbarLine.Height    = 1
$swToolbarLine.BackColor = $script:clrBorder

# ============================================================
#  SISTEMA DE SCROLL MANUAL
#  ┌─ $swViewport  (Fill, ClipChildren, sin AutoScroll) ──────┐
#  │   ├─ $swVBar  (VScrollBar, Right)                        │
#  │   └─ $swInner (Panel, posición Y variable según scroll)  │
#  └──────────────────────────────────────────────────────────┘
#
#  $swInner contiene todos los secPanel apilados con Y manual.
#  Su Height = suma real de alturas → siempre exacto.
#  $swVBar.Maximum se actualiza en cada toggle.
#  MouseWheel en viewport y en inner ambos mueven el scroll.
# ============================================================

$swViewport = New-Object System.Windows.Forms.Panel
$swViewport.Dock        = [System.Windows.Forms.DockStyle]::Fill
$swViewport.BackColor   = $script:clrBackground
$swViewport.AutoScroll  = $false

$swVBar = New-Object System.Windows.Forms.VScrollBar
$swVBar.Dock        = [System.Windows.Forms.DockStyle]::Right
$swVBar.SmallChange = 20
$swVBar.LargeChange = 80

$swInner = New-Object System.Windows.Forms.Panel
$swInner.BackColor  = $script:clrBackground
$swInner.Location   = New-Object System.Drawing.Point(0, 0)
$swInner.AutoSize   = $false

# ── Funciones de scroll ─────────────────────────────────────

# Recalcula Maximum del scrollbar y clampea la posicion actual
function Update-SwScrollBar {
    $contentH  = $swInner.Height
    $viewportH = $swViewport.ClientSize.Height
    $innerW    = $swViewport.ClientSize.Width - $swVBar.Width

    # Ajustar ancho del inner al viewport (descontando scrollbar)
    if ($swInner.Width -ne $innerW -and $innerW -gt 0) {
        $swInner.Width = $innerW
        foreach ($sp in $script:swSecPanels) {
            $sp.Width = $innerW
        }
    }

    if ($contentH -le $viewportH) {
        $swVBar.Enabled = $false
        $swVBar.Value   = 0
        $swInner.Top    = 0
    } else {
        $swVBar.Enabled = $true
        $range          = $contentH - $viewportH
        $swVBar.Maximum = $range + $swVBar.LargeChange - 1
        # Clampear valor actual para que no quede fuera de rango
        if ($swVBar.Value -gt $range) { $swVBar.Value = $range }
        $swInner.Top    = -$swVBar.Value
    }
}

# Reposiciona todos los secPanel dentro de $swInner y actualiza altura
function Reflow-SwSections {
    $gap = 6
    $y   = 8
    foreach ($sp in $script:swSecPanels) {
        $sp.Location = New-Object System.Drawing.Point(0, $y)
        $y += $sp.Height + $gap
    }
    $swInner.Height = $y + 8
    Update-SwScrollBar
}

# ── Eventos del scrollbar ────────────────────────────────────
$swVBar.Add_Scroll({
    $swInner.Top = -$swVBar.Value
})

# ── MouseWheel en el viewport y en el inner ──────────────────
$wheelHandler = {
    if (-not $swVBar.Enabled) { return }
    $delta  = [int]($_.Delta / 120) * $swVBar.SmallChange * 3
    $newVal = $swVBar.Value - $delta
    $maxVal = $swVBar.Maximum - $swVBar.LargeChange + 1
    if ($newVal -lt 0)       { $newVal = 0 }
    if ($newVal -gt $maxVal) { $newVal = $maxVal }
    $swVBar.Value = $newVal
    $swInner.Top  = -$newVal
}
$swViewport.Add_MouseWheel($wheelHandler)
$swInner.Add_MouseWheel($wheelHandler)

# ── Resize del viewport ──────────────────────────────────────
$swViewport.Add_Resize({ Update-SwScrollBar })

$swViewport.Controls.Add($swVBar)
$swViewport.Controls.Add($swInner)

# ============================================================
#  FUNCIÓN: actualizar contador y sincronizar chkAll
# ============================================================
function Update-SwSelection {
    $count = ($script:swCheckboxes | Where-Object { $_.Chk.Checked }).Count
    $total = $script:swCheckboxes.Count
    if ($count -eq 1) { $lblCount.Text = "1 seleccionado" }
    else              { $lblCount.Text = "$count seleccionados" }
    $lblCount.ForeColor    = if ($count -gt 0) { $script:clrAccent } else { $script:clrTextMuted }
    $btnInstallAll.Enabled = ($count -gt 0)

    $chkAll.remove_CheckedChanged($script:chkAllHandler)
    if ($count -eq 0)          { $chkAll.CheckState = [System.Windows.Forms.CheckState]::Unchecked }
    elseif ($count -eq $total) { $chkAll.CheckState = [System.Windows.Forms.CheckState]::Checked }
    else                       { $chkAll.CheckState = [System.Windows.Forms.CheckState]::Indeterminate }
    $chkAll.add_CheckedChanged($script:chkAllHandler)
}

# ============================================================
#  CONSTRUIR SECCIONES COLAPSABLES
# ============================================================
$cardH        = 44
$cardGap      = 5
$headerH      = 40
$subHeaderH   = 24
$subHeaderGap = 8

foreach ($secName in $script:swSections.Keys) {
    $secData  = $script:swSections[$secName]
    $secColor = $secData.Color
    $secSubs  = $secData.Sub

    # ── Calcular alturas ────────────────────────────────────
    $totalApps = 0
    foreach ($k in $secSubs.Keys) { $totalApps += $secSubs[$k].Count }
    $subCount  = $secSubs.Keys.Count

    $bodyInnerH = 8 `
        + ($subCount  * ($subHeaderH + $subHeaderGap)) `
        + ($totalApps * ($cardH + $cardGap)) `
        + ($subCount  * $subHeaderGap) `
        + 8
    $expandedH  = $headerH + $bodyInnerH
    $collapsedH = $headerH

    # ── Panel contenedor ────────────────────────────────────
    $secPanel = New-Object System.Windows.Forms.Panel
    $secPanel.BackColor = $script:clrBackground
    $secPanel.Width     = $swInner.Width
    $secPanel.Height    = $collapsedH
    $secPanel.Tag       = "collapsed"
    # Location la asigna Reflow-SwSections

    # ── Cabecera ─────────────────────────────────────────────
    $secHeader = New-Object System.Windows.Forms.Panel
    $secHeader.BackColor = $secColor
    $secHeader.Size      = New-Object System.Drawing.Size($secPanel.Width, $headerH)
    $secHeader.Location  = New-Object System.Drawing.Point(0, 0)
    $secHeader.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                           [System.Windows.Forms.AnchorStyles]::Left -bor
                           [System.Windows.Forms.AnchorStyles]::Right
    $secHeader.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $lblSecName = New-Object System.Windows.Forms.Label
    $lblSecName.Text      = $secName
    $lblSecName.Font      = $script:fontButton
    $lblSecName.ForeColor = [System.Drawing.Color]::White
    $lblSecName.AutoSize  = $true
    $lblSecName.Location  = New-Object System.Drawing.Point(14, 12)
    $lblSecName.BackColor = [System.Drawing.Color]::Transparent
    $lblSecName.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $lblSecCount = New-Object System.Windows.Forms.Label
    $lblSecCount.Text      = "$totalApps apps"
    $lblSecCount.Font      = $script:fontSmall
    $lblSecCount.ForeColor = [System.Drawing.Color]::FromArgb(200, 255, 255, 255)
    $lblSecCount.AutoSize  = $true
    $lblSecCount.BackColor = [System.Drawing.Color]::Transparent
    $lblSecCount.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $lblSecCount.Location  = New-Object System.Drawing.Point(0, 14)

    $lblChevron = New-Object System.Windows.Forms.Label
    $lblChevron.Text      = "v"
    $lblChevron.Font      = $script:fontSidebarBold
    $lblChevron.ForeColor = [System.Drawing.Color]::White
    $lblChevron.AutoSize  = $true
    $lblChevron.BackColor = [System.Drawing.Color]::Transparent
    $lblChevron.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $lblChevron.Location  = New-Object System.Drawing.Point(0, 13)

    $secHeader.Controls.AddRange(@($lblSecName, $lblSecCount, $lblChevron))

    $secHeader.Add_Resize({
        $right = $this.Width - 12
        $chev  = $this.Controls | Where-Object { $_.Text -eq "v" -or $_.Text -eq "^" } | Select-Object -First 1
        $cnt   = $this.Controls | Where-Object { $_.Text -match "apps" }               | Select-Object -First 1
        if ($chev -and $chev.Width -gt 0) {
            $chev.Location = New-Object System.Drawing.Point(($right - $chev.Width), $chev.Location.Y)
        }
        if ($cnt -and $cnt.Width -gt 0 -and $chev -and $chev.Width -gt 0) {
            $cntX = $right - $chev.Width - $cnt.Width - 10
            $cnt.Location = New-Object System.Drawing.Point($cntX, $cnt.Location.Y)
        }
    })

    # ── Body ─────────────────────────────────────────────────
    $secBody = New-Object System.Windows.Forms.Panel
    $secBody.BackColor = $script:clrBackground
    $secBody.Location  = New-Object System.Drawing.Point(0, $headerH)
    $secBody.Size      = New-Object System.Drawing.Size($secPanel.Width, $bodyInnerH)
    $secBody.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                         [System.Windows.Forms.AnchorStyles]::Left -bor
                         [System.Windows.Forms.AnchorStyles]::Right
    $secBody.Visible   = $false

    $secBody.Add_Resize({
        foreach ($ctrl in $this.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width - 4 }
        }
    })

    # ── Subcategorías y apps ─────────────────────────────────
    $bodyY = 8
    foreach ($subName in $secSubs.Keys) {
        $appsInSub = $secSubs[$subName]

        $subHeader = New-Object System.Windows.Forms.Panel
        $subHeader.BackColor = [System.Drawing.Color]::FromArgb(
            [Math]::Min(255, $secColor.R + 30),
            [Math]::Min(255, $secColor.G + 30),
            [Math]::Min(255, $secColor.B + 30)
        )
        $subHeader.Size     = New-Object System.Drawing.Size(($secBody.Width - 4), $subHeaderH)
        $subHeader.Location = New-Object System.Drawing.Point(2, $bodyY)
        $subHeader.Anchor   = [System.Windows.Forms.AnchorStyles]::Top -bor
                              [System.Windows.Forms.AnchorStyles]::Left -bor
                              [System.Windows.Forms.AnchorStyles]::Right

        $lblSubName = New-Object System.Windows.Forms.Label
        $lblSubName.Text      = $subName
        $lblSubName.Font      = $script:fontSidebarBold
        $lblSubName.ForeColor = [System.Drawing.Color]::White
        $lblSubName.AutoSize  = $true
        $lblSubName.Location  = New-Object System.Drawing.Point(10, 5)
        $lblSubName.BackColor = [System.Drawing.Color]::Transparent

        $subHeader.Controls.Add($lblSubName)
        $secBody.Controls.Add($subHeader)
        $bodyY += $subHeaderH + $subHeaderGap

        foreach ($app in $appsInSub) {
            $appId   = $app.Id
            $appName = $app.Name
            $appDesc = $app.Desc

            $card = New-Object System.Windows.Forms.Panel
            $card.BackColor = $script:clrCard
            $card.Size      = New-Object System.Drawing.Size(($secBody.Width - 4), $cardH)
            $card.Location  = New-Object System.Drawing.Point(2, $bodyY)
            $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                              [System.Windows.Forms.AnchorStyles]::Left -bor
                              [System.Windows.Forms.AnchorStyles]::Right

            $stripe = New-Object System.Windows.Forms.Panel
            $stripe.BackColor = $secColor
            $stripe.Size      = New-Object System.Drawing.Size(3, $cardH)
            $stripe.Location  = New-Object System.Drawing.Point(0, 0)

            $chk = New-Object System.Windows.Forms.CheckBox
            $chk.Size     = New-Object System.Drawing.Size(18, 18)
            $chk.Location = New-Object System.Drawing.Point(12, 13)
            $chk.Cursor   = [System.Windows.Forms.Cursors]::Hand
            $chk.Tag      = $appId

            $lblName = New-Object System.Windows.Forms.Label
            $lblName.Text      = $appName
            $lblName.Font      = $script:fontButton
            $lblName.ForeColor = $script:clrTextPrimary
            $lblName.AutoSize  = $true
            $lblName.Location  = New-Object System.Drawing.Point(38, 7)
            $lblName.Cursor    = [System.Windows.Forms.Cursors]::Hand

            $lblDesc = New-Object System.Windows.Forms.Label
            $lblDesc.Text      = $appDesc
            $lblDesc.Font      = $script:fontSmall
            $lblDesc.ForeColor = $script:clrTextMuted
            $lblDesc.AutoSize  = $true
            $lblDesc.Location  = New-Object System.Drawing.Point(38, 26)

            $lblId = New-Object System.Windows.Forms.Label
            $lblId.Text      = $appId
            $lblId.Font      = New-Object System.Drawing.Font("Consolas", 7)
            $lblId.ForeColor = [System.Drawing.Color]::FromArgb(180, 190, 210)
            $lblId.AutoSize  = $true
            $lblId.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
            $lblId.Location  = New-Object System.Drawing.Point(0, 8)

            $lblStatus = New-Object System.Windows.Forms.Label
            $lblStatus.Text      = ""
            $lblStatus.Font      = $script:fontSmall
            $lblStatus.ForeColor = $script:clrSuccess
            $lblStatus.AutoSize  = $true
            $lblStatus.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
            $lblStatus.Location  = New-Object System.Drawing.Point(0, 28)

            $chkRef = $chk
            $lblName.Add_Click({ $chkRef.Checked = -not $chkRef.Checked }.GetNewClosure())
            $card.Add_Click({   $chkRef.Checked = -not $chkRef.Checked }.GetNewClosure())

            $chk.Add_CheckedChanged({
                if ($this.Checked) {
                    $this.Parent.BackColor = [System.Drawing.Color]::FromArgb(238, 239, 253)
                } else {
                    $this.Parent.BackColor = $script:clrCard
                }
                Update-SwSelection
            }.GetNewClosure())

            $card.Add_Resize({
                $rightEdge = $this.Width - 10
                foreach ($ctrl in $this.Controls) {
                    if ($ctrl -is [System.Windows.Forms.Label] -and
                        (($ctrl.Anchor -band [System.Windows.Forms.AnchorStyles]::Right) -eq [System.Windows.Forms.AnchorStyles]::Right)) {
                        $ctrl.Location = New-Object System.Drawing.Point(($rightEdge - $ctrl.Width), $ctrl.Location.Y)
                    }
                }
            })

            $card.Controls.AddRange(@($stripe, $chk, $lblName, $lblDesc, $lblId, $lblStatus))
            $secBody.Controls.Add($card)
            $script:swCheckboxes += @{ Chk = $chk; Id = $appId; Name = $appName; StatusLabel = $lblStatus }
            $bodyY += $cardH + $cardGap
        }
        $bodyY += $subHeaderGap
    }

    # ── Toggle colapsar / expandir ───────────────────────────
    $secPanelRef   = $secPanel
    $secBodyRef    = $secBody
    $lblChevronRef = $lblChevron
    $expH          = $expandedH
    $collH         = $collapsedH

    $toggleAction = {
        if ($secPanelRef.Tag -eq "collapsed") {
            $secPanelRef.Tag    = "expanded"
            $secPanelRef.Height = $expH
            $secBodyRef.Visible = $true
        } else {
            $secPanelRef.Tag    = "collapsed"
            $secPanelRef.Height = $collH
            $secBodyRef.Visible = $false
        }
        $lblChevronRef.Text = if ($secPanelRef.Tag -eq "expanded") { "^" } else { "v" }
        # Reflow recalcula $swInner.Height y actualiza el scrollbar
        Reflow-SwSections
    }.GetNewClosure()

    $secHeader.Add_Click($toggleAction)
    $lblSecName.Add_Click($toggleAction)

    $secPanel.Controls.Add($secHeader)
    $secPanel.Controls.Add($secBody)

    $secPanel.Add_Resize({
        $secHeader.Width = $this.Width
        $secBody.Width   = $this.Width - 4
        foreach ($ctrl in $secBody.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $secBody.Width - 4 }
        }
    })

    # Añadir al inner y registrar para reflow
    $swInner.Controls.Add($secPanel)
    $script:swSecPanels += $secPanel
}

# Layout inicial con todas las secciones colapsadas
Reflow-SwSections

# ============================================================
#  EVENTO: SELECCIONAR TODO / NINGUNO
# ============================================================
$script:chkAllHandler = {
    if ($chkAll.CheckState -eq [System.Windows.Forms.CheckState]::Indeterminate) { return }
    $target = ($chkAll.CheckState -eq [System.Windows.Forms.CheckState]::Checked)
    foreach ($entry in $script:swCheckboxes) { $entry.Chk.Checked = $target }
    Update-SwSelection
}
$chkAll.add_CheckedChanged($script:chkAllHandler)

# ============================================================
#  EVENTO: INSTALAR SELECCIONADOS
# ============================================================
$btnInstallAll.Add_Click({
    $selected = $script:swCheckboxes | Where-Object { $_.Chk.Checked }
    $total    = @($selected).Count
    if ($total -eq 0) { return }

    $appList = ($selected | ForEach-Object { "  - $($_.Name)" }) -join "`n"
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Se instalaran $total aplicacion(es) via winget:`n`n$appList`n`nContinuar?",
        "Confirmar instalacion masiva",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($confirm -ne "Yes") { return }

    $btnInstallAll.Enabled = $false
    $chkAll.Enabled        = $false
    foreach ($entry in $script:swCheckboxes) { $entry.Chk.Enabled = $false }

    $current = 0
    foreach ($entry in $selected) {
        $current++
        $appId   = $entry.Id
        $appName = $entry.Name
        $sl      = $entry.StatusLabel

        $script:statusLabel.Text      = "[$current/$total] Instalando $appName..."
        $script:statusLabel.ForeColor = $script:clrWarning
        $sl.Text      = "Instalando..."
        $sl.ForeColor = $script:clrWarning
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $proc = Start-Process -FilePath "winget" `
                -ArgumentList "install --id $appId -e --silent --accept-source-agreements --accept-package-agreements" `
                -Wait -PassThru -WindowStyle Hidden

            switch ($proc.ExitCode) {
                0           { $sl.Text = "OK Instalado";              $sl.ForeColor = $script:clrSuccess }
                -1978335189 { $sl.Text = "Ya instalado";              $sl.ForeColor = $script:clrTextMuted }
                default     { $sl.Text = "Error ($($proc.ExitCode))"; $sl.ForeColor = $script:clrDanger }
            }
        } catch {
            $sl.Text      = "Error: $_"
            $sl.ForeColor = $script:clrDanger
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    $btnInstallAll.Enabled = $true
    $chkAll.Enabled        = $true
    foreach ($entry in $script:swCheckboxes) { $entry.Chk.Enabled = $true }

    $script:statusLabel.Text      = "Listo - $total app(s) procesadas"
    $script:statusLabel.ForeColor = $script:clrSuccess
})

# ============================================================
#  ENSAMBLAR
# ============================================================
$pageSoftware.Controls.Add($swViewport)
$pageSoftware.Controls.Add($swToolbarLine)
$pageSoftware.Controls.Add($swToolbar)

$script:pages["Software"] = $pageSoftware
