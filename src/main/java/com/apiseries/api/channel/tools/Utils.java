/**
 * 
 */
package com.apiseries.api.channel.tools;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * 
 */
public class Utils {


    /**
	  * remove 
	  * @param name
	  */
	  public static Object removeOid(Object payload) {
	  try {

		if ( payload instanceof JSONObject) {
			
			 JSONObject value = ((JSONObject)payload);
			 value.remove("$oid");
			
		return value;	
		}
		if ( payload instanceof JSONArray) {
			
			JSONArray values = ((JSONArray)payload);
			
			   for (int i = 0; i < values.length(); i++) {
		            JSONObject doc = values.getJSONObject(i);
		            doc.remove("_id");
			   }
			   
		return values;
		}
	
	  return null;	
	  }
	  catch (Exception e) {throw e;} 
	  }//end-method

	
}//end-class
