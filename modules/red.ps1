# ============================================================
#  modules/red.ps1
#  Página: Diagnostico de Red
#  Herramientas de conectividad, IP y DNS con consola de output.
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ─── PANEL DE LA PÁGINA ─────────────────────────────────────
$pageRed = New-Object System.Windows.Forms.Panel
$pageRed.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageRed.BackColor = $script:clrBackground
$pageRed.Visible   = $false

# ─── CONSOLA DE OUTPUT (parte inferior) ─────────────────────
$netOutput = New-Object System.Windows.Forms.RichTextBox
$netOutput.Dock        = [System.Windows.Forms.DockStyle]::Bottom
$netOutput.Height      = 160
$netOutput.BackColor   = [System.Drawing.Color]::FromArgb(15, 23, 42)
$netOutput.ForeColor   = [System.Drawing.Color]::FromArgb(134, 239, 172)
$netOutput.Font        = New-Object System.Drawing.Font("Consolas", 8)
$netOutput.ReadOnly    = $true
$netOutput.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$netOutput.ScrollBars  = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$netOutput.Text        = "-- Resultados de red apareceran aqui --`r`n"

# ─── PANEL DE BOTONES CON SCROLL ────────────────────────────
$scrollRed = New-ScrollPanel

# ─── ACCIONES DE RED ────────────────────────────────────────
$netActions = @(
    @{
        Text   = "Ping a Gateway"
        Desc   = "Verifica conectividad con la puerta de enlace"
        Color  = $script:clrAccent
        Action = {
            $script:statusLabel.Text      = "Ejecutando ping..."
            $script:statusLabel.ForeColor = $script:clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            try {
                $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" |
                       Sort-Object RouteMetric |
                       Select-Object -First 1).NextHop
                if (-not $gw) { throw "No se encontro gateway" }
                $netOutput.AppendText(">> PING $gw`r`n")
                $result = ping $gw -n 4 2>&1
                $netOutput.AppendText(($result -join "`r`n") + "`r`n`r`n")
                $script:statusLabel.Text      = "Ping completado"
                $script:statusLabel.ForeColor = $script:clrSuccess
            } catch {
                $netOutput.AppendText("Error: $_`r`n`r`n")
                $script:statusLabel.Text      = "Error en ping"
                $script:statusLabel.ForeColor = $script:clrDanger
            }
        }
    }
    @{
        Text   = "IPConfig"
        Desc   = "Muestra la configuracion de red del equipo"
        Color  = $script:clrSuccess
        Action = {
            $script:statusLabel.Text      = "Obteniendo configuracion de red..."
            $script:statusLabel.ForeColor = $script:clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            $netOutput.AppendText(">> IPCONFIG /ALL`r`n")
            $result = ipconfig /all 2>&1
            $netOutput.AppendText(($result -join "`r`n") + "`r`n`r`n")
            $script:statusLabel.Text      = "IPConfig completado"
            $script:statusLabel.ForeColor = $script:clrSuccess
        }
    }
    @{
        Text   = "Liberar y renovar IP"
        Desc   = "Ejecuta ipconfig /release y luego /renew"
        Color  = $script:clrWarning
        Action = {
            $script:statusLabel.Text      = "Liberando IP..."
            $script:statusLabel.ForeColor = $script:clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            $netOutput.AppendText(">> Liberando IP...`r`n")
            ipconfig /release 2>&1 | Out-Null
            $netOutput.AppendText(">> Renovando IP...`r`n")
            [System.Windows.Forms.Application]::DoEvents()
            ipconfig /renew 2>&1 | Out-Null
            $netOutput.AppendText("IP renovada correctamente.`r`n`r`n")
            $script:statusLabel.Text      = "IP renovada"
            $script:statusLabel.ForeColor = $script:clrSuccess
        }
    }
    @{
        Text   = "Flush DNS"
        Desc   = "Limpia la cache de resolucion DNS"
        Color  = $script:clrAccent
        Action = {
            ipconfig /flushdns 2>&1 | Out-Null
            $netOutput.AppendText(">> Cache DNS limpiada.`r`n`r`n")
            $script:statusLabel.Text      = "Cache DNS limpiada"
            $script:statusLabel.ForeColor = $script:clrSuccess
        }
    }
    @{
        Text   = "Test de conectividad"
        Desc   = "Ping a 8.8.8.8 para verificar salida a internet"
        Color  = $script:clrSuccess
        Action = {
            $script:statusLabel.Text      = "Probando conectividad..."
            $script:statusLabel.ForeColor = $script:clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            $netOutput.AppendText(">> PING 8.8.8.8 (Google DNS)`r`n")
            $result = ping 8.8.8.8 -n 4 2>&1
            $netOutput.AppendText(($result -join "`r`n") + "`r`n`r`n")
            $script:statusLabel.Text      = "Test completado"
            $script:statusLabel.ForeColor = $script:clrSuccess
        }
    }
    @{
        Text   = "Limpiar consola"
        Desc   = "Borra el contenido del panel de resultados"
        Color  = $script:clrTextMuted
        Action = {
            $netOutput.Clear()
            $netOutput.Text = "-- Resultados de red apareceran aqui --`r`n"
            $script:statusLabel.Text      = "Consola limpiada"
            $script:statusLabel.ForeColor = $script:clrTextMuted
        }
    }
)

# Crear tarjetas
$yR = 0
foreach ($ra in $netActions) {
    $action = $ra.Action
    $card = New-ActionCard `
        -Title       $ra.Text `
        -Desc        $ra.Desc `
        -Y           $yR `
        -AccentColor $ra.Color `
        -ButtonText  "Ejecutar" `
        -OnClick     $action

    $card.Width = $scrollRed.Width - 20
    $scrollRed.Controls.Add($card)
    $yR += 56 + 8
}

# ─── ENSAMBLAR ──────────────────────────────────────────────
# Orden importante: primero netOutput (Bottom), luego scrollRed (Fill)
$pageRed.Controls.Add($netOutput)
$pageRed.Controls.Add($scrollRed)

# Registrar en el layout
$script:pages["Red"] = $pageRed
