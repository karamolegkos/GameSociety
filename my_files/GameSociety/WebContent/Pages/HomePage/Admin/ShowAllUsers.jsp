<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sun.jersey.api.client.Client" %>
<%@ page import="com.sun.jersey.api.client.ClientResponse" %>
<%@ page import="com.sun.jersey.api.client.WebResource" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<% 
	Client client = Client.create();
	WebResource webResource = client.resource("http://localhost:8080/GameSociety/rest/GameSociety/testForCellarDB");
	ClientResponse myresponse = webResource.get(ClientResponse.class);
%>
<%

	int userID = -1;
	String nickName = "";
	String profilePicturePath = "";
	String link = "";
	JSONArray allUsers = new JSONArray();
	if(session.getAttribute("adminID") == null){
		response.sendRedirect("../../welcome/login.jsp");
	}
	else{
		userID = (int)session.getAttribute("userID");
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getUser/";
		link+=userID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		JSONObject user = new JSONObject(myresponse.getEntity(String.class));
		nickName = user.getString("nickName");
		profilePicturePath = user.getString("profilePicturePath");
	}
%>
<%
	if(session.getAttribute("adminID") != null){
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getAllUsers/";
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		allUsers = new JSONArray(myresponse.getEntity(String.class));
	}

	if(request.getParameter("GoToProfile")!=null){
		int profileUser = Integer.parseInt(request.getParameter("userID"));
		session.setAttribute("profileUserID",profileUser);
		response.sendRedirect("../Profile/UserProfile.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>All Users - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../HomePage.css">
<link rel="stylesheet" href="../MainPage.css">
<body>
	<ul class="topnav">
	  <li><a class="active" href="../HomePage.jsp">Home Page</a></li>
	  <li><a href="../Search/SearchSelection.jsp">Search Users</a></li>
	  <li><a href="../ShowFreeGames/FreeGamesSelection.jsp">Free Games</a></li>
	  <li><a href="../MyGames/MyGames.jsp">Games I Play</a></li>
	  <%
	  if(session.getAttribute("adminID") != null){
	  %>
	  <li><a href="ShowAllUsers.jsp">Show All Users</a></li>
	  <%
	  }
	  %>
	  <li><a href="../LogOut.jsp">Log out</a></li>
	  <li class="right" ><a href="../Profile/UserProfile.jsp">Profile</a></li>
	</ul>
	
	<div class="details">
		User: <%= nickName %><br>
		<img src="../../profilePicture/<%= profilePicturePath %>.png" alt="User's profile picture">
	</div>
	
	<div>
		<h3>Below you will find all the users in Game Society!</h3>
			<ul><%
				for(int i=0; i<allUsers.length(); i++){
					JSONObject jsonObject = allUsers.getJSONObject(i);
					%><li>
						<img src="../../profilePicture/<%= jsonObject.getString("profilePicturePath") %>.png" alt="Found profile picture">
						<br><%= jsonObject.getString("nickName") %>
						<form action="ShowAllUsers.jsp">
							<input type="submit" value="Go to Profile" name="GoToProfile">
							<input type="hidden" value="<%= jsonObject.getInt("userID") %>" name="userID">
						</form>
					</li><%
				}
				%></ul>
	</div>
</body>
</html>