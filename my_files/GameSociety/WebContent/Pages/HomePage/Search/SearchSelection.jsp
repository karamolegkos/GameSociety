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
	String nickNameError = "";
	String gameError = "";
	JSONArray usersByNickName = new JSONArray();
	JSONArray usersByGame = new JSONArray();
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
	if(request.getParameter("searchByNickname")!=null){
		String searchedNickname = request.getParameter("nickName");
		if(searchedNickname.equals("")){
			nickNameError = "You must fill the field";
		}
		else if(searchedNickname.contains(" ")){
			nickNameError = "You must not use spaces!";
		}
		else{
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/getUsersByNickName/";
			link+=searchedNickname;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			usersByNickName = new JSONArray(myresponse.getEntity(String.class));
		}
	}

	if(request.getParameter("searchByGame")!=null){
		String searchedGame = request.getParameter("name");
		if(searchedGame.equals("")){
			gameError = "You must fill the field";
		}
		else{
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/getUsersPlayingTheGame/";
			link+=searchedGame.replace(' ','_');
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			usersByGame = new JSONArray(myresponse.getEntity(String.class));
		}
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
<title>Search - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../HomePage.css">
<link rel="stylesheet" href="../MainPage.css">
<body>
	<ul class="topnav">
	  <li><a class="active" href="../HomePage.jsp">Home Page</a></li>
	  <li><a href="SearchSelection.jsp">Search Users</a></li>
	  <li><a href="../ShowFreeGames/FreeGamesSelection.jsp">Free Games</a></li>
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
		<h3>Search Users</h3>
		<form action="SearchSelection.jsp" method="POST">
			<label for="nickName">User's Nickname</label>
		    <input type="text" id="nickName" name="nickName" placeholder="e.g. Slayer62">
		    <%= nickNameError %>
			<input type="submit" value="Search By Nickname" name="searchByNickname">
		</form>
		<form action="SearchSelection.jsp" method="POST">
			<label for="name">Game's name</label>
		    <input type="text" id="name" name="name" placeholder="e.g. Assassin's Creed">
		    <%= gameError %>
			<input type="submit" value="Search By Game" name="searchByGame">
		</form>
		<%
		if(request.getParameter("searchByNickname")!=null){
			if(usersByNickName.length()>0){
				%><h3>Below are the found Users!</h3>
				<ul><%
				for(int i=0; i<usersByNickName.length(); i++){
					JSONObject jsonObject = usersByNickName.getJSONObject(i);
					%><li>
						<img src="../../profilePicture/<%= jsonObject.getString("profilePicturePath") %>.png" alt="Found profile picture">
						<br><%= jsonObject.getString("nickName") %>
						<form action="SearchSelection.jsp">
							<input type="submit" value="Go to Profile" name="GoToProfile">
							<input type="hidden" value="<%= jsonObject.getInt("userID") %>" name="userID">
						</form>
					</li><%
				}
				%></ul><%
			}
			else if(request.getParameter("searchByGame")==null && nickNameError.equals("")){
				%><h3>No Users found!</h3><%
			}
		}
		
		if(request.getParameter("searchByGame")!=null){
			if(usersByGame.length()>0){
				%><h3>Below are the found Users!</h3>
				<ul><%
				for(int i=0; i<usersByGame.length(); i++){
					JSONObject jsonObject = usersByGame.getJSONObject(i);
					%><li>
						<img src="../../profilePicture/<%= jsonObject.getString("profilePicturePath") %>.png" alt="Found profile picture">
						<br><%= jsonObject.getString("nickName") %>
						<form action="SearchSelection.jsp">
							<input type="submit" value="Go to Profile" name="GoToProfile">
							<input type="hidden" value="<%= jsonObject.getInt("userID") %>" name="userID">
						</form>
					</li><%
				}
				%></ul><%
			}
			else if(request.getParameter("searchByNickname")==null && gameError.equals("")){
				%><h3>No Users found!</h3><%
			}
		}
		%>
		
	</div>
</body>
</html>