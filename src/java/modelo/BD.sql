-- =====================================================================
-- Hospital NovaMed - Script completo de base de datos
-- (incluye los modulos nuevos: Hospitalizaciones, Historias Clinicas,
--  Diagnosticos, Tratamientos y Reportes)
-- =====================================================================
CREATE DATABASE IF NOT EXISTS HospitalDB CHARACTER SET utf8mb4;
USE HospitalDB;

-- ---------- Seguridad y menu ----------
CREATE TABLE Perfil (
    id_perfil INT PRIMARY KEY AUTO_INCREMENT,
    perfil VARCHAR(30)
);

INSERT INTO Perfil (perfil) VALUES
('Administrador'),
('Usuario');

-- clave: VARCHAR(100) porque se guarda el hash BCrypt (~60 caracteres)
CREATE TABLE Usuario (
    identificacion INT PRIMARY KEY,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    email VARCHAR(60),
    telefono VARCHAR(100),
    usuario VARCHAR(20),
    clave VARCHAR(100),
    id_perfil INT,
    intentos_fallidos INT NOT NULL DEFAULT 0,   -- bloqueo de cuenta (5 intentos)
    bloqueado_hasta DATETIME NULL,
    UNIQUE KEY uq_usuario_email (email),        -- no se repite el correo
    UNIQUE KEY uq_usuario_usuario (usuario),    -- no se repite el nombre de usuario
    FOREIGN KEY (id_perfil) REFERENCES Perfil(id_perfil)
);

-- Perfiles adicionales de un usuario (ademas del principal Usuario.id_perfil)
CREATE TABLE usuario_perfil (
    identificacion INT NOT NULL,
    id_perfil INT NOT NULL,
    PRIMARY KEY (identificacion, id_perfil),
    FOREIGN KEY (identificacion) REFERENCES Usuario(identificacion) ON DELETE CASCADE,
    FOREIGN KEY (id_perfil) REFERENCES Perfil(id_perfil) ON DELETE CASCADE
);

-- Bitacora de auditoria
CREATE TABLE auditoria (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor VARCHAR(60),
    accion VARCHAR(40) NOT NULL,
    detalle VARCHAR(500),
    ip VARCHAR(45),
    INDEX idx_aud_fecha (fecha),
    INDEX idx_aud_actor (actor)
);

-- Tokens de recuperacion de contraseña (solo se guarda el hash SHA-256)
CREATE TABLE reset_token (
    token_hash CHAR(64) PRIMARY KEY,
    identificacion INT NOT NULL,
    expira DATETIME NOT NULL,
    FOREIGN KEY (identificacion) REFERENCES Usuario(identificacion) ON DELETE CASCADE
);

-- Parametros de seguridad editables desde la pantalla Configuracion
CREATE TABLE configuracion (
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
    ('retell_voice_agent_id', '');

-- Permisos puntuales por usuario: 1 concede, 0 deniega, sin fila hereda del rol
-- (la tabla se crea mas abajo, despues de actividades, por la clave foranea)

-- Documentos adjuntos (la carga valida extension y contenido real)
CREATE TABLE documentos (
    id_documento INT PRIMARY KEY AUTO_INCREMENT,
    identificacion INT NOT NULL,
    nombre_original VARCHAR(255) NOT NULL,
    nombre_guardado VARCHAR(120) NOT NULL,
    tipo VARCHAR(120),
    tamano BIGINT NOT NULL DEFAULT 0,
    descripcion VARCHAR(255),
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_doc_identificacion (identificacion),
    FOREIGN KEY (identificacion) REFERENCES Usuario(identificacion) ON DELETE CASCADE
);

CREATE TABLE actividades(
    id_actividad INT PRIMARY KEY AUTO_INCREMENT,
    nom_actividad VARCHAR(45),
    enlace VARCHAR(100)
);

INSERT INTO actividades (nom_actividad, enlace) VALUES
('Dashboard', 'dashboard.jsp'),
('Usuarios', 'listaUsuarios.jsp'),
('Perfiles', 'listaPerfiles.jsp'),
('Actividades', 'listaActividades.jsp'),
('GesActividad', 'listaGesActividad.jsp'),
('Pacientes', 'listaPacientes.jsp'),
('Médicos', 'listaMedicos.jsp'),
('Camas', 'listaCamas.jsp'),
('Especialidades', 'listaEspecialidades.jsp'),
('Inventario', 'listaInventario.jsp'),
('Medicamentos', 'listaMedicamentos.jsp'),
('Hospitalizaciones', 'listaHospitalizaciones.jsp'),
('Historias Clínicas', 'listaHistoriasClinicas.jsp'),
('Diagnósticos', 'listaDiagnosticos.jsp'),
('Tratamientos', 'listaTratamientos.jsp'),
('Reportes', 'reportes.jsp'),
('Auditoría', 'listaAuditoria.jsp'),
('Documentos', 'Documentos.jsp');

CREATE TABLE gesActividad(
    idgesActividad INT PRIMARY KEY AUTO_INCREMENT,
    id_perfil INT,
    id_actividad INT,
    FOREIGN KEY (id_perfil) REFERENCES Perfil(id_perfil),
    FOREIGN KEY (id_actividad) REFERENCES actividades(id_actividad)
);

-- El perfil Administrador (1) accede a todas las actividades
INSERT INTO gesActividad (id_perfil, id_actividad) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18);

-- El perfil Usuario tambien puede usar Documentos
INSERT INTO gesActividad (id_perfil, id_actividad) VALUES (2,18);

-- Permisos puntuales por usuario: 1 concede, 0 deniega, sin fila hereda del rol
CREATE TABLE usuario_actividad (
    identificacion INT NOT NULL,
    id_actividad INT NOT NULL,
    permitido TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (identificacion, id_actividad),
    FOREIGN KEY (identificacion) REFERENCES Usuario(identificacion) ON DELETE CASCADE,
    FOREIGN KEY (id_actividad) REFERENCES actividades(id_actividad) ON DELETE CASCADE
);

-- ---------- Modulos clinicos ----------
CREATE TABLE camas (
    id_cama INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(20),
    tipo VARCHAR(30),
    estado VARCHAR(20)
);

CREATE TABLE especialidades (
    id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60),
    descripcion VARCHAR(200)
);

CREATE TABLE inventario (
    id_item INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80),
    categoria VARCHAR(50),
    cantidad INT,
    ubicacion VARCHAR(60),
    estado VARCHAR(20)
);

CREATE TABLE medicamentos (
    id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80),
    descripcion VARCHAR(200),
    stock INT,
    precio DECIMAL(10,2),
    estado VARCHAR(20)
);

CREATE TABLE medicos (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    documento VARCHAR(20),
    nombre VARCHAR(40),
    apellido VARCHAR(40),
    telefono VARCHAR(20),
    correo VARCHAR(60),
    id_especialidad INT NULL,
    estado VARCHAR(20),
    FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
);

CREATE TABLE pacientes (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    documento VARCHAR(20),
    nombre VARCHAR(40),
    apellido VARCHAR(40),
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    direccion VARCHAR(100),
    correo VARCHAR(60),
    estado VARCHAR(20),
    id_cama INT NULL,
    FOREIGN KEY (id_cama) REFERENCES camas(id_cama)
);

-- ---------- Modulos nuevos ----------
CREATE TABLE hospitalizaciones (
    id_hospitalizacion INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT NOT NULL,
    id_cama INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_egreso DATE NULL,
    motivo VARCHAR(255),
    estado VARCHAR(20) NOT NULL DEFAULT 'Activa',
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_cama) REFERENCES camas(id_cama),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
);

CREATE TABLE historias_clinicas (
    id_historia INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha DATE NOT NULL,
    antecedentes TEXT,
    motivo TEXT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
);

CREATE TABLE diagnosticos (
    id_diagnostico INT PRIMARY KEY AUTO_INCREMENT,
    id_historia INT NOT NULL,
    codigo_cie10 VARCHAR(10) NOT NULL,
    descripcion VARCHAR(255),
    fecha DATE NOT NULL,
    FOREIGN KEY (id_historia) REFERENCES historias_clinicas(id_historia)
);

CREATE TABLE tratamientos (
    id_tratamiento INT PRIMARY KEY AUTO_INCREMENT,
    id_diagnostico INT NOT NULL,
    id_medicamento INT NOT NULL,
    dosis VARCHAR(100),
    duracion_dias INT,
    estado VARCHAR(20) NOT NULL DEFAULT 'En curso',
    FOREIGN KEY (id_diagnostico) REFERENCES diagnosticos(id_diagnostico),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);

-- Usuario administrador inicial (usuario: admin / clave: Admin#2026, guardada con BCrypt).
-- CAMBIA esta clave inmediatamente despues del primer ingreso (Mi perfil).
INSERT INTO Usuario (identificacion, nombre, apellido, email, telefono, usuario, clave, id_perfil) VALUES
(1001, 'Juan', 'Pérez', 'admin@novamed.com', '3001112233', 'admin', '$2a$12$6bQ9tsD6r7xDR./x07CEFe923JhKlfQ3YSOjLyFb9j28s0MLi1raC', 1);
