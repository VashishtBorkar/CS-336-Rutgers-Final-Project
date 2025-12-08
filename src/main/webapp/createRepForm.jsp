<%
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("admin")) {
    response.sendRedirect("success.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Customer Representative</title>
</head>
<body>
<h2>Create Customer Representative</h2>

<form action="createRep.jsp" method="post">
    Username: <input type="text" name="username" required><br><br>
    Password: <input type="password" name="password" required><br><br>
    Email:    <input type="email" name="email" required><br><br>

    <input type="submit" value="Create Representative">
</form>

<br>
<a href="success.jsp">Back to Main Menu</a>
</body>
</html>
