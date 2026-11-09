# Levanta Hospital NovaMed con Docker y espera a que este saludable.
# Uso:
#   powershell -ExecutionPolicy Bypass -File deploy\docker-up.ps1
#   powershell -ExecutionPolicy Bypass -File deploy\docker-up.ps1 -NoBuild

param(
    [switch]$NoBuild,
    [int]$TimeoutSeconds = 180
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root

# Comprobar que el motor de Docker responde
& docker info --format "{{.ServerVersion}}" | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Docker no esta corriendo. Abre Docker Desktop y vuelve a intentar."
}

if ($NoBuild) {
    & docker compose up -d
} else {
    & docker compose up -d --build
}
if ($LASTEXITCODE -ne 0) {
    throw "docker compose fallo con codigo $LASTEXITCODE."
}

Write-Host ""
Write-Host "Esperando a que la aplicacion este saludable..." -ForegroundColor Cyan

$healthy = $false
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 3
    $estado = & docker inspect --format "{{.State.Health.Status}}" novamed-app 2>$null
    if ($estado -eq "healthy") { $healthy = $true; break }
    if ($estado -eq "unhealthy") { break }
}

$url = "http://localhost:8081/ProyectoFina8semestre/"
if ($healthy) {
    Write-Host "Aplicacion lista: $url" -ForegroundColor Green
} else {
    Write-Host "La aplicacion aun no reporta 'healthy'." -ForegroundColor Yellow
    Write-Host "Revisa los logs con: docker compose logs -f app"
}

Write-Host ""
& docker compose ps
