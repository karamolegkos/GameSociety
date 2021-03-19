<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sun.jersey.api.client.Client" %>
<%@ page import="com.sun.jersey.api.client.ClientResponse" %>
<%@ page import="com.sun.jersey.api.client.WebResource" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
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
	JSONArray allPosts = new JSONArray();
	JSONObject myPost = new JSONObject();
	
	int myPostID = -1;
	int myUserID = -1;
	String myProfilePicturePath = "";
	String myContent = "";
	String myDateTime = "";
	String myNickName = "";
	
	JSONArray allComments = new JSONArray();
	JSONArray allLikes = new JSONArray();
	
	boolean userLikesThisPost = false;
	
	int amountOfLikes = -1;
	
	if(request.getParameter("likeDislike") != null){
		int postID = Integer.parseInt(request.getParameter("likeDislike"));
		client = Client.create();
		String link = "http://localhost:8080/GameSociety/rest/GameSociety/likeOrDislike/";
		link+=userID+"/";
		link+=postID;
		webResource = client.resource(link);
		myresponse = webResource.post(ClientResponse.class);
		session.setAttribute("postViewingID",postID);
	}
	
	if(request.getParameter("deletePost") != null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		client = Client.create();
		String link = "http://localhost:8080/GameSociety/rest/GameSociety/deletePost/";
		link+=postID;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
	}
	
	if(request.getParameter("deleteComment") != null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		int commentID = Integer.parseInt(request.getParameter("commentID"));
		client = Client.create();
		String link = "http://localhost:8080/GameSociety/rest/GameSociety/deleteComment/";
		link+=commentID;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
		session.setAttribute("postViewingID",postID);
	}
	
	if(request.getParameter("seeWhoLiked") != null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		session.setAttribute("postViewingID",postID);
		session.setAttribute("viewingLikesOfPostID",postID);
		response.sendRedirect("Likes.jsp");
	}
	
	String error = "";
	if(request.getParameter("addAComment") != null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		String content = request.getParameter("content");
		if(content.equals("")){
			error = "You must fill the field!";
		}
		String newline = System.getProperty("line.separator");
		boolean hasNewline = content.contains(newline);
		if(hasNewline){
			error = "You may not use enter!";
		}
		else{
			content = content.replace(" ","_");
			DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");  
			LocalDateTime now = LocalDateTime.now();
			String dateTime = dtf.format(now);
			dateTime = dateTime.replace(" ","_");
			client = Client.create();
			String link = "http://localhost:8080/GameSociety/rest/GameSociety/addAComment/";
			link+=userID+"/";
			link+=postID+"/";
			link+=content+"/";
			link+=dateTime;
			webResource = client.resource(link);
			myresponse = webResource.post(ClientResponse.class);
		}
		session.setAttribute("postViewingID",postID);
	}
	
	if(session.getAttribute("userID") != null){
		if(session.getAttribute("postViewingID") == null){
			response.sendRedirect("../../welcome/login.jsp");
		}
		else{
			myPostID = (int)session.getAttribute("postViewingID");
			session.removeAttribute("postViewingID");
			client = Client.create();
			String link = "http://localhost:8080/GameSociety/rest/GameSociety/getHomeScreenPosts/";
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			allPosts = new JSONArray(myresponse.getEntity(String.class));
			for(int i=0; i<allPosts.length(); i++){
				JSONObject jsonObject = allPosts.getJSONObject(i);
				if(jsonObject.getInt("postID")==myPostID){
					myPost = allPosts.getJSONObject(i);
					break;
				}
			}
			myUserID = myPost.getInt("userID");
			myProfilePicturePath = myPost.getString("profilePicturePath");
			myContent = myPost.getString("content");
			myDateTime = myPost.getString("dateTime");
			myNickName = myPost.getString("nickName");
			
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/showComments/";
			link+=myPostID;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			allComments = new JSONArray(myresponse.getEntity(String.class));
			
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/getAllUsersLiked/";
			link+=myPostID;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			allLikes = new JSONArray(myresponse.getEntity(String.class));
			
			for(int i=0; i<allLikes.length(); i++){
				JSONObject jsonObject = allLikes.getJSONObject(i);
				if(jsonObject.getInt("userID")==userID){
					userLikesThisPost = true;
					break;
				}
			}
			
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/getAmountOfLikes/";
			link+=myPostID;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			JSONObject jsonObject = new JSONObject(myresponse.getEntity(String.class));
			amountOfLikes = jsonObject.getInt("amount");
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title><%= myNickName%>'s Post - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../HomePage.css">
<link rel="stylesheet" href="../MainPage.css">
<link rel="stylesheet" href="Comments.css">
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
	
	<%
	if(myPostID != -1){
		%>
		<div>
		<%
		char charDateTime[] = myDateTime.toCharArray();
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
		%>
		<img src="../../profilePicture/<%=myProfilePicturePath%>.png" alt="Post">
		<%=myNickName%><br>
		> <%=myContent%><br>
		<b><%=timeShown%></b><br>
		<form action="Post.jsp">
			<%
			if(userLikesThisPost){
				%><input type="image" src="../../Like/like.png" name="like"/><%
			}
			else{
				%><input type="image" src="../../Like/dislike.png" alt="like"><%
			}
			%>
			<input type="hidden" value="<%=myPostID%>" name="likeDislike">
		</form>
		<%=amountOfLikes %> people have liked this post!
		<form action="Post.jsp">
			<input type="submit" value="See who liked the post" name="seeWhoLiked">
			<input type="hidden" value="<%=myPostID%>" name="postID">
		</form>
		
		<%
		if(myUserID==userID || isAdmin==1){
			%>
			<form action="Post.jsp">
				<input type="submit" value="Delete" name="deletePost">
				<input type="hidden" value="<%=myPostID%>" name="postID">
			</form>
			<%
		}
		%>
		</div>
		<h3>Comment Section</h3>
		<div>
			<p><strong>Make a Comment: </strong> Type below your comment and press "Comment!" when you are ready!</p>
				<%=error%>
				<form action="Post.jsp">
				  <textarea name="content"></textarea>
				  <input type="submit" value="Comment!" name="addAComment">
				  <input type="hidden" value="<%=myPostID%>" name="postID">
				</form>
		<%
		if(allComments.length()>0){
			for(int i=0; i<allComments.length(); i++){
				JSONObject jsonObject = allComments.getJSONObject(i);
				int sendingUser = jsonObject.getInt("userID");
				int commentID = jsonObject.getInt("commentID");
				String commentProfilePicturePath = jsonObject.getString("profilePicturePath");
				char commentCharDateTime[] = jsonObject.getString("dateTime").toCharArray();
				String commentTimeShown = "";
				commentTimeShown += commentCharDateTime[8];
				commentTimeShown += commentCharDateTime[9];
				commentTimeShown += "/";
				commentTimeShown += commentCharDateTime[5];
				commentTimeShown += commentCharDateTime[6];
				commentTimeShown += "-";
				commentTimeShown += commentCharDateTime[11];
				commentTimeShown += commentCharDateTime[12];
				commentTimeShown += commentCharDateTime[13];
				commentTimeShown += commentCharDateTime[14];
				commentTimeShown += commentCharDateTime[15];
				if(sendingUser == userID){
					%>
					<div class="container darker">
					  <img src="../../profilePicture/<%=commentProfilePicturePath%>.png" alt="Avatar" class="right">
					  <p><%=jsonObject.getString("nickName")%>:<br><%=jsonObject.getString("text")%></p>
					  <span class="time-left"><%=commentTimeShown%></span>
					  <form>
					  	<input type="submit" value="Delete this comment" name="deleteComment">
				  		<input type="hidden" value="<%=myPostID%>" name="postID">
				  		<input type="hidden" value="<%=commentID%>" name="commentID">
					  </form>
					</div>
					<%
				}
				else{
					%>
					<div class="container">
					  <img src="../../profilePicture/<%=commentProfilePicturePath%>.png" alt="Avatar">
					  <p><%=jsonObject.getString("nickName")%>:<br><%=jsonObject.getString("text")%></p>
					  <span class="time-right"><%=commentTimeShown%></span>
					  <%
					  if(isAdmin==1){
						  %>
						  <form>
						  	<input type="submit" value="Delete this comment" name="deleteComment">
					  		<input type="hidden" value="<%=myPostID%>" name="postID">
					  		<input type="hidden" value="<%=commentID%>" name="commentID">
						  </form>
						  <%
					  }
					  %>
					</div>
					<%
				}
			}
		}
		else{
			%>No comments yet :( !<%
		}
		
		%>
		</div>
		<%
	}
	%>
	
	
</body>
</html>