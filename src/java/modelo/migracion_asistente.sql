-- =====================================================================
-- Hospital NovaMed - Asistente virtual con Retell AI
-- =====================================================================
-- Agrega los parametros del asistente a la tabla configuracion.
-- Es IDEMPOTENTE: se puede ejecutar varias veces sin perder lo que hayas
-- configurado (las filas existentes no se sobrescriben).
--
-- Uso local:
--   mysql -uroot -p --default-character-set=utf8mb4 < migracion_asistente.sql
--
-- Uso en Azure (MySQL Flexible Server):
--   mysql -h <servidor>.mysql.database.azure.com -P 3306 -u novamedadmin -p \
--     --ssl-mode=REQUIRED --default-character-set=utf8mb4 \
--     -e "source C:/ruta/al/proyecto/src/java/modelo/migracion_asistente.sql"
-- =====================================================================
USE HospitalDB;

INSERT INTO configuracion (clave, valor) VALUES
    ('retell_habilitado', '0'),
    ('retell_public_key', ''),
    ('retell_agent_id', ''),
    ('retell_voice_public_key', ''),
    ('retell_voice_agent_id', '')
ON DUPLICATE KEY UPDATE valor = valor;

SELECT clave, valor FROM configuracion
WHERE clave LIKE 'retell_%'
ORDER BY clave;
