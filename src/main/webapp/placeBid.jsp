<%@ page import="java.sql.*, java.text.*" %>

<%
	// get parameters
    int auctionId = Integer.parseInt(request.getParameter("auctionId"));
	double maxBid = Double.parseDouble(request.getParameter("maxBid"));
    double bid = Double.parseDouble(request.getParameter("bidAmount"));

    int userId = (int)session.getAttribute("id");

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db", "root", "newpassword");
	
    // current auction data
    PreparedStatement ps1 = con.prepareStatement(
        "select price, min_increment FROM auction WHERE auction_id = ?"
    );
    ps1.setInt(1, auctionId);
    ResultSet rs = ps1.executeQuery();

    if (!rs.next()) {
        out.println("Auction not found.");
        return;
    }

    double currentPrice = rs.getDouble("price");
    double increment = rs.getDouble("min_increment");

    // check for valid bid
    double requiredMinBid = currentPrice + increment;

    if (bid < requiredMinBid) {
        out.println("<h3>Your bid must be at least $" + requiredMinBid + "</h3>");
        out.println("<a href='auction.jsp?auctionId=" + auctionId + "'>Back</a>");
        return;
    }

    double newCurrentPrice = bid;

    // Insert bid
    PreparedStatement ps2 = con.prepareStatement(
        "INSERT INTO bid (auction_id, bidder_id, bid_amount, max_bid, bid_time) " +
        "VALUES (?, ?, ?, ?, NOW())"
    );
    ps2.setInt(1, auctionId);
    ps2.setInt(2, userId);
    ps2.setDouble(3, newCurrentPrice);
    ps2.setDouble(4, maxBid);
    ps2.executeUpdate();

    // update auction price
    PreparedStatement ps3 = con.prepareStatement(
        "UPDATE auction SET price = ? WHERE auction_id = ?"
    );
    ps3.setDouble(1, newCurrentPrice);
    ps3.setInt(2, auctionId);
    ps3.executeUpdate();

    // 7. Redirect back to item page
    response.sendRedirect("auctionPage.jsp?auctionId=" + auctionId);
%>
