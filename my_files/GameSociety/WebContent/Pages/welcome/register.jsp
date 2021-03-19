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
<title>Game Society: Sign up</title>
</head>
<link rel="stylesheet" href="login.css">
<%
	String error = "";
	if(request.getParameter("signup")!=null){
		String link;
		String nickName = request.getParameter("nickName");
		String password = request.getParameter("password");
		String name = request.getParameter("name");
		String surname = request.getParameter("surname");
		String email = request.getParameter("email");
		
		if(nickName.equals("") || password.equals("") ||
				name.equals("") || surname.equals("") ||
				email.equals("")){
			error = "You must fill all the fields!";
		}
		else if(nickName.contains(" ") || password.contains(" ") ||
				name.contains(" ") || surname.contains(" ") ||
				email.contains(" ")){
			error = "You must not use spaces!";
		}
		else{
			client = Client.create();
			link = "http://localhost:8080/GameSociety/rest/GameSociety/testForUser/";
			link+=nickName;
			webResource = client.resource(link);
			myresponse = webResource.accept("application/json").get(ClientResponse.class);
			JSONObject user = new JSONObject(myresponse.getEntity(String.class));
			if(user.length()==0){
				client = Client.create();
				link = "http://localhost:8080/GameSociety/rest/GameSociety/testForEmail/";
				link+=email;
				webResource = client.resource(link);
				myresponse = webResource.accept("application/json").get(ClientResponse.class);
				JSONObject userByEmail = new JSONObject(myresponse.getEntity(String.class));
				if(userByEmail.length()==0){
					
					client = Client.create();
					link = "http://localhost:8080/GameSociety/rest/GameSociety/addAUser/";
					link+=name+"/";
					link+=surname+"/";
					link+=nickName+"/";
					link+=0+"/";
					link+=password+"/";
					link+=email;
					webResource = client.resource(link);
					myresponse = webResource.post(ClientResponse.class);
					
					
					session.setAttribute("registered",true);
					response.sendRedirect("login.jsp");
				}
				else{
					error = "This email already exist!";
				}
			}
			else{
				error = "This nickname already exist!";
			}
		}
	}
%>
<body>

	You already have an account?
	<form action="login.jsp">
		<input type="submit" value="Log in" name="toLogIn">
	</form>
	
	<h3>Welcome to Game Society<br>Register</h3>
	
	<div>
	  <form method="POST">
	    <label for="nickName">Nickname</label>
	    <input type="text" id="nickName" name="nickName" placeholder="Your Nickname..">
	
	    <label for="password">Password</label>
	    <input type="password" id="password" name="password" placeholder="Your Password..">
	    
	    <label for="name">Name</label>
	    <input type="text" id="name" name="name" placeholder="Your Name...">
	    
	    <label for="surname">Surname</label>
	    <input type="text" id="surname" name="surname" placeholder="Your Surname...">
	    
	    <label for="email">Email</label>
	    <input type="text" id="email" name="email" placeholder="Your Email...">
	    
	    <%=error %>
	  
	    <input type="submit" value="Sign up" name="signup">
	  </form>
	</div>

</body>
</html>