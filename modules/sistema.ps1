# ============================================================
#  modules/sistema.ps1
#  Pagina: Herramientas del Sistema
#  Dos secciones:
#    1) Ajustes de Windows  — checkboxes + ejecutar seleccionados
#    2) Paneles y accesos   — botones directos a herramientas
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ============================================================
#  CATÁLOGO DE AJUSTES (checkbox-driven, estilo Chris Titus)
#  Cada ajuste tiene:
#    Name        — texto visible
#    Desc        — descripción corta
#    Category    — agrupa visualmente
#    Risk        — "safe" | "moderate" | "advanced"
#    Script      — scriptblock que se ejecuta al aplicar
# ============================================================
$script:sysTweaks = @(

    # ── AJUSTES ESENCIALES ──────────────────────────────────
    @{
        Category = "Ajustes Esenciales"
        Name     = "Crear punto de restauracion"
        Desc     = "Crea un punto de restauracion del sistema antes de aplicar cambios"
        Risk     = "safe"
        Script   = {
            try {
                $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
                Set-ItemProperty -Path $regPath -Name SystemRestorePointCreationFrequency -Value 0 -Type DWord -Force
                if (-not (Get-ComputerRestorePoint -ErrorAction SilentlyContinue)) {
                    Enable-ComputerRestore -Drive $Env:SystemDrive
                }
                Checkpoint-Computer -Description "TI Tool - Punto de restauracion" -RestorePointType MODIFY_SETTINGS
                return "Punto de restauracion creado correctamente"
            } catch {
                return "Error: $_"
            }
        }
    }
    @{
        Category = "Ajustes Esenciales"
        Name     = "Borrar archivos temporales"
        Desc     = "Elimina carpetas TEMP del usuario y del sistema"
        Risk     = "safe"
        Script   = {
            try {
                $removed = 0
                $paths = @("$Env:Temp\*", "$Env:SystemRoot\Temp\*")
                foreach ($p in $paths) {
                    $items = Get-ChildItem -Path $p -ErrorAction SilentlyContinue
                    $removed += $items.Count
                    Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
                }
                return "Archivos temporales eliminados ($removed elementos)"
            } catch {
                return "Error: $_"
            }
        }
    }
    @{
        Category = "Ajustes Esenciales"
        Name     = "Liberador de espacio en disco"
        Desc     = "Ejecuta Disk Cleanup en C: y limpia componentes Windows Update"
        Risk     = "safe"
        Script   = {
            try {
                Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d C: /VERYLOWDISK" -Wait -WindowStyle Hidden
                Start-Process -FilePath "Dism.exe" `
                    -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase" `
                    -Wait -WindowStyle Hidden
                return "Limpieza de disco completada"
            } catch {
                return "Error: $_"
            }
        }
    }
    @{
        Category = "Ajustes Esenciales"
        Name     = "Deshabilitar Telemetria"
        Desc     = "Desactiva la recopilacion de datos de diagnostico de Microsoft"
        Risk     = "moderate"
        Script   = {
            try {
                $regs = @(
                    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo";                     Name="Enabled";                                       Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy";                             Name="TailoredExperiencesWithDiagnosticDataEnabled";   Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy";                Name="HasAccepted";                                    Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Input\TIPC";                                                 Name="Enabled";                                        Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\InputPersonalization";                                       Name="RestrictImplicitInkCollection";                  Value=1 }
                    @{ Path="HKCU:\Software\Microsoft\InputPersonalization";                                       Name="RestrictImplicitTextCollection";                 Value=1 }
                    @{ Path="HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore";                      Name="HarvestContacts";                               Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Personalization\Settings";                                   Name="AcceptedPrivacyPolicy";                         Value=0 }
                    @{ Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection";             Name="AllowTelemetry";                                Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";                   Name="Start_TrackProgs";                              Value=0 }
                    @{ Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System";                                    Name="PublishUserActivities";                         Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Siuf\Rules";                                                 Name="NumberOfSIUFInPeriod";                          Value=0 }
                )
                foreach ($r in $regs) {
                    if (-not (Test-Path $r.Path)) { New-Item -Path $r.Path -Force | Out-Null }
                    Set-ItemProperty -Path $r.Path -Name $r.Name -Value $r.Value -Type DWord -Force
                }
                Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
                Set-Service -Name diagtrack -StartupType Disabled -ErrorAction SilentlyContinue
                Set-Service -Name wermgr   -StartupType Disabled -ErrorAction SilentlyContinue
                $mem = (Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1KB
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name SvcHostSplitThresholdInKB -Value $mem -Force
                Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name PeriodInNanoSeconds -ErrorAction SilentlyContinue
                return "Telemetria deshabilitada correctamente"
            } catch {
                return "Error: $_"
            }
        }
    }

    # ── RENDIMIENTO ─────────────────────────────────────────
    @{
        Category = "Rendimiento"
        Name     = "Deshabilitar efectos visuales (modo rendimiento)"
        Desc     = "Configura Windows para priorizar el rendimiento sobre la apariencia"
        Risk     = "safe"
        Script   = {
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
                    -Name VisualFXSetting -Value 2 -Type DWord -Force
                return "Efectos visuales reducidos al minimo"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Rendimiento"
        Name     = "Deshabilitar animaciones de Windows"
        Desc     = "Desactiva transiciones y animaciones de la interfaz"
        Risk     = "safe"
        Script   = {
            try {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
                    -Name MinAnimate -Value "0" -Force
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
                    -Name WindowArrangementActive -Value "0" -Force
                return "Animaciones deshabilitadas"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Rendimiento"
        Name     = "Ajustar plan de energia a Alto Rendimiento"
        Desc     = "Activa el plan de energia de Alto Rendimiento del sistema"
        Risk     = "safe"
        Script   = {
            try {
                powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
                return "Plan de energia: Alto Rendimiento activado"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Rendimiento"
        Name     = "Deshabilitar SuperFetch / SysMain"
        Desc     = "Detiene el servicio SysMain que puede causar alto uso de disco"
        Risk     = "moderate"
        Script   = {
            try {
                Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue
                Set-Service  -Name SysMain -StartupType Disabled
                return "SysMain (SuperFetch) deshabilitado"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Rendimiento"
        Name     = "Limpiar lista de programas recientes"
        Desc     = "Borra el historial de archivos y programas recientes"
        Risk     = "safe"
        Script   = {
            try {
                $paths = @(
                    "$Env:APPDATA\Microsoft\Windows\Recent\*",
                    "$Env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*",
                    "$Env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*"
                )
                foreach ($p in $paths) { Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue }
                return "Historial de recientes limpiado"
            } catch { return "Error: $_" }
        }
    }

    # ── PRIVACIDAD ──────────────────────────────────────────
    @{
        Category = "Privacidad"
        Name     = "Deshabilitar Cortana"
        Desc     = "Desactiva Cortana y sus funciones de busqueda en la nube"
        Risk     = "safe"
        Script   = {
            try {
                $paths = @(
                    @{ Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; Name="AllowCortana"; Value=0 }
                    @{ Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search";   Name="CortanaConsent"; Value=0 }
                )
                foreach ($r in $paths) {
                    if (-not (Test-Path $r.Path)) { New-Item -Path $r.Path -Force | Out-Null }
                    Set-ItemProperty -Path $r.Path -Name $r.Name -Value $r.Value -Type DWord -Force
                }
                return "Cortana deshabilitada"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Privacidad"
        Name     = "Deshabilitar publicidad personalizada"
        Desc     = "Desactiva el ID de publicidad y experiencias personalizadas"
        Risk     = "safe"
        Script   = {
            try {
                $paths = @(
                    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo";  Name="Enabled";                    Value=0 }
                    @{ Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy";          Name="TailoredExperiencesWithDiagnosticDataEnabled"; Value=0 }
                )
                foreach ($r in $paths) {
                    if (-not (Test-Path $r.Path)) { New-Item -Path $r.Path -Force | Out-Null }
                    Set-ItemProperty -Path $r.Path -Name $r.Name -Value $r.Value -Type DWord -Force
                }
                return "Publicidad personalizada deshabilitada"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Privacidad"
        Name     = "Deshabilitar sugerencias en el menu Inicio"
        Desc     = "Elimina apps sugeridas y publicidad en el menu Inicio"
        Risk     = "safe"
        Script   = {
            try {
                $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
                if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                $props = @("SystemPaneSuggestionsEnabled","SilentInstalledAppsEnabled",
                           "SoftLandingEnabled","SubscribedContent-338393Enabled",
                           "SubscribedContent-353694Enabled","SubscribedContent-353696Enabled")
                foreach ($p in $props) {
                    Set-ItemProperty -Path $path -Name $p -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                }
                return "Sugerencias del menu Inicio deshabilitadas"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Privacidad"
        Name     = "Deshabilitar Activity History"
        Desc     = "Desactiva el historial de actividad y Timeline de Windows"
        Risk     = "safe"
        Script   = {
            try {
                $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
                if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                Set-ItemProperty -Path $path -Name PublishUserActivities   -Value 0 -Type DWord -Force
                Set-ItemProperty -Path $path -Name EnableActivityFeed      -Value 0 -Type DWord -Force
                Set-ItemProperty -Path $path -Name AllowCrossDeviceClipboard -Value 0 -Type DWord -Force
                return "Activity History deshabilitado"
            } catch { return "Error: $_" }
        }
    }

    # ── EXPLORER / UI ────────────────────────────────────────
    @{
        Category = "Explorer / Interfaz"
        Name     = "Mostrar extensiones de archivo"
        Desc     = "Muestra las extensiones en el Explorador de archivos"
        Risk     = "safe"
        Script   = {
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                    -Name HideFileExt -Value 0 -Type DWord -Force
                return "Extensiones de archivo visibles"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Explorer / Interfaz"
        Name     = "Mostrar archivos ocultos"
        Desc     = "Hace visibles los archivos y carpetas ocultos en el Explorador"
        Risk     = "safe"
        Script   = {
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                    -Name Hidden -Value 1 -Type DWord -Force
                return "Archivos ocultos visibles"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Explorer / Interfaz"
        Name     = "Abrir Explorador en Este Equipo"
        Desc     = "El Explorador de archivos abre Este Equipo en lugar de Acceso rapido"
        Risk     = "safe"
        Script   = {
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                    -Name LaunchTo -Value 1 -Type DWord -Force
                return "Explorador configurado para abrir en Este Equipo"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Explorer / Interfaz"
        Name     = "Deshabilitar Widget de noticias en barra de tareas"
        Desc     = "Elimina el boton de noticias y clima de la barra de tareas"
        Risk     = "safe"
        Script   = {
            try {
                $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
                if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                Set-ItemProperty -Path $path -Name ShellFeedsTaskbarViewMode -Value 2 -Type DWord -Force
                return "Widget de noticias deshabilitado"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Explorer / Interfaz"
        Name     = "Deshabilitar busqueda en Bing desde el menu Inicio"
        Desc     = "Evita que las busquedas locales se envien a Bing"
        Risk     = "safe"
        Script   = {
            try {
                $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
                if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                Set-ItemProperty -Path $path -Name BingSearchEnabled    -Value 0 -Type DWord -Force
                Set-ItemProperty -Path $path -Name CortanaConsent        -Value 0 -Type DWord -Force
                return "Busqueda en Bing deshabilitada"
            } catch { return "Error: $_" }
        }
    }

    # ── SERVICIOS / SEGURIDAD ───────────────────────────────
    @{
        Category = "Servicios"
        Name     = "Deshabilitar Xbox Game Bar"
        Desc     = "Desactiva el overlay de Xbox Game Bar (consume recursos en segundo plano)"
        Risk     = "safe"
        Script   = {
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" `
                    -Name ShowStartupPanel -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
                    -Name AllowGameDVR -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                return "Xbox Game Bar deshabilitado"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Servicios"
        Name     = "Deshabilitar Remote Assistance"
        Desc     = "Desactiva la Asistencia Remota de Windows (distinta a RDP)"
        Risk     = "moderate"
        Script   = {
            try {
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" `
                    -Name fAllowToGetHelp -Value 0 -Type DWord -Force
                return "Remote Assistance deshabilitado"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Servicios"
        Name     = "Habilitar RDP (Escritorio Remoto)"
        Desc     = "Activa el Escritorio Remoto de Windows para conexiones entrantes"
        Risk     = "moderate"
        Script   = {
            try {
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
                    -Name fDenyTSConnections -Value 0 -Type DWord -Force
                Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
                return "RDP habilitado — asegurese de tener contrasena configurada"
            } catch { return "Error: $_" }
        }
    }
    @{
        Category = "Servicios"
        Name     = "Flush DNS y reset Winsock"
        Desc     = "Limpia la cache DNS y restablece la configuracion de red de sockets"
        Risk     = "safe"
        Script   = {
            try {
                ipconfig /flushdns    | Out-Null
                netsh winsock reset   | Out-Null
                netsh int ip reset    | Out-Null
                return "DNS limpiado y Winsock reiniciado — se recomienda reiniciar"
            } catch { return "Error: $_" }
        }
    }
)

# ============================================================
#  PANELES LEGACY / ACCESOS DIRECTOS
# ============================================================
$script:sysPanels = @(
    # Herramientas principales
    @{ Name="Administrador de tareas";   Desc="Monitor de procesos y rendimiento en tiempo real";  Cmd="taskmgr.exe";          Args=""                    ; Color=[System.Drawing.Color]::FromArgb(99,102,241) }
    @{ Name="Panel de Control";          Desc="Configuracion clasica del sistema";                  Cmd="control.exe";          Args=""                    ; Color=[System.Drawing.Color]::FromArgb(99,102,241) }
    @{ Name="Informacion del Sistema";   Desc="Resumen de hardware, software y componentes";        Cmd="msinfo32.exe";         Args=""                    ; Color=[System.Drawing.Color]::FromArgb(99,102,241) }
    # Legacy Windows Panels
    @{ Name="Administracion de Equipos"; Desc="Consola MMC: discos, usuarios, servicios y mas";    Cmd="compmgmt.msc";         Args=""                    ; Color=[System.Drawing.Color]::FromArgb(59,130,246) }
    @{ Name="Opciones de Energia";       Desc="Planes de energia y configuracion de suspension";    Cmd="powercfg.cpl";         Args=""                    ; Color=[System.Drawing.Color]::FromArgb(59,130,246) }
    @{ Name="Conexiones de Red";         Desc="Adaptadores de red, VPN y configuracion IP";         Cmd="ncpa.cpl";             Args=""                    ; Color=[System.Drawing.Color]::FromArgb(59,130,246) }
    @{ Name="Region";                    Desc="Formato de fecha, hora, moneda e idioma";            Cmd="intl.cpl";             Args=""                    ; Color=[System.Drawing.Color]::FromArgb(59,130,246) }
    @{ Name="Sonido";                    Desc="Dispositivos de audio, reproduccion y grabacion";    Cmd="mmsys.cpl";            Args=""                    ; Color=[System.Drawing.Color]::FromArgb(59,130,246) }
    @{ Name="Propiedades del Sistema";   Desc="Nombre del equipo, dominio y opciones avanzadas";    Cmd="sysdm.cpl";            Args=""                    ; Color=[System.Drawing.Color]::FromArgb(59,130,246) }
    @{ Name="Restaurar Sistema";         Desc="Asistente para revertir el sistema a un punto anterior"; Cmd="rstrui.exe";       Args=""                    ; Color=[System.Drawing.Color]::FromArgb(239,68,68)  }
)

# ============================================================
#  COLORES DE RIESGO
# ============================================================
$riskColors = @{
    "safe"     = [System.Drawing.Color]::FromArgb(34,  197, 94)    # verde
    "moderate" = [System.Drawing.Color]::FromArgb(234, 179, 8)     # amarillo
    "advanced" = [System.Drawing.Color]::FromArgb(239, 68,  68)    # rojo
}
$riskLabels = @{
    "safe"     = "Seguro"
    "moderate" = "Moderado"
    "advanced" = "Avanzado"
}

# Referencias globales
$script:sysTweakCheckboxes = @()
$script:sysTweakCatPanels  = @()

# ============================================================
#  PÁGINA PRINCIPAL
# ============================================================
$pageSistema = New-Object System.Windows.Forms.Panel
$pageSistema.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageSistema.BackColor = $script:clrBackground
$pageSistema.Visible   = $false

# ============================================================
#  SISTEMA DE SCROLL MANUAL (mismo patrón que software.ps1)
#  $sysViewport  → Fill, sin AutoScroll
#    $sysVBar    → VScrollBar anclado a la derecha
#    $sysInner   → Panel contenedor, Top = -$sysVBar.Value
#      [toolbar de tweaks]
#      [sep]
#      [header "Ajustes de Windows"]
#      [tweakBlock  ← altura variable según categorías]
#      [header "Paneles y accesos"]
#      [panelsBlock ← altura fija]
# ============================================================

$sysViewport = New-Object System.Windows.Forms.Panel
$sysViewport.Dock       = [System.Windows.Forms.DockStyle]::Fill
$sysViewport.BackColor  = $script:clrBackground
$sysViewport.AutoScroll = $false

$sysVBar = New-Object System.Windows.Forms.VScrollBar
$sysVBar.Dock        = [System.Windows.Forms.DockStyle]::Right
$sysVBar.SmallChange = 20
$sysVBar.LargeChange = 80

$sysInner = New-Object System.Windows.Forms.Panel
$sysInner.BackColor = $script:clrBackground
$sysInner.Location  = New-Object System.Drawing.Point(0, 0)
$sysInner.AutoSize  = $false

# ── Funciones de scroll ──────────────────────────────────────
function Update-SysScrollBar {
    $contentH  = $sysInner.Height
    $viewportH = $sysViewport.ClientSize.Height
    $innerW    = $sysViewport.ClientSize.Width - $sysVBar.Width
    if ($sysInner.Width -ne $innerW -and $innerW -gt 0) {
        $sysInner.Width = $innerW
        # Propagar ancho a hijos directos del inner
        foreach ($ctrl in $sysInner.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $innerW }
        }
    }
    if ($contentH -le $viewportH) {
        $sysVBar.Enabled = $false
        $sysVBar.Value   = 0
        $sysInner.Top    = 0
    } else {
        $sysVBar.Enabled = $true
        $range           = $contentH - $viewportH
        $sysVBar.Maximum = $range + $sysVBar.LargeChange - 1
        if ($sysVBar.Value -gt $range) { $sysVBar.Value = $range }
        $sysInner.Top    = -$sysVBar.Value
    }
}

# Recalcula Y de cada control en sysInner y ajusta su Height total
function Reflow-SysInner {
    $y = 0
    $tweakToolbar.Location      = New-Object System.Drawing.Point(0, $y); $y += 44
    $tweakToolbarLine.Location  = New-Object System.Drawing.Point(0, $y); $y += 1
    $tweakSectionHdr.Location   = New-Object System.Drawing.Point(0, $y); $y += 32
    $tweakBlock.Location        = New-Object System.Drawing.Point(0, $y); $y += $tweakBlock.Height + 8
    $panelsSectionHdr.Location  = New-Object System.Drawing.Point(0, $y); $y += 32 + 4
    $panelsBlock.Location       = New-Object System.Drawing.Point(0, $y); $y += $panelsBlock.Height
    $sysInner.Height            = $y + 16
    Update-SysScrollBar
}

# Reposiciona catPanels dentro de tweakBlock y actualiza su Height
function Reflow-TweakCats {
    $y = 0
    foreach ($cp in $script:sysTweakCatPanels) {
        $cp.Location = New-Object System.Drawing.Point(0, $y)
        $y += $cp.Height + 4
    }
    $tweakBlock.Height = $y + 4
    # Al cambiar tweakBlock.Height hay que relayoutar el sysInner completo
    Reflow-SysInner
}

$sysVBar.Add_Scroll({ $sysInner.Top = -$sysVBar.Value })

$sysWheelHandler = {
    if (-not $sysVBar.Enabled) { return }
    $delta  = [int]($_.Delta / 120) * $sysVBar.SmallChange * 3
    $newVal = $sysVBar.Value - $delta
    $maxVal = $sysVBar.Maximum - $sysVBar.LargeChange + 1
    if ($newVal -lt 0)       { $newVal = 0 }
    if ($newVal -gt $maxVal) { $newVal = $maxVal }
    $sysVBar.Value = $newVal
    $sysInner.Top  = -$newVal
}
$sysViewport.Add_MouseWheel($sysWheelHandler)
$sysInner.Add_MouseWheel($sysWheelHandler)

$sysViewport.Add_Resize({ Update-SysScrollBar })

$sysViewport.Controls.Add($sysVBar)
$sysViewport.Controls.Add($sysInner)

# ============================================================
#  TOOLBAR DE TWEAKS
# ============================================================
$tweakToolbar = New-Object System.Windows.Forms.Panel
$tweakToolbar.BackColor = $script:clrCard
$tweakToolbar.Height    = 44
$tweakToolbar.Width     = $sysInner.Width

$tweakChkAll = New-Object System.Windows.Forms.CheckBox
$tweakChkAll.Text       = "Seleccionar todo"
$tweakChkAll.Font       = $script:fontLabel
$tweakChkAll.ForeColor  = $script:clrTextPrimary
$tweakChkAll.AutoSize   = $true
$tweakChkAll.Location   = New-Object System.Drawing.Point(12, 13)
$tweakChkAll.Cursor     = [System.Windows.Forms.Cursors]::Hand
$tweakChkAll.ThreeState = $true

$tweakLblCount = New-Object System.Windows.Forms.Label
$tweakLblCount.Text      = "0 seleccionados"
$tweakLblCount.Font      = $script:fontSmall
$tweakLblCount.ForeColor = $script:clrTextMuted
$tweakLblCount.AutoSize  = $true
$tweakLblCount.Location  = New-Object System.Drawing.Point(165, 16)

$btnApplyTweaks = New-RoundedButton `
    -Text    "Aplicar seleccionados" `
    -Location (New-Object System.Drawing.Point(0, 8)) `
    -Size    (New-Object System.Drawing.Size(165, 28)) `
    -BgColor $script:clrAccent
$btnApplyTweaks.Anchor  = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$btnApplyTweaks.Enabled = $false

$tweakToolbar.Controls.AddRange(@($tweakChkAll, $tweakLblCount, $btnApplyTweaks))
$tweakToolbar.Add_Resize({
    $btnApplyTweaks.Location = New-Object System.Drawing.Point(($this.Width - 173), 8)
})

$tweakToolbarLine = New-Object System.Windows.Forms.Panel
$tweakToolbarLine.Height    = 1
$tweakToolbarLine.BackColor = $script:clrBorder
$tweakToolbarLine.Width     = $sysInner.Width

# ── Header "Ajustes de Windows" ─────────────────────────────
$tweakSectionHdr = New-Object System.Windows.Forms.Panel
$tweakSectionHdr.BackColor = [System.Drawing.Color]::FromArgb(30, 33, 48)
$tweakSectionHdr.Height    = 32
$tweakSectionHdr.Width     = $sysInner.Width

$tweakSectionLbl = New-Object System.Windows.Forms.Label
$tweakSectionLbl.Text      = "  Ajustes de Windows"
$tweakSectionLbl.Font      = $script:fontSidebarBold
$tweakSectionLbl.ForeColor = [System.Drawing.Color]::White
$tweakSectionLbl.BackColor = [System.Drawing.Color]::Transparent
$tweakSectionLbl.AutoSize  = $true
$tweakSectionLbl.Location  = New-Object System.Drawing.Point(0, 8)
$tweakSectionHdr.Controls.Add($tweakSectionLbl)

# ── Bloque de tweaks (altura dinámica) ──────────────────────
$tweakBlock = New-Object System.Windows.Forms.Panel
$tweakBlock.BackColor = $script:clrBackground
$tweakBlock.Width     = $sysInner.Width
$tweakBlock.Height    = 0   # Reflow-TweakCats lo calculará

$tweakBlock.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width }
    }
})

# ── Función de selección ─────────────────────────────────────
function Update-TweakSelection {
    $count = ($script:sysTweakCheckboxes | Where-Object { $_.Chk.Checked }).Count
    $total = $script:sysTweakCheckboxes.Count
    if ($count -eq 1) { $tweakLblCount.Text = "1 seleccionado" }
    else              { $tweakLblCount.Text = "$count seleccionados" }
    $tweakLblCount.ForeColor = if ($count -gt 0) { $script:clrAccent } else { $script:clrTextMuted }
    $btnApplyTweaks.Enabled  = ($count -gt 0)

    $tweakChkAll.remove_CheckedChanged($script:tweakChkAllHandler)
    if ($count -eq 0)          { $tweakChkAll.CheckState = [System.Windows.Forms.CheckState]::Unchecked }
    elseif ($count -eq $total) { $tweakChkAll.CheckState = [System.Windows.Forms.CheckState]::Checked }
    else                       { $tweakChkAll.CheckState = [System.Windows.Forms.CheckState]::Indeterminate }
    $tweakChkAll.add_CheckedChanged($script:tweakChkAllHandler)
}

# ============================================================
#  CONSTRUIR CATEGORÍAS DE TWEAKS
# ============================================================
$cardH      = 48
$cardGap    = 5
$catHeaderH = 28

$categories = $script:sysTweaks | ForEach-Object { $_.Category } | Select-Object -Unique

foreach ($cat in $categories) {
    $catTweaks    = $script:sysTweaks | Where-Object { $_.Category -eq $cat }
    $finalBodyH   = 4 + ($catTweaks.Count * ($cardH + $cardGap)) + 4
    $expH         = $catHeaderH + $finalBodyH
    $collH        = $catHeaderH

    $catPanel = New-Object System.Windows.Forms.Panel
    $catPanel.BackColor = $script:clrBackground
    $catPanel.Width     = $tweakBlock.Width
    $catPanel.Height    = $collH
    $catPanel.Tag       = "collapsed"

    $catHdr = New-Object System.Windows.Forms.Panel
    $catHdr.BackColor = [System.Drawing.Color]::FromArgb(45, 50, 70)
    $catHdr.Size      = New-Object System.Drawing.Size($catPanel.Width, $catHeaderH)
    $catHdr.Location  = New-Object System.Drawing.Point(0, 0)
    $catHdr.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                        [System.Windows.Forms.AnchorStyles]::Left -bor
                        [System.Windows.Forms.AnchorStyles]::Right
    $catHdr.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $catLbl = New-Object System.Windows.Forms.Label
    $catLbl.Text      = $cat
    $catLbl.Font      = $script:fontSidebarBold
    $catLbl.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $catLbl.AutoSize  = $true
    $catLbl.Location  = New-Object System.Drawing.Point(12, 7)
    $catLbl.BackColor = [System.Drawing.Color]::Transparent
    $catLbl.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $catCountLbl = New-Object System.Windows.Forms.Label
    $catCountLbl.Text      = "$($catTweaks.Count) ajustes"
    $catCountLbl.Font      = $script:fontSmall
    $catCountLbl.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $catCountLbl.AutoSize  = $true
    $catCountLbl.BackColor = [System.Drawing.Color]::Transparent
    $catCountLbl.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $catCountLbl.Location  = New-Object System.Drawing.Point(0, 9)

    $catChevron = New-Object System.Windows.Forms.Label
    $catChevron.Text      = "v"
    $catChevron.Font      = $script:fontSidebarBold
    $catChevron.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $catChevron.AutoSize  = $true
    $catChevron.BackColor = [System.Drawing.Color]::Transparent
    $catChevron.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $catChevron.Location  = New-Object System.Drawing.Point(0, 8)

    $catHdr.Controls.AddRange(@($catLbl, $catCountLbl, $catChevron))

    $catHdr.Add_Resize({
        $r    = $this.Width - 10
        $chev = $this.Controls | Where-Object { $_.Text -eq "v" -or $_.Text -eq "^" } | Select-Object -First 1
        $cnt  = $this.Controls | Where-Object { $_.Text -match "ajustes" }             | Select-Object -First 1
        if ($chev -and $chev.Width -gt 0) {
            $chevX = $r - $chev.Width
            $chev.Location = New-Object System.Drawing.Point($chevX, $chev.Location.Y)
        }
        if ($cnt -and $cnt.Width -gt 0 -and $chev -and $chev.Width -gt 0) {
            $cntX = $r - $chev.Width - $cnt.Width - 8
            $cnt.Location = New-Object System.Drawing.Point($cntX, $cnt.Location.Y)
        }
    })

    $catBody = New-Object System.Windows.Forms.Panel
    $catBody.BackColor = $script:clrBackground
    $catBody.Location  = New-Object System.Drawing.Point(0, $catHeaderH)
    $catBody.Size      = New-Object System.Drawing.Size($catPanel.Width, $finalBodyH)
    $catBody.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                         [System.Windows.Forms.AnchorStyles]::Left -bor
                         [System.Windows.Forms.AnchorStyles]::Right
    $catBody.Visible   = $false

    $catBody.Add_Resize({
        foreach ($ctrl in $this.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width - 2 }
        }
    })

    $bodyY = 4
    foreach ($tweak in $catTweaks) {
        $tweakName   = $tweak.Name
        $tweakDesc   = $tweak.Desc
        $tweakRisk   = $tweak.Risk
        $tweakScript = $tweak.Script
        $riskColor   = $riskColors[$tweakRisk]
        $riskLabel   = $riskLabels[$tweakRisk]

        $card = New-Object System.Windows.Forms.Panel
        $card.BackColor = $script:clrCard
        $card.Size      = New-Object System.Drawing.Size(($catBody.Width - 2), $cardH)
        $card.Location  = New-Object System.Drawing.Point(1, $bodyY)
        $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                          [System.Windows.Forms.AnchorStyles]::Left -bor
                          [System.Windows.Forms.AnchorStyles]::Right

        $stripe = New-Object System.Windows.Forms.Panel
        $stripe.BackColor = $riskColor
        $stripe.Size      = New-Object System.Drawing.Size(3, $cardH)
        $stripe.Location  = New-Object System.Drawing.Point(0, 0)

        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Size     = New-Object System.Drawing.Size(18, 18)
        $chk.Location = New-Object System.Drawing.Point(12, 15)
        $chk.Cursor   = [System.Windows.Forms.Cursors]::Hand

        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text      = $tweakName
        $lblName.Font      = $script:fontButton
        $lblName.ForeColor = $script:clrTextPrimary
        $lblName.AutoSize  = $true
        $lblName.Location  = New-Object System.Drawing.Point(38, 8)
        $lblName.Cursor    = [System.Windows.Forms.Cursors]::Hand

        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text      = $tweakDesc
        $lblDesc.Font      = $script:fontSmall
        $lblDesc.ForeColor = $script:clrTextMuted
        $lblDesc.AutoSize  = $true
        $lblDesc.Location  = New-Object System.Drawing.Point(38, 27)

        $lblRisk = New-Object System.Windows.Forms.Label
        $lblRisk.Text      = $riskLabel
        $lblRisk.Font      = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
        $lblRisk.ForeColor = $riskColor
        $lblRisk.BackColor = [System.Drawing.Color]::FromArgb(
            [Math]::Min(255, $riskColor.R + 180),
            [Math]::Min(255, $riskColor.G + 180),
            [Math]::Min(255, $riskColor.B + 180)
        )
        $lblRisk.AutoSize  = $true
        $lblRisk.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
        $lblRisk.Location  = New-Object System.Drawing.Point(0, 8)
        $lblRisk.Padding   = New-Object System.Windows.Forms.Padding(4, 2, 4, 2)

        $lblStatus = New-Object System.Windows.Forms.Label
        $lblStatus.Text      = ""
        $lblStatus.Font      = $script:fontSmall
        $lblStatus.ForeColor = $script:clrSuccess
        $lblStatus.AutoSize  = $true
        $lblStatus.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
        $lblStatus.Location  = New-Object System.Drawing.Point(0, 30)

        $chkRef = $chk
        $lblName.Add_Click({ $chkRef.Checked = -not $chkRef.Checked }.GetNewClosure())
        $card.Add_Click({   $chkRef.Checked = -not $chkRef.Checked }.GetNewClosure())

        $chk.Add_CheckedChanged({
            if ($this.Checked) {
                $this.Parent.BackColor = [System.Drawing.Color]::FromArgb(238, 239, 253)
            } else {
                $this.Parent.BackColor = $script:clrCard
            }
            Update-TweakSelection
        }.GetNewClosure())

        $card.Add_Resize({
            $re = $this.Width - 10
            foreach ($ctrl in $this.Controls) {
                if ($ctrl -is [System.Windows.Forms.Label] -and
                    (($ctrl.Anchor -band [System.Windows.Forms.AnchorStyles]::Right) -eq [System.Windows.Forms.AnchorStyles]::Right)) {
                    $ctrl.Location = New-Object System.Drawing.Point(($re - $ctrl.Width), $ctrl.Location.Y)
                }
            }
        })

        $card.Controls.AddRange(@($stripe, $chk, $lblName, $lblDesc, $lblRisk, $lblStatus))
        $catBody.Controls.Add($card)
        $script:sysTweakCheckboxes += @{ Chk = $chk; Data = $tweak; StatusLabel = $lblStatus }
        $bodyY += $cardH + $cardGap
    }

    $catPanelRef = $catPanel
    $catBodyRef  = $catBody
    $catChevRef  = $catChevron
    $expHRef     = $expH
    $collHRef    = $collH

    $toggleCat = {
        if ($catPanelRef.Tag -eq "collapsed") {
            $catPanelRef.Tag    = "expanded"
            $catPanelRef.Height = $expHRef
            $catBodyRef.Visible = $true
            $catBodyRef.Width   = $catPanelRef.Width - 2
            $catChevRef.Text    = "^"
        } else {
            $catPanelRef.Tag    = "collapsed"
            $catPanelRef.Height = $collHRef
            $catBodyRef.Visible = $false
            $catChevRef.Text    = "v"
        }
        Reflow-TweakCats
    }.GetNewClosure()

    $catHdr.Add_Click($toggleCat)
    $catLbl.Add_Click($toggleCat)

    $catPanel.Controls.Add($catHdr)
    $catPanel.Controls.Add($catBody)

    $catPanel.Add_Resize({
        $catHdr.Width  = $this.Width
        $catBody.Width = $this.Width - 2
        foreach ($ctrl in $catBody.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $catBody.Width - 2 }
        }
    })

    $tweakBlock.Controls.Add($catPanel)
    $script:sysTweakCatPanels += $catPanel
}

# ============================================================
#  SECCIÓN 2 — PANELES Y ACCESOS DIRECTOS
# ============================================================
$panelsSectionHdr = New-Object System.Windows.Forms.Panel
$panelsSectionHdr.BackColor = [System.Drawing.Color]::FromArgb(30, 33, 48)
$panelsSectionHdr.Height    = 32
$panelsSectionHdr.Width     = $sysInner.Width

$panelsSectionLbl = New-Object System.Windows.Forms.Label
$panelsSectionLbl.Text      = "  Paneles y accesos directos"
$panelsSectionLbl.Font      = $script:fontSidebarBold
$panelsSectionLbl.ForeColor = [System.Drawing.Color]::White
$panelsSectionLbl.BackColor = [System.Drawing.Color]::Transparent
$panelsSectionLbl.AutoSize  = $true
$panelsSectionLbl.Location  = New-Object System.Drawing.Point(0, 8)
$panelsSectionHdr.Controls.Add($panelsSectionLbl)

$panelsBlock = New-Object System.Windows.Forms.Panel
$panelsBlock.BackColor = $script:clrBackground
$panelsBlock.Width     = $sysInner.Width

$panelsBlock.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width }
    }
})

$panelCardH   = 48
$panelCardGap = 5
$pY           = 4

foreach ($panel in $script:sysPanels) {
    $pCmd   = $panel.Cmd
    $pName  = $panel.Name
    $pColor = $panel.Color

    $pCard = New-ActionCard `
        -Title       $pName `
        -Desc        $panel.Desc `
        -Y           $pY `
        -AccentColor $pColor `
        -ButtonText  "Abrir" `
        -OnClick     {
            try {
                Start-Process $pCmd
                $script:statusLabel.Text      = "Abriendo $pName..."
                $script:statusLabel.ForeColor = $script:clrTextMuted
            } catch {
                $script:statusLabel.Text      = "Error: $_"
                $script:statusLabel.ForeColor = $script:clrDanger
            }
        }.GetNewClosure()

    $pCard.Width = $panelsBlock.Width
    $panelsBlock.Controls.Add($pCard)
    $pY += $panelCardH + $panelCardGap
}

$panelsBlock.Height = $pY + 4

# ============================================================
#  ENSAMBLAR sysInner y calcular layout inicial
# ============================================================
$sysInner.Controls.AddRange(@(
    $tweakToolbar, $tweakToolbarLine,
    $tweakSectionHdr, $tweakBlock,
    $panelsSectionHdr, $panelsBlock
))

# Propagar resize del sysInner a todos sus hijos directos
$sysInner.Add_Resize({
    $w = $this.Width
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $w }
    }
    Reflow-SysInner
})

# Layout inicial: primero las categorías, luego el inner completo
Reflow-TweakCats   # calcula tweakBlock.Height y llama Reflow-SysInner

# ============================================================
#  EVENTO: SELECCIONAR TODO
# ============================================================
$script:tweakChkAllHandler = {
    if ($tweakChkAll.CheckState -eq [System.Windows.Forms.CheckState]::Indeterminate) { return }
    $target = ($tweakChkAll.CheckState -eq [System.Windows.Forms.CheckState]::Checked)
    foreach ($entry in $script:sysTweakCheckboxes) { $entry.Chk.Checked = $target }
    Update-TweakSelection
}
$tweakChkAll.add_CheckedChanged($script:tweakChkAllHandler)

# ============================================================
#  EVENTO: APLICAR AJUSTES SELECCIONADOS
# ============================================================
$btnApplyTweaks.Add_Click({
    $selected = $script:sysTweakCheckboxes | Where-Object { $_.Chk.Checked }
    $total    = @($selected).Count
    if ($total -eq 0) { return }

    $tweakList = ($selected | ForEach-Object { "  - $($_.Data.Name)" }) -join "`n"
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Se aplicaran $total ajuste(s):`n`n$tweakList`n`nAlgunos cambios requieren reinicio.`nContinuar?",
        "Confirmar ajustes",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne "Yes") { return }

    $btnApplyTweaks.Enabled = $false
    $tweakChkAll.Enabled    = $false
    foreach ($entry in $script:sysTweakCheckboxes) { $entry.Chk.Enabled = $false }

    $current = 0
    foreach ($entry in $selected) {
        $current++
        $tweakName   = $entry.Data.Name
        $sl          = $entry.StatusLabel
        $scriptBlock = $entry.Data.Script

        $script:statusLabel.Text      = "[$current/$total] Aplicando: $tweakName..."
        $script:statusLabel.ForeColor = $script:clrWarning
        $sl.Text      = "Aplicando..."
        $sl.ForeColor = $script:clrWarning
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $result = & $scriptBlock
            if ($result -match "^Error") {
                $sl.Text      = $result
                $sl.ForeColor = $script:clrDanger
            } else {
                $sl.Text      = $result
                $sl.ForeColor = $script:clrSuccess
            }
        } catch {
            $sl.Text      = "Error: $_"
            $sl.ForeColor = $script:clrDanger
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    $btnApplyTweaks.Enabled = $true
    $tweakChkAll.Enabled    = $true
    foreach ($entry in $script:sysTweakCheckboxes) { $entry.Chk.Enabled = $true }

    $script:statusLabel.Text      = "Listo - $total ajuste(s) aplicados"
    $script:statusLabel.ForeColor = $script:clrSuccess
})

# ============================================================
#  ENSAMBLAR PÁGINA
# ============================================================
$pageSistema.Controls.Add($sysViewport)

$script:pages["Sistema"] = $pageSistema
