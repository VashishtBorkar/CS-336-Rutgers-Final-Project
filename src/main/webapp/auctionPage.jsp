<%@ page import="java.sql.*" %>
<%
    int auctionId = Integer.parseInt(request.getParameter("auctionId"));

	Class.forName("com.mysql.jdbc.Driver");
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme_db","root","newpassword");

    PreparedStatement psAuction = con.prepareStatement(
        "select i.item_id, i.item_name, i.item_desc, c.category_name, " +
        "a.price, a.min_increment, a.end_time " +
        "from auction a " +
        "join item i on a.item_id = i.item_id " +
        "join category c on i.category_id = c.category_id " +
        "where a.auction_id = ?"
    );
    
    psAuction.setInt(1, auctionId);
    ResultSet auctionRs = psAuction.executeQuery();

    if (!auctionRs.next()) {
        out.println("<h2>Auction not found.</h2>");
        return;
    }
%>

<p><strong>Name:</strong> <%= auctionRs.getString("item_name") %></p>
<p><strong>Category:</strong> <%= auctionRs.getString("category_name") %></p>
<p><strong>Description:</strong><%= auctionRs.getString("item_desc") %></p>
<p><strong>Current Price:</strong> $<%= auctionRs.getDouble("price") %></p>
<p><strong>Minimum Increment:</strong> $<%= auctionRs.getDouble("min_increment") %></p>
<p><strong>Auction Ends:</strong> <%= auctionRs.getTimestamp("end_time") %></p>

<hr>


<h2>Place a New Bid</h2>
<form action="placeBid.jsp" method="post">
    <input type="hidden" name="auctionId" value="<%= auctionId %>">
    
	<label>Bid:</label>
    <input type="number" name="bidAmount" step="0.01" required>
    
    <label>Your Max Bid Amount:</label>
    <input type="number" name="maxBid" step="0.01" required>
    

    <button type="submit">Submit Bid</button>
</form>

<hr>

 
<h2>Bid History</h2>
<table border="1">
    <tr>
        <th> User</th>
        <th>Bid Price</th>
        <th>Bid Time</th>
    </tr>

<%
    PreparedStatement psHistory = con.prepareStatement(
        "select u.username, b.bid_amount, b.bid_time " +
        "from bid b " +
        "join user u on b.bidder_id = u.user_id " +
        "where b.auction_id = ? " +
        "order by b.bid_time DESC"
    );

    psHistory.setInt(1, auctionId);
    ResultSet bidRs = psHistory.executeQuery();

    while (bidRs.next()) {
%>
    <tr>
        <td><%= bidRs.getString("username") %></td>
        <td>$<%= bidRs.getDouble("bid_amount") %></td>
        <td><%= bidRs.getTimestamp("bid_time") %></td>
    </tr>
<%
    }
%>
</table>

<hr>


<a href="browsePage.jsp">Back to Search</a>
