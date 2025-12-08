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

if ("delete".equals(action)) {
    int aucId = Integer.parseInt(request.getParameter("auction_id"));

    PreparedStatement psB = con.prepareStatement("DELETE FROM Bid WHERE auction_id=?");
    psB.setInt(1, aucId);
    psB.executeUpdate();
    psB.close();

    PreparedStatement psA = con.prepareStatement("DELETE FROM Auction WHERE auction_id=?");
    psA.setInt(1, aucId);
    psA.executeUpdate();
    psA.close();
}

Statement st = con.createStatement();
ResultSet rs = st.executeQuery(
    "SELECT a.auction_id, a.item_id, a.start_time, a.end_time, i.seller_id " +
    "FROM Auction a JOIN Item i ON a.item_id = i.item_id " +
    "ORDER BY a.end_time DESC");
%>

<html>
<body>
<h3>Manage Auctions</h3>
<table border="1">
<tr><th>Auction ID</th><th>Item</th><th>Seller</th><th>Start</th><th>End</th><th>Delete</th></tr>
<%
while (rs.next()) {
%>
<tr>
<td><%= rs.getInt("auction_id") %></td>
<td><%= rs.getInt("item_id") %></td>
<td><%= rs.getInt("seller_id") %></td>
<td><%= rs.getTimestamp("start_time") %></td>
<td><%= rs.getTimestamp("end_time") %></td>
<td>
<form method="post" onsubmit="return confirm('Delete this auction?');">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="auction_id" value="<%= rs.getInt("auction_id") %>">
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
