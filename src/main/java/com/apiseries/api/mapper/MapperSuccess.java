/**
 * 
 */
package com.apiseries.api.mapper;

import com.gear.tools.function.JSONInclude;

/**
 * 
 */
public class MapperSuccess {
	
	@JSONInclude(key="status") private int status = 0;
	@JSONInclude(key="message") private String message = null;
	
	/**
	 * @return the status
	 */
	public int getStatus() {
		return status;
	}
	/**
	 * @param status the status to set
	 */
	public void setStatus(int status) {
		this.status = status;
	}
	/**
	 * @return the message
	 */
	public String getMessage() {
		return message;
	}
	/**
	 * @param message the message to set
	 */
	public void setMessage(String message) {
		this.message = message;
	}
	

	
}//end-class
