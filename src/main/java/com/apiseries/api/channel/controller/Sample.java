package com.apiseries.api.channel.controller;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.XML;

import com.apiseries.api.channel.tools.Utils;
import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gear.tools.function.Tools4JSON;
import com.gear.tools.function.Tools4Text;

public class Sample {
	private JsonFactory factory = new JsonFactory();
	private ObjectMapper mapper = new ObjectMapper();
    private String payload = "{\"status\":200,\"accessToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0b2tlbiIsInN1YiI6Ijk5OTE1MzY2IiwidXNlcm5hbWUiOiJncXVlemFkYSIsInJvbGVzIjpbImFkbWluIl0sInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3NzE4Njc5OTgsImV4cCI6MTc3MTg2ODg5OH0.Eta7CnC-vuHKwkvxFVdHj5hLrPvwdpTzTfNWMV6G1fg\",\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0b2tlbiIsInN1YiI6Ijk5OTE1MzY2IiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NzE4Njc5OTgsImV4cCI6MTc3MTg2ODg5OH0.8JrbMi9e3XxmmGeB8YVyBmPKT2BPpCY5Bxg-MoYmxjU\"}";
	
	public Sample() {
    try {

    	System.out.println("\u001B[36m▄  ▄\u001B[0m\u001B[37m    ▄▄▄▄ ▄▄▄▄▄  ▄▄▄  ▄▄▄▄       ▄▄▄  ▄▄▄▄  ▄▄\u001B[0m\"");
		System.out.println("\u001B[36m ▀▄ ▀▄\u001B[0m\u001B[37m ██ ▄▄ ██▄▄  ██▀██ ██▄█▄ ▄▄▄ ██▀██ ██▄█▀ ██\u001B[0m\""); 
		System.out.println("\u001B[36m▄▀ ▄▀\u001B[0m\u001B[37m  ▀███▀ ██▄▄▄ ██▀██ ██ ██     ██▀██ ██    ██\u001B[0m\"");
    	
    	
    	System.out.println("\u001B[36m██╗ ██╗\u001B[0m\u001B[37m   ██████╗ ███████╗ █████╗ ██████╗        █████╗ ██████╗ \u001B[0m\u001B[35m██╗\u001B[0m");
    	System.out.println("\u001B[36m╚██╗╚██╗\u001B[0m\u001B[37m ██╔════╝ ██╔════╝██╔══██╗██╔══██╗      ██╔══██╗██╔══██╗\u001B[0m\u001B[35m██║\u001B[0m");
    	System.out.println("\u001B[36m ╚██╗╚██╗\u001B[0m\u001B[37m██║  ███╗█████╗  ███████║██████╔╝█████╗███████║██████╔╝\u001B[0m\u001B[35m██║\u001B[0m");
    	System.out.println("\u001B[36m ██╔╝██╔╝\u001B[0m\u001B[37m██║   ██║██╔══╝  ██╔══██║██╔══██╗╚════╝██╔══██║██╔═══╝ \u001B[0m\u001B[35m██║\u001B[0m");
    	System.out.println("\u001B[36m██╔╝██╔╝\u001B[0m\u001B[37m ╚██████╔╝███████╗██║  ██║██║  ██║      ██║  ██║██║     \u001B[0m\u001B[35m██║\u001B[0m");
    	System.out.println("\u001B[36m╚═╝ ╚═╝\u001B[0m\u001B[37m   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝     \u001B[0m\u001B[35m╚═╝\u001B[0m");
    	
 
    	System.out.println("\u001B[36m██╗ ██╗\u001B[0m\u001B[35m  ▄███▄██  ▄████▄  ▄█████ ▄██▄██      ▄█████▄ ██▄███▄  ██\u001B[0m");    
    	System.out.println("\u001B[36m╚██╗╚██╗\u001B[0m\u001B[35m ██▀  ▀████▄▄▄▄██ ▀ ▄▄▄█ ██          ▀ ▄▄▄██ ██▀  ▀██ ██\u001B[0m");    
    	System.out.println("\u001B[36m ╚██╗╚██╗\u001B[0m\u001B[35m██    ████▀▀▀▀▀▀▄██▀▀▀█ ██   █████ ▄██▀▀▀██ ██    ██ ██\u001B[0m");    
    	System.out.println("\u001B[36m ██╔╝██╔╝\u001B[0m\u001B[35m▀██▄▄███▀██▄▄▄▄███▄▄▄██ ██         ██▄▄▄███ ███▄▄██▀ ██\u001B[0m"); 
    	System.out.println("\u001B[36m██╔╝██╔╝\u001B[0m\u001B[35m  ▄ ▀▀ ██  ▀▀▀▀▀  ▀▀▀▀ ▀ ▀▀          ▀▀▀▀ ▀▀ ██ ▀▀▀   ▀▀ \u001B[0m");
    	System.out.println("\u001B[36m╚═╝ ╚═╝\u001B[0m\u001B[35m   ▀████▀▀                                    ██                \u001B[0m"); 

    	
    	System.out.println(Tools4Text.generateCodeIdentity(this.getClass().getPackageName()));
    	System.out.println(Tools4Text.generateCodeIdentity("com.apiseries.gear"));
    	
    	JSONObject json = new JSONObject(payload);
    	System.out.println(XML.toString(json));

    	
        String include = "sii";
    	String[] values = include.split(",");
    	for (String string : values) {
			System.out.println("values ->" + string);
		}
    	
    	JSONArray response = new JSONArray("[{\"sii\":{\"id\":\"Fr+MYEN6v7vkisyjQn1m+g==\",\"key\":\"XAnr0MGEt25x67l19jPuww==\"},\"previred\":{\"id\":\"\",\"key\":\"\"},\"rutCntr\":\"76186481-5\",\"_id\":{\"$oid\":\"68d1d0425641106c89d7c9c7\"}},{\"sii\":{\"id\":\"0D1g8yMCseGH6rJHF06EZA==\",\"key\":\"mrsM6Wj2znw=\"},\"previred\":{\"id\":\"\",\"key\":\"\"},\"rutCntr\":\"9991536-6\",\"_id\":{\"$oid\":\"68d1d21d5641106c89d7c9ce\"}},{\"sii\":{\"id\":\"BnnyBukY7m8BpI4QXNt/lA==\",\"key\":\"/eevsgck3To=\"},\"previred\":{\"id\":\"\",\"key\":\"\"},\"rutCntr\":\"76701256-K\",\"_id\":{\"$oid\":\"68d1d2405641106c89d7c9cf\"}},{\"sii\":{\"id\":\"dDZVa7E3zGcfccf+BnsOlg==\",\"key\":\"3mSyjayLNqy5XEtw89ECSA==\"},\"previred\":{\"id\":\"\",\"key\":\"\"},\"rutCntr\":\"77122581-0\",\"_id\":{\"$oid\":\"68d1d2615641106c89d7c9d0\"}}]");
    	System.out.println((JSONArray)Utils.removeOid(response));
    	
    	
		mapper = new ObjectMapper();
	    System.out.println(mapper.writeValueAsString(((JSONArray)Utils.removeOid(response)).toList()));
    	
    	
    	/*
    	System.out.println("JSON valid -> " + Tools4JSON.isJSONValid(payload));
		System.out.println("Payload -> " + this.payload);
		
		TokenRequest request = mapper.readValue(this.payload,TokenRequest.class);
		System.out.println("username:" + request.getUsername());
		System.out.println("userid:" + request.getUserid());
		System.out.println("roles:" + request.getRoles());
		*/
    	
    	
    	
    	
    	
		
    }
    catch(Exception e) {e.printStackTrace();}
	}//end-constructor

	public static void main(String[] args) {new Sample();}

}
