/**
 * 
 */
package com.apiseries.api.channel.implement;

import com.apiseries.api.channel.exception.APIException;
import com.apiseries.gear.mapper.RequestMapper;

/**
 * 
 */
public interface ControllerImplement {

	public Object toEmit(RequestMapper value) throws APIException;
	public boolean jwt(String value) throws APIException;
	
}
