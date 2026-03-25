package com.crms.db;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection getConnection(){

        Connection conn = null;

        try{

            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/campus_rms",
                "root",
                "yuva@2005"
            );

            System.out.println("Connected to database");

        }catch(Exception e){
            e.printStackTrace();
        }

        return conn;
    }
}