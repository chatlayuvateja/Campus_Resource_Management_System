<%
String _role = (String) session.getAttribute("role");
if (_role == null || (!_role.equals("warden") && !_role.equals("admin"))) {
    response.sendRedirect("dashboard.jsp?error=unauthorized");
    return;
}
// Allowed roles: warden, admin
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Hostel - CRMS</title>
  <link rel="stylesheet" href="styles.css">
  
</head>
<body>
<div class="layout">

<jsp:include page="sidebar.jsp" />

  <div class="content">
    <header class="header">
      <h1>Hostel</h1>
      <div class="user-info">Logged in as: <strong><%= session.getAttribute("username") %> (<%= session.getAttribute("role") %>)</strong></div>
    </header>

    <main>
      <div class="card">
        <h2>Hostel Room Allocation (Sample View)</h2>
        <table>
          <thead>
            <tr>
              <th>Room</th>
              <th>Block</th>
              <th>Capacity</th>
              <th>Allocated</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>G-101</td>
              <td>A</td>
              <td>3</td>
              <td>2</td>
            </tr>
            <tr>
              <td>G-102</td>
              <td>A</td>
              <td>3</td>
              <td>3</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="card">
        <h2>Student Complaints (Shortcut)</h2>
        <p>Hostel maintenance complaints can be managed from the <strong>Complaints</strong> module.</p>
      </div>
    </main>
  </div>
</div>
</body>
</html>
