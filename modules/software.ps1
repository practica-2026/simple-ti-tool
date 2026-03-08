# ============================================================
#  modules/software.ps1
#  Página: Instalacion de Software
#  Seleccion multiple con checkboxes + instalacion masiva via winget.
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ─── CATÁLOGO DE APLICACIONES POR CATEGORÍA ─────────────────
$script:swCatalog = @(
    @{ Cat = "Navegadores";    Name = "Google Chrome";          Desc = "Navegador web de Google";                 Id = "Google.Chrome" }
    @{ Cat = "Navegadores";    Name = "Mozilla Firefox";        Desc = "Navegador web de Mozilla";                Id = "Mozilla.Firefox" }
    @{ Cat = "Navegadores";    Name = "Brave Browser";          Desc = "Navegador con bloqueador integrado";       Id = "Brave.Brave" }
    @{ Cat = "Desarrollo";     Name = "Visual Studio Code";     Desc = "Editor de codigo de Microsoft";           Id = "Microsoft.VisualStudioCode" }
    @{ Cat = "Desarrollo";     Name = "Notepad++";              Desc = "Editor de texto avanzado";                Id = "Notepad++.Notepad++" }
    @{ Cat = "Desarrollo";     Name = "Git";                    Desc = "Control de versiones distribuido";        Id = "Git.Git" }
    @{ Cat = "Desarrollo";     Name = "Python 3";               Desc = "Lenguaje de programacion Python";         Id = "Python.Python.3" }
    @{ Cat = "Utilidades";     Name = "7-Zip";                  Desc = "Compresor y descompresor de archivos";    Id = "7zip.7zip" }
    @{ Cat = "Utilidades";     Name = "WinRAR";                 Desc = "Compresor de archivos RAR y ZIP";         Id = "RARLab.WinRAR" }
    @{ Cat = "Utilidades";     Name = "Adobe Acrobat Reader";   Desc = "Lector de documentos PDF";                Id = "Adobe.Acrobat.Reader.64-bit" }
    @{ Cat = "Utilidades";     Name = "VLC Media Player";       Desc = "Reproductor multimedia universal";        Id = "VideoLAN.VLC" }
    @{ Cat = "Soporte remoto"; Name = "TeamViewer";             Desc = "Acceso y soporte remoto";                 Id = "TeamViewer.TeamViewer" }
    @{ Cat = "Soporte remoto"; Name = "AnyDesk";                Desc = "Escritorio remoto rapido y seguro";       Id = "AnyDesk.AnyDesk" }
    @{ Cat = "Soporte remoto"; Name = "Remote Desktop Client";  Desc = "Escritorio remoto nativo de Microsoft";   Id = "Microsoft.RemoteDesktopClient" }
    @{ Cat = "Comunicacion";   Name = "Zoom";                   Desc = "Videoconferencias y reuniones";           Id = "Zoom.Zoom" }
    @{ Cat = "Comunicacion";   Name = "Microsoft Teams";        Desc = "Plataforma de colaboracion Microsoft";    Id = "Microsoft.Teams" }
    @{ Cat = "Comunicacion";   Name = "Slack";                  Desc = "Mensajeria para equipos de trabajo";      Id = "SlackTechnologies.Slack" }
)

# ─── COLORES POR CATEGORÍA ───────────────────────────────────
$script:catColors = @{
    "Navegadores"    = [System.Drawing.Color]::FromArgb(99,  102, 241)
    "Desarrollo"     = [System.Drawing.Color]::FromArgb(20,  184, 166)
    "Utilidades"     = [System.Drawing.Color]::FromArgb(234, 179, 8)
    "Soporte remoto" = [System.Drawing.Color]::FromArgb(239, 68,  68)
    "Comunicacion"   = [System.Drawing.Color]::FromArgb(34,  197, 94)
}

# Lista global de entradas { Chk, Id, Name, StatusLabel }
$script:swCheckboxes = @()

# ============================================================
#  LAYOUT
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
$chkAll.Text      = "Seleccionar todo"
$chkAll.Font      = $script:fontLabel
$chkAll.ForeColor = $script:clrTextPrimary
$chkAll.AutoSize  = $true
$chkAll.Location  = New-Object System.Drawing.Point(12, 13)
$chkAll.Cursor    = [System.Windows.Forms.Cursors]::Hand
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

# Línea separadora bajo toolbar
$swToolbarLine = New-Object System.Windows.Forms.Panel
$swToolbarLine.Dock      = [System.Windows.Forms.DockStyle]::Top
$swToolbarLine.Height    = 1
$swToolbarLine.BackColor = $script:clrBorder

# ─── SCROLL PANEL ───────────────────────────────────────────
$scrollSoftware = New-Object System.Windows.Forms.Panel
$scrollSoftware.Dock       = [System.Windows.Forms.DockStyle]::Fill
$scrollSoftware.AutoScroll = $true
$scrollSoftware.BackColor  = $script:clrBackground
$scrollSoftware.Padding    = New-Object System.Windows.Forms.Padding(0, 8, 0, 16)

$scrollSoftware.Add_Resize({
    foreach ($ctrl in $this.Controls) {
        if ($ctrl -is [System.Windows.Forms.Panel]) {
            $ctrl.Width = $this.Width - 20
        }
    }
})

# ============================================================
#  FUNCIÓN: actualizar contador y estado del botón instalar
# ============================================================
function Update-SwSelection {
    $count = ($script:swCheckboxes | Where-Object { $_.Chk.Checked }).Count
    $total = $script:swCheckboxes.Count

    if ($count -eq 1) { $lblCount.Text = "1 seleccionado" }
    else              { $lblCount.Text = "$count seleccionados" }
    $lblCount.ForeColor    = if ($count -gt 0) { $script:clrAccent } else { $script:clrTextMuted }
    $btnInstallAll.Enabled = ($count -gt 0)

    # Sincronizar chkAll sin re-disparar el evento
    $chkAll.remove_CheckedChanged($script:chkAllHandler)
    if ($count -eq 0)         { $chkAll.CheckState = [System.Windows.Forms.CheckState]::Unchecked }
    elseif ($count -eq $total){ $chkAll.CheckState = [System.Windows.Forms.CheckState]::Checked }
    else                      { $chkAll.CheckState = [System.Windows.Forms.CheckState]::Indeterminate }
    $chkAll.add_CheckedChanged($script:chkAllHandler)
}

# ============================================================
#  CONSTRUIR CARDS POR CATEGORÍA
# ============================================================
$yOffset    = 0
$cardHeight = 48
$cardGap    = 6
$catGap     = 18
$catHeaderH = 26

$categories = $script:swCatalog | ForEach-Object { $_.Cat } | Select-Object -Unique

foreach ($cat in $categories) {
    $catColor = $script:catColors[$cat]

    # Encabezado de categoría
    $catHeader = New-Object System.Windows.Forms.Panel
    $catHeader.BackColor = $script:clrBackground
    $catHeader.Size      = New-Object System.Drawing.Size(1, $catHeaderH)
    $catHeader.Location  = New-Object System.Drawing.Point(0, $yOffset)
    $catHeader.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                           [System.Windows.Forms.AnchorStyles]::Left -bor
                           [System.Windows.Forms.AnchorStyles]::Right

    $catBadge = New-Object System.Windows.Forms.Label
    $catBadge.Text      = "  $cat  "
    $catBadge.Font      = $script:fontSidebarBold
    $catBadge.ForeColor = [System.Drawing.Color]::White
    $catBadge.BackColor = $catColor
    $catBadge.AutoSize  = $true
    $catBadge.Location  = New-Object System.Drawing.Point(2, 3)

    $catHeader.Controls.Add($catBadge)
    $scrollSoftware.Controls.Add($catHeader)
    $yOffset += $catHeaderH + 4

    # Cards de cada app
    $appsInCat = $script:swCatalog | Where-Object { $_.Cat -eq $cat }

    foreach ($app in $appsInCat) {
        $appId   = $app.Id
        $appName = $app.Name
        $appDesc = $app.Desc

        $card = New-Object System.Windows.Forms.Panel
        $card.BackColor = $script:clrCard
        $card.Size      = New-Object System.Drawing.Size(1, $cardHeight)
        $card.Location  = New-Object System.Drawing.Point(0, $yOffset)
        $card.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor
                          [System.Windows.Forms.AnchorStyles]::Left -bor
                          [System.Windows.Forms.AnchorStyles]::Right

        $stripe = New-Object System.Windows.Forms.Panel
        $stripe.BackColor = $catColor
        $stripe.Size      = New-Object System.Drawing.Size(3, $cardHeight)
        $stripe.Location  = New-Object System.Drawing.Point(0, 0)

        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Size     = New-Object System.Drawing.Size(18, 18)
        $chk.Location = New-Object System.Drawing.Point(14, 15)
        $chk.Cursor   = [System.Windows.Forms.Cursors]::Hand
        $chk.Tag      = $appId

        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text      = $appName
        $lblName.Font      = $script:fontButton
        $lblName.ForeColor = $script:clrTextPrimary
        $lblName.AutoSize  = $true
        $lblName.Location  = New-Object System.Drawing.Point(40, 8)
        $lblName.Cursor    = [System.Windows.Forms.Cursors]::Hand

        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text      = $appDesc
        $lblDesc.Font      = $script:fontSmall
        $lblDesc.ForeColor = $script:clrTextMuted
        $lblDesc.AutoSize  = $true
        $lblDesc.Location  = New-Object System.Drawing.Point(40, 28)

        $lblId = New-Object System.Windows.Forms.Label
        $lblId.Text      = $appId
        $lblId.Font      = New-Object System.Drawing.Font("Consolas", 7)
        $lblId.ForeColor = [System.Drawing.Color]::FromArgb(180, 190, 210)
        $lblId.AutoSize  = $true
        $lblId.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
        $lblId.Location  = New-Object System.Drawing.Point(0, 10)

        $lblStatus = New-Object System.Windows.Forms.Label
        $lblStatus.Text      = ""
        $lblStatus.Font      = $script:fontSmall
        $lblStatus.ForeColor = $script:clrSuccess
        $lblStatus.AutoSize  = $true
        $lblStatus.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
        $lblStatus.Location  = New-Object System.Drawing.Point(0, 30)

        # Clic en nombre o en card también activa la checkbox
        $chkRef = $chk
        $cardRef = $card
        $lblName.Add_Click({ $chkRef.Checked = -not $chkRef.Checked }.GetNewClosure())
        $card.Add_Click({
            # Solo si el clic no fue sobre un control hijo clickeable
            $chkRef.Checked = -not $chkRef.Checked
        }.GetNewClosure())

        # Resaltar card al marcar
        $chk.Add_CheckedChanged({
            if ($this.Checked) {
                $this.Parent.BackColor = [System.Drawing.Color]::FromArgb(238, 239, 253)
            } else {
                $this.Parent.BackColor = $script:clrCard
            }
            Update-SwSelection
        }.GetNewClosure())

        # Reposicionar etiquetas ancladas a la derecha
        $card.Add_Resize({
            $rightEdge = $this.Width - 12
            foreach ($ctrl in $this.Controls) {
                if ($ctrl -is [System.Windows.Forms.Label] -and
                    (($ctrl.Anchor -band [System.Windows.Forms.AnchorStyles]::Right) -eq [System.Windows.Forms.AnchorStyles]::Right)) {
                    $ctrl.Location = New-Object System.Drawing.Point(($rightEdge - $ctrl.Width), $ctrl.Location.Y)
                }
            }
        })

        $card.Controls.AddRange(@($stripe, $chk, $lblName, $lblDesc, $lblId, $lblStatus))
        $scrollSoftware.Controls.Add($card)

        $script:swCheckboxes += @{ Chk = $chk; Id = $appId; Name = $appName; StatusLabel = $lblStatus }
        $yOffset += $cardHeight + $cardGap
    }

    $yOffset += $catGap
}

# ============================================================
#  EVENTO: SELECCIONAR TODO / NINGUNO
# ============================================================
$script:chkAllHandler = {
    # Ignorar si el estado es Indeterminate (fue puesto por Update-SwSelection)
    if ($chkAll.CheckState -eq [System.Windows.Forms.CheckState]::Indeterminate) { return }
    $target = ($chkAll.CheckState -eq [System.Windows.Forms.CheckState]::Checked)
    foreach ($entry in $script:swCheckboxes) {
        $entry.Chk.Checked = $target
    }
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
        "Se instalaran $total aplicacion(es) via winget:`n`n$appList`n`n continuar?",
        "Confirmar instalacion masiva",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($confirm -ne "Yes") { return }

    # Deshabilitar controles durante la instalación
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
                0            { $sl.Text = "OK Instalado";   $sl.ForeColor = $script:clrSuccess }
                -1978335189  { $sl.Text = "Ya instalado";    $sl.ForeColor = $script:clrTextMuted }
                default      { $sl.Text = "Error ($($proc.ExitCode))"; $sl.ForeColor = $script:clrDanger }
            }
        } catch {
            $sl.Text      = "Error: $_"
            $sl.ForeColor = $script:clrDanger
        }

        [System.Windows.Forms.Application]::DoEvents()
    }

    # Rehabilitar controles
    $btnInstallAll.Enabled = $true
    $chkAll.Enabled        = $true
    foreach ($entry in $script:swCheckboxes) { $entry.Chk.Enabled = $true }

    $script:statusLabel.Text      = "Listo - $total app(s) procesadas"
    $script:statusLabel.ForeColor = $script:clrSuccess
})

# ============================================================
#  ENSAMBLAR
# ============================================================
$pageSoftware.Controls.Add($scrollSoftware)
$pageSoftware.Controls.Add($swToolbarLine)
$pageSoftware.Controls.Add($swToolbar)

$script:pages["Software"] = $pageSoftware
