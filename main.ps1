# ============================================================
#  TI Tool - Mesa de Soporte v1.0
#  Entry point — ejecutar con:
#  irm https://raw.githubusercontent.com/practica-2026/simple-ti-tool/main/main.ps1 | iex
# ============================================================

$base = "https://raw.githubusercontent.com/practica-2026/simple-ti-tool/main"

Write-Host "Cargando TI Tool..." -ForegroundColor Cyan

# 1. Núcleo: variables de UI y helpers compartidos
Invoke-Expression (Invoke-RestMethod "$base/core/ui.ps1")

# 2. Layout: formulario, sidebar, header, statusbar
Invoke-Expression (Invoke-RestMethod "$base/core/layout.ps1")

# 3. Módulos de cada sección
Invoke-Expression (Invoke-RestMethod "$base/modules/software.ps1")
Invoke-Expression (Invoke-RestMethod "$base/modules/sistema.ps1")
Invoke-Expression (Invoke-RestMethod "$base/modules/red.ps1")
Invoke-Expression (Invoke-RestMethod "$base/modules/inventario.ps1")

# 4. Iniciar la aplicación (ensambla todo y muestra la ventana)
Start-TITool
