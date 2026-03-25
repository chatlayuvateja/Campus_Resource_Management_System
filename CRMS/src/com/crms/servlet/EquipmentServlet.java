package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/EquipmentServlet")
public class EquipmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.html"); return;
        }
        int userId = (Integer) session.getAttribute("user_id");

        String resourceId = request.getParameter("resource_id");
        String date       = request.getParameter("date");
        String time       = request.getParameter("time");
        String purpose    = request.getParameter("purpose");

        if (resourceId==null||resourceId.trim().isEmpty()||
            date==null||date.trim().isEmpty()||
            time==null||time.trim().isEmpty()||
            purpose==null||purpose.trim().isEmpty()) {
            response.sendRedirect("equipment.jsp?error=missing"); return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO equipment_requests(user_id, resource_id, req_date, req_time, purpose) VALUES(?,?,?,?,?)");
            ps.setInt(1, userId);
            ps.setInt(2, Integer.parseInt(resourceId.trim()));
            ps.setString(3, date.trim());
            ps.setString(4, time.trim());
            ps.setString(5, purpose.trim());
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("equipment.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("equipment.jsp?error=db");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ig) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String status = request.getParameter("status");
        if (id == null || status == null) { response.sendRedirect("admin.jsp?tab=equipment"); return; }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE equipment_requests SET status=? WHERE request_id=?");
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("admin.jsp?tab=equipment&updated=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?tab=equipment");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ig) {}
        }
    }
}
