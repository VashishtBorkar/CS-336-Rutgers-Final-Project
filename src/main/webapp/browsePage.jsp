<!DOCTYPE html>
<html>
<head>
    <title>Browse Auctions</title>
</head>
<body>
<h2>Browse Auctions</h2>

<form action="searchDB.jsp" method="get">
    <label for="itemType">Select Category:</label>
    <select name="itemType" id="itemType">
        <option value="all">-- All --</option>
        <option value="shirts">Shirts</option>
        <option value="pants">Pants</option>
        <option value="shoes">Shoes</option>
    </select>
    
    <label for="sortBy">Sort by:</label>
    <select name="sortBy" id="sortBy">
        <option value="">Select One</option>
        <option value="price_asc">Price Ascending</option>
        <option value="price_desc">Price Descending</option>
        <option value="ending_soon">Ending Soon</option>
    </select>
    
    <button type="submit">Search</button>
</form>



<hr>

<a href="success.jsp">Back</a>

</body>
</html>
