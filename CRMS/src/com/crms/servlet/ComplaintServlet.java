package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ComplaintServlet")
public class ComplaintServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.html"); return;
        }
        int userId = (Integer) session.getAttribute("user_id");

        String category    = request.getParameter("category");
        String title       = request.getParameter("complaint-title");
        String description = request.getParameter("complaint-desc");

        if (category==null||category.trim().isEmpty()||
            title==null||title.trim().isEmpty()||
            description==null||description.trim().isEmpty()) {
            response.sendRedirect("complaints.jsp?error=missing"); return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO complaints(user_id, category, title, description) VALUES(?,?,?,?)");
            ps.setInt(1, userId);
            ps.setString(2, category.trim());
            ps.setString(3, title.trim());
            ps.setString(4, description.trim());
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("complaints.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("complaints.jsp?error=db");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ig) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String status = request.getParameter("status");
        if (id == null || status == null) { response.sendRedirect("admin.jsp?tab=complaints"); return; }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE complaints SET status=? WHERE complaint_id=?");
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("admin.jsp?tab=complaints&updated=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?tab=complaints");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ig) {}
        }
    }
}
