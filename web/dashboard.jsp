<%@page import="modelo.DashboardDAO"%>
<%@page import="modelo.Util"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private String num(int v) {
        return v < 0 ? "—" : String.valueOf(v);
    }

    private int pct(int parte, int total) {
        return (parte < 0 || total <= 0) ? 0 : (int) Math.round(parte * 100.0 / total);
    }
%>
<%
    DashboardDAO.Datos d = new DashboardDAO().cargar();

    int totalCamas = d.camasTotales < 0 ? 0 : d.camasTotales;
    int ocupadas = d.camasOcupadas < 0 ? 0 : d.camasOcupadas;
    int disponibles = d.camasDisponibles < 0 ? 0 : d.camasDisponibles;
    int mantenimiento = d.camasMantenimiento < 0 ? 0 : d.camasMantenimiento;
    int pctOcupacion = pct(ocupadas, totalCamas);

    int totalTrat = (d.tratamientosCurso < 0 ? 0 : d.tratamientosCurso)
            + (d.tratamientosFinalizados < 0 ? 0 : d.tratamientosFinalizados);
    int totalMed = d.medicamentosTotales < 0 ? 0 : d.medicamentosTotales;
    int dispMed = d.medicamentosDisponibles < 0 ? 0 : d.medicamentosDisponibles;
    int agotMed = d.medicamentosAgotados < 0 ? 0 : d.medicamentosAgotados;
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard - Hospital NovaMed</title>
<style>
    :root {
        --ink: #12263a;
        --muted: #64748b;
        --blue: #1f3a5f;
        --teal: #0f766e;
        --line: #e2e8f0;
        --soft: #f8fafc;
    }

    *, *::before, *::after { box-sizing: border-box; }

    body {
        margin: 0;
        padding: 22px;
        background: #eef2f7;
        color: var(--ink);
        font-family: "Segoe UI", Tahoma, Arial, sans-serif;
    }

    h1, h2, h3, p { margin: 0; }

    .top {
        display: flex;
        flex-wrap: wrap;
        align-items: flex-end;
        justify-content: space-between;
        gap: 14px;
        margin-bottom: 18px;
    }

    .tag {
        display: inline-block;
        background: #e0f2f1;
        color: var(--teal);
        border-radius: 999px;
        padding: 3px 12px;
        font-size: .72rem;
        font-weight: 700;
        letter-spacing: .08em;
        text-transform: uppercase;
        margin-bottom: 8px;
    }

    .top h1 { font-size: 1.75rem; color: var(--blue); }
    .top p { color: var(--muted); font-size: .9rem; margin-top: 4px; }

    .stamp {
        text-align: right;
        font-size: .75rem;
        color: var(--muted);
        line-height: 1.5;
    }
    .stamp b { color: var(--blue); font-size: .85rem; }

    .kpis {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
        gap: 14px;
        margin-bottom: 14px;
    }

    .kpi {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 16px 18px;
        box-shadow: 0 4px 14px rgba(15, 23, 42, .05);
    }

    .kpi .label {
        font-size: .76rem;
        font-weight: 700;
        letter-spacing: .05em;
        text-transform: uppercase;
        color: var(--muted);
    }

    .kpi .value {
        font-size: 2rem;
        font-weight: 700;
        color: var(--blue);
        line-height: 1.15;
        margin: 6px 0 2px;
    }

    .kpi .hint { font-size: .78rem; color: var(--muted); }

    .chips {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
        gap: 10px;
        margin-bottom: 16px;
    }

    .chip {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 10px;
        padding: 10px 12px;
    }
    .chip span { display: block; font-size: .72rem; color: var(--muted); }
    .chip b { font-size: 1.15rem; color: var(--ink); }
    .chip.alerta b { color: #b91c1c; }

    .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 14px;
        margin-bottom: 14px;
    }

    .panel {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 16px 18px;
        box-shadow: 0 4px 14px rgba(15, 23, 42, .05);
    }

    .panel h2 {
        font-size: .95rem;
        color: var(--blue);
        margin-bottom: 12px;
        padding-bottom: 8px;
        border-bottom: 1px solid var(--line);
    }

    .panel h2 small {
        color: var(--muted);
        font-weight: 400;
        font-size: .75rem;
        margin-left: 6px;
    }

    .bar-row {
        display: grid;
        grid-template-columns: 104px 1fr 46px;
        align-items: center;
        gap: 10px;
        margin-bottom: 10px;
        font-size: .8rem;
        color: var(--muted);
    }

    .bar-row b { text-align: right; color: var(--ink); font-size: .82rem; }

    .track {
        height: 10px;
        background: #eef2f7;
        border-radius: 999px;
        overflow: hidden;
    }

    .fill { height: 100%; border-radius: 999px; background: var(--teal); }
    .fill.blue { background: #2563eb; }
    .fill.red { background: #dc2626; }
    .fill.amber { background: #d97706; }

    .foot {
        display: flex;
        justify-content: space-between;
        margin-top: 12px;
        padding-top: 10px;
        border-top: 1px dashed var(--line);
        font-size: .78rem;
        color: var(--muted);
    }

    table {
        width: 100%;
        border-collapse: collapse;
        font-size: .8rem;
    }

    th {
        text-align: left;
        color: var(--muted);
        font-size: .7rem;
        letter-spacing: .05em;
        text-transform: uppercase;
        padding: 6px 8px;
        border-bottom: 1px solid var(--line);
    }

    td {
        padding: 8px;
        border-bottom: 1px solid #f1f5f9;
        color: #334155;
        vertical-align: top;
    }

    tr:last-child td { border-bottom: 0; }

    .pill {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 999px;
        background: #e0f2f1;
        color: var(--teal);
        font-weight: 700;
        font-size: .72rem;
    }

    .pill.bad { background: #fee2e2; color: #b91c1c; }
    .pill.warn { background: #fef3c7; color: #b45309; }

    .empty {
        text-align: center;
        color: var(--muted);
        font-size: .82rem;
        padding: 14px 0;
    }

    .footer {
        margin-top: 16px;
        text-align: center;
        font-size: .72rem;
        color: #94a3b8;
    }
</style>
</head>
<body>

<div class="top">
    <div>
        <span class="tag">Panel general</span>
        <h1>Dashboard</h1>
        <p>Resumen de la información registrada en Hospital NovaMed.</p>
    </div>
    <div class="stamp">
        Actualizado<br>
        <b><%= Util.esc(d.actualizado) %></b>
    </div>
</div>

<!-- KPIs principales -->
<section class="kpis">
    <div class="kpi">
        <div class="label">Pacientes registrados</div>
        <div class="value"><%= num(d.pacientes) %></div>
        <div class="hint"><%= num(d.pacientesActivos) %> activos</div>
    </div>
    <div class="kpi">
        <div class="label">Médicos activos</div>
        <div class="value"><%= num(d.medicosActivos) %></div>
        <div class="hint">de <%= num(d.medicosTotales) %> registrados</div>
    </div>
    <div class="kpi">
        <div class="label">Hospitalizaciones activas</div>
        <div class="value"><%= num(d.hospitalizados) %></div>
        <div class="hint"><%= num(ocupadas) %> camas ocupadas</div>
    </div>
    <div class="kpi">
        <div class="label">Ocupación de camas</div>
        <div class="value"><%= totalCamas == 0 ? "0" : (pctOcupacion + "%") %></div>
        <div class="hint"><%= num(ocupadas) %> de <%= num(totalCamas) %> camas</div>
    </div>
</section>

<!-- Datos complementarios -->
<section class="chips">
    <div class="chip"><span>Historias clínicas</span><b><%= num(d.historias) %></b></div>
    <div class="chip"><span>Diagnósticos</span><b><%= num(d.diagnosticos) %></b></div>
    <div class="chip"><span>Tratamientos en curso</span><b><%= num(d.tratamientosCurso) %></b></div>
    <div class="chip"><span>Medicamentos disponibles</span><b><%= num(dispMed) %></b></div>
    <div class="chip alerta"><span>Stock crítico</span><b><%= num(d.stockCritico) %></b></div>
    <div class="chip"><span>Eventos hoy</span><b><%= num(d.eventosHoy) %></b></div>
</section>

<div class="grid">
    <!-- Camas -->
    <div class="panel">
        <h2>Ocupación de camas <small>total: <%= num(totalCamas) %></small></h2>

        <div class="bar-row">
            <span>Ocupadas</span>
            <div class="track"><div class="fill red" style="width:<%= pct(ocupadas, totalCamas) + "%" %>"></div></div>
            <b><%= num(ocupadas) %></b>
        </div>
        <div class="bar-row">
            <span>Disponibles</span>
            <div class="track"><div class="fill" style="width:<%= pct(disponibles, totalCamas) + "%" %>"></div></div>
            <b><%= num(disponibles) %></b>
        </div>
        <div class="bar-row">
            <span>Mantenimiento</span>
            <div class="track"><div class="fill amber" style="width:<%= pct(mantenimiento, totalCamas) + "%" %>"></div></div>
            <b><%= num(mantenimiento) %></b>
        </div>

        <div class="foot">
            <span>Ocupación actual</span>
            <strong><%= totalCamas == 0 ? "0" : (pctOcupacion + "%") %></strong>
        </div>
    </div>

    <!-- Tratamientos y medicamentos -->
    <div class="panel">
        <h2>Tratamientos <small>total: <%= num(totalTrat) %></small></h2>

        <div class="bar-row">
            <span>En curso</span>
            <div class="track"><div class="fill blue" style="width:<%= pct(d.tratamientosCurso, totalTrat) + "%" %>"></div></div>
            <b><%= num(d.tratamientosCurso) %></b>
        </div>
        <div class="bar-row">
            <span>Finalizados</span>
            <div class="track"><div class="fill" style="width:<%= pct(d.tratamientosFinalizados, totalTrat) + "%" %>"></div></div>
            <b><%= num(d.tratamientosFinalizados) %></b>
        </div>

        <h2 style="margin-top:18px">Medicamentos <small>total: <%= num(totalMed) %></small></h2>

        <div class="bar-row">
            <span>Disponibles</span>
            <div class="track"><div class="fill" style="width:<%= pct(dispMed, totalMed) + "%" %>"></div></div>
            <b><%= num(dispMed) %></b>
        </div>
        <div class="bar-row">
            <span>Agotados</span>
            <div class="track"><div class="fill red" style="width:<%= pct(agotMed, totalMed) + "%" %>"></div></div>
            <b><%= num(agotMed) %></b>
        </div>

        <div class="foot">
            <span>Inventario de insumos</span>
            <strong><%= num(d.inventario) %> ítems</strong>
        </div>
    </div>
</div>

<div class="grid">
    <!-- Stock crítico -->
    <div class="panel">
        <h2>Stock crítico <small>stock ≤ 5 o agotado</small></h2>
        <%
            List<String[]> stock = d.stock;
            if (stock.isEmpty()) {
        %>
        <p class="empty">Sin medicamentos en nivel crítico.</p>
        <%
            } else {
        %>
        <table>
            <tr><th>Medicamento</th><th>Stock</th><th>Estado</th></tr>
            <%
                for (String[] f : stock) {
                    boolean agotado = "Agotado".equalsIgnoreCase(f[2]) || "0".equals(f[1]);
            %>
            <tr>
                <td><%= Util.esc(f[0]) %></td>
                <td><%= Util.esc(f[1]) %></td>
                <td><span class="pill <%= agotado ? "bad" : "warn" %>"><%= Util.esc(f[2]) %></span></td>
            </tr>
            <%
                }
            %>
        </table>
        <%
            }
        %>
    </div>

    <!-- Hospitalizaciones activas -->
    <div class="panel">
        <h2>Hospitalizaciones activas <small>últimas 5</small></h2>
        <%
            List<String[]> hos = d.hospitalizaciones;
            if (hos.isEmpty()) {
        %>
        <p class="empty">No hay pacientes hospitalizados.</p>
        <%
            } else {
        %>
        <table>
            <tr><th>Paciente</th><th>Cama</th><th>Médico</th><th>Ingreso</th></tr>
            <%
                for (String[] f : hos) {
            %>
            <tr>
                <td><%= Util.esc(f[0]) %></td>
                <td><%= Util.esc(f[1]) %></td>
                <td><%= Util.esc(f[2]) %></td>
                <td><%= Util.esc(f[3]) %></td>
            </tr>
            <%
                }
            %>
        </table>
        <%
            }
        %>
    </div>
</div>

<!-- Actividad reciente -->
<div class="panel">
    <h2>Actividad reciente <small>últimos 8 eventos de auditoría</small></h2>
    <%
        List<String[]> act = d.actividad;
        if (act.isEmpty()) {
    %>
    <p class="empty">Todavía no hay eventos registrados en la bitácora.</p>
    <%
        } else {
    %>
    <table>
        <tr><th>Fecha</th><th>Usuario</th><th>Acción</th><th>Detalle</th></tr>
        <%
            for (String[] f : act) {
                boolean alerta = f[2] != null && (f[2].contains("FALLIDO") || f[2].contains("BLOQUE")
                        || f[2].contains("DENEGADO") || f[2].contains("INCORRECTA"));
        %>
        <tr>
            <td><%= Util.esc(f[0]) %></td>
            <td><%= Util.esc(f[1]) %></td>
            <td><span class="pill <%= alerta ? "bad" : "" %>"><%= Util.esc(f[2]) %></span></td>
            <td><%= Util.esc(f[3]) %></td>
        </tr>
        <%
            }
        %>
    </table>
    <%
        }
    %>
</div>

<p class="footer">Datos leídos directamente de la base HospitalDB · Hospital NovaMed</p>

</body>
</html>
