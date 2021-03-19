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
	String nickName = "";
	String name = "";
	String surname = "";
	int isAdmin = -1;
	String profilePicturePath = "";
	String link = "";
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
		name = user.getString("name");
		surname = user.getString("surname");
		isAdmin = user.getInt("isAdmin");
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
	}

%>
<%
	if(request.getParameter("deleteUser")!=null){
		int userIDToDelete = Integer.parseInt(request.getParameter("profileUserID"));
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/deleteAUser/";
		link+=userIDToDelete;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
		response.sendRedirect("../HomePage.jsp");
	}

	if(request.getParameter("editProfile")!=null){
		response.sendRedirect("EditProfile.jsp");
	}
	
	if(request.getParameter("chat")!=null){
		int profileUser = Integer.parseInt(request.getParameter("profileUserID"));
		session.setAttribute("profileUserID",profileUser);
		response.sendRedirect("OtherUser/Chat.jsp");
	}
	
	if(request.getParameter("seeGames")!=null){
		int profileUser = Integer.parseInt(request.getParameter("profileUserID"));
		session.setAttribute("profileUserID",profileUser);
		response.sendRedirect("OtherUser/SeeGames.jsp");
	}
	
	if(request.getParameter("changePrivileges")!=null){
		int profileUser = Integer.parseInt(request.getParameter("profileUserID"));
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/changePrivileges/";
		link+=profileUser;
		webResource = client.resource(link);
		myresponse = webResource.put(ClientResponse.class);
		session.setAttribute("profileUserID",profileUser);
		response.sendRedirect("UserProfile.jsp");
	}

	String error = "";
	if(request.getParameter("makeAPost")!=null){ 
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
			link = "http://localhost:8080/GameSociety/rest/GameSociety/addAPost/";
			link+=userID+"/";
			link+=content+"/";
			link+=dateTime;
			webResource = client.resource(link);
			myresponse = webResource.post(ClientResponse.class);
		}
	}
	
	if(request.getParameter("deletePost")!=null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/deletePost/";
		link+=postID;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
		
		if(request.getParameter("profileUserID")!=null){
			int profileUser = Integer.parseInt(request.getParameter("profileUserID"));
			session.setAttribute("profileUserID",profileUser);
			response.sendRedirect("UserProfile.jsp");
		}
	}
	
	if(request.getParameter("goToThePost")!=null){
		int postID = Integer.parseInt(request.getParameter("postID"));
		session.setAttribute("postViewingID",postID);
		response.sendRedirect("../Post/Post.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Profile - 
<%
if(otherUser){
	%><%= otherNickName %><%
}
else{
	%><%= nickName %><%
}

%>
</title>
</head>
<link rel="stylesheet" href="../HomePage.css">
<link rel="stylesheet" href="../MainPage.css">
<link rel="stylesheet" href="OtherUser/Messages.css">
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
	  <li class="right" ><a href="UserProfile.jsp">Profile</a></li>
	</ul>
	
	<div class="details">
		User: <%= nickName %><br>
		<img src="../../profilePicture/<%= profilePicturePath %>.png" alt="User's profile picture">
	</div>
	<% 
	int trueUserID = userID;
	String trueNickName = nickName;
	String trueName = name;
	String trueSurname = surname;
	int trueIsAdmin = isAdmin;
	String trueProfilePicturePath = profilePicturePath;
	if(otherUser){
		trueUserID = profileUserID;
		trueNickName = otherNickName;
		trueName = otherName;
		trueSurname = otherSurname;
		trueIsAdmin = otherIsAdmin;
		trueProfilePicturePath = otherProfilePicturePath;
	}
	JSONArray allPosts = new JSONArray();
	if(session.getAttribute("userID") != null){
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/getAllPosts/";
		link+=trueUserID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		allPosts = new JSONArray(myresponse.getEntity(String.class));
	}
	
	%>
	<div class="profile">
		<img src="../../profilePicture/<%= trueProfilePicturePath %>.png" alt="profile"><br>
		<b>Nickname: <%= trueNickName %></b><br> 
		Name: <%= trueName %><br> 
		Surname: <%= trueSurname %>
		<% 
		if(isAdmin == 1){
			String a = "";
			if(trueIsAdmin==1)a="Admin";
			else a="User";
			%>
			<br>Privileges: <%= a %>
		<%
		}
		%>
		<form action="UserProfile.jsp">
			<%
			if(otherUser){
				%>
				<input type="submit" value="Chat" name="chat">
				<input type="hidden" value="<%= profileUserID %>" name="profileUserID">
				<%
			}
			else{
				%><input type="submit" value="Edit Profile" name="editProfile"><%
			}
			%>
		</form>
		<form action="UserProfile.jsp">
			<%
			if(otherUser){
				%>
				<input type="submit" value="See what Games this User is playing!" name="seeGames">
				<input type="hidden" value="<%= profileUserID %>" name="profileUserID">
				<%
			}
			%>
		</form>
		<%
		if(isAdmin==1 && trueUserID!=userID){
			%>
			<form action="UserProfile.jsp">
				<input type="submit" value="Delete User" name="deleteUser">
				<input type="hidden" value="<%= profileUserID %>" name="profileUserID">
			</form>
			<form action="UserProfile.jsp">
				<input type="submit" value="Change Privileges" name="changePrivileges">
				<input type="hidden" value="<%= profileUserID %>" name="profileUserID">
			</form>
			<%
		}
		%>
		
		<%
		if(!otherUser){
			%>
			<form action="UserProfile.jsp">
				<h3>Type something below to tell to everyone!</h3>
				<%=error %>
				<textarea name="content"></textarea>
				<input type="submit" value="Post it!" name="makeAPost">
			</form>
			<%
		}
		%>
	</div>
	
	<%
	if(allPosts.length()>0){
		%><h3>Below are <%=trueNickName%>'s posts!</h3><%
		for(int i=0; i<allPosts.length();i++){
			JSONObject jsonObject = allPosts.getJSONObject(i);
			int posterUser = jsonObject.getInt("userID");
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
			%>
				<br>
				<div>
					<img src="../../profilePicture/<%=trueProfilePicturePath%>.png" alt="Post">
					<%=trueNickName%><br>
					> <%=jsonObject.getString("content")%><br>
					<b><%=timeShown%></b>
					<form action="UserProfile.jsp">
						<input type="submit" value="See more" name="goToThePost">
						<input type="hidden" value="<%= jsonObject.getInt("postID") %>" name="postID">
					</form>
					<%
					if(jsonObject.getInt("userID")==userID || isAdmin==1){
						%>
						<form action="UserProfile.jsp">
							<input type="submit" value="Delete" name="deletePost">
							<input type="hidden" value="<%= jsonObject.getInt("postID") %>" name="postID">
							<%
							if(profileUserID != -1){
								%>
								<input type="hidden" value="<%= profileUserID %>" name="profileUserID">
								<%
							}
							%>
						</form>
						<%
					}
					%>
				</div>
			<%
		}
	}
	else{
		%><h3><%=trueNickName%> has not made any posts yet :( !</h3><%
	}
	
	%>
	
</body>
</html>