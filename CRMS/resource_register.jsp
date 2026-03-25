<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String path    = request.getContextPath();
String _role   = (String) session.getAttribute("role");
if (_role == null || !_role.equals("admin")) {
    response.sendRedirect("dashboard.jsp?error=unauthorized"); return;
}
String username = (String) session.getAttribute("username");
String success  = request.getParameter("success");
String error    = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Register Resource – CRMS</title>
<link rel="stylesheet" href="<%=path%>/styles.css">
<style>
  .alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; font-weight:500; }
  .alert-err { background:#2b0d0d; border:1px solid #6a2d2d; color:#e57373;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; }
  .ferr      { color:#e57373; font-size:12px; margin-top:4px; display:none; }
  .ferr.show { display:block; }
  .is-invalid { border-color:#e57373 !important; }
  .del-btn { background:rgba(255,61,90,.12); color:#ff3d5a; border:1px solid rgba(255,61,90,.3);
             padding:4px 12px; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600; }
  .del-btn:hover { background:rgba(255,61,90,.25); }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>Register Resource</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (admin)</strong></div>
</header>
<main>

<%-- ── ALERTS ─────────────────────────────────────────────── --%>
<% if ("1".equals(success)) { %>
<div class="alert-ok">✅ Resource registered and saved to database successfully!</div>
<% } else if ("deleted".equals(success)) { %>
<div class="alert-ok">✅ Resource deleted from database.</div>
<% } else if ("missing_fields".equals(error)) { %>
<div class="alert-err">⚠️ Name, Type and Location are required fields.</div>
<% } else if ("db".equals(error)) { %>
<div class="alert-err">⚠️ Database error. Ensure MySQL is running and <code>fix_database.sql</code> has been executed.</div>
<% } %>

<%-- ── REGISTRATION FORM ────────────────────────────────── --%>
<div class="card">
  <h2>Add New Resource</h2>
  <form action="<%=path%>/ResourceServlet" method="post" id="rForm" novalidate>

    <div>
      <label>Resource Name <span style="color:#e57373">*</span></label>
      <input type="text" name="resource_name" id="f_name"
             placeholder="e.g. Computer Lab 3, Room 204, Projector Set…" required>
      <div class="ferr" id="e_name">Resource name is required.</div>
    </div>

    <div>
      <label>Resource Type <span style="color:#e57373">*</span></label>
      <select name="resource_type" id="f_type" required>
        <option value="">-- Select Type --</option>
        <option value="room">🏫 Classroom / Room</option>
        <option value="lab">🔬 Laboratory</option>
        <option value="equipment">🖥️ Equipment</option>
        <option value="vehicle">🚐 Vehicle</option>
        <option value="sports">🏆 Sports Facility</option>
        <option value="library">📚 Library</option>
        <option value="hostel">🏠 Hostel</option>
      </select>
      <div class="ferr" id="e_type">Please select a resource type.</div>
    </div>

    <div>
      <label>Description <span style="color:#7a8fa8; font-weight:400">(optional)</span></label>
      <textarea name="description" rows="3"
        placeholder="Brief description – capacity, features, purpose…"></textarea>
    </div>

    <div>
      <label>Location <span style="color:#e57373">*</span></label>
      <input type="text" name="location" id="f_loc"
             placeholder="e.g. Block A, Floor 2" required>
      <div class="ferr" id="e_loc">Location is required.</div>
    </div>

    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📋 Register Resource</button>
    </div>
  </form>
</div>

<%-- ── TABLE: all resources from DB ───────────────────────── --%>
<div class="card">
  <h2>Registered Resources
    <span style="font-size:12px;color:#7a8fa8;font-weight:400;margin-left:8px;">live from database</span>
  </h2>
  <div class="table-wrap">
  <table>
    <thead>
      <tr><th>ID</th><th>Name</th><th>Type</th><th>Description</th><th>Location</th><th>Added On</th><th>Action</th></tr>
    </thead>
    <tbody>
    <%
    Connection rc = null;
    try {
        rc = DBConnection.getConnection();
        PreparedStatement rps = rc.prepareStatement(
            "SELECT resource_id, resource_name, resource_type, description, location, created_at " +
            "FROM resources ORDER BY created_at DESC");
        ResultSet rrs = rps.executeQuery();
        boolean found = false;
        while (rrs.next()) {
            found = true;
            String rtype = rrs.getString("resource_type");
            String icon  = "room".equals(rtype)      ? "🏫"
                         : "lab".equals(rtype)       ? "🔬"
                         : "equipment".equals(rtype) ? "🖥️"
                         : "vehicle".equals(rtype)   ? "🚐"
                         : "sports".equals(rtype)    ? "🏆"
                         : "library".equals(rtype)   ? "📚"
                         : "hostel".equals(rtype)    ? "🏠" : "📦";
            String desc  = rrs.getString("description");
            if (desc == null || desc.trim().isEmpty()) desc = "<span style='color:#3a4f63'>—</span>";
    %>
    <tr>
      <td style="color:#7a8fa8"><%= rrs.getInt("resource_id") %></td>
      <td><strong><%= rrs.getString("resource_name") %></strong></td>
      <td><%= icon %> <%= rtype %></td>
      <td style="max-width:200px; font-size:13px; color:#7a8fa8"><%= desc %></td>
      <td><%= rrs.getString("location") %></td>
      <td style="font-size:12px; color:#7a8fa8"><%= rrs.getString("created_at") %></td>
      <td>
        <a href="<%=path%>/ResourceServlet?action=delete&id=<%= rrs.getInt("resource_id") %>"
           class="del-btn"
           onclick="return confirm('Delete this resource? This cannot be undone.')">🗑 Delete</a>
      </td>
    </tr>
    <%  }
        if (!found) { %>
    <tr>
      <td colspan="7" style="text-align:center; color:#7a8fa8; padding:28px">
        No resources registered yet. Use the form above to add one.
      </td>
    </tr>
    <%  }
        rps.close(); rc.close();
    } catch(Exception e) { %>
    <tr>
      <td colspan="7" style="text-align:center; color:#e57373; padding:28px">
        <strong>Database error:</strong> <%= e.getMessage() %><br>
        <small>Run <code>fix_database.sql</code> in MySQL first.</small>
      </td>
    </tr>
    <% } finally {
        if (rc != null) try { rc.close(); } catch(Exception ignored) {}
    } %>
    </tbody>
  </table>
  </div>
</div>

</main>
</div>
</div>
<script>
document.getElementById('rForm').addEventListener('submit', function(e) {
  let ok = true;
  const nm = document.getElementById('f_name');
  const tp = document.getElementById('f_type');
  const lc = document.getElementById('f_loc');
  [nm,tp,lc].forEach(el => el.classList.remove('is-invalid'));
  document.querySelectorAll('.ferr').forEach(el => el.classList.remove('show'));

  if (!nm.value.trim()) { nm.classList.add('is-invalid'); document.getElementById('e_name').classList.add('show'); ok=false; }
  if (!tp.value)        { tp.classList.add('is-invalid'); document.getElementById('e_type').classList.add('show'); ok=false; }
  if (!lc.value.trim()) { lc.classList.add('is-invalid'); document.getElementById('e_loc').classList.add('show');  ok=false; }
  if (!ok) { e.preventDefault(); window.scrollTo({top:0, behavior:'smooth'}); }
});
</script>
</body>
</html>
