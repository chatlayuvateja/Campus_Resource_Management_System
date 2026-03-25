<%-- Public registration page --%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register - CRMS</title>
<link rel="stylesheet" href="styles.css">
</head>

<body>

<div class="login-wrapper">
<div class="login-card">

<h1>Register User</h1>

<form action="RegisterServlet" method="post">

<label>Username</label>
<input type="text" name="username" required>

<label>Full Name</label>
<input type="text" name="fullname" required>

<label>Email</label>
<input type="email" name="email" required>

<label>Password</label>
<input type="password" name="password" required>

<label>ID Number</label>
<input type="text" name="idnumber" required>

<label>Role</label>
<select name="role" required>

<option value="">Select Role</option>

<option value="student">Student</option>

<option value="faculty">Faculty</option>

<option value="librarian">Librarian</option>

<option value="labtech">Lab Technician</option>

<option value="warden">Hostel Warden</option>

<option value="admin">Admin</option>

</select>

<button class="btn-primary">Register</button>

</form>

<p>Already registered? <a href="login.html">Login</a></p>

</div>
</div>

</body>
</html>