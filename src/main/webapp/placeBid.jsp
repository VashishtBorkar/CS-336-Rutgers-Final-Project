<%@ page import="java.sql.*, java.text.*, java.util.*" 
%>

<%

    int userId = (int)session.getAttribute("id");

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db", "root", "newpassword");
    
    // get parameters
    int auctionId = Integer.parseInt(request.getParameter("auctionId"));
	
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
    
    String bidType = (String) request.getParameter("bidType");
	double maxBid = 0;
	double bid = 0;
	
	if (bidType.equals("manual")) {
		bid = Double.parseDouble(request.getParameter("bidAmount"));
		maxBid = bid;
	} else if (bidType.equals("auto")) {
		maxBid = Double.parseDouble(request.getParameter("maxBid"));
		bid = currentPrice + increment;
	}

    // check for valid bid
    double requiredMinBid = currentPrice + increment;

    if (bid < requiredMinBid) {
        out.println("<h3>Your bid must be at least $" + requiredMinBid + "</h3>");
        out.println("<a href='auctionPage.jsp?auctionId=" + auctionId + "'>Back</a>");
        return;
    }

    double newCurrentPrice = bid;

    // Insert bid
    PreparedStatement ps2 = con.prepareStatement(
        "INSERT INTO bid (auction_id, bidder_id, bid_amount, max_bid, bid_type, bid_time) " +
        "VALUES (?, ?, ?, ?, ?, NOW())"
    );
    ps2.setInt(1, auctionId);
    ps2.setInt(2, userId);
    ps2.setDouble(3, newCurrentPrice);
    ps2.setDouble(4, maxBid);
    ps2.setString(5, bidType);
    ps2.executeUpdate();

    // update auction price
    PreparedStatement ps3 = con.prepareStatement(
        "UPDATE auction SET price = ? WHERE auction_id = ?"
    );
    ps3.setDouble(1, newCurrentPrice);
    ps3.setInt(2, auctionId);
    ps3.executeUpdate();
    
    
    
    // handle other bidders
    /*
    PreparedStatement psAll = con.prepareStatement(
    	"SELECT b.bidder_id, b.bid_amount, b.max_bid, " +
    	"a.item_id, i.item_name " +
    	"FROM bid b " +
    	"join auction a on b.auction_id = a.auction_id " +
    	"join item i on i.item_id = a.item_id " +
    	"WHERE b.auction_id = ? " + 
    	"ORDER BY b.max_bid DESC, b.bid_time ASC " 
	 );
    */
    
    
    // Handle other bidders on same auction
    PreparedStatement psAll = con.prepareStatement(
    	    "SELECT b.bidder_id, " +
    	    "       MAX(b.max_bid) AS max_bid, " +
    	    "       MAX(b.bid_amount) AS bid_amount, " +
    	    "       a.item_id, i.item_name " +
    	    "FROM bid b " +
    	    "JOIN auction a ON b.auction_id = a.auction_id " +
    	    "JOIN item i ON i.item_id = a.item_id " +
    	    "WHERE b.auction_id = ? " +
    	    "GROUP BY b.bidder_id, a.item_id, i.item_name " +
    	    "ORDER BY max_bid DESC"
    	);
	 psAll.setInt(1, auctionId);
	 ResultSet allBids = psAll.executeQuery();
	 
	 List<Integer> bidderIds = new ArrayList<>();
	 List<Double> maxBids = new ArrayList<>();
	 List<Double> bidAmounts = new ArrayList<>();
	 
	 int itemId = -1;
	 String itemName = "";

	 while (allBids.next()) {
	     bidderIds.add(allBids.getInt("bidder_id"));
	     maxBids.add(allBids.getDouble("max_bid"));
	     bidAmounts.add(allBids.getDouble("bid_amount"));
	     
	     if (itemId == -1) {
	    	 itemId = allBids.getInt("item_id");
	    	 itemName = allBids.getString("item_name");
	     }
	 }
	 
	 
	 
	// handle bidders with higher max bid.
	if (bidderIds.size() > 1) {
		int topBidder = bidderIds.get(0);
		double highestMax = maxBids.get(0);
		double secondMax = maxBids.get(1);
		
		if (highestMax > newCurrentPrice) {
			double autoBidPrice = secondMax + increment;

	        if (autoBidPrice > highestMax) {
	            autoBidPrice = highestMax;

	            // alert highest bidder that max reached
	            PreparedStatement psWarn = con.prepareStatement(
	                "INSERT INTO alerts (user_id, item_id, alert_message) " +
	                "VALUES (?, ?, ?)"
	            );
	            psWarn.setInt(1, topBidder);
	            psWarn.setInt(2, itemId);
	            psWarn.setString(3, "Your automatic bid max was reached for item '" + itemName + "'.");
	            psWarn.executeUpdate();
	        } else if (topBidder != userId){
	        	
	        	// Insert automatic bid row
	            PreparedStatement psAuto = con.prepareStatement(
	            		"INSERT INTO bid (auction_id, bidder_id, bid_amount, max_bid, bid_type, bid_time) " +
	            		"VALUES (?, ?, ?, ?, ?, NOW())"
	            );
	            psAuto.setInt(1, auctionId);
	            psAuto.setInt(2, topBidder);
	            psAuto.setDouble(3, autoBidPrice);
	            psAuto.setDouble(4, highestMax);
	            psAuto.setString(5, bidType);
	            psAuto.executeUpdate();

	            // Update auction price
	            PreparedStatement psUpd = con.prepareStatement(
	                "UPDATE auction SET price = ? WHERE auction_id = ?"
	            );
	            psUpd.setDouble(1, autoBidPrice);
	            psUpd.setInt(2, auctionId);
	            psUpd.executeUpdate();
	        }
		}
	}
	
	// handle bidders who have been outbid
		 for (int i = 0; i < bidderIds.size(); i++) {
			if (maxBids.get(i) < newCurrentPrice) {
			    PreparedStatement psAlert = con.prepareStatement(
			        "INSERT INTO alerts (user_id, item_id, alert_message) VALUES (?, ?, ?)"
			    );
			    psAlert.setInt(1, bidderIds.get(i));
			    psAlert.setInt(2, itemId);
			    psAlert.setString(3, "You have been outbid on item '" + itemName + "'.");
			    psAlert.executeUpdate();
			}
			
		}
	 

    // 7. Redirect back to item page
    response.sendRedirect("auctionPage.jsp?auctionId=" + auctionId);
%>
