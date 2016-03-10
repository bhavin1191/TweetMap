<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
   <%@page import="client.http.TwitterConsumer1"%>
   <%@page import="oauth.signpost.OAuthConsumer"%>
	<%@page import="oauth.signpost.commonshttp.CommonsHttpOAuthConsumer"%>
	
<html>
	<head>
	<style>
#header {
    background-color:gray;
    color:white;
    text-align:center;
    padding:5px;
}
#nav {
    line-height:30px;
    background-color:#00000;
    height:300px;
    width:100px;
    float:left;
    padding:5px;	      
}
#section {
    width:350px;
    float:left;
    padding:10px;	 	 
}
 
}
</style>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Tweet Map</title>
		<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.4.8/angular.min.js"></script>
	</head>
	<body>
	<div id='cssmenu'>
		<form method="GET" action="tweetmap.jsp">
			<div id="header">
			<h2 align="center"><u>TweetMap</u></h2>
			</div>
			<div id="nav"></div>
			<div id=section>
			Please Select the search parameter<br/>
 			<select id="keyword" name="filterQuery">
			<option value="trump" selected="selected">Trump</option>
			<option value="fashion">Fashion</option>
			<option value="cricket">Cricket</option>
			<option value="madrid">Madrid</option>
			<option value="obama">Obama</option>
			<option value="shopping">Shopping</option>
			<option value="usa">USA</option>
			<option value="selfie">Selfie</option>
			<option value="followme">followme</option>
			<option value="music">music</option>
		   </select>
		   
		   <%
		   try{
			   TwitterConsumer1 t = new TwitterConsumer1(
		            "", 
		            "",
		            "",
		            "",
		            "https://stream.twitter.com/1.1/statuses/filter.json?track=t20,trump,oscars,fashion,music,obama,shopping,selfie,followme,usa", "trump");
		        t.start();
		   }catch(Exception e)
		   {e.printStackTrace();}
		     %>
    	<input type="submit" value="Search"></input>
    	</div>
		</form>
	</div>
	</body>
</html>