<%
if (session.getAttribute("user") == null) {
   response.sendRedirect("index.jsp");
   return;
}

String itemType = request.getParameter("itemType");
if (itemType == null) {
	itemType = "shirts";
}

%>

<html>
<head>
    <title>Create Auction</title>
</head>

<form action="createAuction.jsp" method="post">

    Item Type:
    <select name="itemType" onchange="this.form.submit()" required>
        <option value="shirts" <%= itemType.equals("shirts") ? "selected" : "" %>>Shirt</option>
	    <option value="pants" <%= itemType.equals("pants") ? "selected" : "" %>>Pants</option>
	    <option value="shoes" <%= itemType.equals("shoes") ? "selected" : "" %>>Shoes</option>
    </select>
    <br><br>

<%


if (itemType.equals("shirts")) {
%>

	Shirt Size:
    <select name="shirtSize">
        <option>XS</option>
        <option>S</option>
        <option>M</option>
        <option>L</option>
        <option>XL</option>
    </select>
    		
<%
} else if (itemType.equals("pants")) {
	// System.out.println("Shoe Size: <input type=\"number\" name=\"shoeSize\" step=\"1\" required>");
%>

	Waist Size:
	<input type="number" name="waistSize" step="1" required>
	
	Pant Length:
	<input type="number" name="length" step="1" required>
	
	
<%

} else {
	// System.out.println("Waist Size: <input type=\"number\" name=\"waistSize\" step=\"1\" required>");
	// System.out.println("Pant Length: <input type=\"number\" name=\"length\" step=\"1\" required>");
	
%>

	Shoe Size:
    <input type="number" name="shoeSize" step="1" required>
    
<%
}
%>

<br><br>
	
	Start Price:
    <input type="number" name="startPrice" step="0.01" required>
    <br><br>
    
    
    Reserve Price:
    <input type="number" name="minPrice" step="0.01" required>
    <br><br>
    
    Minimum Increment:
    <input type="number" name="minIncrement" step="0.01" required>
    <br><br>

    End Date and Time:
    <input type="datetime-local" name="endDate" required>
    <br><br>

    <input type="submit" name="finalSubmit" value="Create Auction">

</form>

<br>

<a href="success.jsp">Back</a>
</html>

