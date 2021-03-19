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
	if(session.getAttribute("userID") == null){
		response.sendRedirect("../../../welcome/login.jsp");
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
	int profileUserID = -1;
	String otherNickName = "";
	String otherName = "";
	String otherSurname = "";
	int otherIsAdmin = -1;
	String otherProfilePicturePath = "";
	JSONArray userGames = new JSONArray();
	boolean otherUser = false;
	if(session.getAttribute("profileUserID") != null){
		otherUser = true;
		profileUserID = (int)session.getAttribute("profileUserID");
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getUser/";
		link+=profileUserID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		JSONObject user = new JSONObject(myresponse.getEntity(String.class));
		otherNickName = user.getString("nickName");
		otherName = user.getString("name");
		otherSurname = user.getString("surname");
		otherIsAdmin = user.getInt("isAdmin");
		otherProfilePicturePath = user.getString("profilePicturePath");
		session.removeAttribute("profileUserID");
		
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getAllUserGames/";
		link+=profileUserID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		userGames = new JSONArray(myresponse.getEntity(String.class));
	}
	else if(request.getParameter("GoToProfile")==null){
		response.sendRedirect("../../../welcome/login.jsp");
	}
%>
<%
	if(request.getParameter("GoToProfile")!=null){
		int profileUser = Integer.parseInt(request.getParameter("userID"));
		session.setAttribute("profileUserID",profileUser);
		response.sendRedirect("../UserProfile.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title><%=otherNickName %>'s Games - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../../HomePage.css">
<link rel="stylesheet" href="../../MainPage.css">
<body>
	<ul class="topnav">
	  <li><a class="active" href="../../HomePage.jsp">Home Page</a></li>
	  <li><a href="../../Search/SearchSelection.jsp">Search Users</a></li>
	  <li><a href="../../ShowFreeGames/FreeGamesSelection.jsp">Free Games</a></li>
	  <li><a href="../../MyGames/MyGames.jsp">Games I Play</a></li>
	  <%
	  if(session.getAttribute("adminID") != null){
	  %>
	  <li><a href="../../Admin/ShowAllUsers.jsp">Show All Users</a></li>
	  <%
	  }
	  %>
	  <li><a href="../../LogOut.jsp">Log out</a></li>
	  <li class="right" ><a href="../UserProfile.jsp">Profile</a></li>
	</ul>
	
	<div class="details">
		User: <%= nickName %><br>
		<img src="../../../profilePicture/<%= profilePicturePath %>.png" alt="User's profile picture">
	</div>
	
	<div>
		<form action="SeeGames.jsp">
			<input type="submit" value="Go Back" name="GoToProfile">
			<input type="hidden" value="<%= profileUserID %>" name="userID">
		</form>
		
		<%
		if(userGames.length()>0){
			%><h3>Below are the Games that <%=otherNickName %> inserted!</h3>
			<ul><%
			for(int i=0; i<userGames.length(); i++){
				JSONObject jsonObject = userGames.getJSONObject(i);
				%><li>
					<%= jsonObject.getString("name") %>
				</li><%
			}
			%></ul><%
		}
		else{
			%><h3><%=otherNickName %> has not inserted any Games :( !</h3><%
		}
		%>
		
	</div>
	
</body>
</html>