package client.http;
/**
 *
 * @author Bhavin
 */
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClientBuilder;
import org.json.JSONArray;
import org.json.JSONObject;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.services.cloudsearchdomain.AmazonCloudSearchDomainClient;
import com.amazonaws.services.cloudsearchdomain.model.UploadDocumentsRequest;
import com.amazonaws.services.cloudsearchdomain.model.UploadDocumentsResult;

import oauth.signpost.OAuthConsumer;
import oauth.signpost.commonshttp.CommonsHttpOAuthConsumer;

public class TwitterConsumer1 extends Thread {
    //
    static String STORAGE_DIR = "d://twitterfiles/";
    static long BYTES_PER_FILE = 5 * 1024 * 1024;
    public static AmazonCloudSearchDomainClient cloudclient;
    public static AWSCredentials credentials;
    public static UploadDocumentsRequest upload;
    //
    public long Messages = 0;
    public long Bytes = 0;
    public long Timestamp = 0;

    private static String accessToken = "";
    private static String accessSecret = "";
    private static String consumerKey = "";
    private static String consumerSecret = ""; 

    private String feedUrl;
    private String filePrefix;
    boolean isRunning = true;
    File file = null;
    FileWriter fw = null;
    long bytesWritten = 0;

    public static void main(String[] args) {
        TwitterConsumer1 t = new TwitterConsumer1(
            "accessToken", 
            "accessSecret",
            "consumerKey",
            "consumerSecret",
            "https://stream.twitter.com/1.1/statuses/filter.json?track=cricket,trump,madrid,fashion,music,obama,shopping,selfie,followme,usa", "trump");
        t.start();
    }

    public TwitterConsumer1(String accessToken, String accessSecret, String consumerKey, String consumerSecret, String url, String prefix) {
        this.accessToken = accessToken;
        this.accessSecret = accessSecret;
        this.consumerKey = consumerKey;
        this.consumerSecret = consumerSecret;
        feedUrl = url;
        filePrefix = prefix;
        Timestamp = System.currentTimeMillis();
    }

    private void writeFile() throws IOException {
        // Handle the existing file
        if (fw != null)
            fw.close();
        // Create the next file
        file = new File(STORAGE_DIR, filePrefix + "-"
                + System.currentTimeMillis() + ".json");
        bytesWritten = 0;
        fw = new FileWriter(file);
        System.out.println("Writing to " + file.getAbsolutePath());
    }

    public void run() {
    	int count=0;
    	double longi=0,lati = 0;
		credentials = new ProfileCredentialsProvider("default").getCredentials();
    	cloudclient = new AmazonCloudSearchDomainClient(credentials);
    	cloudclient.setEndpoint("https://cloudsearch url");
    	
        // Run loop
        while (isRunning) {
            try {
                OAuthConsumer consumer = new CommonsHttpOAuthConsumer(consumerKey, consumerSecret);
                consumer.setTokenWithSecret(accessToken, accessSecret);
                HttpGet request = new HttpGet(feedUrl);
                consumer.sign(request);

                HttpClient client = HttpClientBuilder.create().build();
                HttpResponse response = client.execute(request);
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(response.getEntity().getContent()));
                while (true) {
                    String line = reader.readLine();
                    //System.out.println(line);
                    JSONObject jsonobj = new JSONObject(line);
                    
                    if(
                    		( !( jsonobj.get("place").equals(null)	) )
                      )
                  
                    {
                    	String cloudformat = "[{\"type\":\"add\","
                    						+"\"id\":\""+jsonobj.getInt("id")+"\","
                    						+"\"fields\":{";
                    						//+ "\"created_at\":\""+jsonobj.getString("created_at")+"\","
                    						
                    	String trimmedtext = jsonobj.getString("text").trim();
                    	trimmedtext = trimmedtext.replace('\"',' ').replace('\n', ' ');
                    	cloudformat = cloudformat + "\"text\":\""+trimmedtext+"\","
                    						+ "\"user_screen_name\":\""+jsonobj.getJSONObject("user").getString("screen_name")+"\",";
                    						//+ "\"statuses_count\":\""+jsonobj.getJSONObject("user").getInt("statuses_count")+"\",";
                    	
                    	
                    	if(!(jsonobj.get("place").equals(null)))
                    	{
                    		JSONArray jsonarr = jsonobj.getJSONObject("place").getJSONObject("bounding_box").getJSONArray("coordinates");
                    		JSONArray childarr = jsonarr.getJSONArray(0);
                    		JSONArray othrchild = childarr.getJSONArray(0);
                    		for(int i = 0;i<othrchild.length(); i++)
                    		{
                    			longi = othrchild.getDouble(0);
                    			lati=othrchild.getDouble(1);
                    		}
                    			
                    		cloudformat = cloudformat + "\"latitude\":\""+lati+"\",\"longitude\":\""+longi+"\"";
                    	    System.out.println(lati+","+longi);	
                    	}
                    		
                    	else
                    	{  
                    		cloudformat = cloudformat + "\"latitude\":\""+0+"\",\"longitude\":\""+0+"\"";
                    	}					
                    	
                    	cloudformat = cloudformat + "}}]";

                    System.out.println(cloudformat);
                    line=cloudformat;
                    System.out.println("long value = "+line);
                    
                    upload = new UploadDocumentsRequest();

                    
                    InputStream doc = new ByteArrayInputStream(line.getBytes());
                    upload.setContentType("application/json");
                    Long l = Long.valueOf(line.getBytes().length);
                    System.out.println("long value = "+l);
                    upload.setContentLength(l);
                    upload.setDocuments(doc);
                    UploadDocumentsResult results = cloudclient.uploadDocuments(upload);
                    
                    if (line == null)
                        break;
                    count = count + 1; 
                    System.out.println("Write count: "+count);
                    
                    }
                }
            } catch (Exception e) {
            	e.printStackTrace();
            	e.getMessage();
            }
            System.out.println("Sleeping before reconnect...");
            try { Thread.sleep(20000); } catch (Exception e) { }
        }
    }
}
