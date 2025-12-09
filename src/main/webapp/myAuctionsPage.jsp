<%@ page import ="java.sql.*" %>
<%

// check if logged in
int userId = (int) session.getAttribute("id");
if (userId <= 0) {
    response.sendRedirect("index.jsp");
    return;
}


Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme_db","root","newpassword");


StringBuilder sql = new StringBuilder("select * from auction a ");
sql.append("join user u on a.seller_id = u.user_id ");
sql.append("join item i on a.item_id = i.item_id ");
sql.append("join category c on i.category_id = c.category_id ");
sql.append("where a.seller_id = ? ");
sql.append("order by a.start_time desc");


PreparedStatement ps; 
ps = con.prepareStatement(sql.toString());
ps.setInt(1, userId);

ResultSet rs = ps.executeQuery();
%>


<a href="success.jsp">Back</a>
<h2>My Auctions</h2>

<table border="1" cellpadding="8" cellspacing="0">
    <tr>
        <th>Item Name</th>
        <th>Item ID</th>
        <th> Category </th>
        <td><p>Start Time</p></td>
    </tr>
    

<%

while (rs.next()) {
    String itemName = rs.getString("item_name");
    int itemId = rs.getInt("item_id");
    String categoryName = rs.getString("category_name");
    String startTime = rs.getString("start_time");
	
	%>
	
	<tr> 
		<td><p><%= itemName %></p> </td>
		<td><p><%= itemId %></p> </td>
		<td><p><%= categoryName %></p> </td>
		<td><p> <%= startTime %></p></td>
	</tr>
	
	
	<%
}


con.close();
%>





