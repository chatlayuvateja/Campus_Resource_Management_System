package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ResourceServlet")
public class ResourceServlet extends HttpServlet {

    /** POST – insert a new resource into the database */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name        = request.getParameter("resource_name");
        String type        = request.getParameter("resource_type");
        String description = request.getParameter("description");   // ← was missing
        String location    = request.getParameter("location");

        // ── server-side validation ──────────────────────────────────────
        if (name     == null || name.trim().isEmpty() ||
            type     == null || type.trim().isEmpty() ||
            location == null || location.trim().isEmpty()) {
            response.sendRedirect("resource_register.jsp?error=missing_fields");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();

            // ── PreparedStatement with all 4 columns ────────────────────
            String sql = "INSERT INTO resources (resource_name, resource_type, description, location) "
                       + "VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name.trim());
            ps.setString(2, type.trim());
            ps.setString(3, description == null ? "" : description.trim());
            ps.setString(4, location.trim());
            ps.executeUpdate();
            ps.close();

            response.sendRedirect("resource_register.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("resource_register.jsp?error=db");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    /** GET – admin can delete a resource */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String id     = request.getParameter("id");

        if ("delete".equals(action) && id != null && !id.isEmpty()) {
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM resources WHERE resource_id = ?");
                ps.setInt(1, Integer.parseInt(id));
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("resource_register.jsp?success=deleted");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("resource_register.jsp?error=db");
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            }
        } else {
            response.sendRedirect("resource_register.jsp");
        }
    }
}
