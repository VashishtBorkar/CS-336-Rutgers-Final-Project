<%@ page import ="java.sql.*" %>
<%
	String username = request.getParameter("username");
	String pwd = request.getParameter("password");
	Class.forName("com.mysql.jdbc.Driver");
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme_db","root","newpassword");
	Statement st = con.createStatement();
	ResultSet rs;
	rs = st.executeQuery("select * from user where username='" + username + "' and password='" + pwd + "'");
	if (rs.next()) {
		int userId = rs.getInt("user_id");
		session.setAttribute("id", userId);
		session.setAttribute("user", username);
		
		out.println("welcome " + username);
		out.println("<a href='logout.jsp'>Log out</a>");
		response.sendRedirect("success.jsp");
	} else {
		out.println("Invalid password <a href='index.jsp'>try again</a>");
	}
	rs.close();
	st.close();
	con.close();
%>