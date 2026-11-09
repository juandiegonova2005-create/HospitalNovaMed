# =====================================================================
# Hospital NovaMed - imagen Docker (Tomcat 11 + Java 17)
#
# Compila el WAR dentro de la imagen (igual que deploy\build-war.ps1) y lo
# publica en Tomcat. No necesitas tener Java ni NetBeans instalado para
# construirla; solo Docker.
#
#   docker compose up -d --build
#   http://localhost:8081/ProyectoFina8semestre/
#
# La base de datos, las variables de entorno y los volumenes estan en
# docker-compose.yml. Ver DOCKER.md.
# =====================================================================

# ---------- Etapa 1: compilar el WAR ----------
FROM tomcat:11.0-jdk17-temurin AS build

WORKDIR /src

# Solo lo necesario para compilar: fuentes, web y librerias
COPY src ./src
COPY web ./web
COPY lib ./lib

# Equivalente a deploy\build-war.ps1:
#  - copia web/ al staging
#  - compila src/java con el servlet-api de Tomcat y las librerias del proyecto
#  - copia los .jar a WEB-INF/lib
#  - escribe META-INF/context.xml (sin "path" y con el flag de Tomcat 11)
#  - empaqueta todo en un WAR
RUN mkdir -p build/WEB-INF/classes \
 && cp -R web/. build/ \
 && find src -name '*.java' > sources.txt \
 && javac --release 17 -encoding UTF-8 \
        -cp "/usr/local/tomcat/lib/*:/src/lib/*" \
        -d build/WEB-INF/classes @sources.txt \
 && mkdir -p build/WEB-INF/lib \
 && cp lib/*.jar build/WEB-INF/lib/ \
 && mkdir -p build/META-INF \
 && printf '%s\n' \
      '<?xml version="1.0" encoding="UTF-8"?>' \
      '<Context suspendWrappedResponseAfterForward="false">' \
      '</Context>' \
      > build/META-INF/context.xml \
 && cd build \
 && jar --create --file /tmp/ProyectoFina8semestre.war .

# ---------- Etapa 2: imagen final ----------
FROM tomcat:11.0-jdk17-temurin

ENV LANG=C.UTF-8 \
    TZ=UTC \
    CATALINA_OPTS="-Dfile.encoding=UTF-8 -Duser.timezone=UTC -Xms256m -Xmx512m"

# curl se usa para el healthcheck de docker-compose
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/local/tomcat/webapps/* \
 && mkdir -p /data/uploads

COPY --from=build /tmp/ProyectoFina8semestre.war \
     /usr/local/tomcat/webapps/ProyectoFina8semestre.war

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
  CMD curl -fsS http://localhost:8080/ProyectoFina8semestre/login.jsp || exit 1

# El entrypoint oficial de Tomcat arranca catalina.sh
CMD ["catalina.sh", "run"]
