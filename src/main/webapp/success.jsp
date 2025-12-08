<%
String user = (String) session.getAttribute("user");
String role = (String) session.getAttribute("role");

if (user == null) {
%>

	You are not logged in<br/>
	<a href="index.jsp">Please Login</a>

<%
	return;
} 
%>

Welcome <%=session.getAttribute("user")%> 
<a href='logout.jsp'>Log out</a>'


<h3>Main Menu</h3>

<ul>

	<li><a href="selling-items/createItemPage.jsp"> Sell Item </a> </li>
	<li><a href="browsePage.jsp">Browse Items</a></li>
    <li><a href="myAuctions.jsp">My Auctions</a></li>
    <li><a href="myBids.jsp">My Bids</a></li>
    <li><a href="alertsPage.jsp">My Alerts</a></li>
	
</ul>


