<!DOCTYPE html>
<html>
<head>
    <title>Browse Auctions</title>
    <script>
        function updateFilters() {
            var type = document.getElementById("itemType").value;
            document.getElementById("shirtFilters").style.display = (type === "shirts") ? "block" : "none";
            document.getElementById("pantsFilters").style.display = (type === "pants") ? "block" : "none";
            document.getElementById("shoeFilters").style.display  = (type === "shoes")  ? "block" : "none";
        }
        window.onload = updateFilters;
    </script>
</head>
<body>
<h2>Browse Auctions</h2>

<form action="searchDB.jsp" method="get">
    <label for="itemType">Select Category:</label>
    <select name="itemType" id="itemType" onchange="updateFilters()">
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

    <br><br>

    <div id="shirtFilters" style="display:none;">
        <label>Shirt size:
            <select name="shirtSizeFilter">
                <option value="">Any</option>
                <option value="XS">XS</option>
                <option value="S">S</option>
                <option value="M">M</option>
                <option value="L">L</option>
                <option value="XL">XL</option>
            </select>
        </label>
    </div>

    <div id="pantsFilters" style="display:none;">
        <label>Waist:
            <input type="number" name="waistFilter" min="20" max="60">
        </label>
        <label>Length:
            <input type="number" name="lengthFilter" min="24" max="40">
        </label>
    </div>

    <div id="shoeFilters" style="display:none;">
        <label>Shoe size:
            <input type="number" name="shoeSizeFilter" step="0.5">
        </label>
    </div>

    <br><br>
    <button type="submit">Search</button>
</form>

<hr>

<a href="success.jsp">Back</a>

</body>
</html>