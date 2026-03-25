<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String _role = (String) session.getAttribute("role");
if (_role == null) { response.sendRedirect("login.html"); return; }
String username = (String) session.getAttribute("username");
int userId = (session.getAttribute("user_id") != null) ? (int) session.getAttribute("user_id") : 0;
String path = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Notifications - CRMS</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp" />
<div class="content">
<header class="header">
  <h1>Notifications</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

  <div class="card">
    <h2>Announcements for You</h2>
    <table>
      <thead><tr><th>Title</th><th>Message</th><th>Posted By</th><th>Date</th></tr></thead>
      <tbody>
      <%
      try {
          Connection c = DBConnection.getConnection();
          PreparedStatement ps = c.prepareStatement(
              "SELECT a.title, a.message, u.username, a.created_at FROM announcements a " +
              "JOIN users u ON a.user_id=u.user_id " +
              "WHERE a.target_role='all' OR a.target_role=? ORDER BY a.created_at DESC");
          ps.setString(1, _role);
          ResultSet rs = ps.executeQuery();
          boolean found = false;
          while (rs.next()) { found = true; %>
          <tr>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("message") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("created_at") %></td>
          </tr>
          <% } if (!found) { %><tr><td colspan="4" style="text-align:center;color:#888;">No announcements yet.</td></tr><% }
          c.close(); } catch(Exception e) { %><tr><td colspan="4" style="text-align:center;color:#888;">No announcements yet.</td></tr><% } %>
      </tbody>
    </table>
  </div>

  <div class="card">
    <h2>Your Booking Status</h2>
    <table>
      <thead><tr><th>Resource</th><th>Start</th><th>End</th><th>Status</th></tr></thead>
      <tbody>
      <%
      try {
          Connection c = DBConnection.getConnection();
          PreparedStatement ps = c.prepareStatement(
              "SELECT r.resource_name, b.start_time, b.end_time, b.status " +
              "FROM bookings b JOIN resources r ON b.resource_id=r.resource_id " +
              "WHERE b.user_id=? ORDER BY b.created_at DESC LIMIT 5");
          ps.setInt(1, userId);
          ResultSet rs = ps.executeQuery();
          boolean found = false;
          while (rs.next()) { found = true;
              String st = rs.getString("status");
              String bc = "badge-pending";
              if ("approved".equals(st)) bc = "badge-approved";
              if ("rejected".equals(st)) bc = "badge-rejected"; %>
          <tr>
            <td><%= rs.getString("resource_name") %></td>
            <td><%= rs.getString("start_time") %></td>
            <td><%= rs.getString("end_time") %></td>
            <td><span class="badge <%= bc %>"><%= st %></span></td>
          </tr>
          <% } if (!found) { %><tr><td colspan="4" style="text-align:center;color:#888;">No bookings yet.</td></tr><% }
          c.close(); } catch(Exception e) { %><tr><td colspan="4" style="text-align:center;color:#888;">No bookings yet.</td></tr><% } %>
      </tbody>
    </table>
  </div>

  <div class="card">
    <h2>Your Complaint Status</h2>
    <table>
      <thead><tr><th>Title</th><th>Category</th><th>Status</th><th>Date</th></tr></thead>
      <tbody>
      <%
      try {
          Connection c = DBConnection.getConnection();
          PreparedStatement ps = c.prepareStatement(
              "SELECT title, category, status, created_at FROM complaints WHERE user_id=? ORDER BY created_at DESC LIMIT 5");
          ps.setInt(1, userId);
          ResultSet rs = ps.executeQuery();
          boolean found = false;
          while (rs.next()) { found = true;
              String st = rs.getString("status");
              String bc = "badge-pending";
              if ("resolved".equals(st))    bc = "badge-approved";
              if ("in-progress".equals(st)) bc = "badge-in-progress"; %>
          <tr>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("category") %></td>
            <td><span class="badge <%= bc %>"><%= st %></span></td>
            <td><%= rs.getString("created_at") %></td>
          </tr>
          <% } if (!found) { %><tr><td colspan="4" style="text-align:center;color:#888;">No complaints yet.</td></tr><% }
          c.close(); } catch(Exception e) { %><tr><td colspan="4" style="text-align:center;color:#888;">No complaints yet.</td></tr><% } %>
      </tbody>
    </table>
  </div>

</main>
</div>
</div>
</body>
</html>
