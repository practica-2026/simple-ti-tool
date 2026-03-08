# ============================================================
#  modules/inventario.ps1
#  Página: Inventario y Entregas
#  Formulario de registro de equipos entregados a usuarios,
#  con tabla de historial en sesion.
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ─── PANEL DE LA PÁGINA ─────────────────────────────────────
$pageInventario = New-Object System.Windows.Forms.Panel
$pageInventario.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageInventario.BackColor = $script:clrBackground
$pageInventario.Visible   = $false

# ─── TARJETA DE FORMULARIO ──────────────────────────────────
$invCard = New-Object System.Windows.Forms.Panel
$invCard.BackColor = $script:clrCard
$invCard.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                     [System.Windows.Forms.AnchorStyles]::Left -bor
                     [System.Windows.Forms.AnchorStyles]::Right
$invCard.Size      = New-Object System.Drawing.Size(1, 230)
$invCard.Location  = New-Object System.Drawing.Point(0, 0)

# Borde decorativo izquierdo de la tarjeta
$invStripe = New-Object System.Windows.Forms.Panel
$invStripe.BackColor = $script:clrAccent
$invStripe.Size      = New-Object System.Drawing.Size(4, 230)
$invStripe.Location  = New-Object System.Drawing.Point(0, 0)
$invStripe.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                       [System.Windows.Forms.AnchorStyles]::Left -bor
                       [System.Windows.Forms.AnchorStyles]::Bottom

# Título interno de la tarjeta
$invCardTitle = New-Object System.Windows.Forms.Label
$invCardTitle.Text      = "Registrar nueva entrega"
$invCardTitle.Font      = $script:fontButton
$invCardTitle.ForeColor = $script:clrTextPrimary
$invCardTitle.AutoSize  = $true
$invCardTitle.Location  = New-Object System.Drawing.Point(16, 12)

$invCard.Controls.Add($invStripe)
$invCard.Controls.Add($invCardTitle)

# Helper local para crear campo label + textbox dentro de la tarjeta
function New-FormField {
    param(
        [string]$LabelText,
        [int]$Y,
        [System.Windows.Forms.Panel]$Parent
    )
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $LabelText
    $lbl.Font      = $script:fontSmall
    $lbl.ForeColor = $script:clrTextMuted
    $lbl.AutoSize  = $true
    $lbl.Location  = New-Object System.Drawing.Point(16, $Y)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Font        = $script:fontLabel
    $txt.ForeColor   = $script:clrTextPrimary
    $txt.BackColor   = $script:clrBackground
    $txt.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $txt.Size        = New-Object System.Drawing.Size(1, 24)
    $txtY = $Y + 16
    $txt.Location    = New-Object System.Drawing.Point(16, $txtY)
    $txt.Anchor      = [System.Windows.Forms.AnchorStyles]::Top -bor
                       [System.Windows.Forms.AnchorStyles]::Left -bor
                       [System.Windows.Forms.AnchorStyles]::Right

    $Parent.Controls.Add($lbl)
    $Parent.Controls.Add($txt)
    return $txt
}

# Campos del formulario (Y relativo a la tarjeta)
$txtUsuario = New-FormField -LabelText "Usuario / Destinatario" -Y 40  -Parent $invCard
$txtEquipo  = New-FormField -LabelText "Equipo / Activo"        -Y 94  -Parent $invCard
$txtSerial  = New-FormField -LabelText "Numero de Serie"        -Y 148 -Parent $invCard

# Botón guardar
$btnGuardar = New-RoundedButton `
    -Text     "Registrar entrega" `
    -Location (New-Object System.Drawing.Point(16, 190)) `
    -Size     (New-Object System.Drawing.Size(150, 32)) `
    -BgColor  $script:clrAccent
$btnGuardar.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor
                     [System.Windows.Forms.AnchorStyles]::Left

$invCard.Controls.Add($btnGuardar)

# Ajuste de ancho de TextBoxes al redimensionar la tarjeta
$invCard.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.TextBox]) {
            $ctrl.Width = $this.Width - 32
        }
    }
})

# ─── TABLA DE ENTREGAS ──────────────────────────────────────
$listView = New-Object System.Windows.Forms.ListView
$listView.View          = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.GridLines     = $true
$listView.BackColor     = $script:clrCard
$listView.ForeColor     = $script:clrTextPrimary
$listView.Font          = $script:fontLabel
$listView.BorderStyle   = [System.Windows.Forms.BorderStyle]::None
$listView.Anchor        = [System.Windows.Forms.AnchorStyles]::Top -bor
                          [System.Windows.Forms.AnchorStyles]::Left -bor
                          [System.Windows.Forms.AnchorStyles]::Right -bor
                          [System.Windows.Forms.AnchorStyles]::Bottom
$listView.Location      = New-Object System.Drawing.Point(0, 238)

[void]$listView.Columns.Add("Fecha / Hora", 130)
[void]$listView.Columns.Add("Usuario",      165)
[void]$listView.Columns.Add("Equipo",       165)
[void]$listView.Columns.Add("Serial",       140)

# ─── EVENTO: REGISTRAR ENTREGA ──────────────────────────────
$btnGuardar.Add_Click({
    if ($txtUsuario.Text.Trim() -eq "" -or $txtEquipo.Text.Trim() -eq "") {
        [System.Windows.Forms.MessageBox]::Show(
            "Por favor completa al menos los campos Usuario y Equipo.",
            "Campos requeridos",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    $item = New-Object System.Windows.Forms.ListViewItem((Get-Date -Format "yyyy-MM-dd HH:mm"))
    [void]$item.SubItems.Add($txtUsuario.Text.Trim())
    [void]$item.SubItems.Add($txtEquipo.Text.Trim())
    [void]$item.SubItems.Add($txtSerial.Text.Trim())
    [void]$listView.Items.Add($item)

    $txtUsuario.Clear()
    $txtEquipo.Clear()
    $txtSerial.Clear()
    $txtUsuario.Focus()

    $script:statusLabel.Text      = "Entrega registrada correctamente"
    $script:statusLabel.ForeColor = $script:clrSuccess
})

# ─── RESIZE RESPONSIVO ──────────────────────────────────────
$pageInventario.Add_Resize({
    $invCard.Width  = $this.Width
    $listView.Width = $this.Width
    $listView.Height = $this.Height - 238
})

# ─── ENSAMBLAR ──────────────────────────────────────────────
$pageInventario.Controls.Add($invCard)
$pageInventario.Controls.Add($listView)

# Registrar en el layout
$script:pages["Inventario"] = $pageInventario
