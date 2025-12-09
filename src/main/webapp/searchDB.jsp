<%@ page import="java.sql.*" %>
<%
    // Require login (you already had this)
    String seller = (String) session.getAttribute("user");
    if (seller == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // DB setup
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buyme_db",
        "root",
        "Saransh1!"
    );

    try {
        StringBuilder expSQL = new StringBuilder();
        expSQL.append("SELECT * FROM auction a ");
        expSQL.append("WHERE a.end_time <= NOW() ");
        expSQL.append("AND a.is_active = true");

        PreparedStatement psExp = con.prepareStatement(expSQL.toString());
        ResultSet expRs = psExp.executeQuery();

        while (expRs.next()) {
            int auctionId = expRs.getInt("auction_id");
            int sellerId  = expRs.getInt("seller_id");
            int itemId    = expRs.getInt("item_id");
            double minPrice = expRs.getDouble("min_price");

            // find top bid
            PreparedStatement psBids = con.prepareStatement(
                "SELECT bidder_id, bid_amount " +
                "FROM bid " +
                "WHERE auction_id = ? " +
                "ORDER BY bid_amount DESC LIMIT 1"
            );
            psBids.setInt(1, auctionId);
            ResultSet topBid = psBids.executeQuery();

            if (!topBid.next()) {
                // no bids
                PreparedStatement alert = con.prepareStatement(
                    "INSERT INTO alerts (user_id, item_id, alert_message, created_at) " +
                    "VALUES (?, ?, ?, NOW())"
                );
                alert.setInt(1, sellerId);
                alert.setInt(2, itemId);
                alert.setString(3, "Your item received no bids.");
                alert.executeUpdate();
                alert.close();
            } else {
                int winnerId   = topBid.getInt("bidder_id");
                double highest = topBid.getDouble("bid_amount");

                if (highest >= minPrice) {
                    PreparedStatement alertWinner = con.prepareStatement(
                        "INSERT INTO alerts (user_id, item_id, alert_message, created_at) " +
                        "VALUES (?, ?, ?, NOW())"
                    );
                    alertWinner.setInt(1, winnerId);
                    alertWinner.setInt(2, itemId);
                    alertWinner.setString(3, "Congratulations! You won the auction.");
                    alertWinner.executeUpdate();
                    alertWinner.close();

                    PreparedStatement alertSeller = con.prepareStatement(
                        "INSERT INTO alerts (user_id, item_id, alert_message, created_at) " +
                        "VALUES (?, ?, ?, NOW())"
                    );
                    alertSeller.setInt(1, sellerId);
                    alertSeller.setInt(2, itemId);
                    alertSeller.setString(3, "Your item has been sold.");
                    alertSeller.executeUpdate();
                    alertSeller.close();
                } else {
                    // not sold: reserve not met
                    PreparedStatement alertSeller = con.prepareStatement(
                        "INSERT INTO alerts (user_id, item_id, alert_message, created_at) " +
                        "VALUES (?, ?, ?, NOW())"
                    );
                    alertSeller.setInt(1, sellerId);
                    alertSeller.setInt(2, itemId);
                    alertSeller.setString(3,
                        "Your item did not meet the minimum price. Highest bid was $" + highest);
                    alertSeller.executeUpdate();
                    alertSeller.close();
                }
            }

            topBid.close();
            psBids.close();

            // mark auction inactive
            PreparedStatement psMark = con.prepareStatement(
                "UPDATE auction SET is_active = false WHERE auction_id = ?"
            );
            psMark.setInt(1, auctionId);
            psMark.executeUpdate();
            psMark.close();
        }
        expRs.close();
        psExp.close();

        String itemType = request.getParameter("itemType"); // "all", "shirts", "pants", "shoes"
        String sortBy   = request.getParameter("sortBy");   // price_asc, price_desc, ending_soon

        if (itemType == null) {
            itemType = "all";
        }

        String shirtSizeFilter = request.getParameter("shirtSizeFilter"); // XS/S/M/L/XL
        String waistFilter     = request.getParameter("waistFilter");     // int
        String lengthFilter    = request.getParameter("lengthFilter");    // int
        String shoeSizeFilter  = request.getParameter("shoeSizeFilter");  // int

        int categoryId = 0;
        if ("shirts".equals(itemType)) {
            categoryId = 1;
        } else if ("pants".equals(itemType)) {
            categoryId = 2;
        } else if ("shoes".equals(itemType)) {
            categoryId = 3;
        }
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.auction_id, a.item_id, i.item_name, c.category_name, ");
        sql.append("       a.price, a.end_time ");
        sql.append("FROM auction a ");
        sql.append("JOIN item i ON a.item_id = i.item_id ");
        sql.append("JOIN category c ON i.category_id = c.category_id ");

        boolean needShirts = "shirts".equals(itemType) ||
                             (shirtSizeFilter != null && !shirtSizeFilter.isEmpty());
        boolean needPants  = "pants".equals(itemType) ||
                             (waistFilter != null && !waistFilter.isEmpty()) ||
                             (lengthFilter != null && !lengthFilter.isEmpty());
        boolean needShoes  = "shoes".equals(itemType) ||
                             (shoeSizeFilter != null && !shoeSizeFilter.isEmpty());

        if (needShirts) {
            sql.append("LEFT JOIN shirts sh ON i.item_id = sh.item_id ");
        }
        if (needPants) {
            sql.append("LEFT JOIN pants p ON i.item_id = p.item_id ");
        }
        if (needShoes) {
            sql.append("LEFT JOIN shoes s ON i.item_id = s.item_id ");
        }

        sql.append("WHERE a.is_active = true ");

        // Filter by category if not "all"
        if (!"all".equals(itemType) && categoryId != 0) {
            sql.append("AND c.category_id = ? ");
        }

        // Category-specific filters
        if (shirtSizeFilter != null && !shirtSizeFilter.isEmpty()) {
            sql.append("AND sh.size = ? ");
        }
        if (waistFilter != null && !waistFilter.isEmpty()) {
            sql.append("AND p.waist = ? ");
        }
        if (lengthFilter != null && !lengthFilter.isEmpty()) {
            sql.append("AND p.length = ? ");
        }
        if (shoeSizeFilter != null && !shoeSizeFilter.isEmpty()) {
            sql.append("AND s.size = ? ");
        }

        // Sort
        if ("price_asc".equals(sortBy)) {
            sql.append("ORDER BY a.price ASC ");
        } else if ("price_desc".equals(sortBy)) {
            sql.append("ORDER BY a.price DESC ");
        } else if ("ending_soon".equals(sortBy)) {
            sql.append("ORDER BY a.end_time ASC ");
        } else {
            sql.append("ORDER BY a.end_time ASC ");
        }

        PreparedStatement ps = con.prepareStatement(sql.toString());

        int paramIndex = 1;

        if (!"all".equals(itemType) && categoryId != 0) {
            ps.setInt(paramIndex++, categoryId);
        }
        if (shirtSizeFilter != null && !shirtSizeFilter.isEmpty()) {
            ps.setString(paramIndex++, shirtSizeFilter);
        }
        if (waistFilter != null && !waistFilter.isEmpty()) {
            ps.setInt(paramIndex++, Integer.parseInt(waistFilter));
        }
        if (lengthFilter != null && !lengthFilter.isEmpty()) {
            ps.setInt(paramIndex++, Integer.parseInt(lengthFilter));
        }
        if (shoeSizeFilter != null && !shoeSizeFilter.isEmpty()) {
            ps.setInt(paramIndex++, Integer.parseInt(shoeSizeFilter));
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
            int auctionId   = rs.getInt("auction_id");
            int itemId      = rs.getInt("item_id");
            String itemName = rs.getString("item_name");
            String categoryName = rs.getString("category_name");
            double price    = rs.getDouble("price");
            String endTime  = rs.getString("end_time");
%>
    <tr>
        <td><%= auctionId %></td>
        <td><%= itemId %></td>
        <td><%= itemName %></td>
        <td><%= categoryName %></td>
        <td>$<%= price %></td>
        <td><%= endTime %></td>
        <td><a href="auctionPage.jsp?auctionId=<%= auctionId %>">View Auction</a></td>
    </tr>
<%
        }

        rs.close();
        ps.close();
    } finally {
        con.close();
    }
%>
</table>