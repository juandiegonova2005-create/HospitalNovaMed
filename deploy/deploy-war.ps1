# Publica el WAR en un Azure App Service ya creado.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File deploy\deploy-war.ps1 `
#     -ResourceGroup "rg-novamed" -AppName "novamed-app-88257"
#
# Antes genera el WAR con deploy\build-war.ps1.

param(
    [Parameter(Mandatory = $true)][string]$ResourceGroup,
    [Parameter(Mandatory = $true)][string]$AppName,
    [string]$WarPath = ""
)

$ErrorActionPreference = "Stop"

# Buscar az aunque el PATH de esta sesion no se haya actualizado tras instalarlo
$azExe = $null
$azCmd = Get-Command az -ErrorAction SilentlyContinue
if ($azCmd) { $azExe = $azCmd.Source }
if (-not $azExe) {
    foreach ($c in @(
        "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd",
        "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin\az.cmd",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\az.cmd"
    )) {
        if (Test-Path $c) { $azExe = $c; break }
    }
}
if (-not $azExe) {
    throw "Azure CLI (az) no esta instalado. Instalalo desde https://aka.ms/installazurecli"
}

# Ejecuta az sin que sus mensajes de stderr aborten el script.
function Invoke-Az {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $out = & $azExe @Arguments
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
    if ($code -ne 0) {
        throw "Fallo el comando: az $($Arguments -join ' ') (codigo $code)"
    }
    return $out
}

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($WarPath)) {
    $WarPath = Join-Path $root "dist\ProyectoFina8semestre.war"
}

if (-not (Test-Path $WarPath)) {
    throw "No se encontro el WAR: $WarPath. Ejecuta primero deploy\build-war.ps1"
}

# App Service (Tomcat en Linux) solo reemplaza la raiz del dominio si el WAR se
# llama ROOT.war. Si se sube con el nombre original, Tomcat sigue sirviendo el
# ROOT.war anterior. Se publica una copia temporal con el nombre correcto.
$rootWar = Join-Path $env:TEMP "ROOT.war"
Copy-Item $WarPath $rootWar -Force

Write-Host "Desplegando $WarPath como ROOT.war en $AppName ($ResourceGroup)..." -ForegroundColor Cyan

Invoke-Az @(
    "webapp", "deploy",
    "--resource-group", $ResourceGroup,
    "--name", $AppName,
    "--src-path", $rootWar,
    "--type", "war"
) | Out-Host

$hostName = (Invoke-Az @(
    "webapp", "show",
    "--resource-group", $ResourceGroup,
    "--name", $AppName,
    "--query", "defaultHostName",
    "--output", "tsv"
) | Out-String).Trim()

Write-Host ""
Write-Host "Despliegue completado." -ForegroundColor Green
Write-Host "Abre: https://$hostName/"
Write-Host "Logs: az webapp log tail -g $ResourceGroup -n $AppName"
