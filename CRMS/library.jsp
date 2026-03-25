<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.crms.db.DBConnection" %>
<%
String _role = (String) session.getAttribute("role");
if (_role == null || (!_role.equals("student") && !_role.equals("faculty") &&
                      !_role.equals("librarian") && !_role.equals("admin"))) {
    response.sendRedirect("dashboard.jsp?error=unauthorized"); return;
}
String username  = (String) session.getAttribute("username");
int    userId    = (Integer) session.getAttribute("user_id");
String path      = request.getContextPath();
String success   = request.getParameter("success");
String error     = request.getParameter("error");
String tab       = request.getParameter("tab");
String searchQ   = request.getParameter("q");
String catFilter = request.getParameter("cat");
if (tab == null) tab = "search";
if (searchQ   == null) searchQ   = "";
if (catFilter == null) catFilter = "";
boolean isLibStaff = "librarian".equals(_role) || "admin".equals(_role);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Library – CRMS</title>
<link rel="stylesheet" href="styles.css">
<style>
/* ── ALERTS ─────────────────────────────────────────────── */
.alert-ok  { background:#0d2b1a; border:1px solid #2d6a4f; color:#52b788;
             padding:12px 18px; border-radius:8px; margin-bottom:18px; font-weight:500; }
.alert-err { background:#2b0d0d; border:1px solid #6a2d2d; color:#e57373;
             padding:12px 18px; border-radius:8px; margin-bottom:18px; }
/* ── BADGES ─────────────────────────────────────────────── */
.badge-available { background:rgba(0,230,118,.15);  color:#00e676; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
.badge-none      { background:rgba(255,61,90,.15);  color:#ff3d5a; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
.badge-pending   { background:rgba(255,154,0,.18);  color:#ff9a00; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
.badge-approved  { background:rgba(0,230,118,.15);  color:#00e676; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
.badge-rejected  { background:rgba(255,61,90,.15);  color:#ff3d5a; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
.badge-issued    { background:rgba(41,121,255,.18); color:#2979ff; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
.badge-returned  { background:rgba(0,210,200,.15);  color:#00d2c8; border-radius:20px; padding:2px 10px; font-size:12px; font-weight:600; }
/* ── BOOK CARDS ─────────────────────────────────────────── */
.book-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:16px; margin-top:16px; }
.book-card {
  background:rgba(11,21,32,0.8); border:1px solid rgba(0,210,200,0.12);
  border-radius:12px; padding:18px; transition:all 0.2s;
  display:flex; flex-direction:column; gap:8px;
}
.book-card:hover { border-color:rgba(0,210,200,0.35); transform:translateY(-2px);
                   box-shadow:0 6px 24px rgba(0,210,200,0.1); }
.book-title   { font-weight:700; font-size:14px; color:#e2eaf3; line-height:1.4; }
.book-author  { font-size:12px; color:#00d2c8; font-weight:600; }
.book-meta    { font-size:11px; color:#7a8fa8; }
.book-desc    { font-size:12px; color:#7a8fa8; line-height:1.5; }
.book-footer  { display:flex; justify-content:space-between; align-items:center; margin-top:6px; }
.cat-pill     { display:inline-block; padding:2px 10px; border-radius:20px; font-size:11px;
                font-weight:600; background:rgba(212,168,67,.15); color:#d4a843; }
/* ── REQUEST MODAL ──────────────────────────────────────── */
.modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,0.7);
                 z-index:1000; align-items:center; justify-content:center; }
.modal-overlay.open { display:flex; }
.modal-box { background:#0b1520; border:1px solid rgba(0,210,200,0.25); border-radius:16px;
             padding:32px; width:100%; max-width:480px; position:relative; }
.modal-box h3 { font-family:'Orbitron',monospace; color:#00d2c8; margin-bottom:20px; }
.modal-close  { position:absolute; top:16px; right:20px; cursor:pointer; color:#7a8fa8;
                font-size:20px; background:none; border:none; }
/* ── SEARCH BAR ─────────────────────────────────────────── */
.search-row { display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end; margin-bottom:20px; }
.search-row input, .search-row select { flex:1; min-width:180px; }
.search-row .btn-primary { flex-shrink:0; }
/* ── ACTION BTNS ────────────────────────────────────────── */
.btn-req { background:rgba(0,210,200,.12); color:#00d2c8; border:1px solid rgba(0,210,200,.3);
           padding:6px 14px; border-radius:8px; cursor:pointer; font-size:12px; font-weight:600; }
.btn-req:hover { background:rgba(0,210,200,.25); }
.btn-issue { background:rgba(0,230,118,.12); color:#00e676; border:1px solid rgba(0,230,118,.3);
             padding:5px 12px; border-radius:8px; cursor:pointer; font-size:12px; font-weight:600; }
.btn-reject{ background:rgba(255,61,90,.12);  color:#ff3d5a; border:1px solid rgba(255,61,90,.3);
             padding:5px 12px; border-radius:8px; cursor:pointer; font-size:12px; font-weight:600; }
.btn-return{ background:rgba(212,168,67,.12); color:#d4a843; border:1px solid rgba(212,168,67,.3);
             padding:5px 12px; border-radius:8px; cursor:pointer; font-size:12px; font-weight:600; }
/* ── FERR ────────────────────────────────────────────────── */
.ferr      { color:#e57373; font-size:12px; margin-top:4px; display:none; }
.ferr.show { display:block; }
.is-invalid { border-color:#e57373 !important; }
</style>
</head>
<body>
<div class="layout">
<jsp:include page="sidebar.jsp"/>
<div class="content">
<header class="header">
  <h1>📚 LIBRARY</h1>
  <div class="user-info">Logged in as: <strong><%= username %> (<%= _role %>)</strong></div>
</header>
<main>

<%-- ── ALERTS ───────────────────────────────────────────── --%>
<% if ("requested".equals(success))  { %><div class="alert-ok">✅ Book request submitted! Awaiting librarian approval.</div><% }
   else if ("issued".equals(success))   { %><div class="alert-ok">✅ Book issued successfully.</div><% }
   else if ("returned".equals(success)) { %><div class="alert-ok">✅ Book returned successfully.</div><% }
   else if ("rejected".equals(success)) { %><div class="alert-ok">✅ Request status updated.</div><% }
   else if ("updated".equals(success))  { %><div class="alert-ok">✅ Status updated successfully.</div><% }
   else if ("missing".equals(error))    { %><div class="alert-err">⚠️ Please fill all required fields.</div><% }
   else if ("already_requested".equals(error)) { %><div class="alert-err">⚠️ You already have a pending request for this book.</div><% }
   else if ("no_copies".equals(error))  { %><div class="alert-err">⚠️ No copies available to issue.</div><% }
   else if ("db".equals(error))         { %><div class="alert-err">⚠️ Database error. Ensure library_books.sql has been run.</div><% }
%>

<%-- ── TABS ─────────────────────────────────────────────── --%>
<div class="tabs" style="margin-bottom:20px">
  <button class="tab-btn <%= "search".equals(tab) ? "active":"" %>"
          onclick="location.href='library.jsp?tab=search'">🔍 Search Books</button>
  <% if (!isLibStaff) { %>
  <button class="tab-btn <%= "my_requests".equals(tab) ? "active":"" %>"
          onclick="location.href='library.jsp?tab=my_requests'">📋 My Requests</button>
  <button class="tab-btn <%= "my_loans".equals(tab) ? "active":"" %>"
          onclick="location.href='library.jsp?tab=my_loans'">📖 My Loans</button>
  <% } %>
  <% if (isLibStaff) { %>
  <button class="tab-btn <%= "librarian".equals(tab) ? "active":"" %>"
          onclick="location.href='library.jsp?tab=librarian'">🏛️ Librarian Panel</button>
  <button class="tab-btn <%= "all_requests".equals(tab) ? "active":"" %>"
          onclick="location.href='library.jsp?tab=all_requests'">📥 All Requests</button>
  <button class="tab-btn <%= "all_loans".equals(tab) ? "active":"" %>"
          onclick="location.href='library.jsp?tab=all_loans'">📊 All Active Loans</button>
  <% } %>
</div>

<%-- ════════════════════════════════════════════════════════
     TAB 1 — SEARCH BOOKS
     ════════════════════════════════════════════════════════ --%>
<% if ("search".equals(tab)) { %>
<div class="card">
  <h2>🔍 Search Library Books</h2>

  <%-- Search form --%>
  <form method="get" action="library.jsp" id="searchForm">
    <input type="hidden" name="tab" value="search">
    <div class="search-row">
      <div style="flex:2;min-width:200px">
        <label>Title / Author / ISBN / Keyword</label>
        <input type="text" name="q" id="q" value="<%= searchQ %>"
               placeholder="e.g. Data Structures, Korth, 978-...">
      </div>
      <div style="flex:1;min-width:160px">
        <label>Category</label>
        <select name="cat" id="cat">
          <option value="">All Categories</option>
          <option value="Computer Science"  <%= "Computer Science".equals(catFilter)  ? "selected":"" %>>💻 Computer Science</option>
          <option value="Electronics"       <%= "Electronics".equals(catFilter)       ? "selected":"" %>>⚡ Electronics</option>
          <option value="Mechanical"        <%= "Mechanical".equals(catFilter)        ? "selected":"" %>>⚙️ Mechanical</option>
          <option value="Civil"             <%= "Civil".equals(catFilter)             ? "selected":"" %>>🏗️ Civil</option>
          <option value="Mathematics"       <%= "Mathematics".equals(catFilter)       ? "selected":"" %>>📐 Mathematics</option>
          <option value="Physics"           <%= "Physics".equals(catFilter)           ? "selected":"" %>>🔭 Physics</option>
          <option value="Chemistry"         <%= "Chemistry".equals(catFilter)         ? "selected":"" %>>🧪 Chemistry</option>
          <option value="Management"        <%= "Management".equals(catFilter)        ? "selected":"" %>>📊 Management</option>
          <option value="English"           <%= "English".equals(catFilter)           ? "selected":"" %>>📝 English</option>
          <option value="Environmental"     <%= "Environmental".equals(catFilter)     ? "selected":"" %>>🌿 Environmental</option>
          <option value="Data Science"      <%= "Data Science".equals(catFilter)      ? "selected":"" %>>🤖 Data Science</option>
          <option value="Reference"         <%= "Reference".equals(catFilter)         ? "selected":"" %>>📚 Reference</option>
        </select>
      </div>
      <button type="submit" class="btn-primary">Search</button>
      <% if (!searchQ.isEmpty() || !catFilter.isEmpty()) { %>
      <a href="library.jsp?tab=search" class="btn-primary"
         style="background:rgba(255,61,90,.15);border-color:rgba(255,61,90,.3);color:#ff3d5a">
         Clear
      </a>
      <% } %>
    </div>
  </form>

  <%-- Results count --%>
  <%
  Connection sc = null;
  int bookCount = 0;
  try {
      sc = DBConnection.getConnection();
      String countSql = "SELECT COUNT(*) FROM books WHERE 1=1";
      if (!searchQ.isEmpty()) countSql += " AND (title LIKE ? OR author LIKE ? OR isbn LIKE ? OR description LIKE ?)";
      if (!catFilter.isEmpty()) countSql += " AND category=?";
      PreparedStatement cp = sc.prepareStatement(countSql);
      int pi = 1;
      if (!searchQ.isEmpty()) {
          String kw = "%" + searchQ + "%";
          cp.setString(pi++,kw); cp.setString(pi++,kw);
          cp.setString(pi++,kw); cp.setString(pi++,kw);
      }
      if (!catFilter.isEmpty()) cp.setString(pi++, catFilter);
      ResultSet cr = cp.executeQuery();
      if (cr.next()) bookCount = cr.getInt(1);
      cp.close(); sc.close();
  } catch(Exception e) {}
  finally { if(sc!=null)try{sc.close();}catch(Exception ig){} }
  %>
  <div style="margin-bottom:14px;font-size:13px;color:#7a8fa8">
    <% if (!searchQ.isEmpty() || !catFilter.isEmpty()) { %>
      Showing <strong style="color:#00d2c8"><%= bookCount %></strong> result(s)
      <% if (!searchQ.isEmpty()) { %> for "<strong style="color:#e2eaf3"><%= searchQ %></strong>"<% } %>
      <% if (!catFilter.isEmpty()) { %> in <strong style="color:#e2eaf3"><%= catFilter %></strong><% } %>
    <% } else { %>
      Showing all <strong style="color:#00d2c8"><%= bookCount %></strong> books in the library
    <% } %>
  </div>

  <%-- Book cards grid --%>
  <div class="book-grid">
  <%
  Connection bc = null;
  try {
      bc = DBConnection.getConnection();
      String sql = "SELECT book_id, isbn, title, author, publisher, pub_year, category, " +
                   "total_copies, available_copies, shelf_location, description " +
                   "FROM books WHERE 1=1";
      if (!searchQ.isEmpty()) sql += " AND (title LIKE ? OR author LIKE ? OR isbn LIKE ? OR description LIKE ?)";
      if (!catFilter.isEmpty()) sql += " AND category=?";
      sql += " ORDER BY category, title";

      PreparedStatement bps = bc.prepareStatement(sql);
      int idx = 1;
      if (!searchQ.isEmpty()) {
          String kw = "%" + searchQ + "%";
          bps.setString(idx++,kw); bps.setString(idx++,kw);
          bps.setString(idx++,kw); bps.setString(idx++,kw);
      }
      if (!catFilter.isEmpty()) bps.setString(idx++, catFilter);
      ResultSet brs = bps.executeQuery();
      boolean anyBook = false;
      while (brs.next()) {
          anyBook = true;
          int avail = brs.getInt("available_copies");
          int total = brs.getInt("total_copies");
          String desc = brs.getString("description");
          if (desc == null) desc = "";
          if (desc.length() > 90) desc = desc.substring(0, 90) + "...";
  %>
  <div class="book-card">
    <div class="book-title"><%= brs.getString("title") %></div>
    <div class="book-author">✍️ <%= brs.getString("author") %></div>
    <div class="book-meta">
      📅 <%= brs.getInt("pub_year") %>
      &nbsp;·&nbsp; 🏢 <%= brs.getString("publisher") != null ? brs.getString("publisher") : "" %>
      &nbsp;·&nbsp; 📍 Shelf: <%= brs.getString("shelf_location") != null ? brs.getString("shelf_location") : "" %>
    </div>
    <div class="book-meta">ISBN: <%= brs.getString("isbn") != null ? brs.getString("isbn") : "—" %></div>
    <% if (!desc.isEmpty()) { %><div class="book-desc"><%= desc %></div><% } %>
    <div class="book-footer">
      <div>
        <span class="cat-pill"><%= brs.getString("category") %></span>
        &nbsp;
        <% if (avail > 0) { %>
          <span class="badge-available">✅ <%= avail %>/<%= total %> Available</span>
        <% } else { %>
          <span class="badge-none">❌ Not Available</span>
        <% } %>
      </div>
      <% if (!isLibStaff && avail > 0) { %>
      <button class="btn-req"
        onclick="openRequestModal(<%= brs.getInt("book_id") %>, '<%= brs.getString("title").replace("'","\\'") %>')">
        📥 Request
      </button>
      <% } else if (!isLibStaff && avail == 0) { %>
      <button class="btn-req" style="opacity:.5;cursor:not-allowed" disabled>Unavailable</button>
      <% } %>
    </div>
  </div>
  <%  }
      if (!anyBook) { %>
  <div style="grid-column:1/-1;text-align:center;color:#7a8fa8;padding:48px;font-size:14px">
    📭 No books found matching your search.<br>
    <small>Try a different keyword or <a href="library.jsp?tab=search" style="color:#00d2c8">clear the filter</a>.</small>
  </div>
  <% }
     bps.close(); bc.close();
  } catch(Exception e) { %>
  <div style="grid-column:1/-1;text-align:center;color:#e57373;padding:32px">
    <strong>Database Error:</strong> <%= e.getMessage() %><br>
    <small>Run <code>library_books.sql</code> in MySQL first.</small>
  </div>
  <% } finally { if(bc!=null)try{bc.close();}catch(Exception ig){} } %>
  </div>
</div>

<%-- ── REQUEST MODAL ────────────────────────────────────── --%>
<div class="modal-overlay" id="reqModal">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">✕</button>
    <h3>📥 Request Book</h3>
    <p id="modalBookTitle" style="color:#e2eaf3;margin-bottom:20px;font-weight:600"></p>
    <form action="<%=path%>/LibraryServlet" method="post" id="reqForm" novalidate>
      <input type="hidden" name="action" value="request">
      <input type="hidden" name="book_id" id="modalBookId">
      <div>
        <label>Required Date <span style="color:#e57373">*</span></label>
        <input type="date" name="request_date" id="reqDate" required>
        <div class="ferr" id="e_date">Please select a date.</div>
      </div>
      <div style="margin-top:14px">
        <label>Purpose / Reason <small style="color:#7a8fa8">(optional)</small></label>
        <textarea name="purpose" rows="3"
          placeholder="Study purpose, assignment, project research..."></textarea>
      </div>
      <div style="margin-top:18px;display:flex;gap:12px">
        <button type="submit" class="btn-primary">✅ Submit Request</button>
        <button type="button" class="btn-primary"
          style="background:rgba(255,61,90,.15);border-color:rgba(255,61,90,.3);color:#ff3d5a"
          onclick="closeModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>

<%-- ════════════════════════════════════════════════════════
     TAB 2 — MY REQUESTS (student/faculty)
     ════════════════════════════════════════════════════════ --%>
<% } else if ("my_requests".equals(tab) && !isLibStaff) { %>
<div class="card">
  <h2>📋 My Book Requests</h2>
  <div class="table-wrap"><table>
    <thead>
      <tr><th>#</th><th>Book Title</th><th>Author</th><th>Category</th><th>Req. Date</th><th>Status</th><th>Remarks</th></tr>
    </thead>
    <tbody>
    <%
    Connection rc = null;
    try {
        rc = DBConnection.getConnection();
        PreparedStatement rp = rc.prepareStatement(
            "SELECT br.request_id, b.title, b.author, b.category, br.request_date, br.status, br.remarks " +
            "FROM book_requests br JOIN books b ON br.book_id=b.book_id " +
            "WHERE br.user_id=? ORDER BY br.created_at DESC");
        rp.setInt(1, userId);
        ResultSet rr = rp.executeQuery();
        boolean rf = false;
        while (rr.next()) { rf = true;
            String st = rr.getString("status");
            String bc = "badge-pending";
            if ("approved".equals(st)) bc = "badge-approved";
            if ("rejected".equals(st)) bc = "badge-rejected";
    %>
    <tr>
      <td style="color:#7a8fa8"><%= rr.getInt("request_id") %></td>
      <td><strong><%= rr.getString("title") %></strong></td>
      <td style="font-size:12px;color:#00d2c8"><%= rr.getString("author") %></td>
      <td><span class="cat-pill"><%= rr.getString("category") %></span></td>
      <td style="font-size:12px"><%= rr.getString("request_date") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td style="font-size:12px;color:#7a8fa8"><%= rr.getString("remarks") != null ? rr.getString("remarks") : "—" %></td>
    </tr>
    <% } if (!rf) { %>
    <tr><td colspan="7" style="text-align:center;color:#7a8fa8;padding:28px">
      No book requests yet. Go to <a href="library.jsp?tab=search" style="color:#00d2c8">Search Books</a> to request one.
    </td></tr>
    <% } rp.close(); rc.close();
    } catch(Exception e) { %>
    <tr><td colspan="7" style="color:#e57373;padding:20px">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(rc!=null)try{rc.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>

<%-- ════════════════════════════════════════════════════════
     TAB 3 — MY LOANS (student/faculty)
     ════════════════════════════════════════════════════════ --%>
<% } else if ("my_loans".equals(tab) && !isLibStaff) { %>
<div class="card">
  <h2>📖 My Current & Past Loans</h2>
  <div class="table-wrap"><table>
    <thead>
      <tr><th>#</th><th>Book Title</th><th>Author</th><th>Issued On</th><th>Due Date</th><th>Returned On</th><th>Fine (₹)</th><th>Status</th></tr>
    </thead>
    <tbody>
    <%
    Connection lc = null;
    try {
        lc = DBConnection.getConnection();
        PreparedStatement lp = lc.prepareStatement(
            "SELECT li.issue_id, b.title, b.author, li.issued_on, li.due_date, " +
            "       li.returned_on, li.fine_amount, li.status " +
            "FROM library_issues li JOIN books b ON li.book_id=b.book_id " +
            "WHERE li.user_id=? ORDER BY li.issued_on DESC");
        lp.setInt(1, userId);
        ResultSet lr = lp.executeQuery();
        boolean lf = false;
        while (lr.next()) { lf = true;
            String st = lr.getString("status");
            String bc = "issued".equals(st) ? "badge-issued" : "badge-returned";
            double fine = lr.getDouble("fine_amount");
    %>
    <tr>
      <td style="color:#7a8fa8"><%= lr.getInt("issue_id") %></td>
      <td><strong><%= lr.getString("title") %></strong></td>
      <td style="font-size:12px;color:#00d2c8"><%= lr.getString("author") %></td>
      <td style="font-size:12px"><%= lr.getString("issued_on") %></td>
      <td style="font-size:12px"><%= lr.getString("due_date") %></td>
      <td style="font-size:12px"><%= lr.getString("returned_on") != null ? lr.getString("returned_on") : "—" %></td>
      <td style="color:<%= fine > 0 ? "#ff3d5a" : "#00e676" %>; font-weight:600">
        ₹<%= String.format("%.2f", fine) %>
      </td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
    </tr>
    <% } if (!lf) { %>
    <tr><td colspan="8" style="text-align:center;color:#7a8fa8;padding:28px">
      No loan records yet.
    </td></tr>
    <% } lp.close(); lc.close();
    } catch(Exception e) { %>
    <tr><td colspan="8" style="color:#e57373;padding:20px">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(lc!=null)try{lc.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>

<%-- ════════════════════════════════════════════════════════
     TAB 4 — LIBRARIAN PANEL (issue/return)
     ════════════════════════════════════════════════════════ --%>
<% } else if ("librarian".equals(tab) && isLibStaff) { %>

<%-- Issue Book Form --%>
<div class="card" style="margin-bottom:20px">
  <h2>📤 Issue Book to Student</h2>
  <form action="<%=path%>/LibraryServlet" method="post" id="issueForm" novalidate>
    <input type="hidden" name="action" value="issue">
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:14px;align-items:end">
      <div>
        <label>Select Book <span style="color:#e57373">*</span></label>
        <select name="book_id" id="iss_book" required>
          <option value="">-- Select Book --</option>
          <%
          Connection ibc = null;
          try {
              ibc = DBConnection.getConnection();
              ResultSet ibr = ibc.prepareStatement(
                  "SELECT book_id, title, author, available_copies FROM books " +
                  "WHERE available_copies > 0 ORDER BY title").executeQuery();
              while (ibr.next()) {
          %><option value="<%= ibr.getInt("book_id") %>">
            <%= ibr.getString("title") %> — <%= ibr.getString("author") %> (<%=ibr.getInt("available_copies")%> left)
          </option><%
              } ibr.close(); ibc.close();
          } catch(Exception e) { %><option disabled>Error loading books</option><% }
          finally { if(ibc!=null)try{ibc.close();}catch(Exception ig){} }
          %>
        </select>
      </div>
      <div>
        <label>Student User ID <span style="color:#e57373">*</span></label>
        <select name="student_user_id" required>
          <option value="">-- Select Student --</option>
          <%
          Connection suc = null;
          try {
              suc = DBConnection.getConnection();
              ResultSet sur = suc.prepareStatement(
                  "SELECT user_id, username, full_name FROM users WHERE role IN ('student','faculty') ORDER BY role,username"
              ).executeQuery();
              while (sur.next()) {
                  String fn = sur.getString("full_name");
          %><option value="<%= sur.getInt("user_id") %>">
            <%= sur.getString("username") %><%= fn!=null&&!fn.isEmpty()?" — "+fn:"" %>
          </option><%
              } sur.close(); suc.close();
          } catch(Exception e) { %><option disabled>Error</option><% }
          finally { if(suc!=null)try{suc.close();}catch(Exception ig){} }
          %>
        </select>
      </div>
      <div>
        <label>Issued On <span style="color:#e57373">*</span></label>
        <input type="date" name="issued_on" required
               value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
      </div>
      <div>
        <label>Due Date <span style="color:#e57373">*</span></label>
        <input type="date" name="due_date" required>
      </div>
    </div>
    <div style="margin-top:14px">
      <button type="submit" class="btn-primary">📤 Issue Book</button>
    </div>
  </form>
</div>

<%-- Return Book Form --%>
<div class="card">
  <h2>📥 Return Book</h2>
  <form action="<%=path%>/LibraryServlet" method="post">
    <input type="hidden" name="action" value="return">
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:14px;align-items:end">
      <div>
        <label>Issue ID <span style="color:#e57373">*</span></label>
        <input type="number" name="issue_id" placeholder="e.g. 1" required>
      </div>
      <div>
        <label>Book ID <span style="color:#e57373">*</span></label>
        <input type="number" name="book_id" placeholder="e.g. 5" required>
      </div>
      <div>
        <label>Return Date <span style="color:#e57373">*</span></label>
        <input type="date" name="return_date" required
               value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
      </div>
      <div>
        <label>Fine Amount (₹)</label>
        <input type="number" name="fine_amount" step="0.01" placeholder="0.00" value="0">
      </div>
    </div>
    <div style="margin-top:14px">
      <button type="submit" class="btn-primary" style="background:rgba(212,168,67,.15);border-color:rgba(212,168,67,.3);color:#d4a843">
        📥 Process Return
      </button>
    </div>
  </form>
</div>

<%-- ════════════════════════════════════════════════════════
     TAB 5 — ALL REQUESTS (librarian)
     ════════════════════════════════════════════════════════ --%>
<% } else if ("all_requests".equals(tab) && isLibStaff) { %>
<div class="card">
  <h2>📥 All Book Requests</h2>
  <div class="table-wrap"><table>
    <thead>
      <tr><th>#</th><th>Student</th><th>Book Title</th><th>Category</th><th>Req. Date</th><th>Status</th><th>Action</th></tr>
    </thead>
    <tbody>
    <%
    Connection arc = null;
    try {
        arc = DBConnection.getConnection();
        ResultSet arr = arc.prepareStatement(
            "SELECT br.request_id, u.username, u.full_name, b.title, b.category, " +
            "       br.request_date, br.status, b.available_copies, br.book_id " +
            "FROM book_requests br " +
            "JOIN users u ON br.user_id=u.user_id " +
            "JOIN books b ON br.book_id=b.book_id " +
            "ORDER BY br.created_at DESC").executeQuery();
        boolean arf = false;
        while (arr.next()) { arf=true;
            String st = arr.getString("status");
            String bc = "badge-pending";
            if ("approved".equals(st)) bc = "badge-approved";
            if ("rejected".equals(st)) bc = "badge-rejected";
            String fn = arr.getString("full_name");
    %>
    <tr>
      <td style="color:#7a8fa8"><%= arr.getInt("request_id") %></td>
      <td><strong><%= arr.getString("username") %></strong>
          <% if (fn!=null&&!fn.isEmpty()) { %><br><small style="color:#7a8fa8"><%= fn %></small><% } %></td>
      <td style="max-width:200px"><strong><%= arr.getString("title") %></strong></td>
      <td><span class="cat-pill"><%= arr.getString("category") %></span></td>
      <td style="font-size:12px"><%= arr.getString("request_date") %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td>
        <% if ("pending".equals(st)) { %>
        <a href="<%=path%>/LibraryServlet?action=updateRequest&id=<%= arr.getInt("request_id") %>&status=approved"
           class="btn-issue">✓ Approve</a>
        &nbsp;
        <a href="<%=path%>/LibraryServlet?action=updateRequest&id=<%= arr.getInt("request_id") %>&status=rejected"
           class="btn-reject"
           onclick="return confirm('Reject this request?')">✗ Reject</a>
        <% } else { %>
        <span style="color:#7a8fa8;font-size:12px"><%= st %></span>
        <% } %>
      </td>
    </tr>
    <% } if (!arf) { %>
    <tr><td colspan="7" style="text-align:center;color:#7a8fa8;padding:28px">No book requests yet.</td></tr>
    <% } arc.close();
    } catch(Exception e) { %>
    <tr><td colspan="7" style="color:#e57373;padding:20px">Error: <%= e.getMessage() %><br><small>Run library_books.sql first.</small></td></tr>
    <% } finally { if(arc!=null)try{arc.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>

<%-- ════════════════════════════════════════════════════════
     TAB 6 — ALL ACTIVE LOANS (librarian)
     ════════════════════════════════════════════════════════ --%>
<% } else if ("all_loans".equals(tab) && isLibStaff) { %>
<div class="card">
  <h2>📊 All Active Loans</h2>
  <div class="table-wrap"><table>
    <thead>
      <tr><th>#</th><th>Student</th><th>Book</th><th>Issued On</th><th>Due Date</th><th>Fine (₹)</th><th>Status</th><th>Action</th></tr>
    </thead>
    <tbody>
    <%
    Connection alc = null;
    try {
        alc = DBConnection.getConnection();
        ResultSet alr = alc.prepareStatement(
            "SELECT li.issue_id, b.book_id, u.username, b.title, b.author, " +
            "       li.issued_on, li.due_date, li.fine_amount, li.status " +
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
      <td><strong><%= alr.getString("title") %></strong><br>
          <small style="color:#00d2c8"><%= alr.getString("author") %></small></td>
      <td style="font-size:12px"><%= alr.getString("issued_on") %></td>
      <td style="font-size:12px"><%= alr.getString("due_date") %></td>
      <td style="color:<%= fine>0?"#ff3d5a":"#00e676" %>;font-weight:600">₹<%= String.format("%.2f",fine) %></td>
      <td><span class="badge <%= bc %>"><%= st %></span></td>
      <td>
        <% if ("issued".equals(st)) { %>
        <button class="btn-return" 
          onclick="openReturnModal(<%= alr.getInt("issue_id") %>, <%= alr.getInt("book_id") %>, '<%= alr.getString("title").replace("'","\\'") %>')">
          📥 Return
        </button>
        <% } else { %>
        <span style="color:#7a8fa8;font-size:12px">Returned</span>
        <% } %>
      </td>
    </tr>
    <% } if (!alf) { %>
    <tr><td colspan="8" style="text-align:center;color:#7a8fa8;padding:28px">No loan records yet.</td></tr>
    <% } alc.close();
    } catch(Exception e) { %>
    <tr><td colspan="8" style="color:#e57373;padding:20px">Error: <%= e.getMessage() %></td></tr>
    <% } finally { if(alc!=null)try{alc.close();}catch(Exception ig){} } %>
    </tbody>
  </table></div>
</div>
<% } %>

<%-- ── RETURN MODAL ──────────────────────────────────────── --%>
<div class="modal-overlay" id="returnModal">
  <div class="modal-box">
    <button class="modal-close" onclick="closeReturnModal()">✕</button>
    <h3>📥 Process Return</h3>
    <p id="returnBookTitle" style="color:#e2eaf3;margin-bottom:20px;font-weight:600"></p>
    <form action="<%=path%>/LibraryServlet" method="post" id="returnForm" novalidate>
      <input type="hidden" name="action" value="return">
      <input type="hidden" name="issue_id" id="retIssueId">
      <input type="hidden" name="book_id" id="retBookId">
      <div>
        <label>Return Date <span style="color:#e57373">*</span></label>
        <input type="date" name="return_date" id="retDate" required>
        <div class="ferr" id="e_ret_date">Please select a return date.</div>
      </div>
      <div style="margin-top:14px">
        <label>Fine Amount (₹) <small style="color:#7a8fa8">(optional)</small></label>
        <input type="number" name="fine_amount" id="retFine" step="0.01" value="0">
      </div>
      <div style="margin-top:18px;display:flex;gap:12px">
        <button type="submit" class="btn-primary" style="background:rgba(212,168,67,.15);border-color:rgba(212,168,67,.3);color:#d4a843">
          📥 Confirm Return
        </button>
        <button type="button" class="btn-primary"
          style="background:rgba(255,61,90,.15);border-color:rgba(255,61,90,.3);color:#ff3d5a"
          onclick="closeReturnModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>

</main>
</div>
</div>

<%-- ── REQUEST MODAL SCRIPTS ─────────────────────────────── --%>
<script>
function openRequestModal(bookId, bookTitle) {
  document.getElementById('modalBookId').value    = bookId;
  document.getElementById('modalBookTitle').textContent = '📖 ' + bookTitle;
  const today = new Date().toISOString().split('T')[0];
  document.getElementById('reqDate').min   = today;
  document.getElementById('reqDate').value = today;
  document.getElementById('reqModal').classList.add('open');
}
function closeModal() {
  document.getElementById('reqModal').classList.remove('open');
}
function openReturnModal(issueId, bookId, bookTitle) {
  document.getElementById('retIssueId').value = issueId;
  document.getElementById('retBookId').value  = bookId;
  document.getElementById('returnBookTitle').textContent = '📖 Returning: ' + bookTitle;
  const today = new Date().toISOString().split('T')[0];
  document.getElementById('retDate').value = today;
  document.getElementById('retFine').value = "0";
  document.getElementById('returnModal').classList.add('open');
}
function closeReturnModal() {
  document.getElementById('returnModal').classList.remove('open');
}
// Close on overlay click
document.getElementById('reqModal').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});
document.getElementById('returnModal').addEventListener('click', function(e) {
  if (e.target === this) closeReturnModal();
});
// Validate request form
document.getElementById('reqForm').addEventListener('submit', function(e) {
  const dt = document.getElementById('reqDate');
  if (!dt.value) {
    dt.classList.add('is-invalid');
    document.getElementById('e_date').classList.add('show');
    e.preventDefault();
  }
});
// Validate return form
document.getElementById('returnForm').addEventListener('submit', function(e) {
  const dt = document.getElementById('retDate');
  if (!dt.value) {
    dt.classList.add('is-invalid');
    document.getElementById('e_ret_date').classList.add('show');
    e.preventDefault();
  }
});
</script>
</body>
</html>
