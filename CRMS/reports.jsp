<%@ page import="java.sql.*" %>
<%@ page import="com.crms.db.DBConnection" %>
<%
String _role = (String) session.getAttribute("role");
if (_role == null || (!_role.equals("admin"))) {
    response.sendRedirect("dashboard.jsp?error=unauthorized");
    return;
}
// Allowed roles: admin
%>




<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reports - CRMS</title>
<link rel="stylesheet" href="styles.css">
</head>

<body>

<div class="layout">

<jsp:include page="sidebar.jsp" />

<div class="content">

<header class="header">
<h1>CRMS Reports</h1>
</header>

<main>

<div class="card">

<h2>Resource Booking Summary</h2>

<table>

<tr>
<th>Resource</th>
<th>Total Bookings</th>
</tr>

<%

try{

Connection conn = DBConnection.getConnection();

String sql = "SELECT resource_id, COUNT(*) AS total FROM bookings GROUP BY resource_id";

PreparedStatement ps = conn.prepareStatement(sql);

ResultSet rs = ps.executeQuery();

while(rs.next()){

%>

<tr>
<td>Resource <%= rs.getInt("resource_id") %></td>
<td><%= rs.getInt("total") %></td>
</tr>

<%

}

}catch(Exception e){
out.println(e.getMessage());
}

%>

</table>

</div>


<div class="card">

<h2>Maintenance Requests</h2>

<table>

<tr>
<th>Resource</th>
<th>Status</th>
<th>Date</th>
</tr>

<%

try{

Connection conn = DBConnection.getConnection();

String sql = "SELECT resource_id,status,request_id FROM maintenance_requests";

PreparedStatement ps = conn.prepareStatement(sql);

ResultSet rs = ps.executeQuery();

while(rs.next()){

%>

<tr>
<td>Resource <%= rs.getInt("resource_id") %></td>
<td><%= rs.getString("status") %></td>
<td>Request #<%= rs.getInt("request_id") %></td>
</tr>

<%

}

}catch(Exception e){
out.println(e.getMessage());
}

%>

</table>

</div>

</main>

</div>

</div>

</body>
</html>