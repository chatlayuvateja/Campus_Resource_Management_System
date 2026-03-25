@echo off
REM ============================================================
REM  CRMS — COMPILE ALL SERVLETS
REM  Run from inside the CRMS_final folder
REM  Requires: Tomcat installed at C:\apache-tomcat-9.0.xx
REM ============================================================

SET TOMCAT_HOME=C:\apache-tomcat-9.0.115
SET LIB=%TOMCAT_HOME%\lib\servlet-api.jar
SET MYSQL_JAR=WEB-INF\lib\mysql-connector-j-9.6.0.jar
SET SRC=src\com\crms
SET OUT=WEB-INF\classes

echo Compiling all servlets and filters...

javac -cp "%LIB%;%MYSQL_JAR%" -d "%OUT%" ^
  %SRC%\db\DBConnection.java ^
  %SRC%\servlet\AuthFilter.java ^
  %SRC%\servlet\LoginServlet.java ^
  %SRC%\servlet\RegisterServlet.java ^
  %SRC%\servlet\LogoutServlet.java ^
  %SRC%\servlet\ResourceServlet.java ^
  %SRC%\servlet\BookingServlet.java ^
  %SRC%\servlet\EquipmentServlet.java ^
  %SRC%\servlet\ComplaintServlet.java ^
  %SRC%\servlet\MaintenanceServlet.java ^
  %SRC%\servlet\AnnouncementServlet.java ^
  %SRC%\servlet\LibraryServlet.java

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! All files compiled. Copy this folder to:
    echo   %TOMCAT_HOME%\webapps\CRMS_final
    echo Then start Tomcat and open:
    echo   http://localhost:8080/CRMS_final/login.html
) ELSE (
    echo.
    echo ERROR: Compilation failed. Check the error messages above.
    echo Make sure TOMCAT_HOME is set correctly in this file.
)
pause
