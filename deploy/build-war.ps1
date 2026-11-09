# Genera el WAR desplegable de Hospital NovaMed.
# Uso:
#   powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1
#   powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 -TomcatHome "C:\Tomcat 11.0"
#
# Requiere JDK 17+ en el PATH y una instalacion de Tomcat (solo para tomar
# servlet-api.jar y jasper, no se despliega nada localmente).

param(
    [string]$TomcatHome = "C:\Tomcat 11.0",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$servletApi = Join-Path $TomcatHome "lib\servlet-api.jar"
if (-not (Test-Path $servletApi)) {
    throw "No se encontro $servletApi. Instala Tomcat o pasa -TomcatHome con la ruta correcta."
}

$stage = Join-Path $env:TEMP ("novamed-war-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stage | Out-Null

try {
    Copy-Item (Join-Path $root "web\*") $stage -Recurse -Force

    $classes = Join-Path $stage "WEB-INF\classes"
    New-Item -ItemType Directory -Path $classes -Force | Out-Null

    $sources = Get-ChildItem (Join-Path $root "src\java") -Recurse -Filter "*.java" |
        ForEach-Object { $_.FullName }

    & javac --release 17 -encoding UTF-8 -cp "$TomcatHome\lib\*;$root\lib\*" -d $classes @sources
    if ($LASTEXITCODE -ne 0) {
        throw "La compilacion Java fallo (codigo $LASTEXITCODE)."
    }

    $libOut = Join-Path $stage "WEB-INF\lib"
    New-Item -ItemType Directory -Path $libOut -Force | Out-Null
    Copy-Item (Join-Path $root "lib\*.jar") $libOut -Force

    # El context.xml se escribe aqui a proposito. NetBeans puede volver a
    # anadir path="/ProyectoFina8semestre" al desplegar en local, y ese atributo
    # rompe ROOT.war en Azure (el contexto lo define el nombre del WAR).
    # suspendWrappedResponseAfterForward="false" es obligatorio en Tomcat 11:
    # sin el, el forward() cierra la respuesta antes de que FiltroAsistente
    # inyecte el widget y el login fallido devuelve una pagina en blanco.
    $metaInf = Join-Path $stage "META-INF"
    New-Item -ItemType Directory -Path $metaInf -Force | Out-Null
    $contextXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Configuracion del contexto de la aplicacion.
  Sin atributo "path": el contexto lo determina el nombre del WAR.
  suspendWrappedResponseAfterForward="false" es obligatorio para que
  FiltroAsistente pueda inyectar el widget despues de un forward().
-->
<Context suspendWrappedResponseAfterForward="false">
</Context>
"@
    $utf8SinBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $metaInf "context.xml"), $contextXml, $utf8SinBom)

    if ([string]::IsNullOrWhiteSpace($OutDir)) {
        $OutDir = Join-Path $root "dist"
    }
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

    $jar = "jar"
    $jarCandidates = @(
        "C:\Program Files\Apache NetBeans\jdk\bin\jar.exe"
    )
    if ($env:JAVA_HOME) {
        $jarCandidates = @((Join-Path $env:JAVA_HOME "bin\jar.exe")) + $jarCandidates
    }
    foreach ($candidate in $jarCandidates) {
        if (Test-Path $candidate) { $jar = $candidate; break }
    }

    $war = Join-Path $OutDir "ProyectoFina8semestre.war"
    if (Test-Path $war) { Remove-Item $war -Force }

    & $jar --create --file $war -C $stage .
    if ($LASTEXITCODE -ne 0) {
        throw "La creacion del WAR fallo (codigo $LASTEXITCODE)."
    }

    Write-Host ""
    Write-Host "WAR generado: $war" -ForegroundColor Green
    Write-Host ("Tamano: {0:N0} bytes" -f (Get-Item $war).Length)
}
finally {
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
}
