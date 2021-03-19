<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sun.jersey.api.client.Client" %>
<%@ page import="com.sun.jersey.api.client.ClientResponse" %>
<%@ page import="com.sun.jersey.api.client.WebResource" %>
<%@ page import="org.json.JSONObject" %>
<% 
	Client client = Client.create();
	WebResource webResource = client.resource("http://localhost:8080/GameSociety/rest/GameSociety/testForCellarDB");
	ClientResponse myresponse = webResource.get(ClientResponse.class);
%>
<%

	if(session.getAttribute("userID")!= null){
		response.sendRedirect("../HomePage/HomePage.jsp");
	}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Game Society: Login</title>
</head>
<link rel="stylesheet" href="login.css">
<%
	String error = "";
	if(request.getParameter("login")!=null){
		String nickName = request.getParameter("nickName");
		String password = request.getParameter("password");
		
		if(nickName.equals("") || password.equals("")){
			error = "You must fill all the fields!";
		}
		else if(nickName.contains(" ") || password.contains(" ")){
			error = "You must not use spaces!";
		}
		else{
			client = Client.create();
			String link = "http://localhost:8080/GameSociety/rest/GameSociety/testForUser/";
			link+=nickName;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			JSONObject user = new JSONObject(myresponse.getEntity(String.class));
			if(user.length()>0){
				if(password.equals(user.getString("password"))){
					session.setAttribute("userID",user.getInt("userID"));
					if(user.getInt("isAdmin")==1){
						session.setAttribute("adminID",user.getInt("userID"));
					}
					response.sendRedirect("../HomePage/HomePage.jsp");
				}
				else{
					error = "The nickname or password is wrong!";
				}
			}
			else{
				error = "The nickname or password is wrong!";
			}
		}
	}
%>
<body>
	Not signed in yet?
	<form action="register.jsp">
		<input type="submit" value="Sign up" name="toSignUp">
	</form>
	<%
	
	if(session.getAttribute("registered")!= null){
		out.println("Your registration was successful!");
		session.removeAttribute("registered");
	}
	
	%>
	
	<h3>Welcome to Game Society<br>Login</h3>

	<div>
	  <form method="POST">
	    <label for="nickName">Nickname</label>
	    <input type="text" id="nickName" name="nickName" placeholder="Your Nickname..">
	
	    <label for="password">Password</label>
	    <input type="password" id="password" name="password" placeholder="Your Password..">
	    
	    <%=error %>
	  
	    <input type="submit" value="Login" name="login">
	  </form>
	</div>

</body>
</html>