<%@ page import="java.sql.*" %>
<%

    String keyword = request.getParameter("keyword");
    boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
    if (hasKeyword) {
        keyword = keyword.trim();
    }

    String url  = "jdbc:mysql://localhost:3306/buyme_db";
    String user = "root";
    String pass = "Saransh1!";  

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DriverManager.getConnection(url, user, pass);

        String sql =
            "SELECT sq.question_id, " +
            "       sq.question_text, " +
            "       sq.answer_text, " +
            "       sq.created_at, " +
            "       sq.answered_at, " +
            "       sq.answered_by, " +
            "       u.username AS asker_name " +
            "FROM SupportQuestion sq " +
            "JOIN User u ON sq.user_id = u.user_id " +
            "LEFT JOIN CustomerRepresentative cr ON sq.answered_by = cr.rep_id " +
            "WHERE 1 = 1 ";

        if (hasKeyword) {
            sql += "AND (sq.question_text LIKE ? OR sq.answer_text LIKE ?) ";
        }

        sql += " ORDER BY sq.answered_at DESC";

        ps = conn.prepareStatement(sql);

        if (hasKeyword) {
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
        }

        rs = ps.executeQuery();
%>
<html>
<head>
    <title>Support Questions and Answers</title>
</head>
<body>
<h2>Support Questions and Answers</h2>

<form method="get" action="browseQuestion.jsp">
    <label>Search by keyword:
        <input type="text" name="keyword" value="<%= (hasKeyword ? keyword : "") %>">
    </label>
    <input type="submit" value="Search">
    <a href="browseQuestion.jsp">Clear</a>
</form>

<hr>

<%
        boolean any = false;
        while (rs.next()) {
            any = true;
%>
    <div style="border: 1px solid #ccc; padding: 8px; margin-bottom: 10px;">
        <p><b>Asked by:</b> <%= rs.getString("asker_name") %>
           on <%= rs.getTimestamp("created_at") %></p>

        <p><b>Question:</b><br>
           <%= rs.getString("question_text") %></p>

        <hr>

        <p>
        <b>Answer<%
            Integer repId = (Integer) rs.getObject("answered_by");  // may be null
            if (repId != null) { %> (by representative ID <%= repId %>)<% }
        %>:</b><br>
        <%
            String answer = rs.getString("answer_text");
            if (answer != null) {
        %>
            <%= answer %>
        <%
            } else {
        %>
            <i>Not answered yet.</i>
        <%
            }
        %>
    </p>

        <p><i>Answered at: <%= rs.getTimestamp("answered_at") %></i></p>
    </div>
<%
        }

        if (!any) {
%>
    <p>No questions found.</p>
<%
        }
%>

<p><a href="index.jsp">Back to home</a></p>
</body>
</html>
<%
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>