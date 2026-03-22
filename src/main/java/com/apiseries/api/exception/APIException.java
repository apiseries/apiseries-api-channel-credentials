/*******************************************************************************
 * <pre>
 * Copyright (c) 2012 
 * componente: adapter-YYYYMM.VV.FF.jar
 * 
 * Este software esta desarrollado con tecnolog�a Java, 
 * Utilizando la versi�n 1.6.0, bajo licencia GNU GPL.
 * 
 * Otros componentes utilizados son Open Source 
 * bajo Licencia Apache 2.0.
 * 
 * log4j-1.2.15.jar
 * commons-collections-3.2.1.jar
 * commons-lang-2.4.jar
 * commons-digester-1.8.jar
 * commons-beanutils-core-1.8.0.jar
 * commons-io-1.2.jar
 * commons-configuration-1.6.jar
 * 
 * Contribuciones:
 *       Gaston Quezada - Creador de la api adapter-YYYYMM.VV.FF.jar
 * </pre>
 *******************************************************************************/
package com.apiseries.api.exception;

/**
 * @author Gaston Quezada
 * */
public class APIException extends Exception {

	private static final long serialVersionUID = 1932983921075660011L;
	public APIException(){}//fin-constructor
	public APIException(String e){super(e);}//fin-constructor
	public APIException(Exception e) {super(e); this.SFStackTrace();}//fin-constructor

   /**
    * SFStackTrace
    * 
    * @since 1.4
    * @see Exception 	
    */
	private void SFStackTrace(){
		
        System.out.println("class   | " + APIException.class.getName());		
        System.out.println("message | " + super.getMessage());		
        System.out.println("details");		

        if ( super.getStackTrace().length  <= 20 ){
            for (int i = 0; i < super.getStackTrace().length; i++ ){
            	System.out.println("(" + super.getStackTrace()[i].getLineNumber() + ") : " + 
            			                 super.getStackTrace()[i].getFileName() + " : " + 
            			                 super.getStackTrace()[i].getMethodName());		
            }
        } 
        else{
            for (int i = 0; i < 30; i++ ){
            	System.out.println("(" + super.getStackTrace()[i].getLineNumber() + ") : " + 
            			                 super.getStackTrace()[i].getFileName() + " : " + 
            			                 super.getStackTrace()[i].getMethodName());		
            }
        }
        
	}//fin-metodo

}//fin-clase
