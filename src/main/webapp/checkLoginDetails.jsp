<%@ page import ="java.sql.*" %>
<%
    String username = request.getParameter("username");
    String pwd = request.getParameter("password");

    if (username == null || pwd == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db", "root", "Saransh1!"
    );

    String sql = 
        "SELECT u.user_id, " +
        "       CASE " +
        "         WHEN a.user_id IS NOT NULL THEN 'admin' " +
        "         WHEN cr.rep_id IS NOT NULL THEN 'rep' " +
        "         ELSE 'user' " +
        "       END AS role " +
        "FROM User u " +
        "LEFT JOIN Admin a ON u.user_id = a.user_id " +
        "LEFT JOIN CustomerRepresentative cr ON u.user_id = cr.rep_id " +
        "WHERE u.username = ? AND u.password = ?";

    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, username);
    ps.setString(2, pwd);

    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        int userId = rs.getInt("user_id");
        String role  = rs.getString("role");

        session.setAttribute("id", userId);
        session.setAttribute("user", username);
        session.setAttribute("role", role);
        
		out.println("welcome " + username);
		out.println("<a href='logout.jsp'>Log out</a>");
		
        response.sendRedirect("success.jsp");
    } else {
        out.println("Invalid username or password <a href='index.jsp'>Try again</a>");
    }

    rs.close();
    ps.close();
    con.close();
%>

