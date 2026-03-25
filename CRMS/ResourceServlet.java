package com.campus.servlet;
import com.campus.db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/ResourceServlet")
public class ResourceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Read parameters
        String name        = request.getParameter("name");
        String category    = request.getParameter("category");
        String location    = request.getParameter("location");
        String capacityStr = request.getParameter("capacity");
        String status      = request.getParameter("status");
        String description = request.getParameter("description");

        // Validate required fields
        if (name == null || name.trim().isEmpty() ||
            category == null || category.trim().isEmpty() ||
            location == null || location.trim().isEmpty() ||
            capacityStr == null || capacityStr.trim().isEmpty() ||
            status == null || status.trim().isEmpty()) {

            out.println("<p style='color:red;'>Error: All required fields must be filled.</p>");
            return;
        }

        // Validate numeric capacity
        int capacity;
        try {
            capacity = Integer.parseInt(capacityStr.trim());
        } catch (NumberFormatException e) {
            out.println("<p style='color:red;'>Error: Capacity must be numeric.</p>");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();

            // 🔴 Important: Check if connection failed
            if (conn == null) {
                out.println("<p style='color:red;'>Database connection failed.</p>");
                return;
            }

            String sql = "INSERT INTO resources (name, category, location, capacity, status, description) "
                       + "VALUES (?, ?, ?, ?, ?, ?)";

            ps = conn.prepareStatement(sql);
            ps.setString(1, name.trim());
            ps.setString(2, category.trim());
            ps.setString(3, location.trim());
            ps.setInt(4, capacity);
            ps.setString(5, status.trim());
            ps.setString(6, description != null ? description.trim() : "");

            int rows = ps.executeUpdate();

            if (rows > 0) {
                out.println("<p style='color:green;'>Resource added successfully.</p>");
            } else {
                out.println("<p style='color:red;'>Resource could not be added.</p>");
            }

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) { }
            try { if (conn != null) conn.close(); } catch (Exception e) { }
        }
    }
}