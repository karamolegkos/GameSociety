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
	String name = "";
	String surname = "";
	int isAdmin = -1;
	String profilePicturePath = "";
	String email = "";
	String link = "";
	String password = "";
	String nameSurnameError = "";
	String passwordError = "";
	String imageError = "";
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
		email = user.getString("email");
		password = user.getString("password");
		profilePicturePath = user.getString("profilePicturePath");
	}
%>
<%
	if(request.getParameter("updateNameSurname")!=null){
		String newName = request.getParameter("name");
		String newSurname = request.getParameter("surname");
		if(newName.equals("") || newSurname.equals("")){
			nameSurnameError = "You must fill the fields!";
		}
		else if(newName.contains(" ") || newSurname.contains(" ")){
			nameSurnameError = "You may not use spaces!";
		}
		else{
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/changeProfileInfo/";
			link+=userID+"/";
			link+=newName+"/";
			link+=newSurname+"/";
			link+=profilePicturePath+"/";
			link+=nickName+"/";
			link+=password+"/";
			link+=email;
			webResource = client.resource(link);
			myresponse = webResource.put(ClientResponse.class);
			nameSurnameError = "The update is done!";
		}
	}

	if(request.getParameter("changePassword")!=null){
		String newPassword = request.getParameter("password");
		if(newPassword.equals("")){
			passwordError = "You must fill the field!";
		}
		else if(newPassword.contains(" ")){
			passwordError = "You may not use spaces!";
		}
		else{
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/changeProfileInfo/";
			link+=userID+"/";
			link+=name+"/";
			link+=surname+"/";
			link+=profilePicturePath+"/";
			link+=nickName+"/";
			link+=newPassword+"/";
			link+=email;
			webResource = client.resource(link);
			myresponse = webResource.put(ClientResponse.class);
			passwordError = "The update is done!";
		}
	}
	
	if(request.getParameter("imageID")!=null){
		String newPath = request.getParameter("imageID");
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/changeProfileInfo/";
		link+=userID+"/";
		link+=name+"/";
		link+=surname+"/";
		link+=newPath+"/";
		link+=nickName+"/";
		link+=password+"/";
		link+=email;
		webResource = client.resource(link);
		myresponse = webResource.put(ClientResponse.class);
		imageError = "The update is done!";
	}
	
	if(request.getParameter("deleteUser")!=null){
		client = Client.create();
		link = "http://localhost:8080/GameSociety/rest/GameSociety/deleteAUser/";
		link+=userID;
		webResource = client.resource(link);
		myresponse = webResource.delete(ClientResponse.class);
		if(session.getAttribute("adminID")!= null){
			session.removeAttribute("adminID");
		}
		session.removeAttribute("userID");
		response.sendRedirect("../../welcome/login.jsp");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Edit profile - <%= nickName %></title>
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
	  <li class="right" ><a href="UserProfile.jsp">Profile</a></li>
	</ul>
	
	<div>
		Email: <b><%=email %></b><br>
		NickName: <b><%= nickName %></b><br>
	    
	    <form action="EditProfile.jsp">
	    	<h3>To change your Name or Surname fill the field below</h3>
			<label for="name">Name</label>
		    <input type="text" id="name" name="name" placeholder="Your Name...">
		    <label for="surname">Surname</label>
		    <input type="text" id="surname" name="surname" placeholder="Your Surname...">
		    <%=nameSurnameError %> 
		    <input type="submit" value="Update my Account" name="updateNameSurname">
	    </form>
	    
	    <form action="EditProfile.jsp">
	    	<h3>To change your Password fill the field below</h3>
			<label for="password">Password</label>
	    <input type="password" id="password" name="password" placeholder="Your Password..">
		    <%=passwordError %>
		    <input type="submit" value="Change my password" name="changePassword">
	    </form>
	    
	    <h3>Click an image below to update your profile picture</h3>
	    <%=imageError %><br>
	    <%
	    	for(int i=0; i<11; i++){
	    		%>
	    			<form class="profileImages" action="EditProfile.jsp">
	    				<input type="image" src="../../profilePicture/<%=i+1 %>.png" name="image"/>
	    				<input type="hidden" value="<%=i+1 %>" name="imageID">
	    			</form>
	    		<%
	    	}
	    %>
	</div>
	
	
	
	<form action="EditProfile.jsp">
		<h3>If you want to delete your account, <br>press the button below</h3>
		<input type="submit" value="Delete My Account" name="deleteUser">
	</form>
</body>
</html>