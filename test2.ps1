# ============================================================
#  Simple TI Tool - Mesa de Soporte
#  Autor: Practicante TI
#  Descripcion: Herramienta de soporte tecnico para Windows 11
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# ─── PALETA DE COLORES ──────────────────────────────────────
$clrBackground  = [System.Drawing.Color]::FromArgb(245, 246, 250)   # Gris muy claro
$clrSidebar     = [System.Drawing.Color]::FromArgb(30,  33,  48)    # Azul oscuro casi negro
$clrCard        = [System.Drawing.Color]::FromArgb(255, 255, 255)   # Blanco puro
$clrAccent      = [System.Drawing.Color]::FromArgb(99,  102, 241)   # Indigo suave
$clrAccentHover = [System.Drawing.Color]::FromArgb(79,  70,  229)   # Indigo oscuro
$clrSuccess     = [System.Drawing.Color]::FromArgb(34,  197, 94)    # Verde
$clrWarning     = [System.Drawing.Color]::FromArgb(234, 179, 8)     # Amarillo
$clrDanger      = [System.Drawing.Color]::FromArgb(239, 68,  68)    # Rojo
$clrTextPrimary = [System.Drawing.Color]::FromArgb(15,  23,  42)    # Casi negro
$clrTextMuted   = [System.Drawing.Color]::FromArgb(100, 116, 139)   # Gris azulado
$clrBorder      = [System.Drawing.Color]::FromArgb(226, 232, 240)   # Borde sutil
$clrSidebarText = [System.Drawing.Color]::FromArgb(203, 213, 225)   # Texto sidebar
$clrSidebarActive = [System.Drawing.Color]::FromArgb(99, 102, 241)  # Item activo

# ─── FUENTES ────────────────────────────────────────────────
$fontTitle    = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$fontSubtitle = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Regular)
$fontButton   = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::SemiBold)
$fontLabel    = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)
$fontSidebar  = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Regular)
$fontSidebarBold = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$fontSmall    = New-Object System.Drawing.Font("Segoe UI", 7,  [System.Drawing.FontStyle]::Regular)

# ─── DIMENSIONES BASE ───────────────────────────────────────
$sidebarWidth   = 180
$headerHeight   = 60
$minWidth       = 680
$minHeight      = 480
$defaultWidth   = 820
$defaultHeight  = 580

# ============================================================
#  HELPERS
# ============================================================

function New-RoundedButton {
    param(
        [string]$Text,
        [System.Drawing.Point]$Location,
        [System.Drawing.Size]$Size,
        [System.Drawing.Color]$BgColor,
        [System.Drawing.Color]$FgColor = [System.Drawing.Color]::White,
        [string]$Tag = ""
    )
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $Text
    $btn.Location  = $Location
    $btn.Size      = $Size
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize        = 0
    $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BgColor.R - 20),
        [Math]::Max(0, $BgColor.G - 20),
        [Math]::Max(0, $BgColor.B - 20)
    )
    $btn.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $BgColor.R - 40),
        [Math]::Max(0, $BgColor.G - 40),
        [Math]::Max(0, $BgColor.B - 40)
    )
    $btn.BackColor  = $BgColor
    $btn.ForeColor  = $FgColor
    $btn.Font       = $fontButton
    $btn.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $btn.Tag        = $Tag
    $btn.UseVisualStyleBackColor = $false
    return $btn
}

function New-StatusLabel {
    param([string]$Text, [System.Drawing.Point]$Location, [System.Drawing.Color]$Color)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $Text
    $lbl.Location  = $Location
    $lbl.AutoSize  = $true
    $lbl.ForeColor = $Color
    $lbl.Font      = $fontSmall
    $lbl.BackColor = [System.Drawing.Color]::Transparent
    return $lbl
}

function Run-WinGet {
    param([string]$PackageId, [string]$PackageName, [System.Windows.Forms.Label]$StatusLabel)
    $StatusLabel.Text      = "⏳ Instalando $PackageName..."
    $StatusLabel.ForeColor = $clrWarning
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $proc = Start-Process -FilePath "winget" `
            -ArgumentList "install --id $PackageId -e --accept-source-agreements --accept-package-agreements" `
            -Wait -PassThru -WindowStyle Hidden
        if ($proc.ExitCode -eq 0) {
            $StatusLabel.Text      = "✔ $PackageName instalado correctamente"
            $StatusLabel.ForeColor = $clrSuccess
        } else {
            $StatusLabel.Text      = "✖ Error al instalar $PackageName (código $($proc.ExitCode))"
            $StatusLabel.ForeColor = $clrDanger
        }
    } catch {
        $StatusLabel.Text      = "✖ Error: $_"
        $StatusLabel.ForeColor = $clrDanger
    }
}

function Run-Command {
    param([string]$Cmd, [string[]]$Args, [System.Windows.Forms.Label]$StatusLabel, [string]$SuccessMsg)
    $StatusLabel.Text      = "⏳ Ejecutando..."
    $StatusLabel.ForeColor = $clrWarning
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $proc = Start-Process -FilePath $Cmd -ArgumentList $Args -Wait -PassThru -WindowStyle Hidden
        if ($proc.ExitCode -eq 0) {
            $StatusLabel.Text      = "✔ $SuccessMsg"
            $StatusLabel.ForeColor = $clrSuccess
        } else {
            $StatusLabel.Text      = "✖ Error (código $($proc.ExitCode))"
            $StatusLabel.ForeColor = $clrDanger
        }
    } catch {
        $StatusLabel.Text      = "✖ $_"
        $StatusLabel.ForeColor = $clrDanger
    }
}

# ============================================================
#  FORMULARIO PRINCIPAL
# ============================================================
$form = New-Object System.Windows.Forms.Form
$form.Text            = "TI Tool — Mesa de Soporte"
$form.Size            = New-Object System.Drawing.Size($defaultWidth, $defaultHeight)
$form.MinimumSize     = New-Object System.Drawing.Size($minWidth, $minHeight)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $clrBackground
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.Font            = $fontLabel

# ─── SIDEBAR ────────────────────────────────────────────────
$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.BackColor = $clrSidebar
$sidebar.Dock      = [System.Windows.Forms.DockStyle]::Left
$sidebar.Width     = $sidebarWidth

# Logo / título del sidebar
$sidebarTitle = New-Object System.Windows.Forms.Label
$sidebarTitle.Text      = "⚙ TI Tool"
$sidebarTitle.ForeColor = [System.Drawing.Color]::White
$sidebarTitle.Font      = $fontTitle
$sidebarTitle.AutoSize  = $false
$sidebarTitle.Size      = New-Object System.Drawing.Size($sidebarWidth, 60)
$sidebarTitle.Location  = New-Object System.Drawing.Point(0, 0)
$sidebarTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$sidebarTitle.BackColor = [System.Drawing.Color]::FromArgb(20, 23, 38)

$sidebarSep = New-Object System.Windows.Forms.Panel
$sidebarSep.BackColor = [System.Drawing.Color]::FromArgb(50, 60, 80)
$sidebarSep.Size      = New-Object System.Drawing.Size($sidebarWidth, 1)
$sidebarSep.Location  = New-Object System.Drawing.Point(0, 60)

# Secciones del menú sidebar
$menuItems = @(
    @{ Label = "Software";      Icon = "📦"; Y = 80  }
    @{ Label = "Sistema";       Icon = "🛠";  Y = 120 }
    @{ Label = "Red";           Icon = "🌐"; Y = 160 }
    @{ Label = "Inventario";    Icon = "📋"; Y = 200 }
)

$navButtons = @{}
foreach ($item in $menuItems) {
    $nav = New-Object System.Windows.Forms.Button
    $nav.Text      = "$($item.Icon)  $($item.Label)"
    $nav.Size      = New-Object System.Drawing.Size($sidebarWidth, 38)
    $nav.Location  = New-Object System.Drawing.Point(0, $item.Y)
    $nav.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $nav.FlatAppearance.BorderSize = 0
    $nav.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(45, 50, 70)
    $nav.BackColor  = $clrSidebar
    $nav.ForeColor  = $clrSidebarText
    $nav.Font       = $fontSidebar
    $nav.TextAlign  = [System.Drawing.ContentAlignment]::MiddleLeft
    $nav.Padding    = New-Object System.Windows.Forms.Padding(14, 0, 0, 0)
    $nav.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $nav.Tag        = $item.Label
    $nav.UseVisualStyleBackColor = $false
    $sidebar.Controls.Add($nav)
    $navButtons[$item.Label] = $nav
}

# Versión en footer del sidebar
$sidebarFooter = New-Object System.Windows.Forms.Label
$sidebarFooter.Text      = "v1.0 · Practicas TI 2026"
$sidebarFooter.ForeColor = [System.Drawing.Color]::FromArgb(70, 85, 110)
$sidebarFooter.Font      = $fontSmall
$sidebarFooter.AutoSize  = $false
$sidebarFooter.TextAlign = [System.Drawing.ContentAlignment]::BottomCenter
$sidebarFooter.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$sidebarFooter.Height    = 30

$sidebar.Controls.Add($sidebarTitle)
$sidebar.Controls.Add($sidebarSep)
$sidebar.Controls.Add($sidebarFooter)

# ─── AREA PRINCIPAL ─────────────────────────────────────────
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.BackColor = $clrBackground
$mainPanel.Dock      = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.Padding   = New-Object System.Windows.Forms.Padding(20, 16, 20, 16)

# Header del área principal
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
$headerPanel.Height    = $headerHeight
$headerPanel.BackColor = $clrBackground

$headerTitle = New-Object System.Windows.Forms.Label
$headerTitle.Text      = "Instalación de Software"
$headerTitle.Font      = $fontTitle
$headerTitle.ForeColor = $clrTextPrimary
$headerTitle.AutoSize  = $true
$headerTitle.Location  = New-Object System.Drawing.Point(0, 8)

$headerSub = New-Object System.Windows.Forms.Label
$headerSub.Text      = "Gestión de aplicaciones vía Winget"
$headerSub.Font      = $fontSubtitle
$headerSub.ForeColor = $clrTextMuted
$headerSub.AutoSize  = $true
$headerSub.Location  = New-Object System.Drawing.Point(0, 34)

$headerPanel.Controls.Add($headerTitle)
$headerPanel.Controls.Add($headerSub)

# Separador bajo el header
$headerLine = New-Object System.Windows.Forms.Panel
$headerLine.Dock      = [System.Windows.Forms.DockStyle]::Top
$headerLine.Height    = 1
$headerLine.BackColor = $clrBorder
$headerLine.Margin    = New-Object System.Windows.Forms.Padding(0, 4, 0, 4)

# ─── STATUS BAR GLOBAL ──────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.Panel
$statusBar.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$statusBar.Height    = 28
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(238, 241, 247)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text      = "Listo"
$statusLabel.ForeColor = $clrTextMuted
$statusLabel.Font      = $fontSmall
$statusLabel.AutoSize  = $true
$statusLabel.Location  = New-Object System.Drawing.Point(10, 6)

$statusBar.Controls.Add($statusLabel)

# ─── CONTENEDOR DE PÁGINAS (TabControl invisible) ───────────
$pageContainer = New-Object System.Windows.Forms.Panel
$pageContainer.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageContainer.BackColor = $clrBackground

# ============================================================
#  PÁGINA: SOFTWARE
# ============================================================
$pageSoftware = New-Object System.Windows.Forms.Panel
$pageSoftware.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageSoftware.BackColor = $clrBackground
$pageSoftware.Visible   = $true

# Helper para crear tarjetas de instalación
function New-AppCard {
    param(
        [string]$AppName,
        [string]$AppDesc,
        [string]$WingetId,
        [int]$Y,
        [System.Windows.Forms.Panel]$Parent
    )

    $card = New-Object System.Windows.Forms.Panel
    $card.BackColor = $clrCard
    $card.Size      = New-Object System.Drawing.Size(1, 56)   # Ancho se ajusta en resize
    $card.Location  = New-Object System.Drawing.Point(0, $Y)
    $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                      [System.Windows.Forms.AnchorStyles]::Left -bor
                      [System.Windows.Forms.AnchorStyles]::Right
    $card.Tag       = "card"

    # Borde izquierdo decorativo
    $accent = New-Object System.Windows.Forms.Panel
    $accent.BackColor = $clrAccent
    $accent.Size      = New-Object System.Drawing.Size(4, 56)
    $accent.Location  = New-Object System.Drawing.Point(0, 0)
    $accent.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                        [System.Windows.Forms.AnchorStyles]::Left -bor
                        [System.Windows.Forms.AnchorStyles]::Bottom

    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text      = $AppName
    $lblName.Font      = $fontButton
    $lblName.ForeColor = $clrTextPrimary
    $lblName.AutoSize  = $true
    $lblName.Location  = New-Object System.Drawing.Point(16, 10)

    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text      = $AppDesc
    $lblDesc.Font      = $fontSmall
    $lblDesc.ForeColor = $clrTextMuted
    $lblDesc.AutoSize  = $true
    $lblDesc.Location  = New-Object System.Drawing.Point(16, 30)

    $btnInstall = New-RoundedButton -Text "Instalar" `
        -Location (New-Object System.Drawing.Point(0, 12)) `
        -Size (New-Object System.Drawing.Size(80, 30)) `
        -BgColor $clrAccent
    $btnInstall.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor
                         [System.Windows.Forms.AnchorStyles]::Right
    $btnInstall.Tag    = $WingetId

    $btnInstall.Add_Click({
        $id   = $this.Tag
        $name = $this.Parent.Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Font.Bold } | Select-Object -First 1
        Run-WinGet -PackageId $id -PackageName ($name.Text) -StatusLabel $statusLabel
    })

    $card.Controls.Add($accent)
    $card.Controls.Add($lblName)
    $card.Controls.Add($lblDesc)
    $card.Controls.Add($btnInstall)

    # Ajustar posición del botón al añadir al panel padre
    $card.Add_Resize({
        $btn = $this.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] }
        if ($btn) { $btn.Location = New-Object System.Drawing.Point(($this.Width - 94), 12) }
    })

    $Parent.Controls.Add($card)
    return $card
}

# ScrollPanel para las cards
$scrollSoftware = New-Object System.Windows.Forms.Panel
$scrollSoftware.Dock          = [System.Windows.Forms.DockStyle]::Fill
$scrollSoftware.AutoScroll    = $true
$scrollSoftware.BackColor     = $clrBackground
$scrollSoftware.Padding       = New-Object System.Windows.Forms.Padding(0, 8, 0, 8)

$apps = @(
    @{ Name = "Google Chrome";        Desc = "Navegador web de Google";                    Id = "Google.Chrome" }
    @{ Name = "Mozilla Firefox";      Desc = "Navegador web de Mozilla";                   Id = "Mozilla.Firefox" }
    @{ Name = "Visual Studio Code";   Desc = "Editor de código de Microsoft";              Id = "Microsoft.VisualStudioCode" }
    @{ Name = "Notepad++";            Desc = "Editor de texto avanzado";                   Id = "Notepad++.Notepad++" }
    @{ Name = "7-Zip";                Desc = "Compresor/descompresor de archivos";         Id = "7zip.7zip" }
    @{ Name = "VLC Media Player";     Desc = "Reproductor multimedia universal";           Id = "VideoLAN.VLC" }
    @{ Name = "Adobe Acrobat Reader"; Desc = "Lector de documentos PDF";                  Id = "Adobe.Acrobat.Reader.64-bit" }
    @{ Name = "TeamViewer";           Desc = "Acceso y soporte remoto";                   Id = "TeamViewer.TeamViewer" }
    @{ Name = "AnyDesk";              Desc = "Escritorio remoto rápido y seguro";          Id = "AnyDesk.AnyDesk" }
    @{ Name = "WinRAR";               Desc = "Compresor de archivos RAR y ZIP";            Id = "RARLab.WinRAR" }
)

$yOffset = 0
$cardGap  = 8
foreach ($app in $apps) {
    $c = New-AppCard -AppName $app.Name -AppDesc $app.Desc -WingetId $app.Id -Y $yOffset -Parent $scrollSoftware
    $c.Width = $scrollSoftware.Width - 20
    $yOffset += 56 + $cardGap
}

# Ajustar anchos de cards al resize del scroll panel
$scrollSoftware.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) {
            $ctrl.Width = $this.Width - 20
        }
    }
})

$pageSoftware.Controls.Add($scrollSoftware)

# ============================================================
#  PÁGINA: SISTEMA
# ============================================================
$pageSistema = New-Object System.Windows.Forms.Panel
$pageSistema.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageSistema.BackColor = $clrBackground
$pageSistema.Visible   = $false

function New-SysButton {
    param([string]$Text, [string]$Desc, [int]$Y, [System.Drawing.Color]$Color, [scriptblock]$Action)
    $card = New-Object System.Windows.Forms.Panel
    $card.BackColor = $clrCard
    $card.Size      = New-Object System.Drawing.Size(1, 56)
    $card.Location  = New-Object System.Drawing.Point(0, $Y)
    $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                      [System.Windows.Forms.AnchorStyles]::Left -bor
                      [System.Windows.Forms.AnchorStyles]::Right

    $accent = New-Object System.Windows.Forms.Panel
    $accent.BackColor = $Color
    $accent.Size      = New-Object System.Drawing.Size(4, 56)
    $accent.Location  = New-Object System.Drawing.Point(0, 0)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $Text
    $lbl.Font      = $fontButton
    $lbl.ForeColor = $clrTextPrimary
    $lbl.AutoSize  = $true
    $lbl.Location  = New-Object System.Drawing.Point(16, 10)

    $lblD = New-Object System.Windows.Forms.Label
    $lblD.Text      = $Desc
    $lblD.Font      = $fontSmall
    $lblD.ForeColor = $clrTextMuted
    $lblD.AutoSize  = $true
    $lblD.Location  = New-Object System.Drawing.Point(16, 30)

    $btn = New-RoundedButton -Text "Ejecutar" `
        -Location (New-Object System.Drawing.Point(0, 12)) `
        -Size (New-Object System.Drawing.Size(80, 30)) `
        -BgColor $Color
    $btn.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $btn.Add_Click($Action)

    $card.Add_Resize({
        $b = $this.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] }
        if ($b) { $b.Location = New-Object System.Drawing.Point(($this.Width - 94), 12) }
    })

    $card.Controls.AddRange(@($accent, $lbl, $lblD, $btn))
    return $card
}

$scrollSistema = New-Object System.Windows.Forms.Panel
$scrollSistema.Dock       = [System.Windows.Forms.DockStyle]::Fill
$scrollSistema.AutoScroll = $true
$scrollSistema.BackColor  = $clrBackground
$scrollSistema.Padding    = New-Object System.Windows.Forms.Padding(0, 8, 0, 8)

$sysActions = @(
    @{
        Text   = "Actualizaciones de Windows"
        Desc   = "Abre la configuración de Windows Update"
        Color  = $clrAccent
        Action = { Start-Process "ms-settings:windowsupdate" }
    }
    @{
        Text   = "Limpiar archivos temporales"
        Desc   = "Elimina archivos TEMP del sistema"
        Color  = $clrSuccess
        Action = {
            $statusLabel.Text = "⏳ Limpiando archivos temporales..."
            $statusLabel.ForeColor = $clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            try {
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                $statusLabel.Text = "✔ Archivos temporales eliminados"
                $statusLabel.ForeColor = $clrSuccess
            } catch {
                $statusLabel.Text = "✖ Error: $_"
                $statusLabel.ForeColor = $clrDanger
            }
        }
    }
    @{
        Text   = "Administrador de tareas"
        Desc   = "Abre el Administrador de tareas de Windows"
        Color  = $clrWarning
        Action = { Start-Process "taskmgr.exe" }
    }
    @{
        Text   = "Panel de control"
        Desc   = "Abre el Panel de control clásico"
        Color  = $clrAccent
        Action = { Start-Process "control.exe" }
    }
    @{
        Text   = "Información del sistema"
        Desc   = "Abre msinfo32 con datos del equipo"
        Color  = $clrTextMuted
        Action = { Start-Process "msinfo32.exe" }
    }
    @{
        Text   = "Reiniciar equipo"
        Desc   = "Reinicia Windows inmediatamente"
        Color  = $clrDanger
        Action = {
            $confirm = [System.Windows.Forms.MessageBox]::Show(
                "¿Estás seguro de que deseas reiniciar el equipo?",
                "Confirmar reinicio",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            if ($confirm -eq "Yes") { Restart-Computer -Force }
        }
    }
)

$yS = 0
foreach ($sa in $sysActions) {
    $c = New-SysButton -Text $sa.Text -Desc $sa.Desc -Y $yS -Color $sa.Color -Action $sa.Action
    $c.Width = $scrollSistema.Width - 20
    $scrollSistema.Controls.Add($c)
    $yS += 56 + 8
}

$scrollSistema.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width - 20 }
    }
})

$pageSistema.Controls.Add($scrollSistema)

# ============================================================
#  PÁGINA: RED
# ============================================================
$pageRed = New-Object System.Windows.Forms.Panel
$pageRed.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageRed.BackColor = $clrBackground
$pageRed.Visible   = $false

$scrollRed = New-Object System.Windows.Forms.Panel
$scrollRed.Dock       = [System.Windows.Forms.DockStyle]::Fill
$scrollRed.AutoScroll = $true
$scrollRed.BackColor  = $clrBackground
$scrollRed.Padding    = New-Object System.Windows.Forms.Padding(0, 8, 0, 8)

# Output box para resultados de red
$netOutput = New-Object System.Windows.Forms.RichTextBox
$netOutput.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$netOutput.Height    = 160
$netOutput.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$netOutput.ForeColor = [System.Drawing.Color]::FromArgb(134, 239, 172)
$netOutput.Font      = New-Object System.Drawing.Font("Consolas", 8)
$netOutput.ReadOnly  = $true
$netOutput.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$netOutput.ScrollBars  = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$netOutput.Text        = "— Resultados de red aparecerán aquí —`r`n"

$netActions = @(
    @{
        Text   = "Ping a Gateway"
        Desc   = "Verifica conectividad con la puerta de enlace"
        Color  = $clrAccent
        Action = {
            $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1).NextHop
            $netOutput.AppendText("PING $gw`r`n")
            $result = ping $gw -n 4 2>&1
            $netOutput.AppendText(($result -join "`r`n") + "`r`n`r`n")
        }
    }
    @{
        Text   = "IPConfig"
        Desc   = "Muestra configuración de red del equipo"
        Color  = $clrSuccess
        Action = {
            $netOutput.AppendText("IPCONFIG /ALL`r`n")
            $result = ipconfig /all 2>&1
            $netOutput.AppendText(($result -join "`r`n") + "`r`n`r`n")
        }
    }
    @{
        Text   = "Liberar y renovar IP"
        Desc   = "ipconfig /release + /renew"
        Color  = $clrWarning
        Action = {
            $netOutput.AppendText("Liberando IP...`r`n")
            ipconfig /release | Out-Null
            $netOutput.AppendText("Renovando IP...`r`n")
            ipconfig /renew | Out-Null
            $netOutput.AppendText("IP renovada.`r`n`r`n")
        }
    }
    @{
        Text   = "Flush DNS"
        Desc   = "Limpia la caché de resolución DNS"
        Color  = $clrAccent
        Action = {
            ipconfig /flushdns | Out-Null
            $netOutput.AppendText("Cache DNS limpiada.`r`n`r`n")
        }
    }
    @{
        Text   = "Limpiar consola"
        Desc   = "Borra el contenido del panel de resultados"
        Color  = $clrTextMuted
        Action = { $netOutput.Clear(); $netOutput.Text = "— Resultados de red aparecerán aquí —`r`n" }
    }
)

$yR = 0
foreach ($ra in $netActions) {
    $c = New-SysButton -Text $ra.Text -Desc $ra.Desc -Y $yR -Color $ra.Color -Action $ra.Action
    $c.Width = $scrollRed.Width - 20
    $scrollRed.Controls.Add($c)
    $yR += 56 + 8
}

$scrollRed.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $this.Width - 20 }
    }
})

$pageRed.Controls.Add($netOutput)
$pageRed.Controls.Add($scrollRed)

# ============================================================
#  PÁGINA: INVENTARIO
# ============================================================
$pageInventario = New-Object System.Windows.Forms.Panel
$pageInventario.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageInventario.BackColor = $clrBackground
$pageInventario.Visible   = $false

# Panel de formulario
$invCard = New-Object System.Windows.Forms.Panel
$invCard.BackColor = $clrCard
$invCard.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                     [System.Windows.Forms.AnchorStyles]::Left -bor
                     [System.Windows.Forms.AnchorStyles]::Right
$invCard.Size      = New-Object System.Drawing.Size(1, 220)
$invCard.Location  = New-Object System.Drawing.Point(0, 0)

function New-FormField {
    param([string]$LabelText, [int]$Y, [System.Windows.Forms.Panel]$Parent)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $LabelText
    $lbl.Font      = $fontSmall
    $lbl.ForeColor = $clrTextMuted
    $lbl.AutoSize  = $true
    $lbl.Location  = New-Object System.Drawing.Point(16, $Y)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Font       = $fontLabel
    $txt.ForeColor  = $clrTextPrimary
    $txt.BackColor  = $clrBackground
    $txt.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $txt.Size       = New-Object System.Drawing.Size(1, 24)
    $txt.Location   = New-Object System.Drawing.Point(16, $Y + 16)
    $txt.Anchor     = [System.Windows.Forms.AnchorStyles]::Top -bor
                      [System.Windows.Forms.AnchorStyles]::Left -bor
                      [System.Windows.Forms.AnchorStyles]::Right

    $Parent.Controls.Add($lbl)
    $Parent.Controls.Add($txt)
    return $txt
}

$txtUsuario  = New-FormField -LabelText "Usuario / Destinatario" -Y 16  -Parent $invCard
$txtEquipo   = New-FormField -LabelText "Equipo / Activo"        -Y 70  -Parent $invCard
$txtSerial   = New-FormField -LabelText "Número de Serie"        -Y 124 -Parent $invCard

$btnGuardar = New-RoundedButton -Text "Registrar entrega" `
    -Location (New-Object System.Drawing.Point(16, 180)) `
    -Size (New-Object System.Drawing.Size(150, 32)) `
    -BgColor $clrAccent
$btnGuardar.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left

$invCard.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.TextBox]) {
            $ctrl.Width = $this.Width - 32
        }
    }
})

$invCard.Controls.Add($btnGuardar)

# Lista de entregas
$listView = New-Object System.Windows.Forms.ListView
$listView.View          = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.GridLines     = $true
$listView.BackColor     = $clrCard
$listView.ForeColor     = $clrTextPrimary
$listView.Font          = $fontLabel
$listView.BorderStyle   = [System.Windows.Forms.BorderStyle]::None
$listView.Anchor        = [System.Windows.Forms.AnchorStyles]::Top -bor
                          [System.Windows.Forms.AnchorStyles]::Left -bor
                          [System.Windows.Forms.AnchorStyles]::Right -bor
                          [System.Windows.Forms.AnchorStyles]::Bottom
$listView.Location      = New-Object System.Drawing.Point(0, 228)

[void]$listView.Columns.Add("Fecha / Hora", 130)
[void]$listView.Columns.Add("Usuario",      160)
[void]$listView.Columns.Add("Equipo",       160)
[void]$listView.Columns.Add("Serial",       140)

$btnGuardar.Add_Click({
    if ($txtUsuario.Text -eq "" -or $txtEquipo.Text -eq "") {
        [System.Windows.Forms.MessageBox]::Show(
            "Por favor completa al menos Usuario y Equipo.",
            "Campos requeridos",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }
    $item = New-Object System.Windows.Forms.ListViewItem((Get-Date -Format "yyyy-MM-dd HH:mm"))
    [void]$item.SubItems.Add($txtUsuario.Text)
    [void]$item.SubItems.Add($txtEquipo.Text)
    [void]$item.SubItems.Add($txtSerial.Text)
    [void]$listView.Items.Add($item)
    $txtUsuario.Clear(); $txtEquipo.Clear(); $txtSerial.Clear()
    $statusLabel.Text = "✔ Entrega registrada correctamente"
    $statusLabel.ForeColor = $clrSuccess
})

$pageInventario.Controls.Add($invCard)
$pageInventario.Controls.Add($listView)

# Ajuste responsivo del inventario
$pageInventario.Add_Resize({
    $invCard.Width   = $this.Width
    $listView.Width  = $this.Width
    $listView.Height = $this.Height - 228
})

# ============================================================
#  ENSAMBLAR LAYOUT
# ============================================================
$pages = @{
    "Software"   = $pageSoftware
    "Sistema"    = $pageSistema
    "Red"        = $pageRed
    "Inventario" = $pageInventario
}

$headerTitles = @{
    "Software"   = @{ Title = "Instalación de Software";       Sub = "Gestión de aplicaciones vía Winget" }
    "Sistema"    = @{ Title = "Herramientas del Sistema";      Sub = "Mantenimiento y configuración de Windows" }
    "Red"        = @{ Title = "Diagnóstico de Red";            Sub = "Conectividad, IP y DNS" }
    "Inventario" = @{ Title = "Inventario y Entregas";         Sub = "Registro de equipos entregados a usuarios" }
}

$currentPage = "Software"

function Switch-Page {
    param([string]$PageName)
    $script:currentPage = $PageName

    # Actualizar visibilidad de páginas
    foreach ($p in $pages.Keys) {
        $pages[$p].Visible = ($p -eq $PageName)
    }

    # Actualizar header
    $headerTitle.Text = $headerTitles[$PageName].Title
    $headerSub.Text   = $headerTitles[$PageName].Sub

    # Actualizar estilos del sidebar
    foreach ($k in $navButtons.Keys) {
        if ($k -eq $PageName) {
            $navButtons[$k].BackColor = [System.Drawing.Color]::FromArgb(40, 45, 65)
            $navButtons[$k].ForeColor = [System.Drawing.Color]::White
            $navButtons[$k].Font      = $fontSidebarBold
        } else {
            $navButtons[$k].BackColor = $clrSidebar
            $navButtons[$k].ForeColor = $clrSidebarText
            $navButtons[$k].Font      = $fontSidebar
        }
    }
}

# Asignar eventos de navegación
foreach ($k in $navButtons.Keys) {
    $pageName = $k
    $navButtons[$k].Add_Click({ Switch-Page -PageName $this.Tag }.GetNewClosure())
}

# Agregar páginas al contenedor
foreach ($p in $pages.Values) {
    $pageContainer.Controls.Add($p)
}

# Armar el panel principal
$mainPanel.Controls.Add($pageContainer)
$mainPanel.Controls.Add($headerLine)
$mainPanel.Controls.Add($headerPanel)

$form.Controls.Add($mainPanel)
$form.Controls.Add($statusBar)
$form.Controls.Add($sidebar)

# Activar página inicial
Switch-Page -PageName "Software"

# ─── RESIZE RESPONSIVO GLOBAL ───────────────────────────────
$form.Add_Resize({
    $w = $form.ClientSize.Width - $sidebarWidth
    $h = $form.ClientSize.Height - $headerHeight - 1 - 28  # header + sep + statusbar

    $pageContainer.Size     = New-Object System.Drawing.Size($w, $h)
    $pageContainer.Location = New-Object System.Drawing.Point(0, 0)
    $mainPanel.Padding      = New-Object System.Windows.Forms.Padding(16, 12, 16, 0)

    # Ajustar cards de software
    foreach ($ctrl in $scrollSoftware.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $scrollSoftware.Width - 20 }
    }
    foreach ($ctrl in $scrollSistema.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $scrollSistema.Width - 20 }
    }
    foreach ($ctrl in $scrollRed.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) { $ctrl.Width = $scrollRed.Width - 20 }
    }

    # Sidebar footer
    $sidebarFooter.Width = $sidebarWidth
})

# ─── INICIAR APP ────────────────────────────────────────────
[void]$form.ShowDialog()
$form.Dispose()
