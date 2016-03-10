<%@page import="twitter4j.JSONObject"%>
<%@page import="twitter4j.JSONArray"%>
<%@page import="twitter4j.JSONException"%>
<%@page import="java.io.*" %>
<%@page import="java.net.*" %>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <title>TweetMap</title>
    <style>
      html, body, #map {
        margin: 1%;
        padding: 10;
        height: 90%;
      }
	#header {
    	background-color:gray;
    	color:white;
    	text-align:center;
    	padding:5px;
	}
    </style>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js">
    </script>
    

  </head>
  <body>
      <%
      URL cloudsearchdomain;
      URLConnection search;
      String line = null;
      String[] lat = null;
      String[] lon = null;
      String[] user = null;
      String[] text = null;
      BufferedReader in = null;
      
		try {
			cloudsearchdomain = new URL("https://cloudsearch url /2013-01-01/search?q="+request.getParameter("filterQuery")+"&size=500");
			search = null;
			search = cloudsearchdomain.openConnection();
			in = new BufferedReader(
                    new InputStreamReader(
                    search.getInputStream()));
		} 
		catch (MalformedURLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
				  
        try {
			while ((line = in.readLine()) != null) 
			{
				String jsonString = line;
				JSONArray documnt = null;
				JSONObject jsonResult = null;
				JSONObject jsonChild = null;
				try {
					jsonResult = new JSONObject(jsonString);
					jsonChild = jsonResult.getJSONObject("hits");
					documnt = jsonChild.getJSONArray("hit");
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				if(documnt != null) {
				     lat = new String[documnt.length()];
				     lon = new String[documnt.length()];
				     user = new String[documnt.length()];
				     text = new String[documnt.length()];
				     
				    for(int i = 0 ; i < documnt.length() ; i++) {
				    	JSONObject pull = null;
				    	JSONObject queryresult = null;
						try {
							pull = (JSONObject)documnt.get(i);
							queryresult = pull.getJSONObject("fields");
						} catch (JSONException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
				    	try {
				    		
							lat[i] = queryresult.getString("latitude");
							lon[i] = queryresult.getString("longitude");
							user[i] = queryresult.getString("user_screen_name");
							text[i] = queryresult.getString("text");
							text[i].replace('\'', ' ');
						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
				        
				    }
				}
			
			}
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
        try {
			in.close();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	   request.setAttribute("latitude",lat);
	   request.setAttribute("username",user);
       request.setAttribute("longitude",lon);
       request.setAttribute("text",text);

 %>
      <div id=header>
    <h1>TweetMap</h1></div>
    <div id="map"></div>
    <script>
        var lat = new Array();
        var lon = new Array();
        var username = new Array();
        var tweet = new Array();
        
        var map = new google.maps.Map(document.getElementById('map'), {
            zoom: 4,
            center: new google.maps.LatLng(-33.865427, 151.196123),
            mapTypeId: google.maps.MapTypeId.TERRAIN
          });
        var marker, i;
        var infowindow = new google.maps.InfoWindow();
        
   <%
      String[] latitude = (String[])request.getAttribute("latitude");
   	  String[] longitude = (String[])request.getAttribute("longitude");
   	  String[] user1 = (String[])request.getAttribute("username");
   	  String[] tweet = (String[])request.getAttribute("text");
   	  
      for(int count=0; count <user1.length; count++) {
   %>
         lat[<%= count %>]='<%= latitude[count] %>';//dont miss the single quotes here
         lon[<%= count %>]='<%= longitude[count] %>';//dont miss the single quotes here
         username[<%= count %>]='<%= user1[count] %>';
         tweet[<%= count %>]="<%= tweet[count] %>";
         
   <% } %>

    for (j = 0; j < lon.length; j++) {  
      marker = new google.maps.Marker({
        position: new google.maps.LatLng(lat[j], lon[j]),
        map: map
      });
      
      google.maps.event.addListener(marker, 'click', (function(marker, j) {
        return function() {
          infowindow.setContent("USERNAME: "+username[j]+", TWEET: "+tweet[j]);
          infowindow.open(map, marker);
        }
      })(marker, j));
    }
           
	</script>
  </body>
</html>
