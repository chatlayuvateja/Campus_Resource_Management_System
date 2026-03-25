package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LibraryServlet")
public class LibraryServlet extends HttpServlet {

    // ── POST: Student submits book request ─────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.html"); return;
        }

        String action = request.getParameter("action");

        // ── Student: Request a book ─────────────────────────────────────
        if ("request".equals(action)) {
            int    userId      = (int) session.getAttribute("user_id");
            String bookIdStr   = request.getParameter("book_id");
            String requestDate = request.getParameter("request_date");
            String purpose     = request.getParameter("purpose");

            if (bookIdStr == null || bookIdStr.trim().isEmpty() ||
                requestDate == null || requestDate.trim().isEmpty()) {
                response.sendRedirect("library.jsp?error=missing"); return;
            }

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();

                // Check if student already has a pending request for this book
                PreparedStatement chk = conn.prepareStatement(
                    "SELECT COUNT(*) FROM book_requests WHERE user_id=? AND book_id=? AND status='pending'");
                chk.setInt(1, userId);
                chk.setInt(2, Integer.parseInt(bookIdStr));
                ResultSet cr = chk.executeQuery();
                cr.next();
                if (cr.getInt(1) > 0) {
                    response.sendRedirect("library.jsp?error=already_requested"); return;
                }
                chk.close();

                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO book_requests (user_id, book_id, request_date, purpose) VALUES (?,?,?,?)");
                ps.setInt(1, userId);
                ps.setInt(2, Integer.parseInt(bookIdStr.trim()));
                ps.setString(3, requestDate.trim());
                ps.setString(4, purpose != null ? purpose.trim() : "");
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("library.jsp?success=requested");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("library.jsp?error=db");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ig) {}
            }

        // ── Librarian/Admin: Issue a book ──────────────────────────────
        } else if ("issue".equals(action)) {
            String bookIdStr  = request.getParameter("book_id");
            String userIdStr  = request.getParameter("student_user_id");
            String issuedOn   = request.getParameter("issued_on");
            String dueDate    = request.getParameter("due_date");
            int    issuedBy   = (int) session.getAttribute("user_id");

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();

                // Check availability
                PreparedStatement chk = conn.prepareStatement(
                    "SELECT available_copies FROM books WHERE book_id=?");
                chk.setInt(1, Integer.parseInt(bookIdStr));
                ResultSet rc = chk.executeQuery();
                if (!rc.next() || rc.getInt(1) < 1) {
                    response.sendRedirect("library.jsp?tab=librarian&error=no_copies"); return;
                }
                chk.close();

                // Insert issue record
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO library_issues (user_id, book_id, issued_on, due_date, issued_by) VALUES (?,?,?,?,?)");
                ps.setInt(1, Integer.parseInt(userIdStr));
                ps.setInt(2, Integer.parseInt(bookIdStr));
                ps.setString(3, issuedOn);
                ps.setString(4, dueDate);
                ps.setInt(5, issuedBy);
                ps.executeUpdate();
                ps.close();

                // Reduce available copies
                PreparedStatement upd = conn.prepareStatement(
                    "UPDATE books SET available_copies = available_copies - 1 WHERE book_id=?");
                upd.setInt(1, Integer.parseInt(bookIdStr));
                upd.executeUpdate();
                upd.close();

                // If there was a pending request for this user+book, mark it approved
                PreparedStatement req = conn.prepareStatement(
                    "UPDATE book_requests SET status='approved' WHERE user_id=? AND book_id=? AND status='pending'");
                req.setInt(1, Integer.parseInt(userIdStr));
                req.setInt(2, Integer.parseInt(bookIdStr));
                req.executeUpdate();
                req.close();

                response.sendRedirect((request.getHeader("referer")!=null&&request.getHeader("referer").contains("admin.jsp")?"admin.jsp?tab=library":"library.jsp?tab=librarian") + "&success=issued");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("library.jsp?tab=librarian&error=db");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ig) {}
            }

        // ── Librarian/Admin: Return a book ─────────────────────────────
        } else if ("return".equals(action)) {
            String issueIdStr = request.getParameter("issue_id");
            String bookIdStr  = request.getParameter("book_id");
            String returnDate = request.getParameter("return_date");
            String fineStr    = request.getParameter("fine_amount");

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();

                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE library_issues SET returned_on=?, fine_amount=?, status='returned' WHERE issue_id=?");
                ps.setString(1, returnDate);
                ps.setDouble(2, fineStr != null && !fineStr.isEmpty() ? Double.parseDouble(fineStr) : 0.0);
                ps.setInt(3, Integer.parseInt(issueIdStr));
                ps.executeUpdate();
                ps.close();

                // Increase available copies
                PreparedStatement upd = conn.prepareStatement(
                    "UPDATE books SET available_copies = available_copies + 1 WHERE book_id=?");
                upd.setInt(1, Integer.parseInt(bookIdStr));
                upd.executeUpdate();
                upd.close();

                response.sendRedirect((request.getHeader("referer")!=null&&request.getHeader("referer").contains("admin.jsp")?"admin.jsp?tab=library":"library.jsp?tab=librarian") + "&success=returned");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("library.jsp?tab=librarian&error=db");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ig) {}
            }

        // ── Admin: Reject a book request ───────────────────────────────
        } else if ("reject".equals(action)) {
            String reqIdStr = request.getParameter("request_id");
            String remarks  = request.getParameter("remarks");

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE book_requests SET status='rejected', remarks=? WHERE request_id=?");
                ps.setString(1, remarks != null ? remarks : "Request rejected.");
                ps.setInt(2, Integer.parseInt(reqIdStr));
                ps.executeUpdate();
                ps.close();
                response.sendRedirect((request.getHeader("referer")!=null&&request.getHeader("referer").contains("admin.jsp")?"admin.jsp?tab=library":"library.jsp?tab=librarian") + "&success=rejected");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("library.jsp?tab=librarian&error=db");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ig) {}
            }

        } else {
            response.sendRedirect("library.jsp");
        }
    }

    // ── GET: Admin updates request status ──────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action    = request.getParameter("action");
        String requestId = request.getParameter("id");
        String status    = request.getParameter("status");

        if ("updateRequest".equals(action) && requestId != null && status != null) {
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE book_requests SET status=? WHERE request_id=?");
                ps.setString(1, status);
                ps.setInt(2, Integer.parseInt(requestId));
                ps.executeUpdate();
                ps.close();
                response.sendRedirect((request.getHeader("referer")!=null&&request.getHeader("referer").contains("admin.jsp")?"admin.jsp?tab=library&updated=1":"library.jsp?tab=librarian&success=updated"));
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("library.jsp?tab=librarian");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ig) {}
            }
        } else {
            response.sendRedirect("library.jsp");
        }
    }
}
