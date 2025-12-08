<%@ page import="java.sql.*" %>
<%
Integer userId = (Integer) session.getAttribute("id");
if (userId == null) {
    response.sendRedirect("index.jsp");
    return;
}

String submit = request.getParameter("submit");
if (submit != null) {
    String question = request.getParameter("question");
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db","root","Saransh1!");

    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO SupportQuestion (user_id, question_text) VALUES (?, ?)");
    ps.setInt(1, userId);
    ps.setString(2, question);
    ps.executeUpdate();
    ps.close();
    con.close();

    out.println("Question submitted!<br>");
}
%>

<html>
<body>
<h3>Ask Customer Support</h3>
<form method="post">
    <textarea name="question" rows="5" cols="50" required></textarea><br>
    <input type="submit" name="submit" value="Send">
</form>
<br>
<a href="success.jsp">Back</a>
</body>
</html>
