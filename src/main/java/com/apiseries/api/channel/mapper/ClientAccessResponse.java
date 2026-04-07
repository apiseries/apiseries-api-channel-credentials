/**
 * 
 */
package com.apiseries.api.channel.mapper;


/**
 * 
 */
public class ClientAccessResponse {

	private int status = 0;
	private String channel = null; 

   /**
	* 
	*/
	public ClientAccessResponse() {}
	
   /**
    * @param status
    * @param channel
    */
	public ClientAccessResponse(int status, String channel) {
		super();
		this.status = status;
		this.channel = channel;
	}

   /**
    * @return the channel
    */
	public String getChannel() {
		return channel;
	}

   /**
    * @param channel the channel to set
    */
    public void setChannel(String channel) {
	  this.channel = channel;
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


	
}//end-class
