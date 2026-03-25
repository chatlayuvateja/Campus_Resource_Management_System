package com.crms.servlet;

import com.crms.db.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.html"); return;
        }
        int userId = (int) session.getAttribute("user_id");

        String resourceId = request.getParameter("resource_id");
        String startTime  = request.getParameter("start_time");
        String endTime    = request.getParameter("end_time");
        String purpose    = request.getParameter("purpose");

        if (resourceId==null||resourceId.trim().isEmpty()||
            startTime==null||startTime.trim().isEmpty()||
            endTime==null||endTime.trim().isEmpty()||
            purpose==null||purpose.trim().isEmpty()) {
            response.sendRedirect("bookings.jsp?error=missing"); return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO bookings(user_id, resource_id, start_time, end_time, purpose) VALUES(?,?,?,?,?)");
            ps.setInt(1, userId);
            ps.setInt(2, Integer.parseInt(resourceId.trim()));
            ps.setString(3, startTime.replace("T", " "));
            ps.setString(4, endTime.replace("T", " "));
            ps.setString(5, purpose.trim());
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("bookings.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("bookings.jsp?error=db");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ig) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String status = request.getParameter("status");
        if (id == null || status == null) { response.sendRedirect("admin.jsp?tab=bookings"); return; }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE bookings SET status=? WHERE booking_id=?");
            ps.setString(1, status);
            ps.setInt(2, Integer.parseInt(id));
            ps.executeUpdate();
            ps.close();
            response.sendRedirect("admin.jsp?tab=bookings&updated=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?tab=bookings");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ig) {}
        }
    }
}
