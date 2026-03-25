<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
/* All logged-in users can raise and view their own complaints */
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
<title>Complaints – CRMS</title>
<link rel="stylesheet" href="styles.css">
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
  <h1>Complaints</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

<% if ("1".equals(success)) { %>
<div class="alert-ok">✅ Complaint submitted and saved to database successfully!</div>
<% } else if ("missing".equals(error)) { %>
<div class="alert-err">⚠️ All fields are required.</div>
<% } else if ("db".equals(error) || "1".equals(error)) { %>
<div class="alert-err">⚠️ Failed to submit complaint. Check database connection.</div>
<% } %>

<%-- ── COMPLAINT FORM ──────────────────────────────────── --%>
<div class="card">
  <h2>Raise New Complaint</h2>
  <form action="<%=path%>/ComplaintServlet" method="post" id="cForm" novalidate>

    <div>
      <label>Category <span style="color:#e57373">*</span></label>
      <select name="category" id="f_cat" required>
        <option value="">-- Select Category --</option>
        <option value="hostel">🏠 Hostel</option>
        <option value="maintenance">🔧 Maintenance</option>
        <option value="library">📚 Library</option>
        <option value="classroom">🏫 Classroom</option>
        <option value="lab">🔬 Laboratory</option>
        <option value="canteen">🍽️ Canteen</option>
        <option value="transport">🚐 Transport</option>
        <option value="sports">🏆 Sports Facility</option>
        <option value="wifi">🌐 WiFi / Network</option>
        <option value="staff">👤 Staff Behaviour</option>
        <option value="other">📋 Other</option>
      </select>
      <div class="ferr" id="e_cat">Please select a category.</div>
    </div>

    <div>
      <label>Title <span style="color:#e57373">*</span></label>
      <input type="text" name="complaint-title" id="f_title"
             placeholder="Fan not working, Water leakage, WiFi down..." required>
      <div class="ferr" id="e_title">Complaint title is required.</div>
    </div>

    <div>
      <label>Description <span style="color:#e57373">*</span>
        <small style="color:#7a8fa8;font-weight:400">(min 10 characters)</small>
      </label>
      <textarea name="complaint-desc" id="f_desc" rows="4"
        placeholder="Describe the issue in detail — exact location, since when, severity..." required></textarea>
      <div class="ferr" id="e_desc">Please describe the issue (at least 10 characters).</div>
    </div>

    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📤 Submit Complaint</button>
    </div>
  </form>
</div>

<%-- ── MY COMPLAINTS TABLE ────────────────────────────── --%>
<div class="card">
  <h2>My Complaints
    <span style="font-size:12px;color:#7a8fa8;font-weight:400;margin-left:8px;">live from database</span>
  </h2>
  <div class="table-wrap">
  <table>
    <thead>
      <tr><th>#</th><th>Title</th><th>Category</th><th>Description</th><th>Status</th><th>Submitted On</th></tr>
    </thead>
    <tbody>
    <%
    Connection cc = null;
    try {
        cc = DBConnection.getConnection();
        PreparedStatement cp = cc.prepareStatement(
            "SELECT complaint_id, title, category, description, status, created_at " +
            "FROM complaints WHERE user_id=? ORDER BY created_at DESC");
        cp.setInt(1, userId);
        ResultSet cr = cp.executeQuery();
        boolean found = false;
        while (cr.next()) { found = true;
            String st = cr.getString("status");
            if (st == null) st = "pending";
            String bc = "badge-pending";
            if("resolved".equals(st))    bc="badge-approved";
            if("in-progress".equals(st)) bc="badge-in-progress";
    %>
    <tr>
      <td style="color:#7a8fa8"><%= cr.getInt("complaint_id") %></td>
      <td><strong><%= cr.getString("title") %></strong></td>
      <td><%= cr.getString("category") %></td>
      <td style="max-width:200px;font-size:13px"><%= cr.getString("description") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= cr.getString("created_at") %></td>
    </tr>
    <% } if (!found) { %>
    <tr><td colspan="6" style="text-align:center;color:#7a8fa8;padding:28px">
      No complaints submitted yet. Use the form above to raise a complaint.
    </td></tr>
    <% } cp.close(); cc.close();
    } catch(Exception e) { %>
    <tr><td colspan="6" style="text-align:center;color:#e57373;padding:24px">
      <strong>Error:</strong> <%= e.getMessage() %><br><small>Run fix_database.sql in MySQL first.</small>
    </td></tr>
    <% } finally { if(cc!=null) try{cc.close();}catch(Exception ig){} } %>
    </tbody>
  </table>
  </div>
</div>

</main>
</div>
</div>
<script>
document.getElementById('cForm').addEventListener('submit', function(e) {
  let ok = true;
  const cat  = document.getElementById('f_cat');
  const tit  = document.getElementById('f_title');
  const desc = document.getElementById('f_desc');
  [cat,tit,desc].forEach(el => el.classList.remove('is-invalid'));
  document.querySelectorAll('.ferr').forEach(el => el.classList.remove('show'));

  if (!cat.value)  { cat.classList.add('is-invalid');  document.getElementById('e_cat').classList.add('show');   ok=false; }
  if (!tit.value.trim())  { tit.classList.add('is-invalid');  document.getElementById('e_title').classList.add('show'); ok=false; }
  if (!desc.value || desc.value.trim().length < 10)
    { desc.classList.add('is-invalid'); document.getElementById('e_desc').classList.add('show'); ok=false; }
  if (!ok) { e.preventDefault(); window.scrollTo({top:0,behavior:'smooth'}); }
});
</script>
</body>
</html>
