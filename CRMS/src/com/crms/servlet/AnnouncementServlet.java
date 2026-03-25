package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AnnouncementServlet")
public class AnnouncementServlet extends HttpServlet {

    /** POST – admin/faculty posts an announcement */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (Integer) session.getAttribute("user_id");

        String title      = request.getParameter("ann-title");
        String targetRole = request.getParameter("ann-target");
        String message    = request.getParameter("ann-body");

        // ── server-side validation ──────────────────────────────────────
        if (title   == null || title.trim().isEmpty() ||
            message == null || message.trim().isEmpty()) {
            response.sendRedirect("announcements.jsp?error=missing");
            return;
        }
        if (targetRole == null || targetRole.trim().isEmpty()) {
            targetRole = "all";
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO announcements (user_id, title, message, target_role) VALUES (?,?,?,?)");
            ps.setInt(1, userId);
            ps.setString(2, title.trim());
            ps.setString(3, message.trim());
            ps.setString(4, targetRole.trim());
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("announcements.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("announcements.jsp?error=db");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /** GET – admin deletes an announcement */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String id     = request.getParameter("id");

        if ("delete".equals(action) && id != null) {
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM announcements WHERE ann_id=?");
                ps.setInt(1, Integer.parseInt(id));
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("announcements.jsp?success=deleted");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("announcements.jsp?error=db");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            }
        } else {
            response.sendRedirect("announcements.jsp");
        }
    }
}
