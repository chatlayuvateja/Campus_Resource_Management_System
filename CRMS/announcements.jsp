<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
/* ── All roles can view announcements; only admin/faculty can post ── */
String _role = (String) session.getAttribute("role");
if (_role == null) { response.sendRedirect("login.html"); return; }
String username    = (String) session.getAttribute("username");
String path        = request.getContextPath();
String success     = request.getParameter("success");
String error       = request.getParameter("error");
boolean canPost    = "admin".equals(_role) || "faculty".equals(_role);
int userId = (session.getAttribute("user_id") != null)
             ? (Integer) session.getAttribute("user_id") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Announcements – CRMS</title>
<link rel="stylesheet" href="styles.css">
<style>
  .alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; font-weight:500; }
  .alert-err { background:#2b0d0d; border:1px solid #6a2d2d; color:#e57373;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; }
  .ferr      { color:#e57373; font-size:12px; margin-top:4px; display:none; }
  .ferr.show { display:block; }
  .is-invalid { border-color:#e57373 !important; }
  .target-pill { display:inline-block; padding:2px 10px; border-radius:20px; font-size:12px; font-weight:600;
                 background:rgba(41,121,255,.18); color:#2979ff; }
  .del-btn { background:rgba(255,61,90,.12); color:#ff3d5a; border:1px solid rgba(255,61,90,.3);
             padding:3px 10px; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600; }
  .del-btn:hover { background:rgba(255,61,90,.25); }
  .ann-card { background:rgba(255,255,255,.04); border:1px solid rgba(255,255,255,.08);
              border-radius:10px; padding:16px 20px; margin-bottom:14px; }
  .ann-card h3 { margin:0 0 6px; font-size:15px; color:#e2e8f0; }
  .ann-card p  { margin:0 0 10px; font-size:13px; color:#a0aec0; line-height:1.6; }
  .ann-meta    { font-size:11px; color:#4a5568; }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>Announcements</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

<%-- ── ALERTS ─────────────────────────────────────────────── --%>
<% if ("1".equals(success)) { %>
<div class="alert-ok">📢 Announcement posted and saved to database successfully!</div>
<% } else if ("deleted".equals(success)) { %>
<div class="alert-ok">✅ Announcement deleted.</div>
<% } else if ("missing".equals(error)) { %>
<div class="alert-err">⚠️ Title and Message are required fields.</div>
<% } else if ("db".equals(error)) { %>
<div class="alert-err">⚠️ Database error. Run <code>fix_database.sql</code> in MySQL first.</div>
<% } %>

<%-- ── POST FORM (admin & faculty only) ─────────────────── --%>
<% if (canPost) { %>
<div class="card">
  <h2>Create New Announcement</h2>
  <form action="<%= path %>/AnnouncementServlet" method="post" id="aForm" novalidate>

    <div>
      <label>Title <span style="color:#e57373">*</span></label>
      <input type="text" name="ann-title" id="f_title"
             placeholder="e.g. Mid-term Examination Schedule, Lab Closure Notice…" required>
      <div class="ferr" id="e_title">Announcement title is required.</div>
    </div>

    <div>
      <label>Target Audience</label>
      <select name="ann-target">
        <option value="all">👥 All Users</option>
        <option value="student">🎓 Students Only</option>
        <option value="faculty">👩‍🏫 Faculty Only</option>
        <option value="warden">🏠 Wardens</option>
        <option value="librarian">📚 Librarians</option>
        <option value="labtech">🔬 Lab Technicians</option>
      </select>
    </div>

    <div>
      <label>Message <span style="color:#e57373">*</span></label>
      <textarea name="ann-body" id="f_body" rows="4"
        placeholder="Write the full announcement message here…" required></textarea>
      <div class="ferr" id="e_body">Message cannot be empty.</div>
    </div>

    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📢 Post Announcement</button>
    </div>
  </form>
</div>
<% } %>

<%-- ── RECENT ANNOUNCEMENTS TABLE (all roles) ────────────── --%>
<div class="card">
  <h2>Recent Announcements
    <span style="font-size:12px;color:#7a8fa8;font-weight:400;margin-left:8px;">live from database</span>
  </h2>
  <div class="table-wrap">
  <table>
    <thead>
      <tr>
        <th>#</th><th>Title</th><th>Message</th><th>Target</th>
        <th>Posted By</th><th>Date &amp; Time</th>
        <% if ("admin".equals(_role)) { %><th>Action</th><% } %>
      </tr>
    </thead>
    <tbody>
    <%
    Connection ac = null;
    try {
        ac = DBConnection.getConnection();
        /* Show only announcements targeted to this role or 'all' */
        PreparedStatement aps = ac.prepareStatement(
            "SELECT a.ann_id, a.title, a.message, a.target_role, u.username, a.created_at " +
            "FROM   announcements a " +
            "JOIN   users u ON a.user_id = u.user_id " +
            "WHERE  a.target_role = 'all' OR a.target_role = ? " +
            "ORDER  BY a.created_at DESC");
        aps.setString(1, _role);
        /* Admin sees everything */
        if ("admin".equals(_role)) {
            aps.close();
            aps = ac.prepareStatement(
                "SELECT a.ann_id, a.title, a.message, a.target_role, u.username, a.created_at " +
                "FROM   announcements a " +
                "JOIN   users u ON a.user_id = u.user_id " +
                "ORDER  BY a.created_at DESC");
        }
        ResultSet ars = aps.executeQuery();
        boolean found = false;
        while (ars.next()) {
            found = true;
            String tgt = ars.getString("target_role");
            String tgtLabel = "all".equals(tgt)       ? "👥 All"
                            : "student".equals(tgt)   ? "🎓 Students"
                            : "faculty".equals(tgt)   ? "👩‍🏫 Faculty"
                            : "warden".equals(tgt)    ? "🏠 Wardens"
                            : "librarian".equals(tgt) ? "📚 Librarians"
                            : "🔬 Lab Techs";
    %>
    <tr>
      <td style="color:#7a8fa8"><%= ars.getInt("ann_id") %></td>
      <td><strong><%= ars.getString("title") %></strong></td>
      <td style="max-width:260px; font-size:13px"><%= ars.getString("message") %></td>
      <td><span class="target-pill"><%= tgtLabel %></span></td>
      <td style="font-weight:600"><%= ars.getString("username") %></td>
      <td style="font-size:12px; color:#7a8fa8"><%= ars.getString("created_at") %></td>
      <% if ("admin".equals(_role)) { %>
      <td>
        <a href="<%= path %>/AnnouncementServlet?action=delete&id=<%= ars.getInt("ann_id") %>"
           class="del-btn"
           onclick="return confirm('Delete this announcement?')">🗑</a>
      </td>
      <% } %>
    </tr>
    <%  }
        if (!found) { %>
    <tr>
      <td colspan="<%= "admin".equals(_role) ? 7 : 6 %>"
          style="text-align:center; color:#7a8fa8; padding:28px">
        No announcements yet.<%= canPost ? " Use the form above to post one." : "" %>
      </td>
    </tr>
    <%  }
        aps.close(); ac.close();
    } catch(Exception e) { %>
    <tr>
      <td colspan="7" style="text-align:center; color:#e57373; padding:24px">
        <strong>Database error:</strong> <%= e.getMessage() %><br>
        <small>Run <code>fix_database.sql</code> in MySQL first.</small>
      </td>
    </tr>
    <% } finally {
        if (ac != null) try { ac.close(); } catch(Exception ignored) {}
    } %>
    </tbody>
  </table>
  </div>
</div>

</main>
</div>
</div>
<% if (canPost) { %>
<script>
document.getElementById('aForm').addEventListener('submit', function(e) {
  let ok = true;
  const t = document.getElementById('f_title');
  const b = document.getElementById('f_body');
  [t,b].forEach(el => el.classList.remove('is-invalid'));
  document.querySelectorAll('.ferr').forEach(el => el.classList.remove('show'));

  if (!t.value.trim()) { t.classList.add('is-invalid'); document.getElementById('e_title').classList.add('show'); ok=false; }
  if (!b.value.trim()) { b.classList.add('is-invalid'); document.getElementById('e_body').classList.add('show');  ok=false; }
  if (!ok) { e.preventDefault(); window.scrollTo({top:0, behavior:'smooth'}); }
});
</script>
<% } %>
</body>
</html>
