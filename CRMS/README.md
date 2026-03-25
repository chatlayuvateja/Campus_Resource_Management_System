# Campus Resource Management System (CRMS)

A comprehensive, role-based web application designed to streamline and automate the daily operations of a university or college campus. Built with **Java Servlets**, **JSP**, and **MySQL**, CRMS provides a centralized platform for managing everything from library books and lab equipment to facility bookings and maintenance requests.

---

## 🚀 Features

### 👥 Role-Based Access Control (RBAC)
Secure, role-specific dashboards tailored for completely different user experiences.
- **Student / Faculty:** Request resources, book rooms, borrow books, and raise complaints.
- **Admin:** Full oversight of users, resources, requests, and system configurations.
- **Librarian:** Manage library catalog, approve book requests, track active loans, and process returns/fines.
- **Lab Technician / Warden:** Manage specific departmental resources, approve equipment requests, and handle maintenance.

### 📚 Comprehensive Library Management
- **Search & Filter:** Browse the entire library catalog with real-time availability tracking.
- **Request System:** Students can request books online; librarians can approve or reject these requests.
- **Active Loan Tracking:** Issuing, returning, and managing overdue fines are handled seamlessly with a dedicated Librarian Panel.

### 🏢 Facility & Equipment Booking
- **Resource Reservations:** Book seminar halls, digital labs, sports grounds, and specialized equipment.
- **Conflict Prevention:** Start and end time tracking ensures no double-booking occurs.

### 🛠️ Maintenance & Complaint Helpdesk
- **Ticketing System:** Users can easily report issues in hostels, classrooms, or labs.
- **Status Updates:** Staff route and update tickets (Pending -> In Progress -> Resolved), keeping the campus well-maintained.

### 📢 Targeted Announcements
- Admins can broadcast messages to specific roles (e.g., "All Students", "All Faculty") or the entire campus. Important notifications appear directly on user dashboards.

---

## 💻 Tech Stack
- **Frontend:** HTML5, CSS3, JavaScript (Vanilla), JSP (JavaServer Pages)
- **Backend:** Java Servlets, JDBC (Java Database Connectivity)
- **Database:** MySQL 8.0
- **Server:** Apache Tomcat 9/10

---

## 🛠️ Installation & Setup

### Prerequisites
- Java Development Kit (JDK 8 or higher)
- Apache Tomcat (v9.0 or higher recommended)
- MySQL Server

### 1. Database Configuration
1. Open your MySQL client (e.g., MySQL Workbench or Command Line).
2. Run the provided database initialization scripts in the exact order:
   - `setup_database.sql` (Creates schemas, tables, and seeds initial resource data)
   - `library_books.sql` (Seeds the library catalog)

### 2. Configure Database Connection
Update the database connection parameters to match your local MySQL credentials.
Open `src/com/crms/db/DBConnection.java` and modify:
```java
private static final String URL  = "jdbc:mysql://localhost:3306/campus_rms";
private static final String USER = "root";       // Your MySQL Username
private static final String PASS = "password";   // Your MySQL Password
```

### 3. Build & Deploy
1. Place the `CRMS` directory inside Tomcat's `webapps` folder: `[Tomcat_Path]/webapps/CRMS`.
2. Compile the Java Servlets. If you are on Windows, you can run the provided batch script:
   ```cmd
   cd C:\apache-tomcat-9.0.115\webapps\CRMS
   compile.bat
   ```
3. Start the Apache Tomcat Server.
   ```cmd
   [Tomcat_Path]\bin\startup.bat
   ```

### 4. Access the Application
Open your web browser and navigate to:  
`http://localhost:8080/CRMS/login.html`

*(You can register a new test user account from the registration page. By default, new users are assigned the "student" role unless modified by an Admin in the database).*

---

## 📄 License
This project is licensed under the MIT License. Feel free to use, modify, and distribute it as needed.
