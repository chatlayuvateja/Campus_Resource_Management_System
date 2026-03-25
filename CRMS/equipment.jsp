<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String _role = (String) session.getAttribute("role");
if (_role == null) { response.sendRedirect("login.html"); return; }
String username = (String) session.getAttribute("username");
int    userId   = (session.getAttribute("user_id") != null)
                  ? (Integer) session.getAttribute("user_id") : 0;
String path     = request.getContextPath();
String success  = request.getParameter("success");
String error    = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Equipment – CRMS</title>
<link rel="stylesheet" href="styles.css">
<style>
  .alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; font-weight:500; }
  .alert-err { background:#2b0d0d; border:1px solid #6a2d2d; color:#e57373;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; }
  .ferr      { color:#e57373; font-size:12px; margin-top:4px; display:none; }
  .ferr.show { display:block; }
  .is-invalid { border-color:#e57373 !important; }
  .badge-pending  { background:rgba(255,154,0,.18);  color:#ff9a00; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-approved { background:rgba(0,230,118,.15);  color:#00e676; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-rejected { background:rgba(255,61,90,.15);  color:#ff3d5a; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>Lab Equipment</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

<% if ("1".equals(success)) { %>
<div class="alert-ok">✅ Equipment request submitted and saved to database! Awaiting admin approval.</div>
<% } else if ("missing".equals(error)) { %>
<div class="alert-err">⚠️ All fields are required.</div>
<% } else if ("db".equals(error) || "1".equals(error)) { %>
<div class="alert-err">⚠️ Failed to submit request. Check database connection and run fix_database.sql.</div>
<% } %>

<%-- ── EQUIPMENT REQUEST FORM ──────────────────────────── --%>
<div class="card">
  <h2>Request Lab Equipment</h2>
  <form action="<%=path%>/EquipmentServlet" method="post" id="eqForm" novalidate>

    <div>
      <label>Select Equipment <span style="color:#e57373">*</span></label>
      <select name="resource_id" id="f_eq" required>
        <option value="">-- Select Equipment --</option>
        <%
        Connection eqc = null;
        try {
            eqc = DBConnection.getConnection();
            ResultSet eqr = eqc.prepareStatement(
                "SELECT resource_id, resource_name, location FROM resources " +
                "WHERE resource_type='equipment' ORDER BY resource_name").executeQuery();
            boolean hasEq = false;
            while (eqr.next()) { hasEq = true; %>
        <option value="<%= eqr.getInt("resource_id") %>">
          🖥️ <%= eqr.getString("resource_name") %> — <%= eqr.getString("location") %>
        </option>
        <% } if (!hasEq) { %>
          <option disabled>No equipment found — run fix_database.sql</option>
        <% }
           eqr.close(); eqc.close();
        } catch(Exception e) {
        %><option disabled>Error loading equipment: <%= e.getMessage() %></option><%
        } finally { if(eqc!=null) try{eqc.close();}catch(Exception ig){} } %>
      </select>
      <div class="ferr" id="e_eq">Please select an equipment item.</div>
    </div>

    <div>
      <label>Date Required <span style="color:#e57373">*</span></label>
      <input type="date" name="date" id="f_date" required>
      <div class="ferr" id="e_date">Please select a date.</div>
    </div>

    <div>
      <label>Time Required <span style="color:#e57373">*</span></label>
      <input type="time" name="time" id="f_time" required>
      <div class="ferr" id="e_time">Please select a time.</div>
    </div>

    <div>
      <label>Purpose <span style="color:#e57373">*</span></label>
      <textarea name="purpose" id="f_purpose" rows="3"
        placeholder="Lab experiment, workshop, presentation, demonstration..." required></textarea>
      <div class="ferr" id="e_purpose">Please describe the purpose.</div>
    </div>

    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📤 Submit Equipment Request</button>
    </div>
  </form>
</div>

<%-- ── MY EQUIPMENT REQUESTS TABLE ──────────────────────── --%>
<div class="card">
  <h2>My Equipment Requests
    <span style="font-size:12px;color:#7a8fa8;font-weight:400;margin-left:8px;">live from database</span>
  </h2>
  <div class="table-wrap">
  <table>
    <thead>
      <tr><th>#</th><th>Equipment</th><th>Date</th><th>Time</th><th>Purpose</th><th>Status</th><th>Submitted On</th></tr>
    </thead>
    <tbody>
    <%
    Connection etc = null;
    try {
        etc = DBConnection.getConnection();
        PreparedStatement etp = etc.prepareStatement(
            "SELECT e.request_id, r.resource_name, e.req_date, e.req_time, " +
            "       e.purpose, e.status, e.created_at " +
            "FROM   equipment_requests e " +
            "JOIN   resources r ON e.resource_id = r.resource_id " +
            "WHERE  e.user_id = ? ORDER BY e.created_at DESC");
        etp.setInt(1, userId);
        ResultSet etr = etp.executeQuery();
        boolean found = false;
        while (etr.next()) { found = true;
            String st=etr.getString("status");
            if (st == null) st = "pending";
            String bc="badge-pending";
            if("approved".equals(st)) bc="badge-approved";
            if("rejected".equals(st)) bc="badge-rejected";
    %>
    <tr>
      <td style="color:#7a8fa8"><%= etr.getInt("request_id") %></td>
      <td><strong><%= etr.getString("resource_name") %></strong></td>
      <td><%= etr.getString("req_date") %></td>
      <td><%= etr.getString("req_time") %></td>
      <td style="max-width:180px;font-size:13px"><%= etr.getString("purpose") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= etr.getString("created_at") %></td>
    </tr>
    <% } if (!found) { %>
    <tr><td colspan="7" style="text-align:center;color:#7a8fa8;padding:28px">
      No equipment requests yet. Use the form above to request equipment.
    </td></tr>
    <% } etp.close(); etc.close();
    } catch(Exception e) { %>
    <tr><td colspan="7" style="text-align:center;color:#e57373;padding:24px">
      <strong>Error:</strong> <%= e.getMessage() %><br><small>Run fix_database.sql in MySQL first.</small>
    </td></tr>
    <% } finally { if(etc!=null) try{etc.close();}catch(Exception ig){} } %>
    </tbody>
  </table>
  </div>
</div>

</main>
</div>
</div>
<script>
const today = new Date().toISOString().split('T')[0];
document.getElementById('f_date').min = today;

document.getElementById('eqForm').addEventListener('submit', function(e) {
  let ok = true;
  const eq   = document.getElementById('f_eq');
  const dt   = document.getElementById('f_date');
  const tm   = document.getElementById('f_time');
  const pur  = document.getElementById('f_purpose');
  [eq,dt,tm,pur].forEach(el => el.classList.remove('is-invalid'));
  document.querySelectorAll('.ferr').forEach(el => el.classList.remove('show'));

  if (!eq.value)  { eq.classList.add('is-invalid');  document.getElementById('e_eq').classList.add('show');      ok=false; }
  if (!dt.value)  { dt.classList.add('is-invalid');  document.getElementById('e_date').classList.add('show');    ok=false; }
  if (!tm.value)  { tm.classList.add('is-invalid');  document.getElementById('e_time').classList.add('show');    ok=false; }
  if (!pur.value.trim()) { pur.classList.add('is-invalid'); document.getElementById('e_purpose').classList.add('show'); ok=false; }
  if (!ok) { e.preventDefault(); window.scrollTo({top:0,behavior:'smooth'}); }
});
</script>
</body>
</html>
