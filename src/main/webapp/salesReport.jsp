 <%@ page import="java.sql.*" %>
<%
    // Only admins allowed
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect("index.jsp");
        return;
    }

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db",
        "root",
        "Saransh1!"
    );
%>
<html>
<head>
    <title>Admin Sales Reports</title>
</head>
<body>
<h2>Sales Reports</h2>
<a href="success.jsp">Back to main menu</a><br><br>

<%
    //total earnings
    String totalSql =
        "SELECT SUM(s.final_price) AS total_earnings " +
        "FROM ( " +
        "  SELECT a.auction_id, a.item_id, MAX(b.max_bid) AS final_price " +
        "  FROM Auction a JOIN Bid b ON a.auction_id = b.auction_id " +
        "  WHERE a.end_time <= NOW() AND b.max_bid >= a.min_price " +
        "  GROUP BY a.auction_id, a.item_id " +
        ") AS s";
    PreparedStatement ps = con.prepareStatement(totalSql);
    ResultSet rs = ps.executeQuery();
    double totalEarnings = 0.0;
    if (rs.next()) {
        totalEarnings = rs.getDouble("total_earnings");
    }
    rs.close();
    ps.close();
%>
<h3>Total Earnings</h3>
<p><%= totalEarnings %></p>

<%
    // earnings per item
    String perItemSql =
        "SELECT s.item_id, SUM(s.final_price) AS item_earnings " +
        "FROM ( " +
        "  SELECT a.auction_id, a.item_id, MAX(b.max_bid) AS final_price " +
        "  FROM Auction a JOIN Bid b ON a.auction_id = b.auction_id " +
        "  WHERE a.end_time <= NOW() AND b.max_bid >= a.min_price " +
        "  GROUP BY a.auction_id, a.item_id " +
        ") AS s " +
        "GROUP BY s.item_id " +
        "ORDER BY item_earnings DESC";
    ps = con.prepareStatement(perItemSql);
    rs = ps.executeQuery();
%>
<h3>Earnings per Item</h3>
<table border="1">
    <tr><th>Item ID</th><th>Earnings</th></tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("item_id") %></td>
        <td><%= rs.getDouble("item_earnings") %></td>
    </tr>
<%
    }
    rs.close();
    ps.close();
%>
</table>

<%
    // earnings per item type
    String perTypeSql =
        "SELECT c.category_id, c.category_name AS name, " +
        "       SUM(s.final_price) AS category_earnings " +
        "FROM ( " +
        "  SELECT a.auction_id, a.item_id, MAX(b.max_bid) AS final_price " +
        "  FROM Auction a JOIN Bid b ON a.auction_id = b.auction_id " +
        "  WHERE a.end_time <= NOW() AND b.max_bid >= a.min_price " +
        "  GROUP BY a.auction_id, a.item_id " +
        ") AS s " +
        "JOIN Item i ON s.item_id = i.item_id " +
        "JOIN Category c ON i.category_id = c.category_id " +
        "GROUP BY c.category_id, c.category_name " +
        "ORDER BY category_earnings DESC";
    ps = con.prepareStatement(perTypeSql);
    rs = ps.executeQuery();
%>
<h3>Earnings per Item Type</h3>
<table border="1">
    <tr><th>Category</th><th>Earnings</th></tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getString("category_name") %></td>
        <td><%= rs.getDouble("category_earnings") %></td>
    </tr>
<%
    }
    rs.close();
    ps.close();
%>
</table>

<%
    // earnings per seller
    String perSellerSql =
        "SELECT u.user_id, u.username, SUM(s.final_price) AS seller_earnings " +
        "FROM ( " +
        "  SELECT a.auction_id, a.item_id, MAX(b.max_bid) AS final_price " +
        "  FROM Auction a JOIN Bid b ON a.auction_id = b.auction_id " +
        "  WHERE a.end_time <= NOW() AND b.max_bid >= a.min_price " +
        "  GROUP BY a.auction_id, a.item_id " +
        ") AS s " +
        "JOIN Item i ON s.item_id = i.item_id " +
        "JOIN User u ON i.seller_id = u.user_id " +
        "GROUP BY u.user_id, u.username " +
        "ORDER BY seller_earnings DESC";
    ps = con.prepareStatement(perSellerSql);
    rs = ps.executeQuery();
%>
<h3>Earnings per Seller</h3>
<table border="1">
    <tr><th>User ID</th><th>Username</th><th>Earnings</th></tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("user_id") %></td>
        <td><%= rs.getString("username") %></td>
        <td><%= rs.getDouble("seller_earnings") %></td>
    </tr>
<%
    }
    rs.close();
    ps.close();
%>
</table>

<%
    // best buyers
    String bestBuyerSql =
        "SELECT u.user_id, u.username, SUM(w.final_price) AS total_spent " +
        "FROM ( " +
        "  SELECT a.auction_id, b.bidder_id, b.max_bid AS final_price " +
        "  FROM Auction a JOIN Bid b ON a.auction_id = b.auction_id " +
        "  WHERE a.end_time <= NOW() AND b.max_bid >= a.min_price " +
        "    AND b.max_bid = ( " +
        "      SELECT MAX(b2.max_bid) FROM Bid b2 WHERE b2.auction_id = a.auction_id " +
        "    ) " +
        ") AS w " +
        "JOIN User u ON w.bidder_id = u.user_id " +
        "GROUP BY u.user_id, u.username " +
        "ORDER BY total_spent DESC " +
        "LIMIT 10";
    ps = con.prepareStatement(bestBuyerSql);
    rs = ps.executeQuery();
%>
<h3>Best Buyers (Top 10 by money spent)</h3>
<table border="1">
    <tr><th>User ID</th><th>Username</th><th>Total Spent</th></tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("user_id") %></td>
        <td><%= rs.getString("username") %></td>
        <td><%= rs.getDouble("total_spent") %></td>
    </tr>
<%
    }
    rs.close();
    ps.close();

    con.close();
%>
</table>

</body>
</html>
