<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sun.jersey.api.client.Client" %>
<%@ page import="com.sun.jersey.api.client.ClientResponse" %>
<%@ page import="com.sun.jersey.api.client.WebResource" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONException" %>
<% 
	Client client = Client.create();
	WebResource webResource = client.resource("http://localhost:8080/GameSociety/rest/GameSociety/testForCellarDB");
	ClientResponse myresponse = webResource.get(ClientResponse.class);
%>
<%

	int userID = -1;
	String nickName = "";
	String profilePicturePath = "";
	JSONArray allFreeGames = new JSONArray();
	JSONArray platformFreeGames = new JSONArray();
	String error = "";
	if(session.getAttribute("userID") == null){
		response.sendRedirect("../../welcome/login.jsp");
	}
	else{
		userID = (int)session.getAttribute("userID");
		client = Client.create();
		String link = "http://localhost:8080/GameSociety/rest/GameSociety/getUser/";
		link+=userID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		JSONObject user = new JSONObject(myresponse.getEntity(String.class));
		nickName = user.getString("nickName");
		profilePicturePath = user.getString("profilePicturePath");
	}
%>
<%
	if(request.getParameter("allFreeGames")!=null){
		client = Client.create();
		String link = "https://www.freetogame.com/api/games";
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		allFreeGames = new JSONArray(myresponse.getEntity(String.class));
	}

	if(request.getParameter("platformSearch")!=null){
		String platform = request.getParameter("platform");
		if(platform.equals("")){
			error = "You must fill the field!";
		}
		else if(platform.contains(" ")){
			error = "You must not use spaces!";
		}
		else{
			client = Client.create();
			String link = "https://www.freetogame.com/api/games?platform="; 
			link+=platform;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			try{
				platformFreeGames = new JSONArray(myresponse.getEntity(String.class));
			}
			catch(JSONException ex){
				
			}
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Free Games - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../HomePage.css">
<link rel="stylesheet" href="../MainPage.css">
<body>
	<ul class="topnav">
	  <li><a class="active" href="../HomePage.jsp">Home Page</a></li>
	  <li><a href="../Search/SearchSelection.jsp">Search Users</a></li>
	  <li><a href="FreeGamesSelection.jsp">Free Games</a></li>
	  <li><a href="../MyGames/MyGames.jsp">Games I Play</a></li>
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
		<h3>Choose below your preference</h3>
		<form action="FreeGamesSelection.jsp">
			Show all Free Games
			<input type="submit" value="Get All Free Games" name="allFreeGames">
		</form>
		<form action="FreeGamesSelection.jsp">
			<label for="platform">Show all Free games for a specific platform</label>
	    	<input type="text" id="platform" name="platform" placeholder="e.g. pc">
	    	<%= error %>
	    	<input type="submit" value="Get All Free Games" name="platformSearch">
		</form>
		
		<%

		if(request.getParameter("allFreeGames")!=null){
			if(allFreeGames.length()>0){
				%><h3>Below are all the Free Games!</h3>
				<ul><%
				for(int i=0; i<allFreeGames.length(); i++){
					JSONObject jsonObject = allFreeGames.getJSONObject(i);
					%><li>
						<img alt="A game" src="<%= jsonObject.getString("thumbnail") %>"><br>
						Title: <%=jsonObject.getString("title") %><br>
						Game URL: <a href="<%=jsonObject.getString("game_url") %>">Link to <%=jsonObject.getString("title") %></a>
					</li><%
				}
				%></ul><%
			}
		}
		
		if(request.getParameter("platformSearch")!=null){
			if(platformFreeGames.length()>0){
				%><h3>Below are all the Free Games for this platform!</h3>
				<ul><%
				for(int i=0; i<platformFreeGames.length(); i++){
					JSONObject jsonObject = platformFreeGames.getJSONObject(i);
					%><li>
						<img alt="A game" src="<%= jsonObject.getString("thumbnail") %>"><br>
						Title: <%=jsonObject.getString("title") %><br>
						Game URL: <a href="<%=jsonObject.getString("game_url") %>">Link to <%=jsonObject.getString("title") %></a>
					</li><%
				}
				%></ul><%
			}
			else if(request.getParameter("platformSearch")!=null && error.equals("")){
				%><h3>No Games found for this platform!</h3><%
			}
		}
		%>
		
		
	</div>
</body>
</html>