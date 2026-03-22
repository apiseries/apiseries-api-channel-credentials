/**
 * 
 */
package com.apiseries.api.controller;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.apiseries.api.exception.APIException;
import com.apiseries.api.implement.ControllerImplement;
import com.apiseries.gear.mapper.RequestMapper;

/**
 * 
 */
public class Controller implements ControllerImplement{

	private Logger logger = null;
	
   /**
	* Controller
	*/
	public Controller() {this.logger = LogManager.getLogger(this.getClass()); this.logger.info(this.getClass().getName() + " : instanceof true");}

	@Override
	public Object toEmit(RequestMapper value) throws APIException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean jwt(String value) throws APIException {
		// TODO Auto-generated method stub
		return false;
	}

}//end-class
