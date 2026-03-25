package com.crms.servlet;

import com.crms.db.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

protected void doPost(HttpServletRequest request, HttpServletResponse response)
throws ServletException, IOException {

response.setContentType("text/html");
PrintWriter out = response.getWriter();

String username = request.getParameter("username");
String fullname = request.getParameter("fullname");
String email = request.getParameter("email");
String password = request.getParameter("password");
String idnumber = request.getParameter("idnumber");
String role = request.getParameter("role");

try{

Connection conn = DBConnection.getConnection();

String sql = "INSERT INTO users(username,password,full_name,email,id_number,role) VALUES(?,?,?,?,?,?)";

PreparedStatement ps = conn.prepareStatement(sql);

ps.setString(1, request.getParameter("username"));
ps.setString(2, request.getParameter("password"));
ps.setString(3, request.getParameter("fullname"));
ps.setString(4, request.getParameter("email"));
ps.setString(5, request.getParameter("idnumber"));
ps.setString(6, request.getParameter("role"));

ps.executeUpdate();

response.sendRedirect("login.html");

}catch(Exception e){

e.printStackTrace();
out.println("Error: "+e.getMessage());

}

}
}