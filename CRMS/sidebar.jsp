<%
String role = (String) session.getAttribute("role");
String path = request.getContextPath();
if (role == null) role = "";
String uri  = request.getRequestURI();
String currentPage = uri.substring(uri.lastIndexOf('/') + 1);
%>
<aside class="sidebar">
<h2>CRMS</h2>

<%-- Dashboard & common pages: all roles --%>
<a href="<%=path%>/dashboard.jsp"     class="<%= "dashboard.jsp".equals(currentPage)     ? "active" : "" %>">Dashboard</a>
<a href="<%=path%>/notifications.jsp" class="<%= "notifications.jsp".equals(currentPage) ? "active" : "" %>">Notifications</a>
<a href="<%=path%>/announcements.jsp" class="<%= "announcements.jsp".equals(currentPage) ? "active" : "" %>">Announcements</a>
<a href="<%=path%>/maintainance.jsp"  class="<%= "maintainance.jsp".equals(currentPage)  ? "active" : "" %>">Maintenance</a>

<%-- Bookings: all roles except librarian --%>
<% if (!role.equals("librarian")) { %>
<a href="<%=path%>/bookings.jsp" class="<%= "bookings.jsp".equals(currentPage) ? "active" : "" %>">Bookings</a>
<% } %>

<%-- Library: student, faculty, librarian, admin --%>
<% if (role.equals("student") || role.equals("faculty") || role.equals("librarian") || role.equals("admin")) { %>
<a href="<%=path%>/library.jsp" class="<%= "library.jsp".equals(currentPage) ? "active" : "" %>">Library</a>
<% } %>

<%-- Equipment: student, faculty, labtech, warden, librarian (anyone who can request equipment) --%>
<% if (role.equals("student") || role.equals("faculty") || role.equals("labtech") || role.equals("warden") || role.equals("librarian") || role.equals("admin")) { %>
<a href="<%=path%>/equipment.jsp" class="<%= "equipment.jsp".equals(currentPage) ? "active" : "" %>">Equipment</a>
<% } %>

<%-- Complaints: all roles --%>
<a href="<%=path%>/complaints.jsp" class="<%= "complaints.jsp".equals(currentPage) ? "active" : "" %>">Complaints</a>

<%-- Hostel: admin and warden only --%>
<% if (role.equals("admin") || role.equals("warden")) { %>
<a href="<%=path%>/hostel.jsp" class="<%= "hostel.jsp".equals(currentPage) ? "active" : "" %>">Hostel</a>
<% } %>

<%-- Admin-only links --%>
<% if (role.equals("admin")) { %>
<a href="<%=path%>/reports.jsp"           class="<%= "reports.jsp".equals(currentPage)           ? "active" : "" %>">Reports</a>
<a href="<%=path%>/resource_register.jsp" class="<%= "resource_register.jsp".equals(currentPage) ? "active" : "" %>">Register Resource</a>
<a href="<%=path%>/register.jsp"          class="<%= "register.jsp".equals(currentPage)           ? "active" : "" %>">Register User</a>
<a href="<%=path%>/admin.jsp"             class="<%= "admin.jsp".equals(currentPage)             ? "active" : "" %>">Admin Panel</a>
<% } %>

<br>
<a href="<%=path%>/LogoutServlet" style="color:#e57373;">Logout</a>
</aside>
