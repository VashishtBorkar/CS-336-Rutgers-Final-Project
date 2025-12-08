<%@ page import ="java.sql.*" %>
<%

// check if logged in
String seller = (String) session.getAttribute("user");
if (seller == null) {
    response.sendRedirect("index.jsp");
    return;
}


// check if actual submission or just changing field
String finalSubmit = request.getParameter("finalSubmit");
int sellerId = (int) session.getAttribute("id");

// load page again if changed dropdown
if (finalSubmit == null) {
    request.getRequestDispatcher("createItem.jsp").forward(request, response);
    return;
}

// insert item if final submission
String itemType = request.getParameter("itemType");

int categoryId = 0;
if (itemType.equals("shirts")) {
	categoryId = 1;	
} else if (itemType.equals("pants")) {
	categoryId = 2;
} else {
	categoryId = 3;
}

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/buyme_db","root","newpassword");



String insertItem = "INSERT INTO Item (category_id, seller_id) VALUES (?, ?)";
PreparedStatement psItem = con.prepareStatement(insertItem, Statement.RETURN_GENERATED_KEYS);
psItem.setInt(1, categoryId);
psItem.setInt(2, sellerId);

psItem.executeUpdate();

ResultSet rs = psItem.getGeneratedKeys();
int itemId = -1;
if (rs.next()) {
    itemId = rs.getInt(1);
}
rs.close();
psItem.close();


if(categoryId == 1) { // Shirt
    String shirtSize = request.getParameter("shirtSize");

    String sql = "insert into shirts (item_id, size) values (?, ?)";
    PreparedStatement psShirt = con.prepareStatement(sql);
    psShirt.setInt(1, itemId);
    psShirt.setString(2, shirtSize);
    psShirt.executeUpdate();
    psShirt.close();

} else if(categoryId == 2) { // Add Pants
    int waist = Integer.parseInt(request.getParameter("waistSize"));
    int length = Integer.parseInt(request.getParameter("length"));
    
    String sql = "insert into pants (item_id, waist, length) values (?, ?, ?)";
    PreparedStatement psPants = con.prepareStatement(sql);
    psPants.setInt(1, itemId);
    psPants.setInt(2, waist);
    psPants.setInt(3, length);
    psPants.executeUpdate();
    psPants.close();

} else if(categoryId == 3) { // Add Shoes
    int shoeSize = Integer.parseInt(request.getParameter("shoeSize"));
    String sql = "insert into shoes (item_id, size) values (?, ?)";
    PreparedStatement psShoes = con.prepareStatement(sql);

    psShoes.setInt(1, itemId);
    psShoes.setInt(2, shoeSize);
    psShoes.executeUpdate();
    psShoes.close();
}

java.util.Date now = new java.util.Date();
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
String startDate = sdf.format(now);


double startPrice = Double.parseDouble(request.getParameter("startPrice"));
double minPrice = Double.parseDouble(request.getParameter("minPrice"));
double minIncrement = Double.parseDouble(request.getParameter("minIncrement"));
String endDate = request.getParameter("endDate");
endDate = endDate.replace("T", " ");

String insertAuction = "insert into Auction (item_id, start_time, end_time, price, min_increment, min_price) values (?, ?, ?, ?, ?, ?)";
PreparedStatement psAuction = con.prepareStatement(insertAuction);

psAuction.setInt(1, itemId);
psAuction.setString(2, startDate);
psAuction.setString(3, endDate);
psAuction.setDouble(4, startPrice);
psAuction.setDouble(5, minIncrement);
psAuction.setDouble(6, minPrice);


int rows = psAuction.executeUpdate();
psAuction.close();

if (rows > 0) {
    out.println("Successfully created auction");
    System.out.println("Auction inserted: itemId=" + itemId + ", category=" + categoryId + 
                       ", start=" + startDate + ", end=" + endDate +
                       ", minPrice=" + minPrice + ", increment=" + minIncrement);

    response.sendRedirect("success.jsp");
} else {
    out.println("Failed to create auction.");
}
con.close();
%>





