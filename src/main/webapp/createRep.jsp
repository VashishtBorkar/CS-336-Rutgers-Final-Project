<%@ page import="java.sql.*" %>
<%
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("admin")) {
    response.sendRedirect("success.jsp");
    return;
}

String username = request.getParameter("username");
String password = request.getParameter("password");
String email    = request.getParameter("email");

if (username == null || password == null || email == null ||
    username.trim().isEmpty() || password.trim().isEmpty() || email.trim().isEmpty()) {
    out.println("All fields are required. <a href='createRepForm.jsp'>Try again</a>");
    return;
}

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/buyme_db",
    "root",
    "Saransh1!"  
);

// first insert into user
String insertUser = "INSERT INTO user (username, password, email) VALUES (?, ?, ?)";
PreparedStatement psUser = con.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS);
psUser.setString(1, username);
psUser.setString(2, password);
psUser.setString(3, email);

int userRows = psUser.executeUpdate();

if (userRows == 0) {
    psUser.close();
    con.close();
    out.println("Could not create user. <a href='createRepForm.jsp'>Try again</a>");
    return;
}

ResultSet rsKeys = psUser.getGeneratedKeys();
int newUserId = -1;
if (rsKeys.next()) {
    newUserId = rsKeys.getInt(1);
}
rsKeys.close();
psUser.close();

String insertRep = "INSERT INTO CustomerRepresentative (rep_id) VALUES (?)";
PreparedStatement psRep = con.prepareStatement(insertRep);
psRep.setInt(1, newUserId);
psRep.executeUpdate();
psRep.close();

con.close();

out.println("Customer representative created successfully. <a href='success.jsp'>Back to menu</a>");
%>
