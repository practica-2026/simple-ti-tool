# ============================================================
#  TI Tool - Mesa de Soporte v1.0
#  Entry point — ejecutar con:
#  irm https://raw.githubusercontent.com/practica-2026/simple-ti-tool/main/main.ps1 | iex
# ============================================================

$base = "https://raw.githubusercontent.com/practica-2026/simple-ti-tool/main"

# ============================================================
#  PASO 1: VERIFICAR ELEVACION DE PRIVILEGIOS
#  Si no es admin, descarga el launcher a disco y lo relanza
#  con Start-Process -Verb RunAs (UAC prompt)
# ============================================================

function Test-IsAdmin {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {

    Write-Host ""
    Write-Host "  TI Tool requiere permisos de administrador." -ForegroundColor Yellow
    Write-Host "  Se mostrara el dialogo de UAC para elevar privilegios..." -ForegroundColor Cyan
    Write-Host ""

    # Construir el script que se ejecutara elevado
    # Usa -EncodedCommand para evitar problemas con comillas y caracteres especiales
    $launchScript = @"
`$base = '$base'
Write-Host 'Cargando TI Tool (elevado)...' -ForegroundColor Cyan
Invoke-Expression (Invoke-RestMethod "`$base/core/ui.ps1")
Invoke-Expression (Invoke-RestMethod "`$base/core/layout.ps1")
Invoke-Expression (Invoke-RestMethod "`$base/modules/software.ps1")
Invoke-Expression (Invoke-RestMethod "`$base/modules/sistema.ps1")
Invoke-Expression (Invoke-RestMethod "`$base/modules/red.ps1")
Start-TITool
"@

    # Codificar en Base64 Unicode (formato que acepta -EncodedCommand)
    $bytes   = [System.Text.Encoding]::Unicode.GetBytes($launchScript)
    $encoded = [Convert]::ToBase64String($bytes)

    try {
        # Lanzar una nueva ventana de PowerShell elevada con el script codificado
        $proc = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded" `
            -Verb RunAs `
            -PassThru

        # Si el usuario acepto el UAC, la sesion actual puede cerrarse
        Write-Host "  TI Tool se esta iniciando en una ventana elevada." -ForegroundColor Green
        Write-Host "  Esta ventana se puede cerrar." -ForegroundColor DarkGray
        exit 0

    } catch {
        # El usuario cancelo el UAC
        Write-Host ""
        Write-Host "  Elevacion cancelada por el usuario." -ForegroundColor Red
        Write-Host "  Algunas funciones no estaran disponibles sin permisos de administrador." -ForegroundColor Yellow
        Write-Host ""

        # Preguntar si desea continuar sin elevacion
        $response = Read-Host "  Continuar de todas formas? (s/N)"
        if ($response -notmatch "^[sS]$") {
            Write-Host "  Saliendo..." -ForegroundColor DarkGray
            exit 1
        }

        Write-Host ""
        Write-Host "  Continuando sin privilegios elevados..." -ForegroundColor Yellow
        Write-Host "  Algunas funciones del modulo Sistema y Red pueden fallar." -ForegroundColor DarkGray
        Write-Host ""
    }
}

# ============================================================
#  PASO 2: YA ES ADMIN (o el usuario eligio continuar)
#  Cargar modulos y lanzar la aplicacion
# ============================================================

Write-Host ""
Write-Host "  Cargando TI Tool..." -ForegroundColor Cyan

# Verificar conectividad antes de descargar
try {
    $null = Invoke-RestMethod "https://raw.githubusercontent.com" -TimeoutSec 5 -ErrorAction Stop
} catch {
    Write-Host ""
    Write-Host "  ERROR: No se puede conectar a GitHub." -ForegroundColor Red
    Write-Host "  Verifica tu conexion a internet e intentalo de nuevo." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Presiona Enter para salir"
    exit 1
}

Write-Host "  [1/6] Cargando UI..." -ForegroundColor DarkCyan
Invoke-Expression (Invoke-RestMethod "$base/core/ui.ps1")

Write-Host "  [2/6] Cargando Layout..." -ForegroundColor DarkCyan
Invoke-Expression (Invoke-RestMethod "$base/core/layout.ps1")

Write-Host "  [3/5] Modulo: Software..." -ForegroundColor DarkCyan
Invoke-Expression (Invoke-RestMethod "$base/modules/software.ps1")

Write-Host "  [4/5] Modulo: Sistema..." -ForegroundColor DarkCyan
Invoke-Expression (Invoke-RestMethod "$base/modules/sistema.ps1")

Write-Host "  [5/5] Modulo: Red..." -ForegroundColor DarkCyan
Invoke-Expression (Invoke-RestMethod "$base/modules/red.ps1")

Write-Host ""
Write-Host "  TI Tool listo." -ForegroundColor Green
Write-Host ""

# Iniciar la aplicacion
Start-TITool
