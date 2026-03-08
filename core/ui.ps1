# ============================================================
#  core/ui.ps1
#  Paleta de colores, fuentes, dimensiones y funciones helper
#  compartidas por todos los módulos.
#  Dependencias: ninguna (primer archivo en cargarse)
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# ─── PALETA DE COLORES ──────────────────────────────────────
$script:clrBackground    = [System.Drawing.Color]::FromArgb(245, 246, 250)
$script:clrSidebar       = [System.Drawing.Color]::FromArgb(30,  33,  48)
$script:clrCard          = [System.Drawing.Color]::FromArgb(255, 255, 255)
$script:clrAccent        = [System.Drawing.Color]::FromArgb(99,  102, 241)
$script:clrAccentHover   = [System.Drawing.Color]::FromArgb(79,  70,  229)
$script:clrSuccess       = [System.Drawing.Color]::FromArgb(34,  197, 94)
$script:clrWarning       = [System.Drawing.Color]::FromArgb(234, 179, 8)
$script:clrDanger        = [System.Drawing.Color]::FromArgb(239, 68,  68)
$script:clrTextPrimary   = [System.Drawing.Color]::FromArgb(15,  23,  42)
$script:clrTextMuted     = [System.Drawing.Color]::FromArgb(100, 116, 139)
$script:clrBorder        = [System.Drawing.Color]::FromArgb(226, 232, 240)
$script:clrSidebarText   = [System.Drawing.Color]::FromArgb(203, 213, 225)
$script:clrSidebarActive = [System.Drawing.Color]::FromArgb(99,  102, 241)

# ─── FUENTES ────────────────────────────────────────────────
$script:fontTitle       = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$script:fontSubtitle    = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Regular)
$script:fontButton      = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$script:fontLabel       = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)
$script:fontSidebar     = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Regular)
$script:fontSidebarBold = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Bold)
$script:fontSmall       = New-Object System.Drawing.Font("Segoe UI", 7,  [System.Drawing.FontStyle]::Regular)

# ─── DIMENSIONES BASE ───────────────────────────────────────
$script:sidebarWidth  = 180
$script:headerHeight  = 60
$script:minWidth      = 680
$script:minHeight     = 480
$script:defaultWidth  = 820
$script:defaultHeight = 580

# ============================================================
#  HELPERS COMPARTIDOS
# ============================================================

# Crea un botón plano con colores hover/click automáticos
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
    $btn.FlatAppearance.BorderSize = 0
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
    $btn.Font       = $script:fontButton
    $btn.Cursor     = [System.Windows.Forms.Cursors]::Hand
    $btn.Tag        = $Tag
    $btn.UseVisualStyleBackColor = $false
    return $btn
}

# Instala un paquete usando winget y actualiza la barra de estado
function Invoke-WinGet {
    param(
        [string]$PackageId,
        [string]$PackageName,
        [System.Windows.Forms.Label]$StatusLabel
    )
    $StatusLabel.Text      = "Instalando $PackageName..."
    $StatusLabel.ForeColor = $script:clrWarning
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $proc = Start-Process -FilePath "winget" `
            -ArgumentList "install --id $PackageId -e --accept-source-agreements --accept-package-agreements" `
            -Wait -PassThru -WindowStyle Hidden
        if ($proc.ExitCode -eq 0) {
            $StatusLabel.Text      = "OK $PackageName instalado correctamente"
            $StatusLabel.ForeColor = $script:clrSuccess
        } else {
            $StatusLabel.Text      = "Error al instalar $PackageName (codigo $($proc.ExitCode))"
            $StatusLabel.ForeColor = $script:clrDanger
        }
    } catch {
        $StatusLabel.Text      = "Error: $_"
        $StatusLabel.ForeColor = $script:clrDanger
    }
}

# Crea una tarjeta (Panel) con borde de color, título, descripción y botón
# Usada tanto por Software como por Sistema y Red
function New-ActionCard {
    param(
        [string]$Title,
        [string]$Desc,
        [int]$Y,
        [System.Drawing.Color]$AccentColor,
        [string]$ButtonText   = "Ejecutar",
        [string]$ButtonTag    = "",
        [scriptblock]$OnClick = {}
    )

    $card = New-Object System.Windows.Forms.Panel
    $card.BackColor = $script:clrCard
    $card.Size      = New-Object System.Drawing.Size(1, 56)
    $card.Location  = New-Object System.Drawing.Point(0, $Y)
    $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                      [System.Windows.Forms.AnchorStyles]::Left -bor
                      [System.Windows.Forms.AnchorStyles]::Right

    # Borde izquierdo decorativo
    $stripe = New-Object System.Windows.Forms.Panel
    $stripe.BackColor = $AccentColor
    $stripe.Size      = New-Object System.Drawing.Size(4, 56)
    $stripe.Location  = New-Object System.Drawing.Point(0, 0)
    $stripe.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                        [System.Windows.Forms.AnchorStyles]::Left -bor
                        [System.Windows.Forms.AnchorStyles]::Bottom

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text      = $Title
    $lblTitle.Font      = $script:fontButton
    $lblTitle.ForeColor = $script:clrTextPrimary
    $lblTitle.AutoSize  = $true
    $lblTitle.Location  = New-Object System.Drawing.Point(16, 10)

    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text      = $Desc
    $lblDesc.Font      = $script:fontSmall
    $lblDesc.ForeColor = $script:clrTextMuted
    $lblDesc.AutoSize  = $true
    $lblDesc.Location  = New-Object System.Drawing.Point(16, 30)

    $btn = New-RoundedButton -Text $ButtonText `
        -Location (New-Object System.Drawing.Point(0, 12)) `
        -Size (New-Object System.Drawing.Size(80, 30)) `
        -BgColor $AccentColor
    $btn.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor
                  [System.Windows.Forms.AnchorStyles]::Right
    $btn.Tag    = $ButtonTag
    $btn.Add_Click($OnClick)

    # Reposicionar botón al redimensionar la tarjeta
    $card.Add_Resize({
        $b = $this.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] }
        if ($b) { $b.Location = New-Object System.Drawing.Point(($this.Width - 94), 12) }
    })

    $card.Controls.AddRange(@($stripe, $lblTitle, $lblDesc, $btn))
    return $card
}

# Crea un panel con scroll vertical y ajusta anchos de hijos al resize
function New-ScrollPanel {
    $pnl = New-Object System.Windows.Forms.Panel
    $pnl.Dock       = [System.Windows.Forms.DockStyle]::Fill
    $pnl.AutoScroll = $true
    $pnl.BackColor  = $script:clrBackground
    $pnl.Padding    = New-Object System.Windows.Forms.Padding(0, 8, 0, 8)
    $pnl.Add_Resize({
        foreach ($ctrl in $this.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) {
                $ctrl.Width = $this.Width - 20
            }
        }
    })
    return $pnl
}
