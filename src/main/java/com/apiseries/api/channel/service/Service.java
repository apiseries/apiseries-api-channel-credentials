/**
 * 
 */
package com.apiseries.api.channel.service;

import java.util.HashMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import com.apiseries.api.channel.exception.APIException;
import com.apiseries.api.channel.implement.NoSQLAccessImplement;
import com.gear.nosql.core.ManagerAdapter;
import com.gear.nosql.mongo.MongoDBAdapter;
import com.gear.tools.yaml.core.YAMLReader;

/**
 * 
 */
public class Service implements NoSQLAccessImplement {

	private Logger logger = null;
	private YAMLReader geardb = null;
	private YAMLReader gearsecurity = null;

   /**
	* 
	*/
	public Service() {this.logger = LogManager.getLogger(this.getClass());}

   /**
    * addDB(YAMLReader x) 
    * 
    * @param YAMLReader
    * return void	
    */
	@Override
	public void addDB(YAMLReader x) {this.geardb = x; this.logger.debug("this.geardb instanceof " + (x instanceof YAMLReader));}

   /**
    * addSecurity
    * 
    *  @param YAMLReader	
    */
	@Override
	public void addSecurity(YAMLReader x) {this.gearsecurity = x;this.logger.debug("this.gearsecurity instanceof " + (x instanceof YAMLReader));}

   /**
    * isDb
    *  
    * @return boolean
    */
	public boolean isDb() {return (this.geardb instanceof YAMLReader);}
	
   /**
    * getListBusiness
    * 	
    * @param service
    * @return
    * @throws APIException
    */
	public Object getListCredentials(String service) throws APIException {
	try {
	     
		 MongoDBAdapter adapter = MongoDBAdapter.getInstance();
	     adapter.addConfig(this.geardb);

	     ManagerAdapter.getInstance().setAdapter(adapter);
      	 ManagerAdapter.getInstance().findById("mongodb." + service);
      	 
		 HashMap<String, Object> registry = new HashMap<>();
 		 String json = ManagerAdapter.getInstance().find(registry);
      	 JSONArray container = new JSONArray(json);
		
    return container;
	}
	catch (Exception e) {throw new APIException(e);}
	}//end-method
	
	
	
	
}//end-class
