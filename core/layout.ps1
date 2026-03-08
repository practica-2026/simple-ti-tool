# ============================================================
#  core/layout.ps1
#  Formulario principal, sidebar, header, statusbar y
#  contenedor de páginas. Define Switch-Page y Start-TITool.
#  Dependencias: core/ui.ps1 debe haberse ejecutado antes.
# ============================================================

# ─── FORMULARIO PRINCIPAL ───────────────────────────────────
$script:form = New-Object System.Windows.Forms.Form
$script:form.Text            = "TI Tool - Mesa de Soporte"
$script:form.Size            = New-Object System.Drawing.Size($script:defaultWidth, $script:defaultHeight)
$script:form.MinimumSize     = New-Object System.Drawing.Size($script:minWidth, $script:minHeight)
$script:form.StartPosition   = "CenterScreen"
$script:form.BackColor       = $script:clrBackground
$script:form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$script:form.Font            = $script:fontLabel

# ─── SIDEBAR ────────────────────────────────────────────────
$script:sidebar = New-Object System.Windows.Forms.Panel
$script:sidebar.BackColor = $script:clrSidebar
$script:sidebar.Dock      = [System.Windows.Forms.DockStyle]::Left
$script:sidebar.Width     = $script:sidebarWidth

# Cabecera del sidebar
$sidebarTitle = New-Object System.Windows.Forms.Label
$sidebarTitle.Text      = "TI Tool"
$sidebarTitle.ForeColor = [System.Drawing.Color]::White
$sidebarTitle.Font      = $script:fontTitle
$sidebarTitle.AutoSize  = $false
$sidebarTitle.Size      = New-Object System.Drawing.Size($script:sidebarWidth, 60)
$sidebarTitle.Location  = New-Object System.Drawing.Point(0, 0)
$sidebarTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$sidebarTitle.BackColor = [System.Drawing.Color]::FromArgb(20, 23, 38)

# Separador bajo la cabecera
$sidebarSep = New-Object System.Windows.Forms.Panel
$sidebarSep.BackColor = [System.Drawing.Color]::FromArgb(50, 60, 80)
$sidebarSep.Size      = New-Object System.Drawing.Size($script:sidebarWidth, 1)
$sidebarSep.Location  = New-Object System.Drawing.Point(0, 60)

# Ítems de navegación: Label visible, ícono y posición Y
$menuItems = @(
    @{ Label = "Software";   Icon = "[SW]"; Y = 80  }
    @{ Label = "Sistema";    Icon = "[SY]"; Y = 120 }
    @{ Label = "Red";        Icon = "[NW]"; Y = 160 }
    @{ Label = "Inventario"; Icon = "[IN]"; Y = 200 }
)

$script:navButtons = @{}
foreach ($item in $menuItems) {
    $nav = New-Object System.Windows.Forms.Button
    $nav.Text      = "  $($item.Label)"
    $nav.Size      = New-Object System.Drawing.Size($script:sidebarWidth, 38)
    $nav.Location  = New-Object System.Drawing.Point(0, $item.Y)
    $nav.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $nav.FlatAppearance.BorderSize = 0
    $nav.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(45, 50, 70)
    $nav.BackColor  = $script:clrSidebar
    $nav.ForeColor  = $script:clrSidebarText
    $nav.Font       = $script:fontSidebar
    $nav.TextAlign  = [System.Drawing.ContentAlignment]::MiddleLeft
    $nav.Padding    = New-Object System.Windows.Forms.Padding(14, 0, 0, 0)
    $nav.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $nav.Tag        = $item.Label
    $nav.UseVisualStyleBackColor = $false
    $script:sidebar.Controls.Add($nav)
    $script:navButtons[$item.Label] = $nav
}

# Footer del sidebar
$script:sidebarFooter = New-Object System.Windows.Forms.Label
$script:sidebarFooter.Text      = "v1.0 - Practicas TI 2026"
$script:sidebarFooter.ForeColor = [System.Drawing.Color]::FromArgb(70, 85, 110)
$script:sidebarFooter.Font      = $script:fontSmall
$script:sidebarFooter.AutoSize  = $false
$script:sidebarFooter.Width     = $script:sidebarWidth
$script:sidebarFooter.TextAlign = [System.Drawing.ContentAlignment]::BottomCenter
$script:sidebarFooter.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$script:sidebarFooter.Height    = 30

$script:sidebar.Controls.Add($sidebarTitle)
$script:sidebar.Controls.Add($sidebarSep)
$script:sidebar.Controls.Add($script:sidebarFooter)

# ─── PANEL PRINCIPAL ────────────────────────────────────────
$script:mainPanel = New-Object System.Windows.Forms.Panel
$script:mainPanel.BackColor = $script:clrBackground
$script:mainPanel.Dock      = [System.Windows.Forms.DockStyle]::Fill
$script:mainPanel.Padding   = New-Object System.Windows.Forms.Padding(20, 16, 20, 16)

# Header dinámico (título + subtítulo)
$script:headerPanel = New-Object System.Windows.Forms.Panel
$script:headerPanel.Dock      = [System.Windows.Forms.DockStyle]::Top
$script:headerPanel.Height    = $script:headerHeight
$script:headerPanel.BackColor = $script:clrBackground

$script:headerTitle = New-Object System.Windows.Forms.Label
$script:headerTitle.Text      = "Instalacion de Software"
$script:headerTitle.Font      = $script:fontTitle
$script:headerTitle.ForeColor = $script:clrTextPrimary
$script:headerTitle.AutoSize  = $true
$script:headerTitle.Location  = New-Object System.Drawing.Point(0, 8)

$script:headerSub = New-Object System.Windows.Forms.Label
$script:headerSub.Text      = "Gestion de aplicaciones via Winget"
$script:headerSub.Font      = $script:fontSubtitle
$script:headerSub.ForeColor = $script:clrTextMuted
$script:headerSub.AutoSize  = $true
$script:headerSub.Location  = New-Object System.Drawing.Point(0, 34)

$script:headerPanel.Controls.Add($script:headerTitle)
$script:headerPanel.Controls.Add($script:headerSub)

# Línea separadora bajo el header
$script:headerLine = New-Object System.Windows.Forms.Panel
$script:headerLine.Dock      = [System.Windows.Forms.DockStyle]::Top
$script:headerLine.Height    = 1
$script:headerLine.BackColor = $script:clrBorder

# ─── BARRA DE ESTADO GLOBAL ─────────────────────────────────
$script:statusBar = New-Object System.Windows.Forms.Panel
$script:statusBar.Dock      = [System.Windows.Forms.DockStyle]::Bottom
$script:statusBar.Height    = 28
$script:statusBar.BackColor = [System.Drawing.Color]::FromArgb(238, 241, 247)

$script:statusLabel = New-Object System.Windows.Forms.Label
$script:statusLabel.Text      = "Listo"
$script:statusLabel.ForeColor = $script:clrTextMuted
$script:statusLabel.Font      = $script:fontSmall
$script:statusLabel.AutoSize  = $true
$script:statusLabel.Location  = New-Object System.Drawing.Point(10, 6)

$script:statusBar.Controls.Add($script:statusLabel)

# ─── CONTENEDOR DE PÁGINAS ──────────────────────────────────
$script:pageContainer = New-Object System.Windows.Forms.Panel
$script:pageContainer.Dock      = [System.Windows.Forms.DockStyle]::Fill
$script:pageContainer.BackColor = $script:clrBackground

# Diccionarios de páginas y títulos de header (los módulos los rellenan)
$script:pages        = @{}
$script:headerTitles = @{
    "Software"   = @{ Title = "Instalacion de Software";    Sub = "Gestion de aplicaciones via Winget" }
    "Sistema"    = @{ Title = "Herramientas del Sistema";   Sub = "Mantenimiento y configuracion de Windows" }
    "Red"        = @{ Title = "Diagnostico de Red";         Sub = "Conectividad, IP y DNS" }
    "Inventario" = @{ Title = "Inventario y Entregas";      Sub = "Registro de equipos entregados a usuarios" }
}

# ─── FUNCIÓN DE NAVEGACIÓN ──────────────────────────────────
function Switch-Page {
    param([string]$PageName)
    $script:currentPage = $PageName

    foreach ($p in $script:pages.Keys) {
        $script:pages[$p].Visible = ($p -eq $PageName)
    }

    if ($script:headerTitles.ContainsKey($PageName)) {
        $script:headerTitle.Text = $script:headerTitles[$PageName].Title
        $script:headerSub.Text   = $script:headerTitles[$PageName].Sub
    }

    foreach ($k in $script:navButtons.Keys) {
        if ($k -eq $PageName) {
            $script:navButtons[$k].BackColor = [System.Drawing.Color]::FromArgb(40, 45, 65)
            $script:navButtons[$k].ForeColor = [System.Drawing.Color]::White
            $script:navButtons[$k].Font      = $script:fontSidebarBold
        } else {
            $script:navButtons[$k].BackColor = $script:clrSidebar
            $script:navButtons[$k].ForeColor = $script:clrSidebarText
            $script:navButtons[$k].Font      = $script:fontSidebar
        }
    }
}

# ─── FUNCIÓN PRINCIPAL: ensambla y lanza la app ─────────────
function Start-TITool {

    # Asignar eventos de navegación del sidebar
    foreach ($k in $script:navButtons.Keys) {
        $script:navButtons[$k].Add_Click({ Switch-Page -PageName $this.Tag }.GetNewClosure())
    }

    # Añadir todas las páginas registradas al contenedor
    foreach ($p in $script:pages.Values) {
        $script:pageContainer.Controls.Add($p)
    }

    # Armar jerarquía del panel principal
    $script:mainPanel.Controls.Add($script:pageContainer)
    $script:mainPanel.Controls.Add($script:headerLine)
    $script:mainPanel.Controls.Add($script:headerPanel)

    # Armar el formulario
    $script:form.Controls.Add($script:mainPanel)
    $script:form.Controls.Add($script:statusBar)
    $script:form.Controls.Add($script:sidebar)

    # Resize responsivo global
    $script:form.Add_Resize({
        $script:sidebarFooter.Width = $script:sidebarWidth
        # Los módulos con scroll se ajustan solos via sus propios Add_Resize
    })

    # Activar página inicial
    Switch-Page -PageName "Software"

    [void]$script:form.ShowDialog()
    $script:form.Dispose()
}
