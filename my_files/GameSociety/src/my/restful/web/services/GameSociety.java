package my.restful.web.services;

import java.sql.*;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.DELETE;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.json.JSONObject;
import org.json.JSONArray;

@Path("GameSociety")
public class GameSociety {
	
	/** JDBC driver name and database URL */
	public static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
	
	/** Gives access to all Databases to test if GameSocietyDB exists */
	static final String ALL_DBS_URL = "jdbc:mysql://localhost/?allowPublicKeyRetrieval=true&autoReconnect=true&useSSL=false";
	
	/** Gives access to cellarDB */
	static final String GAME_SOCIETY_DB_URL = "jdbc:mysql://localhost/GameSocietyDB?allowPublicKeyRetrieval=true&autoReconnect=true&useSSL=false";
	
	// Below are the USERNAME and PASSWORD for the Databases
	public static final String USER = "SONEM";
	public static final String PASS = "Sonem123!";
	
	/** A variable for connecting to MySQL Server */
	public static Connection conn = null;
	
	/** A variable for Preparing Statements */
	public static PreparedStatement ps = null;

	/** A function used to connect to the GameSocietyDB */
	@GET
	@Path("/testForDB")
	public void testForDB() 
			throws SQLException, ClassNotFoundException{
		// Register JDBC driver
		Class.forName(JDBC_DRIVER);
		
		// Open a connection with MySQL server
		conn = DriverManager.getConnection(ALL_DBS_URL, USER, PASS);
		
		// Test if there is GameSocietyDB in MySQL Server
		// if not then create one
		ps = conn.prepareStatement("CREATE DATABASE IF NOT EXISTS GameSocietyDB;");
		ps.executeUpdate();
		// Now GameSocietyDB exists for sure!
		
		// Open a connection with GameSocietyDB
		conn = DriverManager.getConnection(GAME_SOCIETY_DB_URL, USER, PASS);
		
		/*********************************************************************/
		/** Make sure all tables are Ready */
		
		// Table for all Users
		ps = conn.prepareStatement("CREATE TABLE IF NOT EXISTS User ("
				+ "userID int NOT NULL AUTO_INCREMENT, "
				+ "name varchar(45) NOT NULL, "
				+ "surname varchar(45) NOT NULL, "
				+ "profilePicturePath varchar(200) NOT NULL,"
				+ "nickName varchar(45) NOT NULL, "
				+ "isAdmin int NOT NULL, "
				+ "password varchar(45) NOT NULL,"
				+ "email varchar(45) NOT NULL, "
				+ "PRIMARY KEY (userID));");
		ps.executeUpdate();
		
		// Table for Games
		ps = conn.prepareStatement("CREATE TABLE IF NOT EXISTS Game ("
				+ "gameID int NOT NULL AUTO_INCREMENT, "
				+ "userID int NOT NULL, "
				+ "name varchar(45) NOT NULL, "
				+ "PRIMARY KEY (gameID), "
				+ "FOREIGN KEY (userID) REFERENCES User(userID));");
		ps.executeUpdate();
		
		// Table for Messages
		ps = conn.prepareStatement("CREATE TABLE IF NOT EXISTS Message ("
				+ "messageID int NOT NULL AUTO_INCREMENT, "
				+ "theUserID int NOT NULL, "
				+ "friendUserID int NOT NULL, "
				+ "content varchar(300) NOT NULL, "
				+ "dateTime datetime NOT NULL, "
				+ "PRIMARY KEY (messageID), "
				+ "FOREIGN KEY (theUserID) REFERENCES User(userID), "
				+ "FOREIGN KEY (friendUserID) REFERENCES User(userID));");
		ps.executeUpdate();
		
		// Table for Posts
		ps = conn.prepareStatement("CREATE TABLE IF NOT EXISTS Post ("
				+ "postID int NOT NULL AUTO_INCREMENT, "
				+ "content varchar(250) NOT NULL, "
				+ "userID int NOT NULL, "
				+ "dateTime datetime NOT NULL, "
				+ "PRIMARY KEY (postID), "
				+ "FOREIGN KEY (userID) REFERENCES User(userID));");
		ps.executeUpdate();
		
		// Table for Comments
		ps = conn.prepareStatement("CREATE TABLE IF NOT EXISTS Comment ("
				+ "commentID int NOT NULL AUTO_INCREMENT, "
				+ "postID int NOT NULL, "
				+ "userID int NOT NULL, "
				+ "text varchar(100) NOT NULL, "
				+ "dateTime datetime NOT NULL, "
				+ "PRIMARY KEY (commentID), "
				+ "FOREIGN KEY (postID) REFERENCES Post(postID), "
				+ "FOREIGN KEY (userID) REFERENCES User(userID));");
		ps.executeUpdate();
		
		// Table for Likes
		ps = conn.prepareStatement("CREATE TABLE IF NOT EXISTS Upvote ("
				+ "postID int NOT NULL, "
				+ "userID int NOT NULL, "
				+ "PRIMARY KEY (postID, userID), "
				+ "FOREIGN KEY (postID) REFERENCES Post(postID), "
				+ "FOREIGN KEY (userID) REFERENCES User(userID));");
		ps.executeUpdate();
		/*********************************************************************/
		this.setStartingAdmin();
		
	}
	
	@POST
	@Path("/addAUser/{name}/{surname}/{nickName}/{isAdmin}/{password}/{email}")
	public void addAUser(@PathParam("name") String name, 
			@PathParam("surname") String surname, 
			@PathParam("nickName") String nickName,
			@PathParam("isAdmin") int isAdmin, 
			@PathParam("password") String password, 
			@PathParam("email") String email) 
					throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("INSERT INTO User "
				+"(name, surname, profilePicturePath, nickName, isAdmin, password, email)"
				+"VALUES (?,?,?,?,?,?,?);");
		ps.setString(1, name);
		ps.setString(2, surname);
		ps.setString(3, "1");
		ps.setString(4, nickName);
		ps.setInt(5, isAdmin);
		ps.setString(6, password);
		ps.setString(7, email);
		ps.executeUpdate();
	}
	
	@DELETE
	@Path("/deleteAUser/{userID}")
	public void deleteAUser(@PathParam("userID") int userID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("DELETE FROM Upvote WHERE (userID = "+userID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("DELETE FROM Comment WHERE (userID = "+userID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("SELECT * FROM Post WHERE "
				+ "(userID = "+userID+")");
		ResultSet rs = ps.executeQuery();
		while(rs.next()) {
			this.postDelete(rs.getInt("postID"));
		}
		
		ps = conn.prepareStatement("DELETE FROM Message WHERE (theUserID = "+userID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("DELETE FROM Message WHERE (friendUserID = "+userID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("DELETE FROM Game WHERE (userID = "+userID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("DELETE FROM User WHERE (userID = "+userID+")");
		ps.executeUpdate();
		/*********************************************************************/
		this.setStartingAdmin();
	}
	
	@POST
	@Path("/addAUserGame/{userID}/{name}")
	public void addAUserGame(@PathParam("userID") int userID,
			@PathParam("name") String name) 
					throws SQLException, ClassNotFoundException{
		name = name.replace('_', ' ');
		ps = conn.prepareStatement("INSERT INTO Game "
				+"(userID, name) "
				+"VALUES (?,?);");
		ps.setInt(1, userID);
		ps.setString(2, name);
		ps.executeUpdate();
	}
	
	@DELETE
	@Path("/deleteAUserGame/{userID}/{gameID}")
	public void deleteAUserGame(@PathParam("userID") int userID,
			@PathParam("gameID") int gameID) 
					throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("DELETE FROM Game WHERE "
				+ "((userID = '"+userID+"') AND "
				+ "(gameID = '"+gameID+"'));");
		ps.executeUpdate();
	}
	
	@GET
	@Path("/getAllUserGames/{userID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getAllUserGames(@PathParam("userID") int userID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM Game WHERE "
				+ "(userID = "+userID+")");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("gameID", rs.getInt("gameID"));
			jsonObject.put("name", rs.getString("name"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@GET
	@Path("/getUsersPlayingTheGame/{name}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getUsersPlayingTheGame(@PathParam("name") String name) 
			throws SQLException, ClassNotFoundException{
		name = name.replace('_', ' ');
		ps = conn.prepareStatement("SELECT "
				+ "g.gameID, g.name, "
				+ "u.userID, u.nickName, u.profilePicturePath "
				+ "FROM "
				+ "Game AS g, "
				+ "User AS u "
				+ "WHERE "
				+ "(g.name Like '%"+name+"%' AND "
				+ "u.userID = g.userID)");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("gameID", rs.getInt("gameID"));
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("name", rs.getString("name"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@GET
	@Path("/getUsersByNickName/{nickName}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getUsersByNickName(@PathParam("nickName") String nickName) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM User "
				+ "WHERE "
				+ "(nickName Like '%"+nickName+"%')");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("name", rs.getString("name"));
			jsonObject.put("surname", rs.getString("surname"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@GET
	@Path("/testForUser/{nickName}")
	@Produces(MediaType.APPLICATION_JSON)
	public String testForUser(@PathParam("nickName") String nickName) 
			throws SQLException, ClassNotFoundException{
		this.testForDB();
		ps = conn.prepareStatement("SELECT * FROM User "
				+ "WHERE "
				+ "(nickName = '"+nickName+"')");
		ResultSet rs = ps.executeQuery();
		JSONObject jsonObject = new JSONObject();
		while(rs.next()) {
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("isAdmin", rs.getInt("isAdmin"));
			jsonObject.put("name", rs.getString("name"));
			jsonObject.put("surname", rs.getString("surname"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("password", rs.getString("password"));
			jsonObject.put("email", rs.getString("email"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
		}
		return jsonObject.toString();
	}
	
	@GET
	@Path("/testForEmail/{email}")
	@Produces(MediaType.APPLICATION_JSON)
	public String testForEmail(@PathParam("email") String email) 
			throws SQLException, ClassNotFoundException{
		this.testForDB();
		ps = conn.prepareStatement("SELECT * FROM User "
				+ "WHERE "
				+ "(email = '"+email+"')");
		ResultSet rs = ps.executeQuery();
		JSONObject jsonObject = new JSONObject();
		while(rs.next()) {
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("isAdmin", rs.getInt("isAdmin"));
			jsonObject.put("name", rs.getString("name"));
			jsonObject.put("surname", rs.getString("surname"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("password", rs.getString("password"));
			jsonObject.put("email", rs.getString("email"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
		}
		return jsonObject.toString();
	}
	
	@GET
	@Path("/getUser/{userID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getUser(@PathParam("userID") int userID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM User "
				+ "WHERE "
				+ "(userID = "+userID+")");
		ResultSet rs = ps.executeQuery();
		
		JSONObject jsonObject = new JSONObject();
		while(rs.next()) {
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("name", rs.getString("name"));
			jsonObject.put("surname", rs.getString("surname"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonObject.put("isAdmin", rs.getInt("isAdmin"));
			jsonObject.put("password", rs.getString("password"));
			jsonObject.put("email", rs.getString("email"));
		}
		return jsonObject.toString();
	}
	
	@PUT
	@Path("/changePrivileges/{userID}")
	public void changePrivileges(@PathParam("userID") int userID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM User "
				+ "WHERE "
				+ "(userID = "+userID+")");
		ResultSet rs = ps.executeQuery();
		int privilage;
		while(rs.next()) {
			privilage = rs.getInt("isAdmin");
			if(privilage==0) {
				ps = conn.prepareStatement("UPDATE User SET isAdmin = 1 "
						+ "WHERE (userID = "+userID+")");
				ps.executeUpdate();
			}
			else {
				ps = conn.prepareStatement("UPDATE User SET isAdmin = 0 "
						+ "WHERE (userID = "+userID+")");
				ps.executeUpdate();
				this.setStartingAdmin();
			}
		}
	}
	
	@GET
	@Path("/getAllUsers")
	@Produces(MediaType.APPLICATION_JSON)
	public String getAllUsers() 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM User");
		ResultSet rs = ps.executeQuery();
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("name", rs.getString("name"));
			jsonObject.put("surname", rs.getString("surname"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonObject.put("isAdmin", rs.getInt("isAdmin"));
			jsonObject.put("password", rs.getString("password"));
			jsonObject.put("email", rs.getString("email"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@POST
	@Path("/addAPost/{userID}/{content}/{dateTime}")
	public void addAPost(@PathParam("userID") int userID,
			@PathParam("content") String content,
			@PathParam("dateTime") String dateTime) 
			throws SQLException, ClassNotFoundException{
		dateTime = dateTime.replace("_", " ");
		content = content.replace("_", " ");
		ps = conn.prepareStatement("INSERT INTO Post "
				+"(content, userID, dateTime) "
				+"VALUES (?,?,?);");
		ps.setString(1, content);
		ps.setInt(2, userID);
		ps.setString(3, dateTime);
		ps.executeUpdate();
	}
	
	@GET
	@Path("/getAllPosts/{userID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getAllPosts(@PathParam("userID") int userID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM Post "
				+ "WHERE "
				+ "(userID = "+userID+") "
				+ "ORDER BY dateTime DESC");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("postID", rs.getInt("postID"));
			jsonObject.put("content", rs.getString("content"));
			jsonObject.put("dateTime", rs.getString("dateTime"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@GET
	@Path("/getHomeScreenPosts")
	@Produces(MediaType.APPLICATION_JSON)
	public String getHomeScreenPosts() 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT "
				+ "p.postID, p.dateTime, p.content, p.userID, "
				+ "u.nickName, u.profilePicturePath "
				+ "FROM "
				+ "Post AS p, "
				+ "User AS u "
				+ "WHERE "
				+ "(u.userID = p.userID) "
				+ "ORDER BY p.dateTime DESC");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("postID", rs.getInt("postID"));
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("content", rs.getString("content"));
			jsonObject.put("dateTime", rs.getString("dateTime"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@POST
	@Path("/addAComment/{userID}/{postID}/{text}/{dateTime}")
	public void addAComment(@PathParam("userID") int userID,
			@PathParam("postID") int postID,
			@PathParam("text") String text,
			@PathParam("dateTime") String dateTime) 
					throws SQLException, ClassNotFoundException{
		dateTime = dateTime.replace("_", " ");
		text = text.replace("_", " ");
		ps = conn.prepareStatement("INSERT INTO Comment "
				+"(userID, postID, text, dateTime) "
				+"VALUES (?,?,?,?);");
		ps.setInt(1, userID);
		ps.setInt(2, postID);
		ps.setString(3, text);
		ps.setString(4, dateTime);
		ps.executeUpdate();
	}
	
	@DELETE
	@Path("/deleteComment/{commentID}")
	public void deleteComment(@PathParam("commentID") int commentID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("DELETE FROM Comment WHERE (commentID = "+commentID+")");
		ps.executeUpdate();
	}
	
	@GET
	@Path("/showComments/{postID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String showComments(@PathParam("postID") int postID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT "
				+ "c.postID, c.userID, c.text, c.dateTime, c.commentID, "
				+ "u.nickName, u.profilePicturePath "
				+ "FROM "
				+ "Comment AS c, "
				+ "User AS u "
				+ "WHERE "
				+ "(c.postID = "+postID+" AND "
				+ "c.userID = u.userID ) "
				+ "ORDER BY c.dateTime DESC");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("commentID", rs.getInt("commentID"));
			jsonObject.put("postID", rs.getInt("postID"));
			jsonObject.put("text", rs.getString("text"));
			jsonObject.put("dateTime", rs.getString("dateTime"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@POST
	@Path("/likeOrDislike/{userID}/{postID}")
	public void likeOrDislike(@PathParam("userID") int userID,
			@PathParam("postID") int postID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT * FROM Upvote "
				+ "WHERE "
				+ "(userID = "+userID+" AND "
				+ "postID = "+postID+")");
		ResultSet rs = ps.executeQuery();
		if(rs.next()) {
			ps = conn.prepareStatement("DELETE FROM Upvote WHERE "
					+ "(postID = "+postID+" AND "
					+ "userID = "+userID+")");
			ps.executeUpdate();
		}
		else {
			ps = conn.prepareStatement("INSERT INTO Upvote "
					+"(userID, postID) "
					+"VALUES (?,?);");
			ps.setInt(1, userID);
			ps.setInt(2, postID);
			ps.executeUpdate();
		}
	}
	
	@GET
	@Path("/getAllUsersLiked/{postID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getAllUsersLiked(@PathParam("postID") int postID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT "
				+ "u.nickName, u.profilePicturePath, u.userID, "
				+ "upv.postID "
				+ "FROM "
				+ "Upvote AS upv, "
				+ "User AS u "
				+ "WHERE "
				+ "(upv.postID = "+postID+" AND "
				+ "upv.userID = u.userID)");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("userID", rs.getInt("userID"));
			jsonObject.put("postID", rs.getInt("postID"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@GET
	@Path("/getAmountOfLikes/{postID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String getAmountOfLikes(@PathParam("postID") int postID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT count(*) "
				+ "FROM Upvote "
				+ "WHERE postID = "+postID+"");
		ResultSet rs = ps.executeQuery();
		JSONObject jsonObject = new JSONObject();
		while(rs.next()) {
			jsonObject.put("amount", rs.getInt("count(*)"));
		}
		return jsonObject.toString();
	}
	
	@DELETE
	@Path("/deletePost/{postID}")
	public void deletePost(@PathParam("postID") int postID) 
			throws SQLException, ClassNotFoundException{
		this.postDelete(postID);
	}
	
	@PUT
	@Path("/changeProfileInfo/{userID}/{name}/{surname}/{profilePicturePath}/{nickName}/{password}/{email}")
	public void changeProfileInfo(@PathParam("userID") int userID,
			@PathParam("name") String name,
			@PathParam("surname") String surname,
			@PathParam("profilePicturePath") String profilePicturePath,
			@PathParam("nickName") String nickName,
			@PathParam("password") String password,
			@PathParam("email") String email) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("UPDATE User SET "
				+ "name = '"+name+"', "
				+ "surname = '"+surname+"', "
				+ "profilePicturePath = '"+profilePicturePath+"', "
				+ "nickName = '"+nickName+"', "
				+ "password = '"+password+"', "
				+ "email = '"+email+"' "
				+ "WHERE (userID = "+userID+")");
		ps.executeUpdate();
	}
	
	@GET
	@Path("/showMessages/{theUserID}/{friendUserID}")
	@Produces(MediaType.APPLICATION_JSON)
	public String showMessages(@PathParam("theUserID") int theUserID,
			@PathParam("friendUserID") int friendUserID) 
					throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT "
				+ "u.nickName, u.profilePicturePath, "
				+ "m.messageID, m.theUserID, m.friendUserID, m.content, m.dateTime "
				+ "FROM "
				+ "Message AS m ,"
				+ "User AS u "
				+ "WHERE "
				+ "((m.theUserID = "+theUserID+" AND "
				+ "m.theUserID = u.userID AND "
				+ "m.friendUserID = "+friendUserID+") OR "
				+ "(m.friendUserID = "+theUserID+" AND "
				+ "m.theUserID = "+friendUserID+" AND "
				+ "m.friendUserID = u.userID))"
				+ "ORDER BY m.dateTime DESC " 
				+ "LIMIT 10");
		ResultSet rs = ps.executeQuery();
		
		JSONArray jsonArray = new JSONArray();
		while(rs.next()) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("messageID", rs.getInt("messageID"));
			jsonObject.put("theUserID", rs.getInt("theUserID"));
			jsonObject.put("friendUserID", rs.getInt("friendUserID"));
			jsonObject.put("nickName", rs.getString("nickName"));
			jsonObject.put("profilePicturePath", rs.getString("profilePicturePath"));
			jsonObject.put("content", rs.getString("content"));
			jsonObject.put("dateTime", rs.getString("dateTime"));
			jsonArray.put(jsonObject);
		}
		return jsonArray.toString();
	}
	
	@POST
	@Path("/sendAMessage/{theUserID}/{friendUserID}/{content}/{dateTime}")
	public void sendAMessage(@PathParam("theUserID") int theUserID,
			@PathParam("friendUserID") int friendUserID,
			@PathParam("content") String content,
			@PathParam("dateTime") String dateTime) 
					throws SQLException, ClassNotFoundException{
		dateTime = dateTime.replace("_", " ");
		content = content.replace("_", " ");
		ps = conn.prepareStatement("INSERT INTO Message "
				+"(theUserID, friendUserID, content, dateTime) "
				+"VALUES (?,?,?,?);");
		ps.setInt(1, theUserID);
		ps.setInt(2, friendUserID);
		ps.setString(3, content);
		ps.setString(4, dateTime);
		ps.executeUpdate();
	}
	
	private void postDelete(int postID) 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("DELETE FROM Upvote WHERE (postID = "+postID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("DELETE FROM Comment WHERE (postID = "+postID+")");
		ps.executeUpdate();
		
		ps = conn.prepareStatement("DELETE FROM Post WHERE (postID = "+postID+")");
		ps.executeUpdate();
	}
	
	private void setStartingAdmin() 
			throws SQLException, ClassNotFoundException{
		ps = conn.prepareStatement("SELECT count(*) "
				+ "FROM User "
				+ "WHERE isAdmin = 1;");
		ResultSet rs = ps.executeQuery();
		while(rs.next()) {
			if(rs.getInt("count(*)")==0) {
				ps = conn.prepareStatement("INSERT INTO User "
						+"(name, surname, profilePicturePath, nickName, isAdmin, password, email)"
						+"VALUES (?,?,?,?,?,?,?);");
				ps.setString(1, "admin");
				ps.setString(2, "admin");
				ps.setString(3, "1");
				ps.setString(4, "admin");
				ps.setInt(5, 1);
				ps.setString(6, "admin");
				ps.setString(7, "admin@admin.com");
				ps.executeUpdate();
			}
		}
	}
}
