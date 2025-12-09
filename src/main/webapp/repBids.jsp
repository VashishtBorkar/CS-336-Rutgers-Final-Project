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
    int bidId = Integer.parseInt(request.getParameter("bid_id"));
    PreparedStatement ps = con.prepareStatement("DELETE FROM Bid WHERE bid_id=?");
    ps.setInt(1, bidId);
    ps.executeUpdate();
    ps.close();
}

Statement st = con.createStatement();
ResultSet rs = st.executeQuery(
   "SELECT b.bid_id, b.auction_id, u.username, b.max_bid, b.bid_time " +
   "FROM Bid b JOIN User u ON b.bidder_id = u.user_id " +
   "ORDER BY b.bid_time DESC");
%>

<html>
<body>
<h3>Manage Bids</h3>
<table border="1">
<tr><th>Bid ID</th><th>Auction</th><th>Bidder</th><th>Amount</th><th>Time</th><th>Delete</th></tr>
<%
while (rs.next()) {
%>
<tr>
<td><%= rs.getInt("bid_id") %></td>
<td><%= rs.getInt("auction_id") %></td>
<td><%= rs.getString("username") %></td>
<td><%= rs.getBigDecimal("max_bid") %></td>
<td><%= rs.getTimestamp("bid_time") %></td>
<td>
<form method="post" onsubmit="return confirm('Delete this bid?');">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="bid_id" value="<%= rs.getInt("bid_id") %>">
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
