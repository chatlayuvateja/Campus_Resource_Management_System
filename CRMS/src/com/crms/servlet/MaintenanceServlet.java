package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/MaintenanceServlet")
public class MaintenanceServlet extends HttpServlet {

    /** POST – any logged-in user submits a maintenance request */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        String resourceId  = request.getParameter("resource_id");
        String issueType   = request.getParameter("issue_type");
        String description = request.getParameter("description");

        // ── server-side validation ──────────────────────────────────────
        if (resourceId  == null || resourceId.trim().isEmpty() ||
            issueType   == null || issueType.trim().isEmpty()  ||
            description == null || description.trim().isEmpty()) {
            response.sendRedirect("maintainance.jsp?error=missing");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO maintenance_requests "
                       + "(user_id, resource_id, issue_title, description) VALUES (?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, Integer.parseInt(resourceId.trim()));
            ps.setString(3, issueType.trim());
            ps.setString(4, description.trim());
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("maintainance.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("maintainance.jsp?error=db");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /** GET – admin updates the status of a request */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id     = request.getParameter("id");
        String status = request.getParameter("status");

        if (id == null || status == null) {
            response.sendRedirect("admin.jsp?tab=maintenance");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                    "UPDATE maintenance_requests SET status=? WHERE request_id=?");
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("admin.jsp?tab=maintenance&updated=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?tab=maintenance");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }
}
