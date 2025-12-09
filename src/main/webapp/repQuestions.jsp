<%@ page import="java.sql.*" %>
<%
String role = (String) session.getAttribute("role");
Integer repUserId = (Integer) session.getAttribute("id");
if (role == null || !role.equals("rep")) {
    response.sendRedirect("index.jsp");
    return;
}

String answerSubmit = request.getParameter("answerSubmit");
if (answerSubmit != null) {
    int qid = Integer.parseInt(request.getParameter("question_id"));
    String answer = request.getParameter("answer");
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db","root","Saransh1!");

    PreparedStatement psRep = con.prepareStatement(
        "SELECT rep_id FROM CustomerRepresentative WHERE rep_id = ?");
    psRep.setInt(1, repUserId);
    ResultSet rsRep = psRep.executeQuery();
    int repId = repUserId;
    if (rsRep.next()) {
        repId = rsRep.getInt("rep_id");
    }
    rsRep.close();
    psRep.close();

    PreparedStatement ps = con.prepareStatement(
       "UPDATE SupportQuestion " +
       "SET answer_text = ?, answered_at = NOW(), answered_by = ? " +
       "WHERE question_id = ?");
    ps.setString(1, answer);
    ps.setInt(2, repId);
    ps.setInt(3, qid);
    ps.executeUpdate();
    ps.close();
    con.close();
}

Class.forName("com.mysql.jdbc.Driver");
Connection con2 = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/buyme_db","root","Saransh1!");
Statement st = con2.createStatement();
ResultSet rs = st.executeQuery(
    "SELECT q.question_id, u.username, q.question_text, q.answer_text " +
    "FROM SupportQuestion q JOIN User u ON q.user_id = u.user_id " +
    "ORDER BY q.created_at DESC");
%>

<html>
<body>
<h3>Customer Questions</h3>
<table border="1">
<tr>
    <th>ID</th><th>User</th><th>Question</th><th>Answer</th><th>Reply</th>
</tr>
<%
while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("question_id") %></td>
    <td><%= rs.getString("username") %></td>
    <td><%= rs.getString("question_text") %></td>
    <td><%= rs.getString("answer_text") %></td>
    <td>
        <form method="post">
            <input type="hidden" name="question_id" value="<%= rs.getInt("question_id") %>">
            <textarea name="answer" rows="3" cols="30"></textarea><br>
            <input type="submit" name="answerSubmit" value="Reply / Update">
        </form>
    </td>
</tr>
<%
}
rs.close();
st.close();
con2.close();
%>
</table>
<br><a href="success.jsp">Back</a>
</body>
</html>
