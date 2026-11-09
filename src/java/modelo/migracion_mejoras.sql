-- =====================================================================
-- Hospital NovaMed - Migracion de mejoras de seguridad y calidad
-- =====================================================================
-- REQUISITO: haber ejecutado antes migracion_seguridad.sql (bloqueo de
-- cuenta, usuario_perfil y auditoria). Si vienes de cero usa BD.sql.
--
-- Este script es IDEMPOTENTE: se puede ejecutar varias veces sin duplicar
-- filas ni romper la base.
--
-- Uso local:
--   mysql -uroot -p --default-character-set=utf8mb4 < migracion_mejoras.sql
--
-- Uso en Azure (MySQL Flexible Server):
--   az mysql flexible-server execute --name <servidor> --admin-user novamedadmin \
--      --admin-password <clave> --database-name HospitalDB \
--      --file-path src/java/modelo/migracion_mejoras.sql
-- =====================================================================
USE HospitalDB;

-- ---------------------------------------------------------------------
-- 1) Parametros de seguridad editables (tiempo de sesion, intentos, bloqueo)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS configuracion (
    clave VARCHAR(50) PRIMARY KEY,
    valor VARCHAR(100) NOT NULL,
    actualizado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO configuracion (clave, valor) VALUES
    ('sesion_minutos', '30'),
    ('max_intentos', '5'),
    ('minutos_bloqueo', '15'),
    ('retell_habilitado', '0'),
    ('retell_public_key', ''),
    ('retell_agent_id', ''),
    ('retell_voice_public_key', ''),
    ('retell_voice_agent_id', '')
ON DUPLICATE KEY UPDATE valor = valor;

-- ---------------------------------------------------------------------
-- 2) Permisos puntuales por usuario
--    1 = concede el modulo, 0 = lo deniega. Sin fila se hereda del rol.
--    Una denegacion siempre gana sobre cualquier rol.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuario_actividad (
    identificacion INT NOT NULL,
    id_actividad INT NOT NULL,
    permitido TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (identificacion, id_actividad),
    CONSTRAINT fk_ua_usuario FOREIGN KEY (identificacion)
        REFERENCES Usuario (identificacion) ON DELETE CASCADE,
    CONSTRAINT fk_ua_actividad FOREIGN KEY (id_actividad)
        REFERENCES actividades (id_actividad) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 3) Documentos adjuntos (carga validada por extension + contenido real)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS documentos (
    id_documento INT PRIMARY KEY AUTO_INCREMENT,
    identificacion INT NOT NULL,
    nombre_original VARCHAR(255) NOT NULL,
    nombre_guardado VARCHAR(120) NOT NULL,
    tipo VARCHAR(120),
    tamano BIGINT NOT NULL DEFAULT 0,
    descripcion VARCHAR(255),
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_doc_identificacion (identificacion),
    CONSTRAINT fk_doc_usuario FOREIGN KEY (identificacion)
        REFERENCES Usuario (identificacion) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 4) Actividades que faltaban en bases antiguas
-- ---------------------------------------------------------------------
INSERT INTO actividades (nom_actividad, enlace)
    SELECT 'Diagnósticos', 'listaDiagnosticos.jsp' FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE enlace = 'listaDiagnosticos.jsp');

INSERT INTO actividades (nom_actividad, enlace)
    SELECT 'Tratamientos', 'listaTratamientos.jsp' FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE enlace = 'listaTratamientos.jsp');

INSERT INTO actividades (nom_actividad, enlace)
    SELECT 'Reportes', 'reportes.jsp' FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE enlace = 'reportes.jsp');

INSERT INTO actividades (nom_actividad, enlace)
    SELECT 'Documentos', 'Documentos.jsp' FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE enlace = 'Documentos.jsp');

-- El Administrador ve todo lo nuevo
INSERT INTO gesActividad (id_perfil, id_actividad)
    SELECT p.id_perfil, a.id_actividad
    FROM Perfil p
    JOIN actividades a ON a.enlace IN
        ('listaDiagnosticos.jsp', 'listaTratamientos.jsp', 'reportes.jsp', 'Documentos.jsp')
    WHERE p.perfil = 'Administrador'
      AND NOT EXISTS (
          SELECT 1 FROM gesActividad g
          WHERE g.id_perfil = p.id_perfil AND g.id_actividad = a.id_actividad);

-- Documentos queda disponible para todos los perfiles existentes
INSERT INTO gesActividad (id_perfil, id_actividad)
    SELECT p.id_perfil, a.id_actividad
    FROM Perfil p
    JOIN actividades a ON a.enlace = 'Documentos.jsp'
    WHERE NOT EXISTS (
        SELECT 1 FROM gesActividad g
        WHERE g.id_perfil = p.id_perfil AND g.id_actividad = a.id_actividad);

-- ---------------------------------------------------------------------
-- 5) Normalizar contrasenas que no son BCrypt
--    En bases de prueba quedaron filas con el texto 'DEMO_HASH_NO_VALIDO'.
--    Se reemplazan por un hash BCrypt valido de la clave temporal
--    Temporal#2026  (cambiala desde Mi perfil o desde Editar Usuario).
--
--    Nota: la politica de claves rechaza palabras comunes como "novamed",
--    por eso la clave temporal no usa el nombre del sistema.
-- ---------------------------------------------------------------------
UPDATE Usuario
SET clave = '$2a$12$WPHF152KsLvDkTEq1oHcF.fnOZ6YVKW.r/54sGHtcfx3MBU2LcA7q',
    intentos_fallidos = 0,
    bloqueado_hasta = NULL
WHERE clave IS NULL
   OR (LEFT(clave, 4) <> '$2a$' AND LEFT(clave, 4) <> '$2b$' AND LEFT(clave, 4) <> '$2y$');

-- ---------------------------------------------------------------------
-- 6) Verificacion rapida (opcional)
-- ---------------------------------------------------------------------
SELECT 'configuracion' AS tabla, COUNT(*) AS filas FROM configuracion
UNION ALL SELECT 'usuario_actividad', COUNT(*) FROM usuario_actividad
UNION ALL SELECT 'documentos', COUNT(*) FROM documentos
UNION ALL SELECT 'actividades', COUNT(*) FROM actividades;
