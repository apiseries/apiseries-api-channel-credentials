/**
 * 
 */
package com.apiseries.api.mapper;

import java.util.HashMap;
import java.util.Map;

/**
 * 
 */
public class ClientAccessResponse {

	private int status = 0;
	private Map<String,String> sii = new HashMap<>();
	private Map<String,String> previred = new HashMap<>();
	
   /**
	* 
	*/
	public ClientAccessResponse() {}
	
   /**
	* @param status
	*/
	public ClientAccessResponse(int status, Map<String,String> sii, Map<String,String> previred) {
		super();
		this.status = status;
		this.sii = sii;
		this.previred = previred;
	}

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
    * @return the sii
    */
   public Map<String, String> getSii() {
	return sii;
   }

   /**
    * @param sii the sii to set
    */
   public void setSii(Map<String, String> sii) {
	this.sii = sii;
   }

   /**
    * @return the previred
    */
   public Map<String, String> getPrevired() {
	return previred;
   }

   /**
    * @param previred the previred to set
    */
   public void setPrevired(Map<String, String> previred) {
	this.previred = previred;
   }

	
}//end-class
