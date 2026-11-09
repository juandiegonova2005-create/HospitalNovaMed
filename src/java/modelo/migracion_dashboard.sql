-- =====================================================================
-- Migracion: agrega la actividad "Dashboard" al menu (BD existente)
-- Ejecutar una sola vez:  mysql -uroot -p < migracion_dashboard.sql
-- =====================================================================
USE HospitalDB;

INSERT INTO actividades (nom_actividad, enlace)
SELECT 'Dashboard', 'dashboard.jsp' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE enlace = 'dashboard.jsp');

SET @id_dashboard = (SELECT id_actividad FROM actividades WHERE enlace = 'dashboard.jsp' ORDER BY id_actividad LIMIT 1);

-- El perfil Administrador (1) ve el dashboard
INSERT INTO gesActividad (id_perfil, id_actividad)
SELECT 1, @id_dashboard FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM gesActividad WHERE id_perfil = 1 AND id_actividad = @id_dashboard);

-- Si quieres que el perfil Usuario (2) tambien lo vea, descomenta:
-- INSERT INTO gesActividad (id_perfil, id_actividad)
-- SELECT 2, @id_dashboard FROM DUAL
-- WHERE NOT EXISTS (SELECT 1 FROM gesActividad WHERE id_perfil = 2 AND id_actividad = @id_dashboard);

SELECT a.id_actividad, a.nom_actividad, a.enlace
FROM actividades a
JOIN gesActividad g ON g.id_actividad = a.id_actividad
WHERE a.enlace = 'dashboard.jsp';
