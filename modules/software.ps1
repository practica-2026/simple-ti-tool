# ============================================================
#  modules/software.ps1
#  Página: Instalacion de Software
#  Muestra tarjetas de apps instalables vía winget.
#  Dependencias: core/ui.ps1, core/layout.ps1
# ============================================================

# ─── PANEL DE LA PÁGINA ─────────────────────────────────────
$pageSoftware = New-Object System.Windows.Forms.Panel
$pageSoftware.Dock      = [System.Windows.Forms.DockStyle]::Fill
$pageSoftware.BackColor = $script:clrBackground
$pageSoftware.Visible   = $false

# Panel con scroll vertical
$scrollSoftware = New-ScrollPanel

# ─── LISTA DE APLICACIONES ──────────────────────────────────
$apps = @(
    @{ Name = "Google Chrome";        Desc = "Navegador web de Google";               Id = "Google.Chrome" }
    @{ Name = "Mozilla Firefox";      Desc = "Navegador web de Mozilla";              Id = "Mozilla.Firefox" }
    @{ Name = "Visual Studio Code";   Desc = "Editor de codigo de Microsoft";         Id = "Microsoft.VisualStudioCode" }
    @{ Name = "Notepad++";            Desc = "Editor de texto avanzado";              Id = "Notepad++.Notepad++" }
    @{ Name = "7-Zip";                Desc = "Compresor y descompresor de archivos";  Id = "7zip.7zip" }
    @{ Name = "VLC Media Player";     Desc = "Reproductor multimedia universal";      Id = "VideoLAN.VLC" }
    @{ Name = "Adobe Acrobat Reader"; Desc = "Lector de documentos PDF";              Id = "Adobe.Acrobat.Reader.64-bit" }
    @{ Name = "TeamViewer";           Desc = "Acceso y soporte remoto";               Id = "TeamViewer.TeamViewer" }
    @{ Name = "AnyDesk";              Desc = "Escritorio remoto rapido y seguro";     Id = "AnyDesk.AnyDesk" }
    @{ Name = "WinRAR";               Desc = "Compresor de archivos RAR y ZIP";       Id = "RARLab.WinRAR" }
)

$yOffset = 0
$cardGap  = 8

foreach ($app in $apps) {
    # Capturar valores en variables locales para el closure
    $appId   = $app.Id
    $appName = $app.Name

    $card = New-ActionCard `
        -Title       $appName `
        -Desc        $app.Desc `
        -Y           $yOffset `
        -AccentColor $script:clrAccent `
        -ButtonText  "Instalar" `
        -ButtonTag   $appId `
        -OnClick     {
            $id   = $this.Tag
            $name = $this.Parent.Controls |
                    Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Font.Bold } |
                    Select-Object -First 1
            Invoke-WinGet -PackageId $id -PackageName ($name.Text) -StatusLabel $script:statusLabel
        }.GetNewClosure()

    $card.Width = $scrollSoftware.Width - 20
    $scrollSoftware.Controls.Add($card)
    $yOffset += 56 + $cardGap
}

# ─── ENSAMBLAR ──────────────────────────────────────────────
$pageSoftware.Controls.Add($scrollSoftware)

# Registrar en el layout
$script:pages["Software"] = $pageSoftware
