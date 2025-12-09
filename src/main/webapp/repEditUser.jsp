<%@ page import="java.sql.*" %>
<%
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("rep")) {
    response.sendRedirect("index.jsp");
    return;
}

String action = request.getParameter("action");
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/buyme_db","root","Saransh1!");

if ("update".equals(action)) {
    int id = Integer.parseInt(request.getParameter("user_id"));
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");
    String name = request.getParameter("name");

    PreparedStatement ps = con.prepareStatement(
        "UPDATE User SET username=?, password=?, email=?, name=? WHERE user_id=?");
    ps.setString(1, username);
    ps.setString(2, password);
    ps.setString(3, email);
    ps.setString(4, name);
    ps.setInt(5, id);
    ps.executeUpdate();
    ps.close();
} else if ("delete".equals(action)) {
    int id = Integer.parseInt(request.getParameter("user_id"));
    PreparedStatement ps = con.prepareStatement(
        "DELETE FROM User WHERE user_id=?");
    ps.setInt(1, id);
    ps.executeUpdate();
    ps.close();
}

Statement st = con.createStatement();
ResultSet rs = st.executeQuery("SELECT user_id, username, email, name FROM User");
%>

<html>
<body>
<h3>Edit / Delete Users</h3>
<table border="1">
<tr><th>ID</th><th>Username</th><th>Email</th><th>Name</th><th>Edit</th><th>Delete</th></tr>
<%
while (rs.next()) {
    int uid = rs.getInt("user_id");
%>
<tr>
<td><%= uid %></td>
<td><%= rs.getString("username") %></td>
<td><%= rs.getString("email") %></td>
<td><%= rs.getString("name") %></td>
<td>
<form method="post">
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="user_id" value="<%= uid %>">
    Username: <input type="text" name="username" value="<%= rs.getString("username") %>"><br>
    Password: <input type="text" name="password"><br>
    Email: <input type="text" name="email" value="<%= rs.getString("email") %>"><br>
    Name: <input type="text" name="name" value="<%= rs.getString("name") %>"><br>
    <input type="submit" value="Save">
</form>
</td>
<td>
<form method="post" onsubmit="return confirm('Delete this user?');">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="user_id" value="<%= uid %>">
    <input type="submit" value="Delete">
</form>
</td>
</tr>
<%
}
rs.close();
st.close();
con.close();
%>
</table>
<br><a href="success.jsp">Back</a>
</body>
</html>
