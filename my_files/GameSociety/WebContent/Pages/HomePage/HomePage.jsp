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
	int isAdmin = -1;
	if(session.getAttribute("userID") == null){
		response.sendRedirect("../welcome/login.jsp");
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
		isAdmin = user.getInt("isAdmin");
		profilePicturePath = user.getString("profilePicturePath");
	}
%>
<%
	if(request.getParameter("deletePost")!=null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		client = Client.create();
		String link = "http://localhost:8080/GameSociety/rest/GameSociety/deletePost/";
		link+=postID;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
	}
	
	JSONArray allPosts = new JSONArray();
	if(session.getAttribute("userID") != null){
		client = Client.create();
		String link = "http://localhost:8080/GameSociety/rest/GameSociety/getHomeScreenPosts/";
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		allPosts = new JSONArray(myresponse.getEntity(String.class));
	}
	
	if(request.getParameter("goToThePost")!=null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		session.setAttribute("postViewingID",postID);
		response.sendRedirect("Post/Post.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Home Page - <%=nickName %></title>
</head>
<link rel="stylesheet" href="HomePage.css">
<link rel="stylesheet" href="MainPage.css">
<body>
	<ul class="topnav">
	  <li><a class="active" href="HomePage.jsp">Home Page</a></li>
	  <li><a href="Search/SearchSelection.jsp">Search Users</a></li>
	  <li><a href="ShowFreeGames/FreeGamesSelection.jsp">Free Games</a></li>
	  <li><a href="MyGames/MyGames.jsp">Games I Play</a></li>
	  <%
	  if(session.getAttribute("adminID") != null){
	  %>
	  <li><a href="Admin/ShowAllUsers.jsp">Show All Users</a></li>
	  <%
	  }
	  %>
	  <li><a href="LogOut.jsp">Log out</a></li>
	  <li class="right" ><a href="Profile/UserProfile.jsp">Profile</a></li>
	</ul>
	
	<div class="details">
		User: <%= nickName %><br>
		<img src="../profilePicture/<%= profilePicturePath %>.png" alt="User's profile picture">
	</div>
	
	<%
	if(allPosts.length()>0){
		%><h3>Below are all the posts from the Community!</h3><%
		for(int i=0; i<allPosts.length();i++){
			JSONObject jsonObject = allPosts.getJSONObject(i);
			int posterUser = jsonObject.getInt("userID");
			int postID = jsonObject.getInt("postID");
			String content = jsonObject.getString("content");
			String posterNickName = jsonObject.getString("nickName");
			char charDateTime[] = jsonObject.getString("dateTime").toCharArray();
			String timeShown = "";
			timeShown += charDateTime[8];
			timeShown += charDateTime[9];
			timeShown += "/";
			timeShown += charDateTime[5];
			timeShown += charDateTime[6];
			timeShown += "-";
			timeShown += charDateTime[11];
			timeShown += charDateTime[12];
			timeShown += charDateTime[13];
			timeShown += charDateTime[14];
			timeShown += charDateTime[15];
			String posterProfilePicturePath = jsonObject.getString("profilePicturePath");
			%>
				<br>
				<div>
					<img src="../profilePicture/<%=posterProfilePicturePath%>.png" alt="Post">
					<%=posterNickName%><br>
					> <%=content%><br>
					<b><%=timeShown%></b>
					<form action="HomePage.jsp">
						<input type="submit" value="See more" name="goToThePost">
						<input type="hidden" value="<%=postID%>" name="postID">
					</form>
					<%
					if(posterUser==userID || isAdmin==1){
						%>
						<form action="HomePage.jsp">
							<input type="submit" value="Delete" name="deletePost">
							<input type="hidden" value="<%=postID%>" name="postID">
						</form>
						<%
					}
					%>
				</div>
			<%
		}
	}
	else{
		%><h3>No one has posted anything yet :( !</h3><%
	}
	
	%>
	
	
</body>
</html>