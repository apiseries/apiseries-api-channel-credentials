#!/bin/bash

#LIB=$(for i in lib/*.jar; do echo $i: ;done)
#LIBRARY=`echo $LIB | tr -d ' '`

# Definir colores
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
CIAN='\033[36m'

PURPLE_BACK='\033[45m'
CIAN_BACK='\033[46m'
RED_BACK='\033[41m'
GREEN_BACK='\033[42m'

NC='\033[0m'


# Definir lista de variables permitidas
VARS_PERMITIDAS=("GEAR_SERVER" "GEAR_SECURITY" "GEAR_SERVICE" "GEAR_HTTP" "GEAR_CONFIG" "GEAR_DB" "GEAR_SECRETS" "APINAME" "ENVIRONMENT")
security_dir="./security"
keygen_dir="keygen"
ssl_dir="ssl"

function java_version {
    # 1. Check if Java 21 is already installed
	if java -version 2>&1 | grep -q "21\."; then
	    echo "Java 21 is already installed."
	    java -version
	else
		echo "Java 21 not found. Proceeding with installation..."
		
		# 2. Install SDKMAN if not present
		if [ ! -d "$HOME/.sdkman" ]; then
		    echo "Installing SDKMAN!..."
		    curl -s "https://get.sdkman.io" | bash
		fi
		
		# 3. Load SDKMAN into current shell session
		export SDKMAN_DIR="$HOME/.sdkman"
		[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
		
		# 4. Install Java 21 (Temurin or OpenJDK distribution)
		echo "Installing Java 21..."
		sdk install java 21.0.2-tem  # Replace with desired version from 'sdk list java'
		
		# 5. Verify installation
		java -version
	fi
}

function env {

	echo "${YELLOW}1. Verificando variables de entorno...${NC}"
	if [ -z "$GEAR_SERVER" ]; then
	    echo -e "${RED}✗ GEAR_SERVER no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ GEAR_SERVER: $GEAR_SERVER${NC}"
	fi
	
	if [ -z "$GEAR_SECURITY" ]; then
	    echo -e "${RED}✗ GEAR_SECURITY no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ GEAR_SECURITY: $GEAR_SECURITY${NC}"
	fi
	
	if [ -z "$GEAR_SERVICE" ]; then
	    echo -e "${RED}✗ GEAR_SERVICE no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ GEAR_SERVICE: $GEAR_SERVICE${NC}"
	fi
	
	if [ -z "$GEAR_CONFIG" ]; then
	    echo -e "${RED}✗ GEAR_CONFIG no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ GEAR_CONFIG: $GEAR_CONFIG${NC}"
	fi

	if [ -z "$GEAR_DB" ]; then
	    echo -e "${RED}✗ GEAR_DB no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ GEAR_DB: $GEAR_DB${NC}"
	fi

	if [ -z "$APINAME" ]; then
	    echo -e "${RED}✗ APINAME no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ APINAME: $APINAME${NC}"
	fi

	if [ -z "$ENVIRONMENT" ]; then
	    echo -e "${RED}✗ ENVIRONMENT no está configurada${NC}"
	    exit 1
	else
	    echo -e "${GREEN}✓ ENVIRONMENT: $ENVIRONMENT${NC}"
	fi

}

# Función para configurar una variable de entorno permitida
function configurar_variable {
	
    read -p "Introduce el nombre de la variable: " NOMBRE_VAR
    if ! es_valida "$NOMBRE_VAR"; then
        echo "${RED}Error: La variable '$NOMBRE_VAR' no está permitida.${NC}"
        return 1
    fi

    read -s -p "Introduce el valor de la variable (oculto): " VALOR_VAR


    # Detectar el shell y archivo de configuración
    if [ -n "$BASH_VERSION" ]; then
        ARCHIVO_CONFIG="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        ARCHIVO_CONFIG="$HOME/.zshrc"
    else
        ARCHIVO_CONFIG="$HOME/.profile"
    fi


    # Verificar si la variable ya existe en el archivo
    if grep -q "export $NOMBRE_VAR=" "$ARCHIVO_CONFIG" 2>/dev/null; then
       echo
       echo "${YELLOW}La variable $NOMBRE_VAR ya existe. ¿Deseas actualizarla? (s/n)${NC}"
       read -r respuesta
       if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
            # Eliminar la línea existente
            sed -i "/export $NOMBRE_VAR=/d" "$ARCHIVO_CONFIG"
        else
            echo "${RED}Operación cancelada${NC}"
        fi
    fi

    # Agregar la variable al archivo
    echo "export $NOMBRE_VAR=\"$VALOR_VAR\"" >> "$ARCHIVO_CONFIG"
    
    # Exportar en la sesión actual
    export "$NOMBRE_VAR=$VALOR_VAR"
    
    echo ""
    echo "${GREEN}✓ Variable $NOMBRE_VAR guardada en $ARCHIVO_CONFIG${NC}"
    #echo "${GREEN}✓ Valor: $VALOR_VAR${NC}"
    echo ""
    echo "${PURPLE}Para aplicar en la sesión actual ejecuta:${NC}"
    echo "  source $ARCHIVO_CONFIG"

echo "------------------------------------"    
}

# Función para verificar si la variable es válida
function es_valida {
    local var="$1"
    for v in "${VARS_PERMITIDAS[@]}"; do
        if [ "$v" == "$var" ]; then
            return 0
        fi
    done
    return 1
}



function javakeytool {
	
	
	if [ ! -f $security_dir/$ssl_dir/.apiseries.p12 ]; then
	
		 read -p "El dominio principal que va a proteger el certificado: " CN
		 read -p "Departamento o división dentro de la organización: " OU
		 read -p "Nombre legal de la empresa u organización: " O
		 read -p "Ciudad donde se encuentra la organización: " L
		 read -p "Código de país en formato ISO 3166-1 alpha-2: " C
		 read -s -p "Contraseña: " PASSWORD
		
		keytool -genkeypair \
	    -alias gearssl \
	    -keyalg RSA \
	    -keysize 2048 \
	    -validity 365 \
	    -storetype PKCS12 \
	    -keystore $security_dir/$ssl_dir/.apiseries.p12 \
	    -storepass $PASSWORD \
	    -dname "CN=$CN, OU=$OU, O=$O, L=$L, C=$C"
	
	else
	
	    echo "${RED_BACK}Keystore existente. ¿desea regenerarlo?${NC}"
	    read -p "S/N " OPT
	    if [[ "$OPT" == "S" || "$OPT" == "s" ]]; then
	         rm -f $security_dir/$ssl_dir/.apiseries.p12
	         javakeytool 
	    fi
	
	fi
	
}

function mkcert {
	
  if command -v mkcert &> /dev/null; then
   
	   if [ -f $security_dir/$ssl_dir/.apiseries.p12 ]; then

            sudo mkcert localhost 127.0.0.1 ::1
            echo "Certificado creado OK"
            
            if [ -f localhost+2-key.pem ]; then
                 mv localhost+2-key.pem $security_dir/$ssl_dir 	
            fi
            
            if [ -f localhost+2.pem ]; then
                 mv localhost+2.pem $security_dir/$ssl_dir 	
            fi
            
		    #mkcert -install
		    #mkcert localhost 127.0.0.1 ::1
	   fi
  
  else
    echo "mkcert NO está instalado."
  fi
	
}


function keystore {
	
		 read -p "Contraseña: " PASSWORD
         keytool -list -v -keystore $security_dir/$ssl_dir/.apiseries.p12 -storepass $PASSWORD
	
}


if [ "$1" == "start" ]; then


echo "▄▄▄▄   ▄▄▄  ▐▌█  ▐▌▄▄▄▄"  
echo "█   █ █   █ ▐▌▀▄▄▞▘█   █" 
echo "█   █ ▀▄▄▄▀ ▐▛▀▚▖  █▄▄▄▀" 
echo "            ▐▌ ▐▌  █"     
echo "                   ▀"   

env
nohup java -Dgear-server=$GEAR_SERVER \
      -Dgear-security=$GEAR_SECURITY \
      -Dgear-service=$GEAR_SERVICE \
      -Dgear-http=$GEAR_HTTP \
      -Dgear-classpath= \
      -Dgear-config=$GEAR_CONFIG \
      -Dgear-db=$GEAR_DB \
      -Dgear-secrets=$GEAR_SECRETS \
      -Dfile.encoding=ISO-8859-1 \
      -jar ../../../target/apiseries-api.jar > nohup.out  2>&1&
      echo $! > process.pid
fi

if [ "$1" == "stop" ]; then

echo "█  ▄ ▄ █ █" 
echo "█▄▀  ▄ █ █" 
echo "█ ▀▄ █ █ █"
echo "█  █ █ █ █" 

        kill -9 `cat process.pid`
fi

if [ "$1" == "status" ]; then

                                         
echo "    ____  _________  ________  __________"
echo "   / __ \/ ___/ __ \/ ___/ _ \/ ___/ ___/"
echo "  / /_/ / /  / /_/ / /__/  __(__  |__  )" 
echo " /  ___/_/   \____/\___/\___/____/____/"  
echo "/_/"                                      

	if [ -f "process.pid" ]; then
		if ps -p `cat process.pid` > /dev/null; then
		    echo "El proceso con PID <PID> está en ejecución."
		else
		    echo "El proceso con PID <PID> NO está en ejecución."
		fi
	else
	   echo "El proceso NO está en ejecución."
	fi
fi


if [ "$1" == "run" ]; then

echo "██████╗ ██╗   ██╗███╗   ██╗"
echo "██╔══██╗██║   ██║████╗  ██║"
echo "██████╔╝██║   ██║██╔██╗ ██║"
echo "██╔══██╗██║   ██║██║╚██╗██║"
echo "██║  ██║╚██████╔╝██║ ╚████║"
echo "╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"

env
java -Dgear-server=$GEAR_SERVER \
     -Dgear-security=$GEAR_SECURITY \
     -Dgear-service=$GEAR_SERVICE \
     -Dgear-http=$GEAR_HTTP \
     -Dgear-classpath= \
     -Dgear-config=$GEAR_CONFIG \
     -Dgear-db=$GEAR_DB \
     -Dgear-secrets=$GEAR_SECRETS \
     -jar ../../../target/apiseries-api.jar
fi


if [ "$1" == "healthcheck" ]; then

            
echo "     ███"    
echo "    ▒███"    
echo " ███████████"
echo "▒▒▒▒▒███▒▒▒" 
echo "    ▒███"    
echo "    ▒▒▒"   

    echo ${APINAME}
	response=$(curl -s http://localhost:8000/apis/nodes/$(echo ${APINAME})/healthcheck/health)
	body=$(echo "$response")
	message=$(echo "$response" | jq -r '.message')   # -r para quitar las comillas
	status=$(echo "$response" | jq -r '.status')
	
	echo "status: $status"
	echo $message | jq '.'

fi

if [ "$1" == "env" ]; then

 
 
     while true; do
        echo
        
        echo "░█▀▀░█▀▀░█▀█░█▀▄░░░░░█▀▀░█▀█░█░█"
		echo "░█░█░█▀▀░█▀█░█▀▄░▄▄▄░█▀▀░█░█░▀▄▀"
		echo "░▀▀▀░▀▀▀░▀░▀░▀░▀░░░░░▀▀▀░▀░▀░░▀░"
        echo "${PURPLE_BACK}APISeries - Environment Microservices${NC}"  
        echo 

        echo "Variables permitidas: ${VARS_PERMITIDAS[*]}"
        echo "${PURPLE}1) setenv${NC}: Configurar variables de entorno"
        echo "${PURPLE}2) getenv${NC}: Listar variables de entorno"
        echo "${PURPLE}3) api env${NC}: Listar variables de entorno desde la API"
        echo "${RED}4) exit${NC}"
        read -p "Selecciona una opción [1-4]: " opcion

        case $opcion in
            1)
                configurar_variable
                ;;
            2)
                # Definir lista de variables permitidas
                #VARS_PERMITIDAS=("GEAR_SERVER" "GEAR_SECURITY" "GEAR_SERVICE" "GEAR_HTTP" "GEAR_NOSQL")
                echo "${CIAN}APINAME:${NC}${APINAME}"
                echo "${CIAN}GEAR_SERVER:${NC}${GEAR_SERVER}"
                echo "${CIAN}GEAR_SECURITY:${NC}${GEAR_SECURITY}"
                echo "${CIAN}GEAR_SERVICE:${NC}${GEAR_SERVICE}"
                echo "${CIAN}GEAR_CONFIG:${NC}${GEAR_CONFIG}"
                echo "${CIAN}GEAR_DB:${NC}${GEAR_DB}"
                echo "${CIAN}GEAR_SECRETS:${NC}${GEAR_SECRETS}"
                echo "${CIAN}ENVIRONMENT:${NC}${ENVIRONMENT}"
                
                ;;
            3)
				echo " _____ ____ _   _ ___" 
				echo "| ___ |  _ \ | | /___)"
				echo "| ____| | | \ V /___ |"
				echo "|_____)_| |_|\_/(___/"             
				
					response=$(curl -s http://localhost:8000/apis/nodes/${APINAME}/healthcheck/env)
					response=$(echo $response | sed 's/\n//g')
					response=$(echo "$response" | jq -R '.' | jq -s '.' | jq -r 'join("")' )
				
				
				    message=$(echo "$response" | jq -r '.message')
					status=$(echo "$response" | jq -r '.status')
					echo "status: $status"
					echo "$message" | jq '.'
                ;;
            4)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción inválida. Intenta nuevamente."
                ;;
        esac    done
 
fi

if [ "$1" == "properties" ]; then

echo "▗▄▄▖ ▗▄▄▖  ▗▄▖ ▗▄▄▖  ▗▄▄▖"
echo "▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌   "
echo "▐▛▀▘ ▐▛▀▚▖▐▌ ▐▌▐▛▀▘  ▝▀▚▖"
echo "▐▌   ▐▌ ▐▌▝▚▄▞▘▐▌   ▗▄▄▞"            

	response=$(curl -s http://localhost:8000/apis/nodes/${APINAME}/healthcheck/props)
	response=$(echo $response | sed 's/\n//g')
	response=$(echo "$response" | jq -R '.' | jq -s '.' | jq -r 'join("")' )


    message=$(echo "$response" | jq -r '.message')
	status=$(echo "$response" | jq -r '.status')
	echo "status: $status"
	echo "$message" | jq '.'

fi

if [ "$1" == "keygen" ]; then


echo " ▗▄▄▖▗▄▄▖▗▖  ▗▖▗▄▄▖▗▄▄▄▖▗▄▖ "
echo "▐▌   ▐▌ ▐▌▝▚▞▘ ▐▌ ▐▌ █ ▐▌ ▐▌"
echo "▐▌   ▐▛▀▚▖ ▐▌  ▐▛▀▘  █ ▐▌ ▐▌"
echo "▝▚▄▄▖▐▌ ▐▌ ▐▌  ▐▌    █ ▝▚▄▞▘"

java_version

group_id="com.gear.keygen"
artifact_id="gear-keygen"
version="latest"  # o "RELEASE", "LATEST"

	if [ ! -d "$security_dir" ]; then
	     mkdir "$security_dir"
	fi 

	if [ ! -d "$security_dir/$keygen_dir" ]; then
	     mkdir "$security_dir/$keygen_dir"
	fi 


    echo "${PURPLE}1) 3DES ${NC}: Generate 3DES file"
    echo "${PURPLE}2) ASYMETRIC${NC}: Generate asymmetric file pair"
    echo "${PURPLE}3) HASH ${NC}: Generate a message hash"
    echo "${PURPLE}4) HEX Message ${NC}: Generate HEX message"
    echo "${PURPLE}5) HEX/3DES Message ${NC}: Generate HEX/3DES message"
    echo "${RED}6) exit${NC}"
    read -p "Selecciona una opción [1-4]: " opcion

    case $opcion in
            1)
				mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
			    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
			         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "3DES" ${security_dir}/$keygen_dir 256
			         echo "${GREEN}success $2 crypto file${NC}"
			         rm -f "${security_dir}/${artifact_id}-${version}.jar"
			         exit 0
			    fi            
                ;;
            2)
				mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
			    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
			         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "ASIMETRIC" ${security_dir}/$keygen_dir
			         echo "${GREEN}success $2 crypto file${NC}"
			         rm -f "${security_dir}/${artifact_id}-${version}.jar"
			         exit 0
			    fi            
                ;;
            3)
            
				    echo "choose an encryption option"
				    echo "${PURPLE}1) SHA-256 ${NC}"
				    echo "${PURPLE}2) SHA-384${NC}"
				    echo "${PURPLE}3) SHA-512 ${NC}"
				    echo "${RED}4) exit${NC}"
				    read -p "Selecciona una opción [1-4]: " opcion2
	                
	                if [ $opcion2 = 1 ]; then
			                    read -p "Message Payload: " PAYLOAD
								mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
							    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
							         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "HASH" "SHA-256" ${security_dir}/$keygen_dir $PAYLOAD
							         echo "${GREEN}success $2 crypto file${NC}"
							         rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
							         exit 0
							    fi            
			        fi
	                if [ $opcion2 = 2 ]; then
			                    read -p "Message Payload: " PAYLOAD
								mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
							    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
							         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "HASH" "SHA-384" ${security_dir}/$keygen_dir $PAYLOAD
							         echo "${GREEN}success $2 crypto file${NC}"
							         rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
							         exit 0
							    fi
				    fi			                
	                if [ $opcion2 = 3 ]; then
			                    read -p "Message Payload: " PAYLOAD
								mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
							    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
							         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "HASH" "SHA-512" ${security_dir}/$keygen_dir $PAYLOAD
							         echo "${GREEN}success $2 crypto file${NC}"
							         rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
							         exit 0
							    fi            
			        fi
	                if [ $opcion2 = 4 ]; then
  	                     echo "Saliendo..."
			             exit 0
				    fi
	
                ;;
            4)
                read -p "Message Payload: " PAYLOAD
                echo -n "$PAYLOAD" | xxd -p
               
                ;;
            5)
            
                ;;    
            6)
                echo "Saliendo..."
                exit 0
                ;;
    
        esac

				
fi


if [ "$1" == "ssl" ]; then


     while true; do
        echo
        
        
        echo "░█▀▀░█▀▀░█▀█░█▀▄░░░░░█▀▀░█▀▀░█░░"
		echo "░█░█░█▀▀░█▀█░█▀▄░▄▄▄░▀▀█░▀▀█░█░░"
		echo "░▀▀▀░▀▀▀░▀░▀░▀░▀░░░░░▀▀▀░▀▀▀░▀▀▀"
        echo "${PURPLE_BACK}APISeries - SSL Microservices${NC}"  
        echo 

        echo "${PURPLE}1) keytool${NC}: Genera certificado local usando keytool"
        echo "${PURPLE}2) mkcert${NC}: Genera certifiado local usando mkcert"
        echo "${PURPLE}3) ver keystore${NC}: Lista de certificados cargados"
        echo "${RED}4) exit${NC}"
        read -p "Selecciona una opción [1-4]: " opcion

        case $opcion in
            1)
                javakeytool
                ;;
            2)
                mkcert                
                ;;
            3)
                keystore
                ;;
            4)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción inválida. Intenta nuevamente."
                ;;
        esac    done

fi

if [ "$1" == "docker" ]; then


	if [ -z "$APINAME" ]; then
	    echo "${RED}✗ Env APINAME no está configurada${NC}"
	    exit 1
	else
	
	    if [ -f dockerfile ]; then
			    docker build -t apiseries-api-${APINAME} .
		else
		    echo "Dockerfile not found"
		fi
	fi

fi



if [ "$1" == "" ]; then
        
        
        echo "${CIAN}░█▀▀░█▀▀░█▀█░█▀▄░░░░░█▀█░█▀█░▀█▀${NC}"
        echo "${BLUE}░█░█░█▀▀░█▀█░█▀▄░▄▄▄░█▀█░█▀▀░░█░${NC}"
		echo "${PURPLE}░▀▀▀░▀▀▀░▀░▀░▀░▀░░░░░▀░▀░▀░░░▀▀▀${NC}"
        echo "${PURPLE_BACK}APISeries - Microservices${NC}"  
        echo 
        echo "sh gear.sh start|stop|run|status|health|env|properties|keygen|ssl|docker"
        echo ---
        echo ${GREEN}Options:${NC} 
        echo "${PURPLE}start${NC}      : Start in service mode" 
        echo "${PURPLE}stop${NC}       : Stop service"
        echo "${PURPLE}run${NC}        : Start service in interactive mode"
        echo "${PURPLE}status${NC}     : View process ID"
        echo "${PURPLE}health${NC}     : Validate service status"
        echo "${PURPLE}env${NC}        : Environment variables"
        echo "${PURPLE}properties${NC} : View properties"
        echo "${PURPLE}keygen${NC}     : Create PEM files for the following encryption types: 3DES, Asymmetric Hash"
        echo "${PURPLE}ssl${NC}        : Create SSL certificate (Keytool, MakeCert)"
        echo "${PURPLE}docker${NC}     : Generate Docker Image"
        echo 

fi
