<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("admin")) {
    response.sendRedirect("dashboard.jsp"); return;
}
String username = (String) session.getAttribute("username");
String path     = request.getContextPath();
String tab      = request.getParameter("tab");
if (tab == null) tab = "complaints";
String updated  = request.getParameter("updated");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin Panel – CRMS</title>
<link rel="stylesheet" href="styles.css">
<style>
  .alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
               padding:11px 18px; border-radius:8px; margin-bottom:16px; font-weight:500; }
  .badge-pending     { background:rgba(255,154,0,.18);  color:#ff9a00; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-approved    { background:rgba(0,230,118,.15);  color:#00e676; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-rejected    { background:rgba(255,61,90,.15);  color:#ff3d5a; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-in-progress { background:rgba(41,121,255,.18); color:#2979ff; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .action-btn { padding:4px 12px; border-radius:6px; cursor:pointer; font-size:12px; font-weight:600; border:none; }
  .btn-approve  { background:rgba(0,230,118,.15);  color:#00e676; border:1px solid rgba(0,230,118,.3); }
  .btn-reject   { background:rgba(255,61,90,.12);  color:#ff3d5a; border:1px solid rgba(255,61,90,.3); }
  .btn-progress { background:rgba(41,121,255,.15); color:#2979ff; border:1px solid rgba(41,121,255,.3); }
  .btn-resolve  { background:rgba(0,230,118,.15);  color:#00e676; border:1px solid rgba(0,230,118,.3); }
  .action-btn:hover { opacity:.8; }
  .empty-row td { text-align:center; color:#7a8fa8; padding:28px; }
  .err-row  td  { text-align:center; color:#e57373; padding:24px; }
  .target-pill  { display:inline-block; padding:2px 10px; border-radius:20px; font-size:12px; font-weight:600;
                  background:rgba(41,121,255,.18); color:#2979ff; }
  .tabs { flex-wrap:wrap; gap:6px; }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>Admin Panel</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (admin)</strong></div>
</header>
<main>

<% if ("1".equals(updated)) { %>
<div class="alert-ok">✅ Status updated successfully.</div>
<% } %>

<%-- ══════════════ TAB NAVIGATION ══════════════ --%>
<div class="tabs">
  <button class="tab-btn <%= "complaints".equals(tab)    ? "active":"" %>" onclick="location.href='admin.jsp?tab=complaints'">📋 Complaints</button>
  <button class="tab-btn <%= "maintenance".equals(tab)   ? "active":"" %>" onclick="location.href='admin.jsp?tab=maintenance'">🔧 Maintenance</button>
  <button class="tab-btn <%= "announcements".equals(tab) ? "active":"" %>" onclick="location.href='admin.jsp?tab=announcements'">📢 Announcements</button>
  <button class="tab-btn <%= "notifications".equals(tab) ? "active":"" %>" onclick="location.href='admin.jsp?tab=notifications'">🔔 Notifications</button>
  <button class="tab-btn <%= "resources".equals(tab)     ? "active":"" %>" onclick="location.href='admin.jsp?tab=resources'">🏫 Resources</button>
  <button class="tab-btn <%= "bookings".equals(tab)      ? "active":"" %>" onclick="location.href='admin.jsp?tab=bookings'">📅 Room Bookings</button>
  <button class="tab-btn <%= "equipment".equals(tab)     ? "active":"" %>" onclick="location.href='admin.jsp?tab=equipment'">🖥️ Equipment</button>
  <button class="tab-btn <%= "users".equals(tab)         ? "active":"" %>" onclick="location.href='admin.jsp?tab=users'">👤 Users</button>
  <button class="tab-btn <%= "library".equals(tab)       ? "active":"" %>" onclick="location.href='admin.jsp?tab=library'">📚 Library</button>
</div>

<%-- ══════════════ COMPLAINTS ══════════════ --%>
<% if ("complaints".equals(tab)) { %>
<div class="card">
  <h2>All Complaints</h2>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>User</th><th>Category</th><th>Title</th><th>Description</th><th>Status</th><th>Date</th><th>Action</th></tr></thead>
    <tbody>
    <%
    Connection c1 = null;
    try {
        c1 = DBConnection.getConnection();
        ResultSet r1 = c1.prepareStatement(
            "SELECT c.complaint_id, u.username, c.category, c.title, c.description, c.status, c.created_at " +
            "FROM complaints c JOIN users u ON c.user_id=u.user_id ORDER BY c.created_at DESC").executeQuery();
        boolean f1 = false;
        while (r1.next()) { f1=true;
            String st=r1.getString("status"); if(st==null)st="pending";
            String bc="badge-pending";
            if("resolved".equals(st))    bc="badge-approved";
            if("in-progress".equals(st)) bc="badge-in-progress"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r1.getInt("complaint_id") %></td>
      <td><strong><%= r1.getString("username") %></strong></td>
      <td><%= r1.getString("category") %></td>
      <td><%= r1.getString("title") %></td>
      <td style="max-width:200px;font-size:13px"><%= r1.getString("description") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= r1.getString("created_at") %></td>
      <td>
        <button class="action-btn btn-progress" onclick="location.href='ComplaintServlet?id=<%= r1.getInt("complaint_id") %>&status=in-progress'">In Progress</button>
        <button class="action-btn btn-resolve"  onclick="location.href='ComplaintServlet?id=<%= r1.getInt("complaint_id") %>&status=resolved'">Resolve</button>
      </td>
    </tr>
    <% } if (!f1) { %><tr class="empty-row"><td colspan="8">No complaints submitted yet.</td></tr>
    <% } c1.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="8">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(c1!=null) try{c1.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ MAINTENANCE ══════════════ --%>
<% if ("maintenance".equals(tab)) { %>
<div class="card">
  <h2>All Maintenance Requests</h2>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>User</th><th>Resource</th><th>Issue Type</th><th>Description</th><th>Status</th><th>Submitted</th><th>Action</th></tr></thead>
    <tbody>
    <%
    Connection c2 = null;
    try {
        c2 = DBConnection.getConnection();
        ResultSet r2 = c2.prepareStatement(
            "SELECT m.request_id, u.username, r.resource_name, m.issue_title, " +
            "       m.description, m.status, m.created_at " +
            "FROM   maintenance_requests m " +
            "JOIN   resources r ON m.resource_id = r.resource_id " +
            "JOIN   users u     ON m.user_id      = u.user_id " +
            "ORDER  BY m.created_at DESC").executeQuery();
        boolean f2 = false;
        while (r2.next()) { f2=true;
            String st=r2.getString("status"); if(st==null)st="pending";
            String bc="badge-pending";
            if("resolved".equals(st))    bc="badge-approved";
            if("in-progress".equals(st)) bc="badge-in-progress"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r2.getInt("request_id") %></td>
      <td><strong><%= r2.getString("username") %></strong></td>
      <td><%= r2.getString("resource_name") %></td>
      <td><%= r2.getString("issue_title") != null ? r2.getString("issue_title") : "—" %></td>
      <td style="max-width:200px;font-size:13px"><%= r2.getString("description") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= r2.getString("created_at") %></td>
      <td>
        <button class="action-btn btn-progress" onclick="location.href='MaintenanceServlet?id=<%= r2.getInt("request_id") %>&status=in-progress'">In Progress</button>
        <button class="action-btn btn-resolve"  onclick="location.href='MaintenanceServlet?id=<%= r2.getInt("request_id") %>&status=resolved'">Resolve</button>
      </td>
    </tr>
    <% } if (!f2) { %><tr class="empty-row"><td colspan="8">No maintenance requests yet.</td></tr>
    <% } c2.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="8">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(c2!=null) try{c2.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ ANNOUNCEMENTS ══════════════ --%>
<% if ("announcements".equals(tab)) { %>
<div class="card">
  <h2>All Announcements</h2>
  <div style="margin-bottom:14px">
    <a href="<%=path%>/announcements.jsp" class="btn-primary"
       style="padding:7px 16px;border-radius:8px;font-size:13px;font-weight:600;display:inline-block;">
      + Post New Announcement
    </a>
  </div>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>Title</th><th>Message</th><th>Target</th><th>Posted By</th><th>Date</th><th>Delete</th></tr></thead>
    <tbody>
    <%
    Connection c3 = null;
    try {
        c3 = DBConnection.getConnection();
        ResultSet r3 = c3.prepareStatement(
            "SELECT a.ann_id, a.title, a.message, a.target_role, u.username, a.created_at " +
            "FROM   announcements a JOIN users u ON a.user_id=u.user_id " +
            "ORDER  BY a.created_at DESC").executeQuery();
        boolean f3 = false;
        while (r3.next()) { f3=true;
            String tgt=r3.getString("target_role");
            String tl="all".equals(tgt)?"👥 All":"student".equals(tgt)?"🎓 Students"
                     :"faculty".equals(tgt)?"👩‍🏫 Faculty":"warden".equals(tgt)?"🏠 Wardens"
                     :"librarian".equals(tgt)?"📚 Librarians":"🔬 Lab Techs"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r3.getInt("ann_id") %></td>
      <td><strong><%= r3.getString("title") %></strong></td>
      <td style="max-width:260px;font-size:13px"><%= r3.getString("message") %></td>
      <td><span class="target-pill"><%= tl %></span></td>
      <td style="font-weight:600"><%= r3.getString("username") %></td>
      <td style="font-size:12px;color:#7a8fa8"><%= r3.getString("created_at") %></td>
      <td>
        <a href="<%=path%>/AnnouncementServlet?action=delete&id=<%= r3.getInt("ann_id") %>"
           class="action-btn btn-reject"
           onclick="return confirm('Delete this announcement?')">🗑 Delete</a>
      </td>
    </tr>
    <% } if (!f3) { %><tr class="empty-row"><td colspan="7">No announcements posted yet.</td></tr>
    <% } c3.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="7">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(c3!=null) try{c3.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ NOTIFICATIONS (all user activity) ══════════════ --%>
<% if ("notifications".equals(tab)) { %>
<div class="card">
  <h2>All User Notifications &amp; Activity</h2>
  <p style="color:#7a8fa8;font-size:13px;margin-bottom:16px">
    Overview of all bookings, equipment requests, complaints, and maintenance requests across all users.
  </p>

  <h3 style="color:#a0aec0;margin-bottom:10px;font-size:14px">📅 Recent Bookings</h3>
  <div class="table-wrap" style="margin-bottom:24px"><table>
    <thead><tr><th>User</th><th>Resource</th><th>Start</th><th>End</th><th>Purpose</th><th>Status</th><th>Submitted</th></tr></thead>
    <tbody>
    <%
    Connection cn1 = null;
    try {
        cn1 = DBConnection.getConnection();
        ResultSet rn1 = cn1.prepareStatement(
            "SELECT u.username, r.resource_name, b.start_time, b.end_time, b.purpose, b.status, b.created_at " +
            "FROM bookings b JOIN users u ON b.user_id=u.user_id JOIN resources r ON b.resource_id=r.resource_id " +
            "ORDER BY b.created_at DESC LIMIT 20").executeQuery();
        boolean fn1=false;
        while(rn1.next()){ fn1=true;
            String st=rn1.getString("status"); if(st==null)st="pending";
            String bc="badge-pending"; if("approved".equals(st))bc="badge-approved"; if("rejected".equals(st))bc="badge-rejected"; %>
    <tr>
      <td><strong><%= rn1.getString("username") %></strong></td>
      <td><%= rn1.getString("resource_name") %></td>
      <td style="font-size:13px"><%= rn1.getString("start_time") %></td>
      <td style="font-size:13px"><%= rn1.getString("end_time") %></td>
      <td style="max-width:160px;font-size:13px"><%= rn1.getString("purpose")!=null?rn1.getString("purpose"):"—" %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= rn1.getString("created_at") %></td>
    </tr>
    <% } if(!fn1){ %><tr class="empty-row"><td colspan="7">No bookings yet.</td></tr>
    <% } cn1.close();
    } catch(Exception e){ %><tr class="err-row"><td colspan="7">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(cn1!=null) try{cn1.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>

  <h3 style="color:#a0aec0;margin-bottom:10px;font-size:14px">🖥️ Equipment Requests</h3>
  <div class="table-wrap" style="margin-bottom:24px"><table>
    <thead><tr><th>User</th><th>Equipment</th><th>Date</th><th>Time</th><th>Purpose</th><th>Status</th><th>Submitted</th></tr></thead>
    <tbody>
    <%
    Connection cn2 = null;
    try {
        cn2 = DBConnection.getConnection();
        ResultSet rn2 = cn2.prepareStatement(
            "SELECT u.username, r.resource_name, e.req_date, e.req_time, e.purpose, e.status, e.created_at " +
            "FROM equipment_requests e JOIN users u ON e.user_id=u.user_id JOIN resources r ON e.resource_id=r.resource_id " +
            "ORDER BY e.created_at DESC LIMIT 20").executeQuery();
        boolean fn2=false;
        while(rn2.next()){ fn2=true;
            String st=rn2.getString("status"); if(st==null)st="pending";
            String bc="badge-pending"; if("approved".equals(st))bc="badge-approved"; if("rejected".equals(st))bc="badge-rejected"; %>
    <tr>
      <td><strong><%= rn2.getString("username") %></strong></td>
      <td><%= rn2.getString("resource_name") %></td>
      <td><%= rn2.getString("req_date") %></td>
      <td><%= rn2.getString("req_time") %></td>
      <td style="max-width:160px;font-size:13px"><%= rn2.getString("purpose") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= rn2.getString("created_at") %></td>
    </tr>
    <% } if(!fn2){ %><tr class="empty-row"><td colspan="7">No equipment requests yet.</td></tr>
    <% } cn2.close();
    } catch(Exception e){ %><tr class="err-row"><td colspan="7">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(cn2!=null) try{cn2.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>

  <h3 style="color:#a0aec0;margin-bottom:10px;font-size:14px">📋 Recent Complaints</h3>
  <div class="table-wrap"><table>
    <thead><tr><th>User</th><th>Category</th><th>Title</th><th>Status</th><th>Date</th></tr></thead>
    <tbody>
    <%
    Connection cn3 = null;
    try {
        cn3 = DBConnection.getConnection();
        ResultSet rn3 = cn3.prepareStatement(
            "SELECT u.username, c.category, c.title, c.status, c.created_at " +
            "FROM complaints c JOIN users u ON c.user_id=u.user_id " +
            "ORDER BY c.created_at DESC LIMIT 20").executeQuery();
        boolean fn3=false;
        while(rn3.next()){ fn3=true;
            String st=rn3.getString("status"); if(st==null)st="pending";
            String bc="badge-pending"; if("resolved".equals(st))bc="badge-approved"; if("in-progress".equals(st))bc="badge-in-progress"; %>
    <tr>
      <td><strong><%= rn3.getString("username") %></strong></td>
      <td><%= rn3.getString("category") %></td>
      <td><%= rn3.getString("title") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= rn3.getString("created_at") %></td>
    </tr>
    <% } if(!fn3){ %><tr class="empty-row"><td colspan="5">No complaints yet.</td></tr>
    <% } cn3.close();
    } catch(Exception e){ %><tr class="err-row"><td colspan="5">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(cn3!=null) try{cn3.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ RESOURCES ══════════════ --%>
<% if ("resources".equals(tab)) { %>
<div class="card">
  <h2>All Registered Resources</h2>
  <div style="margin-bottom:14px">
    <a href="<%=path%>/resource_register.jsp" class="btn-primary"
       style="padding:7px 16px;border-radius:8px;font-size:13px;font-weight:600;display:inline-block;">
      + Register New Resource
    </a>
  </div>
  <div class="table-wrap"><table>
    <thead><tr><th>ID</th><th>Name</th><th>Type</th><th>Description</th><th>Location</th><th>Added On</th><th>Delete</th></tr></thead>
    <tbody>
    <%
    Connection c4 = null;
    try {
        c4 = DBConnection.getConnection();
        ResultSet r4 = c4.prepareStatement(
            "SELECT resource_id, resource_name, resource_type, description, location, created_at " +
            "FROM resources ORDER BY resource_type, resource_name").executeQuery();
        boolean f4 = false;
        while (r4.next()) { f4=true;
            String rtype=r4.getString("resource_type");
            String icon ="room".equals(rtype)?"🏫":"lab".equals(rtype)?"🔬":"equipment".equals(rtype)?"🖥️"
                        :"vehicle".equals(rtype)?"🚐":"sports".equals(rtype)?"🏆":"library".equals(rtype)?"📚":"hostel".equals(rtype)?"🏠":"📦";
            String desc =r4.getString("description");
            if(desc==null||desc.trim().isEmpty()) desc="<span style='color:#3a4f63'>—</span>"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r4.getInt("resource_id") %></td>
      <td><strong><%= r4.getString("resource_name") %></strong></td>
      <td><%= icon %> <%= rtype %></td>
      <td style="max-width:180px;font-size:13px;color:#7a8fa8"><%= desc %></td>
      <td><%= r4.getString("location") %></td>
      <td style="font-size:12px;color:#7a8fa8"><%= r4.getString("created_at") %></td>
      <td>
        <a href="<%=path%>/ResourceServlet?action=delete&id=<%= r4.getInt("resource_id") %>"
           class="action-btn btn-reject"
           onclick="return confirm('Delete this resource?')">🗑 Delete</a>
      </td>
    </tr>
    <% } if (!f4) { %><tr class="empty-row"><td colspan="7">No resources registered yet. <a href="resource_register.jsp">Add one →</a></td></tr>
    <% } c4.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="7">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(c4!=null) try{c4.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ ROOM BOOKINGS ══════════════ --%>
<% if ("bookings".equals(tab)) { %>
<div class="card">
  <h2>Room / Lab Bookings</h2>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>User</th><th>Resource</th><th>Start</th><th>End</th><th>Purpose</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
    <%
    Connection c5 = null;
    try {
        c5 = DBConnection.getConnection();
        ResultSet r5 = c5.prepareStatement(
            "SELECT b.booking_id, u.username, r.resource_name, b.start_time, b.end_time, b.purpose, b.status " +
            "FROM bookings b JOIN users u ON b.user_id=u.user_id JOIN resources r ON b.resource_id=r.resource_id " +
            "ORDER BY b.created_at DESC").executeQuery();
        boolean f5=false;
        while (r5.next()) { f5=true;
            String st=r5.getString("status"); if(st==null)st="pending";
            String bc="badge-pending";
            if("approved".equals(st)) bc="badge-approved";
            if("rejected".equals(st)) bc="badge-rejected"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r5.getInt("booking_id") %></td>
      <td><strong><%= r5.getString("username") %></strong></td>
      <td><%= r5.getString("resource_name") %></td>
      <td style="font-size:13px"><%= r5.getString("start_time") %></td>
      <td style="font-size:13px"><%= r5.getString("end_time") %></td>
      <td style="max-width:160px;font-size:13px"><%= r5.getString("purpose")!=null?r5.getString("purpose"):"—" %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td>
        <button class="action-btn btn-approve" onclick="location.href='BookingServlet?id=<%= r5.getInt("booking_id") %>&status=approved'">Approve</button>
        <button class="action-btn btn-reject"  onclick="location.href='BookingServlet?id=<%= r5.getInt("booking_id") %>&status=rejected'">Reject</button>
      </td>
    </tr>
    <% } if (!f5) { %><tr class="empty-row"><td colspan="8">No bookings yet.</td></tr>
    <% } c5.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="8">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(c5!=null) try{c5.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ EQUIPMENT REQUESTS ══════════════ --%>
<% if ("equipment".equals(tab)) { %>
<div class="card">
  <h2>Equipment Requests</h2>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>User</th><th>Equipment</th><th>Date</th><th>Time</th><th>Purpose</th><th>Status</th><th>Submitted</th><th>Action</th></tr></thead>
    <tbody>
    <%
    Connection c6 = null;
    try {
        c6 = DBConnection.getConnection();
        ResultSet r6 = c6.prepareStatement(
            "SELECT e.request_id, u.username, r.resource_name, e.req_date, e.req_time, e.purpose, e.status, e.created_at " +
            "FROM equipment_requests e " +
            "JOIN users u ON e.user_id=u.user_id JOIN resources r ON e.resource_id=r.resource_id " +
            "ORDER BY e.created_at DESC").executeQuery();
        boolean f6=false;
        while (r6.next()) { f6=true;
            String st=r6.getString("status"); if(st==null)st="pending";
            String bc="badge-pending";
            if("approved".equals(st)) bc="badge-approved";
            if("rejected".equals(st)) bc="badge-rejected"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r6.getInt("request_id") %></td>
      <td><strong><%= r6.getString("username") %></strong></td>
      <td><%= r6.getString("resource_name") %></td>
      <td><%= r6.getString("req_date") %></td>
      <td><%= r6.getString("req_time") %></td>
      <td style="max-width:160px;font-size:13px"><%= r6.getString("purpose") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= r6.getString("created_at") %></td>
      <td>
        <button class="action-btn btn-approve" onclick="location.href='EquipmentServlet?id=<%= r6.getInt("request_id") %>&status=approved'">Approve</button>
        <button class="action-btn btn-reject"  onclick="location.href='EquipmentServlet?id=<%= r6.getInt("request_id") %>&status=rejected'">Reject</button>
      </td>
    </tr>
    <% } if (!f6) { %><tr class="empty-row"><td colspan="9">No equipment requests yet.</td></tr>
    <% } c6.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="9">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(c6!=null) try{c6.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ USERS ══════════════ --%>
<% if ("users".equals(tab)) { %>
<div class="card">
  <h2>All Registered Users</h2>
  <div style="margin-bottom:14px">
    <a href="<%=path%>/register.jsp" class="btn-primary"
       style="padding:7px 16px;border-radius:8px;font-size:13px;font-weight:600;display:inline-block;">
      + Register New User
    </a>
  </div>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>Username</th><th>Full Name</th><th>Email</th><th>ID Number</th><th>Role</th><th>Joined</th></tr></thead>
    <tbody>
    <%
    Connection c7 = null;
    try {
        c7 = DBConnection.getConnection();
        ResultSet r7 = c7.prepareStatement(
            "SELECT user_id, username, full_name, email, id_number, role, created_at FROM users ORDER BY role, username").executeQuery();
        boolean f7=false;
        while (r7.next()) { f7=true;
            String ur=r7.getString("role");
            String ub="badge-pending";
            if("admin".equals(ur)) ub="badge-rejected";
            if("faculty".equals(ur)) ub="badge-in-progress"; %>
    <tr>
      <td style="color:#7a8fa8"><%= r7.getInt("user_id") %></td>
      <td><strong><%= r7.getString("username") %></strong></td>
      <td><%= r7.getString("full_name")!=null?r7.getString("full_name"):"—" %></td>
      <td style="font-size:13px"><%= r7.getString("email")!=null?r7.getString("email"):"—" %></td>
      <td style="font-size:13px"><%= r7.getString("id_number")!=null?r7.getString("id_number"):"—" %></td>
      <td><span class="badge <%= ub %>"><%= ur %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= r7.getString("created_at")!=null?r7.getString("created_at"):"—" %></td>
    </tr>
    <% } if (!f7) { %><tr class="empty-row"><td colspan="7">No users yet.</td></tr>
    <% } c7.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="7">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(c7!=null) try{c7.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ══════════════ LIBRARY – ISSUE / RETURN ══════════════ --%>
<% if ("library".equals(tab)) { %>
<div class="card">
  <h2>📚 Issue / Return Book</h2>
  <p style="color:#7a8fa8;font-size:13px;margin-bottom:20px">Use this form to issue a book to a student or process a return.</p>
  <form method="post" action="LibraryServlet">
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:14px;align-items:end;">
      <div>
        <label for="lib-student-id">Student ID</label>
        <input type="text" id="lib-student-id" name="studentId" placeholder="e.g. 21CS001" required>
      </div>
      <div>
        <label for="lib-book-id">Book ID / ISBN</label>
        <input type="text" id="lib-book-id" name="bookId" placeholder="e.g. DB1234" required>
      </div>
      <div>
        <label for="lib-action">Action</label>
        <select id="lib-action" name="action">
          <option value="issue">Issue</option>
          <option value="return">Return</option>
        </select>
      </div>
      <div>
        <button type="submit" class="btn-primary" style="width:100%">Submit</button>
      </div>
    </div>
  </form>
</div>

<div class="card" style="margin-top:20px;">
  <h2>📥 Pending Book Requests</h2>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>Student</th><th>Book</th><th>Req. Date</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
    <%
    Connection lbc = null;
    try {
        lbc = DBConnection.getConnection();
        ResultSet lbr = lbc.prepareStatement(
            "SELECT br.request_id, u.username, b.title, br.request_date, br.status " +
            "FROM book_requests br " +
            "JOIN users u ON br.user_id=u.user_id " +
            "JOIN books b ON br.book_id=b.book_id " +
            "ORDER BY br.created_at DESC").executeQuery();
        boolean lbf = false;
        while (lbr.next()) { lbf=true;
            String st=lbr.getString("status");
            String bc="badge-pending";
            if("approved".equals(st)) bc="badge-approved";
            if("rejected".equals(st)) bc="badge-rejected"; %>
    <tr>
      <td style="color:#7a8fa8"><%= lbr.getInt("request_id") %></td>
      <td><strong><%= lbr.getString("username") %></strong></td>
      <td><strong><%= lbr.getString("title") %></strong></td>
      <td style="font-size:12px"><%= lbr.getString("request_date") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td>
        <% if ("pending".equals(st)) { %>
        <button class="action-btn btn-approve" onclick="location.href='LibraryServlet?action=updateRequest&id=<%= lbr.getInt("request_id") %>&status=approved'">Approve</button>
        <button class="action-btn btn-reject"  onclick="location.href='LibraryServlet?action=updateRequest&id=<%= lbr.getInt("request_id") %>&status=rejected'">Reject</button>
        <% } else { %>
        <span style="color:#7a8fa8;font-size:12px">Processed</span>
        <% } %>
      </td>
    </tr>
    <% } if (!lbf) { %><tr class="empty-row"><td colspan="6">No book requests yet.</td></tr>
    <% } lbc.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="6">Error: <%= e.getMessage() %><br><small>Run fix_database.sql</small></td></tr>
    <% } finally { if(lbc!=null) try{lbc.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>

<div class="card" style="margin-top:20px;">
  <h2>📊 Active Book Loans</h2>
  <div class="table-wrap"><table>
    <thead><tr><th>#</th><th>Student</th><th>Book</th><th>Issued On</th><th>Due Date</th><th>Fine</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
    <%
    Connection alc = null;
    try {
        alc = DBConnection.getConnection();
        ResultSet alr = alc.prepareStatement(
            "SELECT li.issue_id, u.username, b.title, li.issued_on, li.due_date, li.fine_amount, li.status, li.book_id " +
            "FROM library_issues li " +
            "JOIN users u ON li.user_id=u.user_id " +
            "JOIN books b ON li.book_id=b.book_id " +
            "ORDER BY li.issued_on DESC").executeQuery();
        boolean alf = false;
        while (alr.next()) { alf=true;
            String st = alr.getString("status");
            String bc = "issued".equals(st) ? "badge-issued" : "badge-returned";
            double fine = alr.getDouble("fine_amount");
    %>
    <tr>
      <td style="color:#7a8fa8"><%= alr.getInt("issue_id") %></td>
      <td><strong><%= alr.getString("username") %></strong></td>
      <td><strong><%= alr.getString("title") %></strong></td>
      <td style="font-size:12px"><%= alr.getString("issued_on") %></td>
      <td style="font-size:12px"><%= alr.getString("due_date") %></td>
      <td style="color:<%= fine>0?"#ff3d5a":"#00e676" %>;font-weight:600">₹<%= String.format("%.2f",fine) %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td>
        <% if ("issued".equals(st)) { %>
        <form method="post" action="LibraryServlet" style="display:inline;">
          <input type="hidden" name="action" value="return">
          <input type="hidden" name="issue_id" value="<%= alr.getInt("issue_id") %>">
          <input type="hidden" name="book_id" value="<%= alr.getInt("book_id") %>">
          <input type="hidden" name="return_date" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
          <input type="hidden" name="fine_amount" value="0">
          <button type="submit" class="action-btn" style="background:rgba(212,168,67,.15);border:1px solid rgba(212,168,67,.3);color:#d4a843" onclick="return confirm('Mark as returned without fine?')">Mark Returned</button>
        </form>
        <% } else { %>
        <span style="color:#7a8fa8;font-size:12px">Returned</span>
        <% } %>
      </td>
    </tr>
    <% } if (!alf) { %><tr class="empty-row"><td colspan="8">No active loans yet.</td></tr>
    <% } alc.close();
    } catch(Exception e) { %><tr class="err-row"><td colspan="8">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(alc!=null) try{alc.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

</main>
</div>
</div>
</body>
</html>
