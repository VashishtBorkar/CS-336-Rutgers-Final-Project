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
    <li><a href="createItem.jsp">Sell Item</a></li>
    <li><a href="browse.jsp">Browse Items</a></li>
    <li><a href="myAuctions.jsp">My Auctions</a></li>
    <li><a href="myBids.jsp">My Bids</a></li>
    <li><a href="alerts.jsp">My Alerts</a></li>
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
