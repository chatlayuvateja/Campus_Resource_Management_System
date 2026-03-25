<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String _role = (String) session.getAttribute("role");
/* Allow all logged-in users to book */
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
<title>Bookings – CRMS</title>
<link rel="stylesheet" href="styles.css">
<style>
  .alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; font-weight:500; }
  .alert-err { background:#2b0d0d; border:1px solid #6a2d2d; color:#e57373;
               padding:12px 18px; border-radius:8px; margin-bottom:18px; }
  .ferr      { color:#e57373; font-size:12px; margin-top:4px; display:none; }
  .ferr.show { display:block; }
  .is-invalid { border-color:#e57373 !important; }
  .badge-pending  { background:rgba(255,154,0,.18);  color:#ff9a00; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-approved { background:rgba(0,230,118,.15);  color:#00e676; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  .badge-rejected { background:rgba(255,61,90,.15);  color:#ff3d5a; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
  optgroup { font-weight:700; color:#00d2c8; }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>Room / Lab Bookings</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

<% if ("1".equals(success)) { %>
<div class="alert-ok">✅ Booking submitted successfully! Awaiting admin approval.</div>
<% } else if ("missing".equals(error)) { %>
<div class="alert-err">⚠️ All fields are required. Please fill every field.</div>
<% } else if ("db".equals(error) || "1".equals(error)) { %>
<div class="alert-err">⚠️ Failed to submit booking. Check database connection.</div>
<% } %>

<%-- ── BOOKING FORM ────────────────────────────────────── --%>
<div class="card">
  <h2>Book a Room / Lab / Venue</h2>
  <form action="<%=path%>/BookingServlet" method="post" id="bForm" novalidate>

    <div>
      <label>Select Venue / Resource <span style="color:#e57373">*</span></label>
      <select name="resource_id" id="f_res" required>
        <option value="">-- Select Room, Lab or Venue --</option>
        <%
        Connection bc = null;
        try {
            bc = DBConnection.getConnection();
            /* Show rooms AND labs AND sports AND library grouped by type */
            ResultSet br = bc.prepareStatement(
                "SELECT resource_id, resource_name, resource_type, location " +
                "FROM resources " +
                "WHERE resource_type IN ('room','lab','sports','library','hostel') " +
                "ORDER BY resource_type, resource_name").executeQuery();

            String lastType = "";
            while (br.next()) {
                String rtype = br.getString("resource_type");
                if (!rtype.equals(lastType)) {
                    if (!lastType.isEmpty()) out.print("</optgroup>");
                    String label = "room".equals(rtype)    ? "🏫 Classrooms & Halls"
                                 : "lab".equals(rtype)     ? "🔬 Laboratories"
                                 : "sports".equals(rtype)  ? "🏆 Sports & Grounds"
                                 : "library".equals(rtype) ? "📚 Library"
                                 : "🏠 Hostel";
                    out.print("<optgroup label=\"" + label + "\">");
                    lastType = rtype;
                }
        %>
        <option value="<%= br.getInt("resource_id") %>">
          <%= br.getString("resource_name") %> — <%= br.getString("location") %>
        </option>
        <%  }
            if (!lastType.isEmpty()) out.print("</optgroup>");
            br.close(); bc.close();
        } catch(Exception e) {
        %><option disabled>Error loading resources — run fix_database.sql</option><%
        } finally { if(bc!=null) try{bc.close();}catch(Exception ig){} } %>
      </select>
      <div class="ferr" id="e_res">Please select a venue.</div>
    </div>

    <div>
      <label>Start Date &amp; Time <span style="color:#e57373">*</span></label>
      <input type="datetime-local" name="start_time" id="f_start" required>
      <div class="ferr" id="e_start">Start date and time is required.</div>
    </div>

    <div>
      <label>End Date &amp; Time <span style="color:#e57373">*</span></label>
      <input type="datetime-local" name="end_time" id="f_end" required>
      <div class="ferr" id="e_end">End date and time is required (must be after start).</div>
    </div>

    <div>
      <label>Purpose <span style="color:#e57373">*</span></label>
      <textarea name="purpose" id="f_purpose" rows="3"
        placeholder="Lecture, Lab session, Meeting, Sports practice, Cultural event..." required></textarea>
      <div class="ferr" id="e_purpose">Please describe the purpose.</div>
    </div>

    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📅 Submit Booking Request</button>
    </div>
  </form>
</div>

<%-- ── MY BOOKINGS TABLE ───────────────────────────────── --%>
<div class="card">
  <h2>My Bookings
    <span style="font-size:12px;color:#7a8fa8;font-weight:400;margin-left:8px;">live from database</span>
  </h2>
  <div class="table-wrap">
  <table>
    <thead>
      <tr><th>Resource</th><th>Start</th><th>End</th><th>Purpose</th><th>Status</th><th>Submitted</th></tr>
    </thead>
    <tbody>
    <%
    Connection btc = null;
    try {
        btc = DBConnection.getConnection();
        PreparedStatement btp = btc.prepareStatement(
            "SELECT r.resource_name, b.start_time, b.end_time, b.purpose, b.status, b.created_at " +
            "FROM bookings b JOIN resources r ON b.resource_id=r.resource_id " +
            "WHERE b.user_id=? ORDER BY b.created_at DESC");
        btp.setInt(1, userId);
        ResultSet btr = btp.executeQuery();
        boolean found = false;
        while (btr.next()) { found = true;
            String st=btr.getString("status");
            if (st == null) st = "pending";
            String bc2="badge-pending";
            if("approved".equals(st)) bc2="badge-approved";
            if("rejected".equals(st)) bc2="badge-rejected";
    %>
    <tr>
      <td><strong><%= btr.getString("resource_name") %></strong></td>
      <td style="font-size:13px"><%= btr.getString("start_time") %></td>
      <td style="font-size:13px"><%= btr.getString("end_time") %></td>
      <td style="max-width:180px;font-size:13px"><%= btr.getString("purpose")!=null?btr.getString("purpose"):"—" %></td>
      <td><span class="badge <%= bc2 %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= btr.getString("created_at") %></td>
    </tr>
    <% } if (!found) { %>
    <tr><td colspan="6" style="text-align:center;color:#7a8fa8;padding:28px">
      No bookings yet. Use the form above to book a venue.
    </td></tr>
    <% } btp.close(); btc.close();
    } catch(Exception e) { %>
    <tr><td colspan="6" style="text-align:center;color:#e57373;padding:24px">
      <strong>Error:</strong> <%= e.getMessage() %><br><small>Run fix_database.sql in MySQL first.</small>
    </td></tr>
    <% } finally { if(btc!=null) try{btc.close();}catch(Exception ig){} } %>
    </tbody>
  </table>
  </div>
</div>

</main>
</div>
</div>
<script>
document.getElementById('bForm').addEventListener('submit', function(e) {
  let ok = true;
  const res  = document.getElementById('f_res');
  const st   = document.getElementById('f_start');
  const en   = document.getElementById('f_end');
  const pur  = document.getElementById('f_purpose');
  [res,st,en,pur].forEach(el => el.classList.remove('is-invalid'));
  document.querySelectorAll('.ferr').forEach(el => el.classList.remove('show'));

  if (!res.value) { res.classList.add('is-invalid'); document.getElementById('e_res').classList.add('show'); ok=false; }
  if (!st.value)  { st.classList.add('is-invalid');  document.getElementById('e_start').classList.add('show'); ok=false; }
  if (!en.value)  { en.classList.add('is-invalid');  document.getElementById('e_end').classList.add('show'); ok=false; }
  else if (st.value && en.value <= st.value) {
    en.classList.add('is-invalid'); document.getElementById('e_end').classList.add('show'); ok=false;
  }
  if (!pur.value.trim()) { pur.classList.add('is-invalid'); document.getElementById('e_purpose').classList.add('show'); ok=false; }
  if (!ok) { e.preventDefault(); window.scrollTo({top:0,behavior:'smooth'}); }
});
// Set min datetime to now
const now = new Date(); now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
const minDT = now.toISOString().slice(0,16);
document.getElementById('f_start').min = minDT;
document.getElementById('f_end').min   = minDT;
document.getElementById('f_start').addEventListener('change', function() {
  document.getElementById('f_end').min = this.value;
});
</script>
</body>
</html>
