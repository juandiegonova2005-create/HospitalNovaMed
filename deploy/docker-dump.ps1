# Regenera docker/mysql/init/01-hospitaldb.sql desde el MySQL local.
# Uso:
#   powershell -ExecutionPolicy Bypass -File deploy\docker-dump.ps1
#   powershell -ExecutionPolicy Bypass -File deploy\docker-dump.ps1 -MysqlPass "otra"
#
# El dump conserva estructura + datos + usuarios + configuracion. La tabla
# "contactos" (vieja y sin uso) se excluye.

param(
    [string]$MysqlUser = "root",
    [string]$MysqlPass = "123",
    [string]$Database = "HospitalDB",
    [string]$OutFile = ""
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = Join-Path $root "docker\mysql\init\01-hospitaldb.sql"
}

$mysqldump = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"
if (-not (Test-Path $mysqldump)) {
    $cmd = Get-Command mysqldump -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "No se encontro mysqldump. Instala MySQL o pasa la ruta en el script."
    }
    $mysqldump = $cmd.Source
}

New-Item -ItemType Directory -Force -Path (Split-Path $OutFile -Parent) | Out-Null

# Evita el warning de clave en la linea de comandos
$env:MYSQL_PWD = $MysqlPass
try {
    & $mysqldump -u $MysqlUser `
        --databases $Database `
        --single-transaction --quick --routines --triggers `
        --set-gtid-purged=OFF --default-character-set=utf8mb4 `
        --ignore-table="$Database.contactos" `
        --result-file="$OutFile"

    if ($LASTEXITCODE -ne 0) {
        throw "mysqldump fallo con codigo $LASTEXITCODE."
    }
}
finally {
    Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Dump generado: $OutFile" -ForegroundColor Green
Write-Host ("Tamano: {0:N2} MB" -f ((Get-Item $OutFile).Length / 1MB))
Write-Host ""
Write-Host "Para que MySQL lo cargue hay que recrear el volumen:" -ForegroundColor Yellow
Write-Host "  docker compose down -v"
Write-Host "  docker compose up -d --build"
