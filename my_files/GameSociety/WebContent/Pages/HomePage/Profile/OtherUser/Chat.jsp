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
	String profilePicturePath = "";
	String link = "";
	String error = "";
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
	if(request.getParameter("sendAMessage")!=null){
		int profileUser = Integer.parseInt(request.getParameter("profileUserID"));
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
			link = "http://localhost:8080/GameSociety/rest/GameSociety/sendAMessage/";
			link+=userID+"/";
			link+=profileUser+"/";
			link+=content+"/";
			link+=dateTime;
			webResource = client.resource(link);
			myresponse = webResource.post(ClientResponse.class);
		}
		session.setAttribute("profileUserID",profileUser);
	}
%>
<%
	int profileUserID = -1;
	String otherNickName = "";
	String otherName = "";
	String otherSurname = "";
	int otherIsAdmin = -1;
	String otherProfilePicturePath = "";
	JSONArray messages = new JSONArray();
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
		///////////////////
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/showMessages/";
		link+=userID+"/";
		link+=profileUserID;
		webResource = client.resource(link);
		myresponse = webResource.accept("application/json").get(ClientResponse.class);
		messages = new JSONArray(myresponse.getEntity(String.class));
		//////////////////
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
<title>Chat: <%=otherNickName %> - <%=nickName %></title>
</head>
<link rel="stylesheet" href="../../HomePage.css">
<link rel="stylesheet" href="../../MainPage.css">
<link rel="stylesheet" href="Messages.css">
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
		<form action="Chat.jsp">
			<input type="submit" value="Go Back" name="GoToProfile">
			<input type="hidden" value="<%= profileUserID %>" name="userID">
		</form>
		<%
		
		if(messages.length()>0){
			%><h3>Below are your last 10 messages with <%=otherNickName %>!</h3><%
			for(int i=0; i<messages.length(); i++){
				JSONObject jsonObject = messages.getJSONObject(messages.length()-i-1);
				int sendingUser = jsonObject.getInt("theUserID");
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
				if(sendingUser == userID){
					%>
					<div class="container darker">
					  <img src="../../../profilePicture/<%=profilePicturePath%>.png" alt="Avatar" class="right">
					  <p><%=jsonObject.getString("content")%></p>
					  <span class="time-left"><%=timeShown%></span>
					</div>
					<%
				}
				else{
					%>
					<div class="container">
					  <img src="../../../profilePicture/<%=otherProfilePicturePath%>.png" alt="Avatar">
					  <p><%=jsonObject.getString("content")%></p>
					  <span class="time-right"><%=timeShown%></span>
					</div>
					<%
				}
			}
		}
		else{
			%>No messages yet with <%=otherNickName %>.<%
		}
		
		%>
		
		<p><strong>Send a Message: </strong> Type below your message and press send when you are ready!</p>
		<%=error %>
		<form action="Chat.jsp">
		  <textarea name="content"></textarea>
		  <input type="hidden" value="<%= profileUserID %>" name="profileUserID">
		  <input type="submit" value="Send it!" name="sendAMessage">
		</form>
		
	</div>
</body>
</html>