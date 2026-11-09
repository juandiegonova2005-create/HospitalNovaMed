-- =====================================================================
-- Migracion segura: crea las tablas clinicas que faltan.
--
-- No borra ni modifica datos: usa CREATE TABLE IF NOT EXISTS.
-- Ejecutar sobre una base existente:
--   mysql -uroot -p < src/java/modelo/migracion_clinicas.sql
--
-- Tablas: hospitalizaciones, historias_clinicas, diagnosticos, tratamientos
-- =====================================================================
USE HospitalDB;

CREATE TABLE IF NOT EXISTS hospitalizaciones (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS historias_clinicas (
    id_historia INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha DATE NOT NULL,
    antecedentes TEXT,
    motivo TEXT,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS diagnosticos (
    id_diagnostico INT PRIMARY KEY AUTO_INCREMENT,
    id_historia INT NOT NULL,
    codigo_cie10 VARCHAR(10) NOT NULL,
    descripcion VARCHAR(255),
    fecha DATE NOT NULL,
    FOREIGN KEY (id_historia) REFERENCES historias_clinicas(id_historia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS tratamientos (
    id_tratamiento INT PRIMARY KEY AUTO_INCREMENT,
    id_diagnostico INT NOT NULL,
    id_medicamento INT NOT NULL,
    dosis VARCHAR(100),
    duracion_dias INT,
    estado VARCHAR(20) NOT NULL DEFAULT 'En curso',
    FOREIGN KEY (id_diagnostico) REFERENCES diagnosticos(id_diagnostico),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SELECT 'migracion_clinicas aplicada' AS resultado;
