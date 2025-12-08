<%@ page import ="java.sql.*" %>
<%

// check if logged in
String seller = (String) session.getAttribute("user");
if (seller == null) {
    response.sendRedirect("index.jsp");
    return;
}


Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme_db","root","newpassword");

// handle expired auctions
StringBuilder expSQL = new StringBuilder("select * from auction a ");
expSQL.append("where 1=1 ");
expSQL.append("and a.end_time <= NOW() "); // load only active 
expSQL.append("and is_active = true");

PreparedStatement psExp;
psExp = con.prepareStatement(expSQL.toString());

ResultSet expRs = psExp.executeQuery();

while (expRs.next()) {
	int auctionId = expRs.getInt("auction_id");
	int sellerId = expRs.getInt("seller_id");
    int itemId = expRs.getInt("item_id");
    double minPrice = expRs.getDouble("min_price");

    PreparedStatement psBids = con.prepareStatement(
        "SELECT bidder_id, bid_amount " +
        "FROM bid " +
        "WHERE auction_id = ? " +
        "ORDER BY bid_amount DESC LIMIT 1"
    );
    psBids.setInt(1, auctionId);
    ResultSet topBid = psBids.executeQuery();
    
    // handle received no bids
    if (!topBid.next()) {
        PreparedStatement alert = con.prepareStatement(
            "INSERT INTO alerts (user_id, item_id, alert_message) VALUES (?, ?, ?)"
        );
        alert.setInt(1, sellerId);
        alert.setInt(2, expRs.getInt("item_id"));
        alert.setString(3, "Your item received no bids.");
        alert.executeUpdate();
		
    } else {
    	int winnerId = topBid.getInt("bidder_id");
        double highestMax = topBid.getDouble("bid_amount");
        
        // item sold
        if (highestMax >= minPrice) {
        	
        	PreparedStatement alertWinner = con.prepareStatement(
                "INSERT INTO alerts (user_id, item_id, alert_message) VALUES (?, ?, ?)"
            );
            alertWinner.setInt(1, winnerId);
            alertWinner.setInt(2, itemId);
            alertWinner.setString(3, "Congratulations! You won the auction.");
            alertWinner.executeUpdate();

            PreparedStatement alertSeller = con.prepareStatement(
                "INSERT INTO alerts (user_id, item_id, alert_message) VALUES (?, ?, ?)"
            );
            alertSeller.setInt(1, sellerId);
            alertSeller.setInt(2, itemId);
            alertSeller.setString(3, "Your item has been sold.");
            alertSeller.executeUpdate();
        	
        } else {
        	PreparedStatement alertSeller = con.prepareStatement(
                "INSERT INTO alerts (user_id, item_id, alert_message) VALUES (?, ?, ?)"
            );
            alertSeller.setInt(1, sellerId);
            alertSeller.setInt(2, itemId);
            alertSeller.setString(3, "Your item did not meet the minimum price. Highest bid was $" + highestMax);
            alertSeller.executeUpdate();
       
        }
    }
    
    // mark auction as completed
    PreparedStatement psMark = con.prepareStatement(
        "UPDATE auction SET is_active = false WHERE auction_id = ?"
    );
    psMark.setInt(1, auctionId);
    psMark.executeUpdate();    
    
}



// Load active auctions
String itemType = request.getParameter("itemType");
String sortBy = request.getParameter("sortBy");

int categoryId = 0;
if (itemType.equals("shirts")) {
	categoryId = 1;	
} else if (itemType.equals("pants")) {
	categoryId = 2;
} else if (itemType.equals("shoes")){
	categoryId = 3;
}



StringBuilder sql = new StringBuilder("select * from auction a ");
sql.append("join item i on a.item_id = i.item_id ");
sql.append("join category c on i.category_id = c.category_id ");
sql.append("where 1=1 ");
sql.append("and a.is_active = true "); // load only active 
PreparedStatement ps; 


if (categoryId != 0) {
	sql.append(" AND I.category_id = ?");
}

if ("price_asc".equals(sortBy)) {
    sql.append(" ORDER BY A.price ASC");
} else if ("price_desc".equals(sortBy)) {
    sql.append(" ORDER BY A.price DESC");
} else if ("ending_soon".equals(sortBy)) {
    sql.append(" ORDER BY A.end_time ASC");
}

ps = con.prepareStatement(sql.toString());

int paramIndex = 1;
if (!"all".equals(itemType)) {   // only bind if a category was selected
    ps.setInt(paramIndex, categoryId);
    paramIndex++;
}


ResultSet rs = ps.executeQuery();
%>


<a href="browsePage.jsp">Back to search</a>
<h2>Search Results</h2>

<table border="1" cellpadding="8" cellspacing="0">
    <tr>
        <th>Auction ID</th>
        <th>Item ID</th>
        <th>Item Name</th>
        <th>Category</th>
        <th>Price</th>
        <th>End Time</th>
        <th>View</th>
    </tr>
    

<%

while (rs.next()) {
	int auctionId = rs.getInt("auction_id");
    int itemId = rs.getInt("item_id");
    String itemName = rs.getString("item_name");
    String categoryName = rs.getString("category_name");
    double price = rs.getDouble("price");
    String endTime = rs.getString("end_time");
	
	%>
	
	<tr> 
		<td><p><%= auctionId %></p></td>
		<td><p><%= itemId %></p> </td>
		<td><p><%= itemName %></p> </td>
		<td><p><%= categoryName %></p> </td>
		<td><p> $<%= price %></p> </td>
		<td><p> <%= endTime %></p> </td>
		<td><a href="auctionPage.jsp?auctionId=<%= auctionId%>"> View Auction </a> </td>
	</tr>
	
	
	<%
}


con.close();
%>





