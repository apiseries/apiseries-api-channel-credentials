/**
 * 
 */
package com.apiseries.api.controller;

import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONObject;

import com.apiseries.api.exception.APIException;
import com.apiseries.api.implement.ControllerImplement;
import com.apiseries.api.mapper.ClientAccessResponse;
import com.apiseries.api.service.Service;
import com.apiseries.gear.mapper.RequestMapper;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gear.tools.http.constant.HttpDef;
import com.gear.tools.jwt.core.JWTUtil;
import com.gear.tools.yaml.core.YAMLReader;

/**
 * 
 */
public class Controller implements ControllerImplement{

	private Logger logger = null;
	private Service service = new Service();
	private YAMLReader geardb = null;
	private YAMLReader gearsecurity = null;
	private ObjectMapper mapper = new ObjectMapper();
	private JWTUtil jwt = new JWTUtil();

   /**
	* Controller
	*/
	public Controller() {this.logger = LogManager.getLogger(this.getClass()); this.logger.info(this.getClass().getName() + " : instanceof true");}
	
   /**
    * toEmit(String value)
    * 
    * @param String
    * @return Object
    * @throws APIException	
    */
	@Override
	public Object toEmit(RequestMapper value) throws APIException {
	try {
		this.logger.info("payload -> [" + value.getPayload().toString() + "]");
		
		if ( this.service.isDb() == false ) {throw new APIException("config db no exists!.");}
		JSONObject response = (JSONObject)this.service.getListCredentials(this.gearsecurity.getString("security.name"));
		this.logger.info("<- [" + response + "]");
		
		ClientAccessResponse object = new ClientAccessResponse(HttpDef.HTTP_CODE_200, (Map<String,String>)response.get("sii"), (Map<String,String>)response.get("previred"));
		mapper = new ObjectMapper();
		
	return mapper.writeValueAsString(object);
	}
	catch (Exception e) {throw new APIException(e);}
	}//end-method
	
   /**
    * jwt(String value)
    * 
    * @param String
    * @return boolean
    * @throws APIException	
    */
	@Override
	public boolean jwt(String value) throws APIException {
	try {
		DecodedJWT decode = jwt.validateAccessToken(value);
		this.logger.info("subject    : " + decode.getSubject());
		this.logger.info("expires at : " + decode.getExpiresAt());
		this.logger.info("payload    : " + decode.getPayload());
		return true;
	}
	catch (Exception e) {return false;}
	}//end-method
    
}//end-class
