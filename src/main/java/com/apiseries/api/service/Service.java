/**
 * 
 */
package com.apiseries.api.service;

import java.util.HashMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import com.apiseries.api.exception.APIException;
import com.apiseries.api.implement.NoSQLAccessImplement;
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
	public void addDB(YAMLReader x) {this.geardb = x;}

   /**
    * addSecurity
    * 
    *  @param YAMLReader	
    */
	@Override
	public void addSecurity(YAMLReader x) {this.gearsecurity = x;}

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
      	 ManagerAdapter.getInstance().findById("mongo." + service);
      	 
		 HashMap<String, Object> registry = new HashMap<>();
      	 registry.put("values", this.geardb.getString("mongo." + service + ".query"));

 		 String json = ManagerAdapter.getInstance().find(registry);
      	 JSONArray container = new JSONArray(json);
      	 JSONObject response = container.getJSONObject(0);
		
    return response;
	}
	catch (Exception e) {throw new APIException(e);}
	}//end-method
	
	
	
	
}//end-class
