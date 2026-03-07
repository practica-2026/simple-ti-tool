Write-Host "Mi herramienta Windows"

Write-Host ""
Write-Host "1 - Instalar Chrome"
Write-Host "2 - Instalar VS Code"

$opcion = Read-Host "Selecciona una opción"

switch ($opcion) {
    "1" { winget install Google.Chrome }
    "2" { winget install Microsoft.VisualStudioCode }
}