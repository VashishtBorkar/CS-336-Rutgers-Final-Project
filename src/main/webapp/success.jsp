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

Welcome <%= user %>
<a href="logout.jsp">Log out</a>

<h3>Main Menu</h3>
<ul>

    <li><a href="createItemPage.jsp">Sell Item</a></li>
    <li><a href="browsePage.jsp">Browse Items</a></li>
    <li><a href="myAuctions.jsp">My Auctions</a></li>
    <li><a href="myBids.jsp">My Bids</a></li>
    <li><a href="alertsPage.jsp">My Alerts</a></li>
	<li><a href="askQuestion.jsp">Contact Customer Support</a></li>

</ul>

<%
if ("admin".equals(role)) {
%>
    <h3>Admin Menu</h3>
    <ul>
        <li><a href="createRepForm.jsp">Create Customer Representative</a></li>
        <li><a href="salesReport.jsp">Sales Reports</a></li>
    </ul>
<%
}
%>

<%
if ("rep".equals(role)) {
%>
	<h3>Customer Representative Menu</h3>
	<ul>
		<li><a href="repQuestions.jsp">Customer Questions</a></li>
    	<li><a href="repEditUser.jsp">Manage Users</a></li>
    	<li><a href="repBids.jsp">Manage Bids</a></li>
    	<li><a href="repAuctions.jsp">Manage Auctions</a></li>
	</ul>
<%
}
%>