# ============================================================
#  modules/sistema.ps1
#  Página: Herramientas del Sistema
#  Accesos directos a mantenimiento y configuracion de Windows.
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ─── PANEL DE LA PÁGINA ─────────────────────────────────────
$pageSistema = New-Object System.Windows.Forms.Panel
$pageSistema.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageSistema.BackColor = $script:clrBackground
$pageSistema.Visible   = $false

$scrollSistema = New-ScrollPanel

# ─── ACCIONES DEL SISTEMA ───────────────────────────────────
$sysActions = @(
    @{
        Text   = "Actualizaciones de Windows"
        Desc   = "Abre la configuracion de Windows Update"
        Color  = $script:clrAccent
        Action = {
            Start-Process "ms-settings:windowsupdate"
            $script:statusLabel.Text      = "Abriendo Windows Update..."
            $script:statusLabel.ForeColor = $script:clrAccent
        }
    }
    @{
        Text   = "Limpiar archivos temporales"
        Desc   = "Elimina archivos TEMP del usuario y del sistema"
        Color  = $script:clrSuccess
        Action = {
            $script:statusLabel.Text      = "Limpiando archivos temporales..."
            $script:statusLabel.ForeColor = $script:clrWarning
            [System.Windows.Forms.Application]::DoEvents()
            try {
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                $script:statusLabel.Text      = "Archivos temporales eliminados"
                $script:statusLabel.ForeColor = $script:clrSuccess
            } catch {
                $script:statusLabel.Text      = "Error: $_"
                $script:statusLabel.ForeColor = $script:clrDanger
            }
        }
    }
    @{
        Text   = "Administrador de tareas"
        Desc   = "Abre el Administrador de tareas de Windows"
        Color  = $script:clrWarning
        Action = {
            Start-Process "taskmgr.exe"
            $script:statusLabel.Text      = "Administrador de tareas abierto"
            $script:statusLabel.ForeColor = $script:clrTextMuted
        }
    }
    @{
        Text   = "Panel de control"
        Desc   = "Abre el Panel de control clasico"
        Color  = $script:clrAccent
        Action = {
            Start-Process "control.exe"
            $script:statusLabel.Text      = "Panel de control abierto"
            $script:statusLabel.ForeColor = $script:clrTextMuted
        }
    }
    @{
        Text   = "Informacion del sistema"
        Desc   = "Abre msinfo32 con datos del equipo"
        Color  = $script:clrTextMuted
        Action = {
            Start-Process "msinfo32.exe"
            $script:statusLabel.Text      = "Informacion del sistema abierta"
            $script:statusLabel.ForeColor = $script:clrTextMuted
        }
    }
    @{
        Text   = "Administrador de dispositivos"
        Desc   = "Gestiona drivers y hardware del equipo"
        Color  = $script:clrAccent
        Action = {
            Start-Process "devmgmt.msc"
            $script:statusLabel.Text      = "Administrador de dispositivos abierto"
            $script:statusLabel.ForeColor = $script:clrTextMuted
        }
    }
    @{
        Text   = "Reiniciar equipo"
        Desc   = "Reinicia Windows de forma inmediata"
        Color  = $script:clrDanger
        Action = {
            $confirm = [System.Windows.Forms.MessageBox]::Show(
                "Estas seguro de que deseas reiniciar el equipo?",
                "Confirmar reinicio",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            if ($confirm -eq "Yes") { Restart-Computer -Force }
        }
    }
)

# Crear tarjetas para cada acción
$yS = 0
foreach ($sa in $sysActions) {
    $action = $sa.Action   # capturar para el closure
    $card = New-ActionCard `
        -Title       $sa.Text `
        -Desc        $sa.Desc `
        -Y           $yS `
        -AccentColor $sa.Color `
        -ButtonText  "Ejecutar" `
        -OnClick     $action

    $card.Width = $scrollSistema.Width - 20
    $scrollSistema.Controls.Add($card)
    $yS += 56 + 8
}

# ─── ENSAMBLAR ──────────────────────────────────────────────
$pageSistema.Controls.Add($scrollSistema)

# Registrar en el layout
$script:pages["Sistema"] = $pageSistema
