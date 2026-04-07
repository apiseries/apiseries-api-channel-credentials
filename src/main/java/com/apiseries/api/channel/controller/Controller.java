/**
 * 
 */
package com.apiseries.api.channel.controller;

import java.util.HashMap;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import com.apiseries.api.channel.exception.APIException;
import com.apiseries.api.channel.implement.ControllerImplement;
import com.apiseries.api.channel.mapper.ClientAccessResponse;
import com.apiseries.api.channel.service.Service;
import com.apiseries.api.channel.tools.Utils;
import com.apiseries.gear.mapper.RequestMapper;
import com.apiseries.gear.security.SecretKey;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gear.tools.http.constant.HttpDef;
import com.gear.tools.jwt.core.JWTUtil;
import com.gear.tools.tags.core.Tag;
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
		JSONArray response = (JSONArray)this.service.getListCredentials(this.gearsecurity.getString("security.name"));
		this.logger.info("<- [" + response + "]");
		
		mapper = new ObjectMapper();
		
	return mapper.writeValueAsString(((JSONArray)Utils.removeOid(response)).toList());
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
		this.logger.info("jwt token : [" + value + "]" );
	    HashMap<String, Object> KEY = (HashMap<String, Object>)Tag.getObject("PEM");
        String secret = ((SecretKey)KEY.get("JWT")).getSecretKey();

     	jwt.addSecret(secret);
     	jwt.addIssuer(Tag.getString("issuer.token"));
        this.logger.debug("issuer token: " + Tag.getString("issuer.token"));
     	
		DecodedJWT decode = jwt.validateToken(value);
		this.logger.info("subject    : " + decode.getSubject());
		this.logger.info("expires at : " + decode.getExpiresAt());
		this.logger.info("payload    : " + decode.getPayload());
		return true;
	}
	catch (Exception e) {
		e.printStackTrace();
		return false;}
	}//end-method
	
   /**
    * addDB(XMLReader x)
    * 
    * @param XMLReader
    * return void	
    */
	public void addDB(YAMLReader x) {this.geardb = x; this.service.addDB(x);}
	
   /**
    * addDB(XMLReader x)
    * 
    * @param XMLReader
    * return void	
    */
	public void addSecurity(YAMLReader x) {this.gearsecurity = x; this.service.addSecurity(x);}
	
	
}//end-class
