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
	String error = "";
	JSONArray UserGames = new JSONArray();
	if(session.getAttribute("userID") == null){
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
	if(request.getParameter("deleteGame")!=null){
		int gameID = Integer.parseInt(request.getParameter("gameID"));
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/deleteAUserGame/";
		link+=userID+"/";
		link+=gameID;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
		
	}

	if(request.getParameter("addGame")!=null){
		String name = request.getParameter("name");
		if(name.equals("")){
			error = "You must fill the field";
		}
		else{
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/addAUserGame/";
			link+=userID+"/";
			link+=name.replace(' ','_');
			webResource = client.resource(link);
			myresponse = webResource.post(ClientResponse.class);
		}
	}

	if(session.getAttribute("userID") != null){
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getAllUserGames/";
		link+=userID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		UserGames = new JSONArray(myresponse.getEntity(String.class));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>My Games - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../HomePage.css">
<link rel="stylesheet" href="../MainPage.css">
<body>
	<ul class="topnav">
	  <li><a class="active" href="../HomePage.jsp">Home Page</a></li>
	  <li><a href="../Search/SearchSelection.jsp">Search Users</a></li>
	  <li><a href="../ShowFreeGames/FreeGamesSelection.jsp">Free Games</a></li>
	  <li><a href="MyGames.jsp">Games I Play</a></li>
	  <%
	  if(session.getAttribute("adminID") != null){
	  %>
	  <li><a href="../Admin/ShowAllUsers.jsp">Show All Users</a></li>
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
		<form action="MyGames.jsp" method="POST">
			<h3>Add A Game that you play:</h3>
			<label for="name">Game's name</label>
		    <input type="text" id="name" name="name" placeholder="e.g. Assassin's Creed">
		    <%=error %>
			<input type="submit" value="Add Game in the list" name="addGame">
		</form>
		
		<%
		if(UserGames.length()>0){
			%><h3>Below are the Games that you inserted!</h3>
			<ul><%
			for(int i=0; i<UserGames.length(); i++){
				JSONObject jsonObject = UserGames.getJSONObject(i);
				%><li>
					<%= jsonObject.getString("name") %>
					<form action="MyGames.jsp">
						<input type="submit" value="Delete" name="deleteGame">
						<input type="hidden" value="<%= jsonObject.getInt("gameID") %>" name="gameID">
					</form>
				</li><%
			}
			%></ul><%
		}
		else{%>
			<h3>You have not inserted any Games yet :(</h3>
		<%}%>
		
	</div>
</body>
</html>