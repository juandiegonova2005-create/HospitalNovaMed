# =====================================================================
# Despliegue completo de Hospital NovaMed en Azure
#
# Crea:
#   - Grupo de recursos
#   - Azure Database for MySQL Flexible Server + base HospitalDB
#   - App Service Linux con Tomcat 11 + Java 17
#   - Variables de entorno de conexion
#   - Importa tus datos locales y publica el WAR
#
# Uso (desde la carpeta del proyecto):
#   powershell -ExecutionPolicy Bypass -File deploy\desplegar-azure.ps1
#
# Requisitos:
#   - Azure CLI instalado y sesion iniciada (az login)
#   - MySQL local en ejecucion (para exportar tus datos)
#   - JDK + Tomcat (para build-war.ps1)
#
# Los nombres y contrasenas quedan en deploy\azure-deploy.json (privado).
# Para empezar de cero: -Reset  (NO borra recursos de Azure, solo el estado)
# =====================================================================

param(
    [string]$ResourceGroup = "rg-novamed",
    [string]$Location = "chilecentral",
    [string]$Sku = "B1",
    [string]$TomcatHome = "C:\Program Files\Apache Software Foundation\Tomcat 11.0",
    [string]$LocalDbUser = "root",
    [string]$LocalDbPass = "123",
    [string]$LocalDbName = "HospitalDB",
    [switch]$SkipBuild,
    [switch]$Reset
)

$ErrorActionPreference = "Stop"

# Windows PowerShell 5.1 puede negociar TLS antiguo; Azure exige TLS 1.2+
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    # En PowerShell 7 ya no es necesario
}

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$statePath = Join-Path $PSScriptRoot "azure-deploy.json"
$warPath = Join-Path $root "dist\ProyectoFina8semestre.war"

function Write-Step([string]$text) {
    Write-Host ""
    Write-Host "==> $text" -ForegroundColor Cyan
}

function Invoke-Az {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    # Los errores de az van por stderr: con ErrorActionPreference=Stop PowerShell
    # los convierte en excepcion antes de poder leer $LASTEXITCODE.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $script:AzExe @Arguments
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
    if ($code -ne 0) {
        throw "Fallo el comando: az $($Arguments -join ' ')"
    }
}

# Devuelve $true si el comando de az termina bien, sin lanzar excepcion.
function Test-Az {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        & $script:AzExe @Arguments *> $null
        return ($LASTEXITCODE -eq 0)
    } finally {
        $ErrorActionPreference = $prev
    }
}

# Devuelve la salida de un comando de az como texto (o $null si falla).
function Get-AzValue {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $out = & $script:AzExe @Arguments
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
    if ($code -ne 0) { return $null }
    return ($out | Out-String).Trim()
}

# Ejecuta un programa externo sin que sus mensajes de stderr aborten el script.
# Devuelve el codigo de salida.
function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        # Out-Host muestra la salida sin contaminar el valor de retorno de la funcion
        & $FilePath @Arguments | Out-Host
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
}

function Find-MysqlExe([string]$name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\$name.exe",
        "C:\Program Files\MySQL\MySQL Server 8.4\bin\$name.exe",
        "C:\Program Files\MySQL\MySQL Server 8.1\bin\$name.exe",
        "C:\xampp\mysql\bin\$name.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    throw "No se encontro $name.exe. Instala MySQL o agrega su carpeta bin al PATH."
}

# ---------------------------------------------------------------
# 0. Comprobaciones
# ---------------------------------------------------------------
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
    throw "Azure CLI (az) no esta instalado. Descargalo de https://aka.ms/installazurecli"
}
$script:AzExe = $azExe
Write-Host "Azure CLI: $script:AzExe"

$mysqlExe = Find-MysqlExe "mysql"
$dumpExe = Find-MysqlExe "mysqldump"

Write-Step "Verificando sesion de Azure"
if (-not (Test-Az @("account", "show", "--output", "none"))) {
    Write-Host "No hay sesion iniciada. Se abrira el navegador para az login..."
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $script:AzExe login
        $loginCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
    if ($loginCode -ne 0) { throw "No se pudo iniciar sesion en Azure." }
}

# Las suscripciones nuevas no tienen todos los proveedores registrados.
# Registrarlos no tiene costo y es requisito para crear MySQL y App Service.
Write-Step "Registrando proveedores de Azure necesarios"
foreach ($ns in @("Microsoft.DBforMySQL", "Microsoft.Web", "Microsoft.Storage", "Microsoft.Insights")) {
    $estado = Get-AzValue @("provider", "show", "--namespace", $ns, "--query", "registrationState", "--output", "tsv")
    if ($estado -ne "Registered") {
        Write-Host "  Registrando $ns (puede tardar 1-2 minutos)..."
        Invoke-Az @("provider", "register", "--namespace", $ns, "--wait")
    } else {
        Write-Host "  $ns ya estaba registrado."
    }
}

# ---------------------------------------------------------------
# 1. Estado (nombres y contrasenas)
# ---------------------------------------------------------------
if ($Reset -and (Test-Path $statePath)) {
    Remove-Item $statePath -Force
}

if (Test-Path $statePath) {
    Write-Step "Reutilizando configuracion de $statePath"
    $state = Get-Content $statePath -Raw | ConvertFrom-Json
    # Permite cambiar la region en una nueva ejecucion: -Location brazilsouth
    if ($PSBoundParameters.ContainsKey("Location")) {
        $state.location = $Location
        [System.IO.File]::WriteAllText(
            $statePath,
            ($state | ConvertTo-Json),
            (New-Object System.Text.UTF8Encoding($false))
        )
    }
} else {
    Write-Step "Generando nombres y contrasenas"
    $suffix = Get-Random -Minimum 10000 -Maximum 99999
    $state = [pscustomobject]@{
        resourceGroup = $ResourceGroup
        location      = $Location
        mysqlServer   = "novamed-mysql-$suffix"
        appName       = "novamed-app-$suffix"
        planName      = "plan-novamed"
        dbAdmin       = "novamedadmin"
        dbAdminPass   = "Nv1!" + [guid]::NewGuid().ToString("N").Substring(0, 18)
        appUser       = "novamed"
        appPass       = "Nv2!" + [guid]::NewGuid().ToString("N").Substring(0, 18)
        dbName        = $LocalDbName
        runtime       = "TOMCAT:11.0-java17"
    }
    [System.IO.File]::WriteAllText(
        $statePath,
        ($state | ConvertTo-Json),
        (New-Object System.Text.UTF8Encoding($false))
    )
}

$rg        = $state.resourceGroup
$mysqlSrv  = $state.mysqlServer
$mysqlHost = "$mysqlSrv.mysql.database.azure.com"
$appName   = $state.appName
$planName  = $state.planName
$dbAdmin   = $state.dbAdmin
$dbAdminPw = $state.dbAdminPass
$appUser   = $state.appUser
$appPass   = $state.appPass
$dbName    = $state.dbName

Write-Host "Grupo de recursos : $rg"
Write-Host "Servidor MySQL    : $mysqlHost"
Write-Host "App Service       : $appName"
Write-Host "Estado privado    : $statePath"
Write-Host "Region            : $($state.location)"

# Aviso temprano si la suscripcion limita las regiones (Azure for Students).
$permitidas = Get-AzValue @(
    "policy", "assignment", "show",
    "--name", "sys.regionrestriction",
    "--query", "parameters.listOfAllowedLocations.value",
    "--output", "tsv"
)
if ($permitidas) {
    $lista = @($permitidas -split '\s+' | Where-Object { $_ })
    if ($lista.Count -gt 0 -and $lista -notcontains $state.location) {
        throw "La region '$($state.location)' no esta permitida en esta suscripcion. Usa una de: $($lista -join ', '). Ejemplo: -Location $($lista[0])"
    }
    Write-Host "Regiones permitidas: $($lista -join ', ')"
}

# ---------------------------------------------------------------
# 2. Grupo de recursos
# ---------------------------------------------------------------
Write-Step "Creando grupo de recursos"
if (-not (Test-Az @("group", "show", "--name", $rg, "--output", "none"))) {
    Invoke-Az @("group", "create", "--name", $rg, "--location", $state.location)
} else {
    Write-Host "El grupo $rg ya existe."
}

# ---------------------------------------------------------------
# 3. MySQL Flexible Server
# ---------------------------------------------------------------
Write-Step "Creando MySQL Flexible Server (puede tardar 5-10 minutos)"
if (-not (Test-Az @("mysql", "flexible-server", "show", "--resource-group", $rg, "--name", $mysqlSrv, "--output", "none"))) {
    try {
        Invoke-Az @(
            "mysql", "flexible-server", "create",
            "--resource-group", $rg,
            "--name", $mysqlSrv,
            "--location", $state.location,
            "--admin-user", $dbAdmin,
            "--admin-password", $dbAdminPw,
            "--version", "8.0.21",
            "--tier", "Burstable",
            "--sku-name", "Standard_B1ms",
            "--storage-size", "32",
            "--public-access", "0.0.0.0"
        )
    } catch {
        Write-Host ""
        Write-Host "No se pudo crear MySQL en '$($state.location)'." -ForegroundColor Yellow
        Write-Host "Si el error fue 'No available SKUs in this location', la suscripcion no" -ForegroundColor Yellow
        Write-Host "tiene capacidad alli. Prueba otra region permitida:" -ForegroundColor Yellow
        Write-Host "  powershell -ExecutionPolicy Bypass -File deploy\desplegar-azure.ps1 -Location chilecentral"
        throw
    }
} else {
    Write-Host "El servidor MySQL ya existe."
}

if (-not (Test-Az @("mysql", "flexible-server", "db", "show", "--resource-group", $rg, "--server-name", $mysqlSrv, "--database-name", $dbName, "--output", "none"))) {
    Invoke-Az @(
        "mysql", "flexible-server", "db", "create",
        "--resource-group", $rg,
        "--server-name", $mysqlSrv,
        "--database-name", $dbName
    )
}

# ---------------------------------------------------------------
# 4. Abrir firewall temporal para importar desde tu PC
# ---------------------------------------------------------------
Write-Step "Habilitando tu IP para la importacion"
$myIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=text").Trim()
Write-Host "IP publica: $myIp"

Test-Az @(
    "mysql", "flexible-server", "firewall-rule", "delete",
    "--resource-group", $rg,
    "--name", $mysqlSrv,
    "--rule-name", "MiIP-Import",
    "--yes"
) | Out-Null

Invoke-Az @(
    "mysql", "flexible-server", "firewall-rule", "create",
    "--resource-group", $rg,
    "--name", $mysqlSrv,
    "--rule-name", "MiIP-Import",
    "--start-ip-address", $myIp,
    "--end-ip-address", $myIp
)

# ---------------------------------------------------------------
# 5. Exportar datos locales
# ---------------------------------------------------------------
Write-Step "Exportando $dbName desde tu MySQL local"
$dumpPath = Join-Path $env:TEMP ("novamed-dump-" + (Get-Date -Format "yyyyMMddHHmmss") + ".sql")
$dumpErr = "$dumpPath.err"

$dumpArgs = @(
    "-u$LocalDbUser",
    "-p$LocalDbPass",
    "--databases", $LocalDbName,
    "--single-transaction",
    "--routines",
    "--triggers",
    "--set-gtid-purged=OFF",
    "--default-character-set=utf8mb4"
)

$proc = Start-Process -FilePath $dumpExe -ArgumentList $dumpArgs `
    -RedirectStandardOutput $dumpPath -RedirectStandardError $dumpErr `
    -Wait -NoNewWindow -PassThru

if ($proc.ExitCode -ne 0) {
    if (Test-Path $dumpErr) { Get-Content $dumpErr -Tail 20 }
    throw "mysqldump fallo (codigo $($proc.ExitCode)). Verifica que MySQL este encendido y la clave sea correcta."
}

$dumpSize = (Get-Item $dumpPath).Length
Write-Host ("Respaldo generado: {0:N0} bytes" -f $dumpSize)
if ($dumpSize -lt 1000) {
    throw "El respaldo es demasiado pequeno. Revisa usuario/clave de MySQL local."
}

# ---------------------------------------------------------------
# 6. Importar en Azure MySQL
# ---------------------------------------------------------------
Write-Step "Importando datos en Azure (puede tardar varios minutos)"
$importOut = "$dumpPath.out"
$importErr = "$dumpPath.err2"
$importArgs = @(
    "-h", $mysqlHost,
    "-u", $dbAdmin,
    "-p$dbAdminPw",
    "--ssl-mode=REQUIRED",
    "--default-character-set=utf8mb4"
)

$importProc = Start-Process -FilePath $mysqlExe -ArgumentList $importArgs `
    -RedirectStandardInput $dumpPath `
    -RedirectStandardOutput $importOut `
    -RedirectStandardError $importErr `
    -Wait -NoNewWindow -PassThru

if ($importProc.ExitCode -ne 0) {
    if (Test-Path $importErr) { Get-Content $importErr -Tail 20 }
    throw "La importacion fallo. El respaldo quedo en $dumpPath y la regla de firewall sigue activa."
}

Write-Host "Importacion completada."

# ---------------------------------------------------------------
# 6.1 Crear tablas clinicas que falten (idempotente)
# ---------------------------------------------------------------
$clinicasSql = Join-Path $root "src\java\modelo\migracion_clinicas.sql"
$migOut = $null
$migErr = $null
if (Test-Path $clinicasSql) {
    Write-Step "Creando tablas clinicas faltantes"
    $migOut = "$dumpPath.mig.out"
    $migErr = "$dumpPath.mig.err"
    $migArgs = @(
        "-h", $mysqlHost,
        "-u", $dbAdmin,
        "-p$dbAdminPw",
        "--ssl-mode=REQUIRED",
        "--default-character-set=utf8mb4"
    )
    $migProc = Start-Process -FilePath $mysqlExe -ArgumentList $migArgs `
        -RedirectStandardInput $clinicasSql `
        -RedirectStandardOutput $migOut `
        -RedirectStandardError $migErr `
        -Wait -NoNewWindow -PassThru
    if ($migProc.ExitCode -ne 0) {
        if (Test-Path $migErr) { Get-Content $migErr -Tail 20 }
        throw "No se pudieron crear las tablas clinicas."
    }
    Write-Host "Tablas clinicas verificadas."
}

# ---------------------------------------------------------------
# 7. Usuario de la aplicacion (permisos minimos)
# ---------------------------------------------------------------
Write-Step "Creando usuario de aplicacion"
$sqlUser = "CREATE USER IF NOT EXISTS '$appUser'@'%' IDENTIFIED BY '$appPass'; " +
           "GRANT SELECT, INSERT, UPDATE, DELETE ON $dbName.* TO '$appUser'@'%'; " +
           "FLUSH PRIVILEGES;"

$userCode = Invoke-Native -FilePath $mysqlExe -Arguments @(
    "-h", $mysqlHost, "-u", $dbAdmin, "-p$dbAdminPw",
    "--ssl-mode=REQUIRED", "-e", $sqlUser
)
if ($userCode -ne 0) {
    throw "No se pudo crear el usuario de la aplicacion."
}

# Verificacion rapida de datos
Write-Step "Verificando datos importados"
Invoke-Native -FilePath $mysqlExe -Arguments @(
    "-h", $mysqlHost, "-u", $dbAdmin, "-p$dbAdminPw",
    "--ssl-mode=REQUIRED", "-N", "-e",
    "SELECT CONCAT('pacientes=', COUNT(*)) FROM $dbName.pacientes;"
) | Out-Null
Invoke-Native -FilePath $mysqlExe -Arguments @(
    "-h", $mysqlHost, "-u", $dbAdmin, "-p$dbAdminPw",
    "--ssl-mode=REQUIRED", "-N", "-e",
    "SELECT CONCAT('medicos=', COUNT(*)) FROM $dbName.medicos;"
) | Out-Null

# Cerrar el acceso desde tu IP (solo queda el acceso de servicios de Azure)
Test-Az @(
    "mysql", "flexible-server", "firewall-rule", "delete",
    "--resource-group", $rg,
    "--name", $mysqlSrv,
    "--rule-name", "MiIP-Import",
    "--yes"
) | Out-Null
Write-Host "Regla temporal de tu IP eliminada."

# Borrar respaldo local
foreach ($f in @($dumpPath, $dumpErr, $importOut, $importErr, $migOut, $migErr)) {
    if ($f -and (Test-Path $f)) { Remove-Item $f -Force }
}

# ---------------------------------------------------------------
# 8. WAR
# ---------------------------------------------------------------
Write-Step "Generando WAR"
if (-not $SkipBuild -or -not (Test-Path $warPath)) {
    $buildCode = Invoke-Native -FilePath "powershell" -Arguments @(
        "-ExecutionPolicy", "Bypass",
        "-File", (Join-Path $PSScriptRoot "build-war.ps1"),
        "-TomcatHome", $TomcatHome
    )
    if ($buildCode -ne 0) { throw "Fallo la generacion del WAR." }
} else {
    Write-Host "Usando WAR existente: $warPath"
}
if (-not (Test-Path $warPath)) { throw "No existe $warPath" }

# ---------------------------------------------------------------
# 9. App Service
# ---------------------------------------------------------------
Write-Step "Creando App Service (Tomcat 11 + Java 17)"

# Si el plan quedo en otra region (por una ejecucion anterior), hay que
# eliminarlo: Azure no permite mover un plan de App Service.
if (Test-Az @("appservice", "plan", "show", "--resource-group", $rg, "--name", $planName, "--output", "none")) {
    $planLoc = Get-AzValue @(
        "appservice", "plan", "show",
        "--resource-group", $rg,
        "--name", $planName,
        "--query", "location",
        "--output", "tsv"
    )
    $normalizar = { param($v) ($v -replace '\s+', '').ToLowerInvariant() }
    $locActual = & $normalizar $planLoc
    $locDeseada = & $normalizar $state.location
    if ($locActual -and $locActual -ne $locDeseada) {
        Write-Host "El plan $planName esta en '$planLoc' y se necesita en '$($state.location)'." -ForegroundColor Yellow
        Write-Host "Se eliminara la app y el plan para recrearlos en la region correcta..." -ForegroundColor Yellow
        # 'webapp delete' no acepta --yes; ademas borra el plan si es la ultima app.
        Test-Az @("webapp", "delete", "--resource-group", $rg, "--name", $appName) | Out-Null
        if (Test-Az @("appservice", "plan", "show", "--resource-group", $rg, "--name", $planName, "--output", "none")) {
            Invoke-Az @("appservice", "plan", "delete", "--resource-group", $rg, "--name", $planName, "--yes")
        }
    }
}

if (-not (Test-Az @("appservice", "plan", "show", "--resource-group", $rg, "--name", $planName, "--output", "none"))) {
    Invoke-Az @(
        "appservice", "plan", "create",
        "--resource-group", $rg,
        "--name", $planName,
        "--location", $state.location,
        "--is-linux",
        "--sku", $Sku
    )
} else {
    Write-Host "El plan $planName ya existe."
}

# --runtime ya configura la version de Tomcat; no hace falta
# 'webapp config set --linux-fx-version' (y el caracter | rompe cmd).
if (-not (Test-Az @("webapp", "show", "--resource-group", $rg, "--name", $appName, "--output", "none"))) {
    Invoke-Az @(
        "webapp", "create",
        "--resource-group", $rg,
        "--plan", $planName,
        "--name", $appName,
        "--runtime", $state.runtime
    )
} else {
    Write-Host "La app $appName ya existe."
}

# ---------------------------------------------------------------
# 10. Variables de entorno
# ---------------------------------------------------------------
Write-Step "Configurando conexion a la base de datos"
$appSettings = @(
    "NOVAMED_DB_HOST=${mysqlHost}:3306",
    "NOVAMED_DB_NAME=$dbName",
    "NOVAMED_DB_USER=$appUser",
    "NOVAMED_DB_PASS=$appPass",
    "NOVAMED_LOG_DIR=/home/LogFiles",
    "NOVAMED_UPLOAD_DIR=/home/data/documentos"
)

Invoke-Az (@(
    "webapp", "config", "appsettings", "set",
    "--resource-group", $rg,
    "--name", $appName,
    "--settings"
) + $appSettings)

# ---------------------------------------------------------------
# 11. Desplegar WAR
# ---------------------------------------------------------------
Write-Step "Publicando el WAR como ROOT.war"
# App Service (Tomcat en Linux) solo reemplaza la raiz del dominio si el WAR
# se llama ROOT.war; con el nombre original Tomcat sigue sirviendo el anterior.
$rootWar = Join-Path $env:TEMP "ROOT.war"
Copy-Item $warPath $rootWar -Force
Invoke-Az @(
    "webapp", "deploy",
    "--resource-group", $rg,
    "--name", $appName,
    "--src-path", $rootWar,
    "--type", "war"
)

# ---------------------------------------------------------------
# 12. Verificar
# ---------------------------------------------------------------
$url = "https://$appName.azurewebsites.net/"
Write-Step "Esperando a que la aplicacion responda"
Write-Host $url

# 'webapp deploy --type war' publica el WAR en la raiz del dominio, por eso
# se comprueba contenido real y no solo el codigo 200 (el login redirige).
$ok = $false
for ($i = 1; $i -le 24; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri "$url/login.jsp" -UseBasicParsing -TimeoutSec 30
        if ($resp.StatusCode -eq 200 -and $resp.Content -match "NovaMed") {
            $ok = $true
            break
        }
    } catch {
        # aun arrancando
    }
    Start-Sleep -Seconds 5
    Write-Host "  intento $i/24..."
}

Write-Host ""
if ($ok) {
    Write-Host "LISTO: la aplicacion responde en $url" -ForegroundColor Green
} else {
    Write-Host "El despliegue termino, pero la app aun no responde." -ForegroundColor Yellow
    Write-Host "Revisa los logs con: az webapp log tail -g $rg -n $appName"
}

Write-Host ""
Write-Host "Credenciales y nombres guardados en: $statePath" -ForegroundColor Yellow
Write-Host "No compartas ese archivo."
Write-Host ""
Write-Host "Para actualizar solo el WAR mas adelante:"
Write-Host "  powershell -ExecutionPolicy Bypass -File deploy\deploy-war.ps1 -ResourceGroup `"$rg`" -AppName `"$appName`""
