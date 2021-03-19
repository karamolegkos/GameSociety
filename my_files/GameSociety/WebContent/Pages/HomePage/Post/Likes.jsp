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
	int isAdmin = -1;
	String nickName = "";
	String profilePicturePath = "";
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
		isAdmin = user.getInt("isAdmin");
		profilePicturePath = user.getString("profilePicturePath");
	}
%>
<%
	int postID = -1;
	String link = "";
	JSONArray allLikes = new JSONArray();
	if(session.getAttribute("viewingLikesOfPostID") != null){
		postID = (int)session.getAttribute("viewingLikesOfPostID");
		session.removeAttribute("viewingLikesOfPostID");
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getAllUsersLiked/";
		link+=postID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		allLikes = new JSONArray(myresponse.getEntity(String.class));
	}
	else if(request.getParameter("GoToPost")==null){
		response.sendRedirect("../../welcome/login.jsp");
	}
%>
<%
	if(request.getParameter("GoToPost")!=null){
		int myPostID = Integer.parseInt(request.getParameter("postID"));
		session.setAttribute("postViewingID",myPostID);
		response.sendRedirect("Post.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Viewing Likes - <%=nickName%></title>
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
		<form action="Likes.jsp">
			<input type="submit" value="Go Back" name="GoToPost">
			<input type="hidden" value="<%= postID %>" name="postID">
		</form>
		
		<%
		if(allLikes.length()>0){
			%><h3>Below are the users who liked this post!</h3>
			<ul>
				<%
				for(int i=0; i<allLikes.length();i++){
					JSONObject jsonObject = allLikes.getJSONObject(i);
					String myNickName = jsonObject.getString("nickName");
					String myProfilePicturePath = jsonObject.getString("profilePicturePath");
					%>
					<li>
					<img src="../../profilePicture/<%= myProfilePicturePath %>.png" alt="Avatar">
					User: <%= myNickName %>
					</li>
					<%
				}
				%>
			</ul>
			<%
		}
		else{
			%><h3>This post has not likes :(</h3><%
		}
		%>
	</div>
</body>
</html>