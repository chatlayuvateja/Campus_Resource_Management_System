<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String username = (String) session.getAttribute("username");
String role     = (String) session.getAttribute("role");
if (username == null || role == null) { response.sendRedirect("login.html"); return; }
String path = request.getContextPath();
String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Dashboard - CRMS</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp" />
<div class="content">
<header class="header">
  <h1>Dashboard</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= role %>)</strong></div>
</header>
<main>

<% if ("unauthorized".equals(errorParam)) { %>
<div style="background:#ffe0e0;border:1px solid #f44336;color:#b71c1c;padding:12px 18px;border-radius:6px;margin-bottom:18px;">
  <strong>Access Denied:</strong> You do not have permission to view that page.
</div>
<% } %>

<div class="card">
  <h2>Quick Actions</h2>
  <div style="margin-top:10px;display:flex;flex-wrap:wrap;gap:10px;">
    <%-- Bookings: available to all except librarian --%>
    <% if (!("librarian".equals(role))) { %>
    <button class="btn-primary" onclick="location.href='<%=path%>/bookings.jsp'">📅 Book Room / Lab</button>
    <% } %>
    <%-- Library: student, faculty, librarian, admin --%>
    <% if ("student".equals(role) || "faculty".equals(role) || "librarian".equals(role) || "admin".equals(role)) { %>
    <button class="btn-secondary" onclick="location.href='<%=path%>/library.jsp'">📚 Library</button>
    <% } %>
    <%-- Equipment: student, faculty, labtech, warden, librarian, admin --%>
    <% if ("student".equals(role) || "faculty".equals(role) || "labtech".equals(role) || "warden".equals(role) || "librarian".equals(role) || "admin".equals(role)) { %>
    <button class="btn-secondary" onclick="location.href='<%=path%>/equipment.jsp'">🖥️ Request Equipment</button>
    <% } %>
    <%-- Complaints: all roles --%>
    <button class="btn-secondary" onclick="location.href='<%=path%>/complaints.jsp'">📋 Complaints</button>
    <%-- Maintenance: all roles --%>
    <button class="btn-secondary" onclick="location.href='<%=path%>/maintainance.jsp'">🔧 Maintenance</button>
    <%-- Hostel: admin and warden --%>
    <% if ("admin".equals(role) || "warden".equals(role)) { %>
    <button class="btn-secondary" onclick="location.href='<%=path%>/hostel.jsp'">🏠 Hostel</button>
    <% } %>
    <%-- Admin Panel: admin only --%>
    <% if ("admin".equals(role)) { %>
    <button class="btn-secondary" onclick="location.href='<%=path%>/admin.jsp'">⚙️ Admin Panel</button>
    <% } %>
  </div>
</div>

<div class="card">
  <h2>Latest Announcements</h2>
  <table>
    <thead><tr><th>Title</th><th>Message</th><th>Posted By</th><th>Date</th></tr></thead>
    <tbody>
    <%
    try {
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT a.title, a.message, u.username, a.created_at FROM announcements a " +
            "JOIN users u ON a.user_id=u.user_id " +
            "WHERE a.target_role='all' OR a.target_role=? ORDER BY a.created_at DESC LIMIT 5");
        ps.setString(1, role);
        ResultSet rs = ps.executeQuery();
        boolean found = false;
        while (rs.next()) { found = true; %>
        <tr>
          <td><%= rs.getString("title") %></td>
          <td><%= rs.getString("message") %></td>
          <td><%= rs.getString("username") %></td>
          <td><%= rs.getString("created_at") %></td>
        </tr>
        <% } if (!found) { %>
        <tr><td colspan="4" style="text-align:center;color:#888;">No announcements yet.</td></tr>
        <% } conn.close();
    } catch(Exception e) { %>
        <tr><td colspan="4" style="text-align:center;color:#888;">No announcements yet.</td></tr>
    <% } %>
    </tbody>
  </table>
</div>

</main>
</div>
</div>
</body>
</html>
