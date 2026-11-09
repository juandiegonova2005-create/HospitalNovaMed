-- =====================================================================
-- Migracion para bases de datos YA CREADAS (HospitalDB).
-- Ejecutar UNA sola vez. Si instalas desde cero usa BD.sql (ya lo incluye).
-- =====================================================================
USE HospitalDB;

-- 1) Bloqueo de cuenta
ALTER TABLE Usuario
    ADD COLUMN intentos_fallidos INT NOT NULL DEFAULT 0,
    ADD COLUMN bloqueado_hasta DATETIME NULL;

-- 2) Unicidad de correo y usuario.
--    Si falla con "Duplicate entry", hay datos repetidos: encuentralos con
--      SELECT email, COUNT(*) FROM Usuario GROUP BY email HAVING COUNT(*) > 1;
--      SELECT usuario, COUNT(*) FROM Usuario GROUP BY usuario HAVING COUNT(*) > 1;
--    corrigelos y vuelve a ejecutar estas dos lineas.
ALTER TABLE Usuario ADD UNIQUE KEY uq_usuario_email (email);
ALTER TABLE Usuario ADD UNIQUE KEY uq_usuario_usuario (usuario);

-- 3) Perfiles adicionales por usuario
CREATE TABLE IF NOT EXISTS usuario_perfil (
    identificacion INT NOT NULL,
    id_perfil INT NOT NULL,
    PRIMARY KEY (identificacion, id_perfil),
    FOREIGN KEY (identificacion) REFERENCES Usuario(identificacion) ON DELETE CASCADE,
    FOREIGN KEY (id_perfil) REFERENCES Perfil(id_perfil) ON DELETE CASCADE
);

-- 4) Bitacora de auditoria
CREATE TABLE IF NOT EXISTS auditoria (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor VARCHAR(60),
    accion VARCHAR(40) NOT NULL,
    detalle VARCHAR(500),
    ip VARCHAR(45),
    INDEX idx_aud_fecha (fecha),
    INDEX idx_aud_actor (actor)
);

-- 5) Tokens de recuperacion de contraseña
CREATE TABLE IF NOT EXISTS reset_token (
    token_hash CHAR(64) PRIMARY KEY,
    identificacion INT NOT NULL,
    expira DATETIME NOT NULL,
    FOREIGN KEY (identificacion) REFERENCES Usuario(identificacion) ON DELETE CASCADE
);

-- 6) Menu: actividad "Auditoria" visible para el Administrador (perfil 1)
INSERT INTO actividades (nom_actividad, enlace)
    SELECT 'Auditoría', 'listaAuditoria.jsp' FROM DUAL
    WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE enlace = 'listaAuditoria.jsp');
INSERT INTO gesActividad (id_perfil, id_actividad)
    SELECT 1, a.id_actividad FROM actividades a
    WHERE a.enlace = 'listaAuditoria.jsp'
      AND NOT EXISTS (SELECT 1 FROM gesActividad g WHERE g.id_perfil = 1 AND g.id_actividad = a.id_actividad);
