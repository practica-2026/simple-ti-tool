Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Simple TI Tool"
$form.Size = New-Object System.Drawing.Size(400,300)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "Mi herramienta Windows"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(120,20)

$btnChrome = New-Object System.Windows.Forms.Button
$btnChrome.Text = "Instalar Chrome"
$btnChrome.Size = New-Object System.Drawing.Size(150,40)
$btnChrome.Location = New-Object System.Drawing.Point(120,80)

$btnVSCode = New-Object System.Windows.Forms.Button
$btnVSCode.Text = "Instalar VS Code"
$btnVSCode.Size = New-Object System.Drawing.Size(150,40)
$btnVSCode.Location = New-Object System.Drawing.Point(120,140)

$btnChrome.Add_Click({
    winget install Google.Chrome
})

$btnVSCode.Add_Click({
    winget install Microsoft.VisualStudioCode
})

$form.Controls.Add($label)
$form.Controls.Add($btnChrome)
$form.Controls.Add($btnVSCode)

$form.ShowDialog()
