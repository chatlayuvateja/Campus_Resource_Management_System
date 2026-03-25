<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
/* ── Allow ALL logged-in roles ── */
String _role = (String) session.getAttribute("role");
if (_role == null) { response.sendRedirect("login.html"); return; }
String username = (String) session.getAttribute("username");
String path     = request.getContextPath();
String success  = request.getParameter("success");
String error    = request.getParameter("error");
int    userId   = (session.getAttribute("user_id") != null)
                  ? (Integer) session.getAttribute("user_id") : 0;
boolean isAdmin = "admin".equals(_role);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Maintenance Request – CRMS</title>
<link rel="stylesheet" href="<%= path %>/styles.css">
<style>
  .alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; font-weight:500; }
  .alert-err { background:#2b0d0d; border:1px solid #6a2d2d; color:#e57373;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; }
  .ferr      { color:#e57373; font-size:12px; margin-top:4px; display:none; }
  .ferr.show { display:block; }
  .is-invalid { border-color:#e57373 !important; }
  .badge-pending     { background:rgba(255,154,0,.18);  color:#ff9a00; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-approved    { background:rgba(0,230,118,.15);  color:#00e676; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-in-progress { background:rgba(41,121,255,.18); color:#2979ff; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>Maintenance Request</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

<%-- ── ALERTS ─────────────────────────────────────────────── --%>
<% if ("1".equals(success)) { %>
<div class="alert-ok">✅ Maintenance request submitted and saved to database successfully!</div>
<% } else if ("deleted".equals(success)) { %>
<div class="alert-ok">✅ Record deleted.</div>
<% } else if ("missing".equals(error)) { %>
<div class="alert-err">⚠️ All fields are required. Please fill every field.</div>
<% } else if ("db".equals(error)) { %>
<div class="alert-err">⚠️ Database error. Ensure MySQL is running and <code>fix_database.sql</code> has been executed.</div>
<% } else if ("1".equals(error)) { %>
<div class="alert-err">⚠️ Failed to submit request. Please try again.</div>
<% } %>

<%-- ── FORM ──────────────────────────────────────────────── --%>
<div class="card">
  <h2>Submit Maintenance Request</h2>
  <form action="<%= path %>/MaintenanceServlet" method="post" id="mForm" novalidate>

    <div>
      <label>Select Resource <span style="color:#e57373">*</span></label>
      <select name="resource_id" id="f_res" required>
        <option value="">-- Select Resource --</option>
        <%
        Connection _c = null;
        try {
            _c = DBConnection.getConnection();
            ResultSet _r = _c.prepareStatement(
                "SELECT resource_id, resource_name, resource_type, location FROM resources ORDER BY resource_type, resource_name"
            ).executeQuery();
            String lastType = "";
            while (_r.next()) {
                String rtype = _r.getString("resource_type");
                if (!rtype.equals(lastType)) {
                    if (!lastType.isEmpty()) out.print("</optgroup>");
                    String lbl = "room".equals(rtype)      ? "🏫 Rooms & Halls"
                               : "lab".equals(rtype)       ? "🔬 Laboratories"
                               : "equipment".equals(rtype) ? "🖥️ Equipment"
                               : "sports".equals(rtype)    ? "🏆 Sports"
                               : "library".equals(rtype)   ? "📚 Library"
                               : "hostel".equals(rtype)    ? "🏠 Hostel" : "📦 Other";
                    out.print("<optgroup label=\"" + lbl + "\">");
                    lastType = rtype;
                }
        %>
          <option value="<%= _r.getInt("resource_id") %>">
            <%= _r.getString("resource_name") %> — <%= _r.getString("location") %>
          </option>
        <% }
           if (!lastType.isEmpty()) out.print("</optgroup>");
           _c.close();
        } catch(Exception _e) { %>
          <option disabled>Error loading resources — run fix_database.sql</option>
        <% } finally { if(_c!=null) try{_c.close();}catch(Exception ig){} } %>
      </select>
      <div class="ferr" id="e_res">Please select a resource.</div>
    </div>

    <div>
      <label>Issue Type <span style="color:#e57373">*</span></label>
      <select name="issue_type" id="f_type" required>
        <option value="">-- Select Issue Type --</option>
        <option value="Electrical">⚡ Electrical</option>
        <option value="Mechanical">🔩 Mechanical</option>
        <option value="Software">💻 Software</option>
        <option value="Cleaning">🧹 Cleaning</option>
        <option value="Plumbing">🚿 Plumbing</option>
        <option value="Furniture">🪑 Furniture</option>
        <option value="Network">🌐 Network / Internet</option>
        <option value="Other">📋 Other</option>
      </select>
      <div class="ferr" id="e_type">Please select an issue type.</div>
    </div>

    <div>
      <label>Description <span style="color:#e57373">*</span>
        <small style="color:#7a8fa8; font-weight:400">(min 10 characters)</small>
      </label>
      <textarea name="description" id="f_desc" rows="4"
        placeholder="Describe the issue in detail – what is broken, exact location, since when..."
        required></textarea>
      <div class="ferr" id="e_desc">Please enter at least 10 characters.</div>
    </div>

    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📤 Submit Maintenance Request</button>
    </div>
  </form>
</div>

<%-- ── TABLE: My requests (all users) / All requests (admin) ─── --%>
<div class="card">
  <h2><%= isAdmin ? "All Maintenance Requests" : "My Maintenance Requests" %>
    <span style="font-size:12px;color:#7a8fa8;font-weight:400;margin-left:8px;">live from database</span>
  </h2>
  <div class="table-wrap">
  <table>
    <thead>
      <tr>
        <th>#</th>
        <% if (isAdmin) { %><th>Submitted By</th><% } %>
        <th>Resource</th><th>Issue Type</th>
        <th>Description</th><th>Status</th><th>Submitted On</th>
        <% if (isAdmin) { %><th>Action</th><% } %>
      </tr>
    </thead>
    <tbody>
    <%
    Connection tc = null;
    try {
        tc = DBConnection.getConnection();
        PreparedStatement tps;
        if (isAdmin) {
            tps = tc.prepareStatement(
                "SELECT m.request_id, u.username, r.resource_name, m.issue_title, " +
                "       m.description, m.status, m.created_at " +
                "FROM   maintenance_requests m " +
                "JOIN   resources r ON m.resource_id = r.resource_id " +
                "JOIN   users u     ON m.user_id = u.user_id " +
                "ORDER  BY m.created_at DESC");
        } else {
            tps = tc.prepareStatement(
                "SELECT m.request_id, NULL AS username, r.resource_name, m.issue_title, " +
                "       m.description, m.status, m.created_at " +
                "FROM   maintenance_requests m " +
                "JOIN   resources r ON m.resource_id = r.resource_id " +
                "WHERE  m.user_id = ? " +
                "ORDER  BY m.created_at DESC");
            tps.setInt(1, userId);
        }
        ResultSet trs = tps.executeQuery();
        boolean found = false;
        while (trs.next()) {
            found = true;
            String st = trs.getString("status");
            if (st == null) st = "pending";
            String bc = "badge-pending";
            if ("resolved".equals(st))    bc = "badge-approved";
            if ("in-progress".equals(st)) bc = "badge-in-progress";
    %>
    <tr>
      <td style="color:#7a8fa8"><%= trs.getInt("request_id") %></td>
      <% if (isAdmin) { %><td><strong><%= trs.getString("username") %></strong></td><% } %>
      <td><strong><%= trs.getString("resource_name") %></strong></td>
      <td><%= trs.getString("issue_title") != null ? trs.getString("issue_title") : "—" %></td>
      <td style="max-width:220px; font-size:13px"><%= trs.getString("description") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px; color:#7a8fa8"><%= trs.getString("created_at") %></td>
      <% if (isAdmin) { %>
      <td>
        <button class="btn-secondary" style="font-size:12px;padding:4px 10px;"
          onclick="location.href='<%= path %>/MaintenanceServlet?id=<%= trs.getInt("request_id") %>&status=in-progress'">
          In Progress
        </button>
        <button class="btn-primary" style="font-size:12px;padding:4px 10px;margin-left:4px;"
          onclick="location.href='<%= path %>/MaintenanceServlet?id=<%= trs.getInt("request_id") %>&status=resolved'">
          Resolve
        </button>
      </td>
      <% } %>
    </tr>
    <% }
       if (!found) { %>
    <tr>
      <td colspan="<%= isAdmin ? 8 : 6 %>" style="text-align:center; color:#7a8fa8; padding:28px">
        <%= isAdmin ? "No maintenance requests submitted yet." : "No maintenance requests submitted yet. Use the form above to report an issue." %>
      </td>
    </tr>
    <% }
       tps.close(); tc.close();
    } catch(Exception e) { %>
    <tr>
      <td colspan="<%= isAdmin ? 8 : 6 %>" style="text-align:center; color:#e57373; padding:24px">
        <strong>Database error:</strong> <%= e.getMessage() %><br>
        <small>Run <code>fix_database.sql</code> in MySQL first.</small>
      </td>
    </tr>
    <% } finally {
        if (tc != null) try { tc.close(); } catch(Exception ignored){}
    } %>
    </tbody>
  </table>
  </div>
</div>

</main>
</div>
</div>
<script>
document.getElementById('mForm').addEventListener('submit', function(e) {
  let ok = true;
  const res  = document.getElementById('f_res');
  const type = document.getElementById('f_type');
  const desc = document.getElementById('f_desc');
  [res,type,desc].forEach(el => { el.classList.remove('is-invalid'); });
  document.querySelectorAll('.ferr').forEach(el => el.classList.remove('show'));

  if (!res.value)  { res.classList.add('is-invalid');  document.getElementById('e_res').classList.add('show');  ok=false; }
  if (!type.value) { type.classList.add('is-invalid'); document.getElementById('e_type').classList.add('show'); ok=false; }
  if (!desc.value || desc.value.trim().length < 10)
                   { desc.classList.add('is-invalid'); document.getElementById('e_desc').classList.add('show'); ok=false; }
  if (!ok) { e.preventDefault(); window.scrollTo({top:0,behavior:'smooth'}); }
});
</script>
</body>
</html>
