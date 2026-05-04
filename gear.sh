#!/bin/bash

##################################################################
# Author : Apiseries - GQUEZADA
# Date   :
# Details: 
##################################################################

#
#
# VARS and folders project
#
#
ALLOWED_VARS=("GEAR_SERVER" "GEAR_SECURITY" "GEAR_SERVICE" "GEAR_HTTP" "GEAR_CONFIG" "GEAR_DB" "GEAR_SECRETS" "APINAME" "ENVIRONMENT")
ALLOWED_FILES=("gear-server.yml" "gear-security.yml" "gear-service.yml" "gear-http.yml" "gear-config.yml" "database.xml" "secrets.yml")

conf_dir="src/main/resources/conf"
security_dir="src/main/resources/security"
keygen_dir="keygen"
ssl_dir="ssl"
JWT=".jwt"

DOCKER_MONGODB_IP=0.0.0.0
DOCKER_QPID_IP=0.0.0.0
DOCKER_KAFKA_IP=0.0.0.0
DOCKER_REDIS_IP=0.0.0.0

ENV_FLAG=0

BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
CIAN='\033[36m'

BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CIAN='\033[46m'
BG_WHITE='\033[47m'

BG_BLACK_I='\033[100m'
BG_RED_I='\033[101m'
BG_GREEN_I='\033[102m'
BG_YELLOW_I='\033[103m'
BG_BLUE_I='\033[104m'
BG_MAGENTA_I='\033[105m'
BG_CIAN_I='\033[106m'
BG_WHITE_I='\033[107'

NC='\033[0m'
RESET="\e[0m"
TCOL=$(tput cols)
COL_MIDDLE=$((TCOL / 2))
COL=$((TCOL - 2))
COL_3=$((TCOL - 3))
COL_4=$((TCOL - 4))
COL_5=$((TCOL - 5))


function  run_with_spinner() {
    local spinstr='.:'
    local delay=0.5
    "$@" &
    local pid=$!

    while kill -0 $pid 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r[%c] running..." "${spinstr:$i:1}"
            sleep "$delay"
        done
    done

    wait "$pid"
    printf "${BG_GREEN}\r%s ${NC} Completed.\n" "$( [ $? -eq 0 ] && echo '✓' || echo '✗' )"
}



#
# function: java_version
# detail: verify installed JVM and install if not available
#
function clean {
	 clear
}

draw_line() {
	echo
    local char=${1:-"-"} # Usa "-" por defecto si no pasas un carácter
    local cols=$(tput cols)
    printf '%*s\n' "$cols" '' | tr ' ' "$char"
    echo
}


#
# function: java_version
# detail: verify installed JVM and install if not available
#
function java_version {

    # 1. Check if Java 21 is already installed
	if ! command -v java >/dev/null 2>&1; then
        printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "Java is not installed or is not in the PATH"
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
        exit 1
        #view_status "Java" 1
        
	else
   	    JAVA_LINE=$(java -version 2>&1 | head -n 1)
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "Java: ${JAVA_LINE} is already installed"
        #view_status "Java: ${JAVA_LINE}" 0
	fi
}

#
# function: java_version
# detail: verify installed JVM and install if not available
#
function ollama_version {

    # 1. Check if Java 21 is already installed
	if ! command -v ollama &> /dev/null; then
        printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "ollama not found. "
        #view_status "ollama" 1
	else
   	    OLLAMA_LINE=$(ollama --version 2>&1 | head -n 1)
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "Ollama: ${OLLAMA_LINE} is already installed"
        #view_status "ollama: ${OLLAMA_LINE}" 0
	fi
}

function fzf_version {

	if ! command -v fzf &> /dev/null; then
	    printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "fzf not found. "
	else
	    FZF_LINE=$(fzf --version 2>&1 | head -n 1)
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "fzf: ${FZF_LINE} is already installed"
	
	fi

}

function whiptail_version {

	if ! command -v whiptail &> /dev/null; then
	    printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "whiptail not found. "
	else
	    WP_LINE=$(whiptail --version 2>&1 | head -n 1)
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "whiptail: ${WP_LINE} is already installed"
	
	fi

}

function docker_version {

	if ! command -v docker &> /dev/null; then
	    printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "docker not found. "
	else
	    DOCKER_LINE=`sudo docker --version 2>&1 | head -n 1`
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "Docker: ${DOCKER_LINE}is already installed"
	
	fi

}

function maven_version {

	if ! command -v mvn &> /dev/null; then
	    printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "maven not found. "
	else
	    MVN_LINE=`mvn --version 2>&1 | head -n 1`
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "Maven: ${MVN_LINE} is already installed"
	
	fi
}

function external_version {

    MONGODB=`grep 'mongodb:' $conf_dir/gear-config.yml | tail -n 1 | xargs`
    QPID=`grep 'qpid' $conf_dir/gear-security.yml | tail -n 1 | xargs`
    KAFKA=`grep 'kafka' $conf_dir/gear-security.yml | tail -n 1 | xargs`
    REDIS= `grep 'redis' $conf_dir/gear-security.yml | tail -n 1 | xargs`

    APPS=("nexus")
    if [ "${MONGODB}" != "" ]; then APPS+=("mongodb"); fi 
    if [ "${QPID}" != "" ]; then APPS+=("qpid"); fi 
    if [ "${KAFKA}" != "" ]; then APPS+=("kafka"); fi 
    if [ "${REDIS}" != "" ]; then APPS+=("redis"); fi 
         
    LIST=`sudo docker ps | tail -n +2 | awk -F ' ' 'BEGIN{OFS="_"}{print $1, $2}'`
    DOCKERS=($LIST) 
    
    IS_ALIVE=false
    for apps in "${APPS[@]}"; do
		 for dock in "${DOCKERS[@]}"; do

		     INDEXOF=`echo ${dock} | grep -o ${apps}`
		     if [ "${INDEXOF}" != "" ]; then
			     DOCKER_ID=`echo ${dock} | awk -F '_' '{print $1}'`
			     #echo "nexus: ${DOCKER_ID}"
	             IP=`sudo docker exec ${DOCKER_ID} hostname -i`
			     #echo "nexus: ${IP}"
			     IS_ALIVE=true
			     
             fi

		 done
		 
		 if [ "${IS_ALIVE}" = "true" ]; then printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "docker ${apps} is online"; fi
		 if [ "${IS_ALIVE}" = "false" ]; then printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "docker ${apps} is offline"; fi
		 IS_ALIVE=false
	done	 


}


function view_status {
    local label=$1
    local status=$2

    if [ "$status" -eq 0 ]; then
        printf "${BG_GREEN}✔ ${NC}$label "
    else
        printf "${BG_RED}✘ ${NC}$label "
    fi
}

#
# function: env
# detail: verify ENV variables for execute API
#
function env {

    echo
    printf "${BG_MAGENTA}? ${NC}${BOLD}%-${COL}s${RESET}\n" "checking environment variables"
    ENV_FLAG=0
    
	if [ -z "$GEAR_SERVER" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}GEAR_SERVER It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "GEAR_SERVER It is not configured"
        ENV_FLAG=1
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "GEAR_SERVER: $GEAR_SERVER"
	fi
	
	if [ -z "$GEAR_SECURITY" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}GEAR_SECURITY It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "GEAR_SECURITY It is not configured"
        ENV_FLAG=1
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "GEAR_SECURITY: $GEAR_SECURITY"
	fi
	
	if [ -z "$GEAR_SERVICE" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}GEAR_SERVICE It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "GEAR_SERVICE It is not configured"
        ENV_FLAG=1
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "GEAR_SERVICE: $GEAR_SERVICE"
	fi
	
	if [ -z "$GEAR_CONFIG" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}GEAR_CONFIG It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "GEAR_CONFIG It is not configured"
        ENV_FLAG=1
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "GEAR_CONFIG: $GEAR_CONFIG"
	fi

	if [ -z "$GEAR_DB" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}GEAR_DB It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "GEAR_DB It is not configured"
        ENV_FLAG=1
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "GEAR_DB: $GEAR_DB"
	fi

	if [ -z "$APINAME" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}APINAME It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "APINAME It is not configured"
        APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
        export APINAME=$APINAME
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "APINAME: $APINAME"
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "APINAME: $APINAME"
	fi

	if [ -z "$ENVIRONMENT" ]; then
        #sleep 0.5 | echo "${BG_RED}✗ ${NC}${BG_BLUE}ENVIRONMENT It is not configured${NC}"
        sleep 0.2 | printf "${BG_RED}✗ ${NC}%-${COL}s${RESET}\n" "ENVIRONMENT It is not configured"
        ENV_FLAG=1
	else
        sleep 0.2 | printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "ENVIRONMENT: $ENVIRONMENT"

	fi

    echo
	#if [ $ENV_FLAG -eq 1 ]; then
	#   exit 1
	#fi

}

#
# function: jave_version
# detail: verify installed JVM and install if not available
#
function configure_variable {
	
    read -p "Enter the variable name: " NOMBRE_VAR
    if ! es_valida "$NOMBRE_VAR"; then
        echo "${RED}Error: The variable '$NOMBRE_VAR' It is not allowed.${NC}"
        return 1
    fi

    read -s -p "Enter the value of the variable (hidden): " VALOR_VAR


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
       echo "${YELLOW}The variable $NOMBRE_VAR It already exists. Do you want to update it? (y/n)${NC}"
       read -r respuesta
       if [ "$respuesta" = "y" ] || [ "$respuesta" = "Y" ]; then
            # Eliminar la línea existente
            sed -i "/export $NOMBRE_VAR=/d" "$ARCHIVO_CONFIG"
        else
            echo "${RED}Operation cancelled${NC}"
        fi
    fi

    # Agregar la variable al archivo
    echo "sudo export $NOMBRE_VAR=\"$VALOR_VAR\"" >> "$ARCHIVO_CONFIG"
    
    # Exportar en la sesión actual
    export "$NOMBRE_VAR=$VALOR_VAR"
    
    echo ""
    echo "${GREEN}✓ Variable $NOMBRE_VAR saved in $ARCHIVO_CONFIG${NC}"
    #echo "${GREEN}✓ Valor: $VALOR_VAR${NC}"
    echo ""
    echo "${PURPLE}To apply in the current session, run:${NC}"
    echo "  source $ARCHIVO_CONFIG"

echo "------------------------------------"    
}

#
# function: verify_variable
# detail: verify installed JVM and install if not available
#
function verify_variable {
	
	NOMBRE_VAR="$1"
	VALOR_VAR="$2"
    printf "${BG_GREEN}✓ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "$NOMBRE_VAR:$VALOR_VAR"

}


#
# function: es_valida
# detail: Function to check if the variable is valid
#
function es_valida {
    local var="$1"
    for v in "${ALLOWED_VARS[@]}"; do
        if [ "$v" == "$var" ]; then
            return 0
        fi
    done
    return 1
}


#
# function: javakeytool
# detail: Generates keystore and self-signed digital certificate
#
function javakeytool {
	
	
	if [ ! -f $security_dir/$ssl_dir/.apiseries.p12 ]; then
	
		 read -p "The primary domain that the certificate will protect: " CN
		 read -p "Department or division within the organization: " OU
		 read -p "Legal name of the company or organization: " O
		 read -p "City where the organization is located: " L
		 read -p "Country code in ISO 3166-1 alpha-2 format: " C
		 read -s -p "Password: " PASSWORD
		
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
	
	    echo "${RED_BACK}Existing keystore. Do you want to regenerate it?${NC}"
	    read -p "Y/n " OPT
	    if [[ "$OPT" == "Y" || "$OPT" == "y" ]]; then
	         rm -f $security_dir/$ssl_dir/.apiseries.p12
	         javakeytool 
	    fi
	
	fi
	
}

#
# function: mkcert
# detail: It generates a local digital certificate and saves it in the previously created Keystore.
#
function mkcert {
	
  if command -v mkcert &> /dev/null; then
   
	   if [ -f $security_dir/$ssl_dir/.apiseries.p12 ]; then

            echo "sudo mkcert localhost 127.0.0.1 ::1"
            sudo mkcert localhost 127.0.0.1 ::1
            echo "Certificate created OK"
            
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
    echo "${RED}✗ mkcert is NOT installed.${NC}"
  fi
	
}

#
# function: keystore
# detail: List of contents of the project keystore
#
function keystore {
	
	KEYSTORE=$security_dir/$ssl_dir/.apiseries.p12
	echo  "${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo  "${BLUE}│ VIEWER PKCS#12 (.p12)                                      │${NC}"
    echo  "${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
	echo	
    read -s -p "Store Password: " PASSWORD

    ALIAS=`keytool -list -v -keystore ${KEYSTORE} -storepass ${PASSWORD} 2>/dev/null | grep "^Nombre de Alias:" | awk '{print $4}'`
         
	SELECTED=$(echo "$ALIAS" | fzf \
	  --header="Keystore: $(basename "$KEYSTORE") | Type to filter | Press Enter to exit" \
	  --preview="keytool -list -v -keystore ${KEYSTORE} -storepass ${PASSWORD} -alias {} 2>/dev/null | head -n 40" \
	  --preview-window="right:65%" \
	  --color="hl:36,hl+:136,fg:-1,bg:-1,fg+:-1,bg+:-1" \
	  --bind "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up") || exit 0
	
	
	if [ $? -ne 0 ] || [ -z "$SELECTED" ]; then return; fi

}

#
# function: ecosystem
# detail: Propagates JWT key in projects identified as microservices
#
function ecosystem {

for dir in ../apiseries-api*; do
    if [ -d "$dir" ]; then
    
       if [ -f $dir/.gear ];then
           printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "Gear project detected"
           
	       cp -f ${security_dir}/${keygen_dir}/jwt.pem $dir/src/main/resources/security/$keygen_dir/
	       ls -l $dir/src/main/resources/security/$keygen_dir/jwt.pem
	       echo "________________________________________"
       fi
       
    fi
done    
}


function navigate_directories {
  local dir="${1:-.}"
  
  while true; do
    # Listamos todo (archivos y carpetas)
    # --preview: Si es carpeta usa 'ls', si es archivo usa 'bat' o 'cat'
    choice=$(ls -ap "$dir" | grep -v "^\./$" | fzf \
      --height=80% \
      --layout=reverse \
      --border \
      --header=" $dir | [Enter] Open/Enter | [ESC] Exit" \
      --preview "
        if [ -d '$dir/{}' ]; then
            ls -Fp --color=always '$dir/{}'
        else
            bat --style=numbers --color=always --line-range :500 '$dir/{}' 2>/dev/null || cat '$dir/{}'
        fi
      ")

    # Si cancela con ESC
    if [ -z "$choice" ]; then break; fi

    local target="$dir/$choice"

    if [ -d "$target" ]; then
        # Si es directorio, entramos
        dir=$(realpath "$target")
    else
        # Si es archivo, lo visualizamos a pantalla completa con 'less'
        # o puedes cambiarlo por tu editor: nano "$target"
        clear
        echo "\033[1;34m--- Contenido de $choice ---\033[0m"
        bat --style=plain --color=always "$target" 2>/dev/null || less "$target"
        echo "\n\033[1;30mPress any key to return...\033[0m"
        read -n 1
    fi
  done
}






function logo_docker {

draw_line       
#echo "${BLUE}             ___|▓|${NC}"
#echo "${BLUE}        ____|▓|▓|▓|      .${NC}"
#echo "${BLUE}     __|▓▓|▓▓|▓▓|▓|    ^   ^ ${NC}"
#echo "${BLUE}    |▓|▓▓|▓▓|▓▓|▓▓▓|   \ v  /${NC}"
#echo "${BLUE}   /'''''''''''''''\___/   /${NC}"
#echo "${BLUE}  (                       /${NC}"
#echo "${BLUE}   \______ o           __/${NC}"
#echo "${BLUE}     \    \         __/${NC}"
#echo "${BLUE}      \____\_______/${NC}"
#echo 

echo "${BLUE}   ██"
echo "${BLUE}   ██|██"
echo "${BLUE}██|██|██ d  o  c  k  e  r${NC}"
echo 


return;	
}

function main { 
	
	clean       
         
        #echo "${BLUE} ▄█. .█▄ ${NC}"
        #echo "${BLUE}▀ ▀█ █▀ ▀ ${NC}"
        #echo "${BLUE}   ▀ ▀   ${NC}" 
        #echo "g e a r  C L I ®"
        #
        #echo "${BLUE}  ▄. .▄ ${NC}"
        #echo "${BLUE}▀ ▀█ █▀ ▀ ${NC}"
        #echo "${BLUE}   ▀ ▀   ${NC}" 
        #             
        #echo "${BLUE}  «•_•»  ${NC}"
        #echo "${BLUE}▀ ▀█ █▀ ▀ ${NC}"
        #echo "${BLUE}   ▀ ▀   ${NC}" 
        #
        #echo "${BLUE}«^_•»  ${NC}"
        #echo "${BLUE}▀█ █▀ ${NC}"
        #echo "${BLUE} ▀ ▀  ${NC}" 
        #
        #echo "${BLUE} ▄█.  .█▄ ${NC}"
        #echo "${BLUE} ▀█ └┘ █▀ ${NC}"
        #echo "${BLUE}   ▀  ▀   ${NC}" 
        #
        #echo "${BLUE} ▄█. .█▄ ${NC}"
        #echo "${BLUE} ▀█ U █▀ ${NC}"
        #echo "${BLUE}   ▀ ▀   ${NC}" 
        
        echo "${BLUE} ▄█. .█▄ ${NC}"
        echo "${BLUE} ▀█ - █▀   g e a r  C L I ®${NC}"
        echo "${BLUE}   ▀ ▀   ${NC}" 

        
        APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
        DOCKER_PORT=`grep 'port:' $conf_dir/gear-server.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
        echo
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
		if [ "$(id -u)" -ne 0 ]; then printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "This script must be run with sudo or as root"; fi
        printf "${BG_YELLOW}i ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "APINAME: ${APINAME}"
        printf "${BG_YELLOW}i ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "LISTENER PORT: ${DOCKER_PORT}"
        printf "${BG_YELLOW}i ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "URL: http://localhost:${DOCKER_PORT}/apis/nodes/${APINAME}"
		java_version
		ollama_version
		maven_version
		fzf_version 
		whiptail_version  
		docker_version
		external_version
		printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
        echo
	
}



function help {
	
	   echo 
       echo "${BOLD}sh gear.sh start|stop|run|status|health|env|keygen|ssl|docker*${NC}"
       echo ---
	
	   echo ${CIAN}Options:${NC} 
       echo "${BLUE}start${NC}          : Start localhost in service mode" 
       echo "${BLUE}stop${NC}           : Stop service"
       echo "${BLUE}run${NC}            : Start localhost service in interactive mode"
       echo "${BLUE}status${NC}         : View process ID"
       echo ""
       echo ${CIAN}API Options:${NC}
       echo "${BLUE}health${NC}         : Validate service status"
       echo "${BLUE}env${NC}            : Environment variables [getenv | setenv | identify]"
       echo "${BLUE}sec${NC}            : Create PEM files for the following encryption types: 3DES, Asymmetric Hash"
       echo "${BLUE}ssl${NC}            : Create SSL certificate (Keytool, MakeCert)"
       echo ""
       echo ${CIAN}Docker Options:${NC}
       echo "${BLUE}docker${NC}         : Generate Docker Image"
       echo "${BLUE}docker-start${NC}   : Docker start"
       echo "${BLUE}docker-stop${NC}    : Docker stop"
       echo "${BLUE}docker-log${NC}     : Docker logs"
       echo "${BLUE}docker-status${NC}  : Docker Status"
       echo "${BLUE}docker-inspect${NC} : Docker Image Inspect"
       echo 
       echo ${CIAN}AI Options:${NC}
       echo "${BLUE}ai${NC}             : AI console"
       echo
       echo ${CIAN}Testing Options:${NC}
       echo "${BLUE}scafold${NC}        : View Files for Project"
       echo "${BLUE}jwt${NC}            : get Token JWT"
       echo "${BLUE}apitest${NC}        : Test API call"
       echo
       echo ${CIAN}Maven Options:${NC}
       echo "${BLUE}mvn-deploy${NC}     : Deploy Artifact to Nexus"
       echo

}


function start {
	
draw_line
#echo "${BLUE}░█▀█░█▀█░█░█░█░█░█▀█${NC}"
#echo "${BLUE}░█░█░█░█░█▀█░█░█░█▀▀${NC}"
#echo "${BLUE}░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░░${NC}"
echo "${BLUE}n o h u p   g e a r   a p i${NC}"

env
if [ $ENV_FLAG -eq 0 ]; then

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
	      run_with_spinner
else
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	     printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "It is necessary to configure the environment variables marked with error"
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""

fi
return	
}


function stop {
	
draw_line
#echo "${BLUE}░█░█░▀█▀░█░░░█░░░░░░░░░▄▀▄${NC}"
#echo "${BLUE}░█▀▄░░█░░█░░░█░░░░░▄▄▄░░▀█${NC}"
#echo "${BLUE}░▀░▀░▀▀▀░▀▀▀░▀▀▀░░░░░░░▀▀░${NC}"
#echo "${BLUE}g  e  a  r  -  a p i  ${NC}"
echo "${BLUE}k i l l   g e a r${NC}"
echo

    if [ -f process.pid ]; then
	    kill -9 `cat process.pid`
	    rm -f process.pid
	else
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	    printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "process PID xxx is DOWN"
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""

    fi
    		
echo
return
}

function status {
	
draw_line
#echo "${BLUE}░█▀█░█▀▄░█▀█░█▀▀░${NC}"
#echo "${BLUE}░█▀▀░█▀▄░█░█░█░░░${NC}"
#echo "${BLUE}░▀░░░▀░▀░▀▀▀░▀▀▀░${NC}"
echo "${BLUE}p r o c   g  e  a  r  -  a p i  ${NC}"
echo 
 
	if [ -f "process.pid" ]; then
		if ps -p `cat process.pid` > /dev/null; then
           printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
           printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "process PID ${PID} is UP"
           printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
		else
          printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	      printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "process PID xxx is DOWN"
          printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
		fi
	else
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	     printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "process PID xxx is DOWN"
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	fi

echo
return
}

function run {
	
draw_line
#echo "${BLUE}░█▀▄░█░█░█▀█${NC}"
#echo "${BLUE}░█▀▄░█░█░█░█${NC}"
#echo "${BLUE}░▀░▀░▀▀▀░▀░▀${NC}"
echo "${BLUE}i n t e r a c t i v e   g  e  a  r   a p i  ${NC}"

env
if [ $ENV_FLAG -eq 0 ]; then

	java -Dgear-server=$GEAR_SERVER \
	     -Dgear-security=$GEAR_SECURITY \
	     -Dgear-service=$GEAR_SERVICE \
	     -Dgear-http=$GEAR_HTTP \
	     -Dgear-classpath= \
	     -Dgear-config=$GEAR_CONFIG \
	     -Dgear-db=$GEAR_DB \
	     -Dgear-secrets=$GEAR_SECRETS \
	     -jar ../../../target/apiseries-api.jar
	     run_with_spinner
else
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	     printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "It is necessary to configure the environment variables marked with error"
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
fi
return	
}


function health {
	
draw_line
              
echo "${BLUE}       ███${NC}"    
echo "${BLUE}      ▒███${NC}"    
echo "${BLUE}   ███████████${NC}"
echo "${BLUE}  ▒▒▒▒▒███▒▒▒${NC}" 
echo "${BLUE}      ▒███${NC}"    
echo "${BLUE}      ▒▒▒${NC}"   
echo "${BLUE} g  e  a  r  -  a p i  ${NC}"

    APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    export APINAME=$APINAME

    DOCKER_PORT=`grep 'port:' $conf_dir/gear-server.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
	response=$(curl -s http://localhost:${DOCKER_PORT}/apis/nodes/$(echo ${APINAME})/healthcheck/health)
	echo
    run_with_spinner

    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    sleep 0.5 | printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "APINAME: ${APINAME}"

    if [ "$response" = "" ]; then
         sleep 0.5 | printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "healthcheck status DOWN"
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
 	     echo
    fi 

	status=$(echo "$response" | jq -r '.status')
    if [ "$status" = "UP" ]; then
 	     sleep 0.5 | printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "healthcheck status ${status}"
         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    fi

	
echo
}

function envconf {

            draw_line 
	        #echo
	        #echo "${BLUE}${BOLD}░█▀▀░█▀▀░█▀█░█▀▄░░░░░█▀▀░█▀█░█░█${NC}"
			#echo "${BLUE}${BOLD}░█░█░█▀▀░█▀█░█▀▄░▄▄▄░█▀▀░█░█░▀▄▀${NC}"
			#echo "${BLUE}${BOLD}░▀▀▀░▀▀▀░▀░▀░▀░▀░░░░░▀▀▀░▀░▀░░▀░${NC}"
	        #echo "${BLUE}${BOLD}g  e  a  r  -  a p i ${NC}"
			#echo
	
			echo ${CIAN}ENV Options:${NC}
	        echo "${BLUE}setenv${NC}: Configure environment variables"
	        echo "${BLUE}getenv${NC}: List environment variables"
	        echo "${BLUE}identy${NC}: Automatic recognition of variables"
			echo

           OPCIONES=(
			 setenv
             getenv
             identify
           )

	        SELECCION=$(printf "%s\n" "${OPCIONES[@]}" | fzf \
	        --prompt="filter > " \
	        --header="↑↓ Browse | Type to filter | Enter to confirm | ESC to Exit" \
	        --reverse \
	        --height=40% \
	        --layout=default \
            --color=pointer:2)
	        
	        if [ $? -ne 0 ] || [ -z "$SELECCION" ]; then
		        echo -e "Exiting..."
		        
	        fi
	        
	        case "$SELECCION" in
	         "setenv") 
	         
         	         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
			         printf "${BG_MAGENTA}? ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "Allowed variables: ${ALLOWED_VARS[*]}"
			         printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
		             echo
		
		             configure_variable
	         
	         ;;
	         "getenv") 
	         
                    echo 
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "APINAME:${APINAME}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "GEAR_SERVER:${GEAR_SERVER}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "GEAR_SECURITY:${GEAR_SECURITY}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "GEAR_SERVICE:${GEAR_SERVICE}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "GEAR_CONFIG:${GEAR_CONFIG}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "GEAR_DB:${GEAR_DB}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "GEAR_SECRETS:${GEAR_SECRETS}"
		            printf "${BG_MAGENTA}env ${NC}${BG_BLUE}%-${COL_4}s${RESET}\n" "ENVIRONMENT:${ENVIRONMENT}"
		            echo
	         
	         ;;
	         "identify") 
	         
                    echo 
		            PWD=`pwd`
		            if [ -f "${conf_dir}/${ALLOWED_FILES[0]}" ]; then verify_variable "${ALLOWED_VARS[0]}" "${PWD}/${conf_dir}/${ALLOWED_FILES[0]}"; fi
		            if [ -f "${conf_dir}/${ALLOWED_FILES[1]}" ]; then verify_variable "${ALLOWED_VARS[1]}" "${PWD}/${conf_dir}/${ALLOWED_FILES[1]}"; fi
		            if [ -f "${conf_dir}/${ALLOWED_FILES[2]}" ]; then verify_variable "${ALLOWED_VARS[2]}" "${PWD}/${conf_dir}/${ALLOWED_FILES[2]}"; fi
		            if [ -f "${conf_dir}/${ALLOWED_FILES[3]}" ]; then verify_variable "${ALLOWED_VARS[3]}" "${PWD}/${conf_dir}/${ALLOWED_FILES[3]}"; fi
		            if [ -f "${conf_dir}/${ALLOWED_FILES[4]}" ]; then verify_variable "${ALLOWED_VARS[4]}" "${PWD}/${conf_dir}/${ALLOWED_FILES[4]}"; fi
		            if [ -f "${conf_dir}/${ALLOWED_FILES[5]}" ]; then verify_variable "${ALLOWED_VARS[5]}" "${PWD}/${conf_dir}/${ALLOWED_FILES[5]}"; fi
		            echo
	         
	         ;;
	        esac

return
}

function ssl {
draw_line

	if [ ! -d "$security_dir" ]; then
	     mkdir "$security_dir"
	fi 

	if [ ! -d "$security_dir/$ssl_dir" ]; then
	     mkdir "$security_dir/$ssl_dir"
	fi 


        #echo ""
        #echo "${BLUE}░█▀▀░█▀▀░█▀█░█▀▄░░░░░█▀▀░█▀▀░█░░${NC}"
		#echo "${BLUE}░█░█░█▀▀░█▀█░█▀▄░▄▄▄░▀▀█░▀▀█░█░░${NC}"
		#echo "${BLUE}░▀▀▀░▀▀▀░▀░▀░▀░▀░░░░░▀▀▀░▀▀▀░▀▀▀${NC}"
        #echo "${BLUE}g  e  a  r  -  a p i  ${NC}"
        echo "${BLUE}s s l   g  e  a  r   a p i  ${NC}"
        echo 
        echo "${BLUE}keytool${NC}: Generate a local certificate using keytool"
        echo "${BLUE}mkcert${NC}: Generate a local certificate using mkcert"
        echo "${BLUE}keystore${NC}: List of loaded certificates"


       OPTIONS=(
		 keytool
         mkcert
         keystore
       )

        SELECTION=$(printf "%s\n" "${OPTIONS[@]}" | fzf \
        --prompt="filter > " \
        --header="↑↓ Browse | Type to filter | Enter to confirm | ESC to Exit" \
        --reverse \
        --height=40% \
        --layout=default \
        --color=pointer:2)
        
        if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
	        echo -e "Exiting..."
	        
        fi


		case "$SELECTION" in

            "keytool")
                javakeytool
                ;;
            "mkcert")
                mkcert                
                ;;
            "keystore")
                keystore
                ;;
		esac


}

function hash_menu {


    draw_line

    echo
    echo "choose an encryption option"
    echo "${BLUE}SHA-256 ${NC}"
    echo "${BLUE}SHA-384${NC}"
    echo "${BLUE}SHA-512 ${NC}"
    echo "${BLUE}Return ${NC}"
    

    OPTIONS=(
	 SHA-256
     SHA-384
     SHA-512
     RETURN
   )

    SELECTION=$(printf "%s\n" "${OPTIONS[@]}" | fzf \
    --prompt="filter > " \
    --header="↑↓ Browse | Type to filter | Enter to confirm | ESC to Exit" \
    --reverse \
    --height=40% \
    --layout=default \
    --color=pointer:2)
    
    if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
        echo -e "Exiting..."
    fi

	case "$SELECTION" in

        "SHA-256")
            echo
            PAYLOAD=$(whiptail --title "Paylod for Hash Message" --inputbox "Write to Payload:" 8 40 3>&1 1>&2 2>&3)
            mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
		    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
		         HASH=`java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "HASH" "SHA-256" ${security_dir}/$keygen_dir $PAYLOAD`
                 echo "HASH=${HASH}" >> ${JWT}	         
	             printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
 			     printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "Hash successfully created. The hash will be saved for future use."
			     printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
		         
		         rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
		    fi            
        ;;
        "SHA-384")	
            echo	
            PAYLOAD=$(whiptail --title "Paylod for Hash Message" --inputbox "Write to Payload:" 8 40 3>&1 1>&2 2>&3)
			mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
		    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
		         HASH=`java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "HASH" "SHA-384" ${security_dir}/$keygen_dir $PAYLOAD`
                 echo "HASH=${HASH}" >> ${JWT}		         
		         echo "${GREEN}success $2 crypto file${NC}"
		         rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
		    fi
        ;;
        "SHA-512")
            echo
            PAYLOAD=$(whiptail --title "Paylod for Hash Message" --inputbox "Write to Payload:" 8 40 3>&1 1>&2 2>&3)
			mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
		    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
		         HASH=`java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "HASH" "SHA-512" ${security_dir}/$keygen_dir $PAYLOAD`
                 echo "HASH=${HASH}" >> ${JWT}		         
		         echo "${GREEN}success $2 crypto file${NC}"
		         rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
		    fi            
        ;;
        "RETURN")
            clean
            security
        ;;

    esac
}



function security {
draw_line

#echo "${BLUE}░█▀▀░█▀▀░█▀▀░█░█░█▀▄░▀█▀░▀█▀░█░█${NC}"
#echo "${BLUE}░▀▀█░█▀▀░█░░░█░█░█▀▄░░█░░░█░░░█░${NC}"
#echo "${BLUE}░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░░▀░░░▀░${NC}"
echo "${BLUE}s e c u r i t y   g  e  a  r   a p i  ${NC}"
echo  

printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
java_version
printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""


group_id="com.gear.keygen"
artifact_id="gear-keygen"
version="latest"  # o "RELEASE", "LATEST"

	if [ ! -d "$security_dir" ]; then
	     mkdir "$security_dir"
	fi 

	if [ ! -d "$security_dir/$keygen_dir" ]; then
	     mkdir "$security_dir/$keygen_dir"
	fi 

    echo "" 
    echo "${BLUE} 3DES ${NC}: Generate 3DES file"
    echo "${BLUE} ASYMETRIC${NC}: Generate asymmetric file pair"
    echo "${BLUE} HASH ${NC}: Generate a message hash"
    echo "${BLUE} HEX Message ${NC}: Generate HEX message"
    echo "${BLUE} HEX/3DES Message ${NC}: Generate HEX/3DES message"
    echo "${BLUE} RETURN ${NC}"
 
 
        OPTIONS=(
		 3DES
         ASYMETRIC
         HASH
         HEXtoMESS
         HEX3DEStoMESS
         RETURN
       )

        SELECTION=$(printf "%s\n" "${OPTIONS[@]}" | fzf \
        --prompt="filter > " \
        --header="↑↓ Browse | Type to filter | Enter to confirm | ESC to Exit" \
        --reverse \
        --height=40% \
        --layout=default \
        --color=pointer:2)
        
        if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
	        echo -e "Exiting..."
        fi


		case "$SELECTION" in
	
            "3DES")
                
                echo
                rm -f ${security_dir}/$keygen_dir/*_3DES_PUB.pem
				mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
			    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
			         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "3DES" ${security_dir}/$keygen_dir 256
			         echo "${GREEN}success $2 crypto file${NC}"
			         rm -f "${security_dir}/${artifact_id}-${version}.jar"
			         
			         draw_line
			         read -p "define room key Y/n " key
			         if [ "$key" = "Y" ] || [ "$key" = "y" ]; then
			              cp ${security_dir}/${keygen_dir}/*_3DES_PUB.pem "${security_dir}/${keygen_dir}/jwt.pem"
			              ecosystem
			         fi
		       fi            
            ;;

            "ASYMETRIC")
                echo
				mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
			    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
			         java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "ASIMETRIC" ${security_dir}/$keygen_dir
			         echo "${GREEN}success $2 crypto file${NC}"
			         rm -f "${security_dir}/${artifact_id}-${version}.jar"
 	            fi            
            ;;

            "HASH")
                hash_menu
            ;;
 
            "HEXtoMESS")
                read -p "Message Payload: " PAYLOAD
                echo -n "$PAYLOAD" | xxd -p
                
            ;;
 
            "HEX3DEStoMESS")
                
            ;;
            
		esac
}



function docker {

	 if [ -z "$ENVIRONMENT" ]; then
	    echo "${RED}✗ Env ENVIRONMENT no está configurada${NC}"
	    return
     fi

 	 logo_docker

     echo "${RED}Are you sure about creating a container? (Y/n)${NC}"
     read -r respuesta
     if [ "$respuesta" = "y" ] || [ "$respuesta" = "Y" ]; then

		     DOCKER_PORT=`grep 'port:' $conf_dir/gear-server.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
		     APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
		     export APINAME=$APINAME
			 
			 sed -E -i '' "s/^(ENV APINAME=).*/\1$APINAME/" dockerfile
			 sed -E -i '' "s/^(ENV APP_PORT=).*/\1\"$DOCKER_PORT\"/" dockerfile
			 sed -E -i '' "s/^(ENV ENVIRONMENT=).*/\1$ENVIRONMENT/" dockerfile
			 
		     DOCKER_INSTANCE=`sudo docker ps | grep apiseries-api-${APINAME}:latest | awk -F ' ' '{print $1}'`
		     if [ "$DOCKER_INSTANCE" != "" ]; then
		          
		          sudo docker stop $DOCKER_INSTANCE
		          if [ $? -eq 0 ]; then
		               DOCKER_IMAGE=`sudo docker images | grep apiseries-api-${APINAME} | awk -F ' ' '{print $2}' | awk '{print tolower($0)}'`
		               echo ${DOCKER_IMAGE}
		               
		               if [ "$DOCKER_IMAGE" != "" ]; then
			               sudo docker rm $DOCKER_INSTANCE 
			               sudo docker rmi $DOCKER_IMAGE
			           
			               sleep 5    
			               if [ $? -eq 0 ]; then
			               
			               	    if [ -f dockerfile ]; then
								    sudo docker build -t apiseries-api-${APINAME} .
								    
		     				        #read -p "${GREEN}✓ docker port:${NC} " port
							        sudo docker run -d --add-host="mongodb.apiseries.com:${DOCKER_MONGODB_IP}" --name apiseries-api-${APINAME} -p $DOCKER_PORT:$DOCKER_PORT apiseries-api-${APINAME}:latest
								else
								    echo "${RED}✗ Dockerfile not found${NC}"
								fi
			               fi 
			           else
			               	    if [ -f dockerfile ]; then
								    sudo docker build -t apiseries-api-${APINAME} .
		
		     				        #read -p "${GREEN}✓ docker port:${NC} " port
							        sudo docker run -d --add-host="mongodb.apiseries.com:${DOCKER_MONGODB_IP}" --name apiseries-api-${APINAME} -p $DOCKER_PORT:$DOCKER_PORT apiseries-api-${APINAME}:latest
								else
								    echo "${RED}✗ Dockerfile not found${NC}"
								fi
			           fi    
		          fi
		     
		     else
		        echo "${RED}✗ docker is not run...${NC}"
		        DOCKER_INSTANCE=`sudo docker ps -a --filter "status=exited" | grep apiseries-api-${APINAME}:latest | awk -F ' ' '{print $1}'`
		        echo "DOCKER INSTANCE: ${DOCKER_INSTANCE}"
		        if [ "$DOCKER_INSTANCE" != "" ]; then
		            sudo docker rm $DOCKER_INSTANCE 
		        fi
		        
		        WARNING="WARNING: This output is designed for human readability. For machine-readable output, please use --format."
		        DOCKER_IMAGE=`sudo docker images | grep apiseries-api-${APINAME} | awk -F ' ' '{print $2}' | awk '{print tolower($0)}'`
		        echo ${DOCKER_IMAGE}
		        
		        if [[ "${DOCKER_IMAGE}" != "" ]] && [[ "${DOCKER_IMAGE}" != "${WARNING}" ]]; then
		               echo "si existo"
		               
		               sudo docker rmi $DOCKER_IMAGE 
		               sleep 5    
		               if [ $? -eq 0 ]; then
		               
		               	    if [ -f dockerfile ]; then
							    sudo docker build -t apiseries-api-${APINAME} .
		  				        
		     				        #read -p "${GREEN}✓ docker port:${NC} " port
							        sudo docker run -d --add-host="mongodb.apiseries.com:${DOCKER_MONGODB_IP}" --name apiseries-api-${APINAME} -p $DOCKER_PORT:$DOCKER_PORT apiseries-api-${APINAME}:latest
							else
							    echo "${RED}✗ Dockerfile not found${NC}"
							fi
		               fi 
		         else
		         echo "no existo y creo docker"
	               	    if [ -f dockerfile ]; then
  	               	        echo "dockerfile OK"
						    sudo docker build -t apiseries-api-${APINAME} .
					        sudo docker run -d --add-host="mongodb.apiseries.com:${DOCKER_MONGODB_IP}" --name apiseries-api-${APINAME} -p $DOCKER_PORT:$DOCKER_PORT apiseries-api-${APINAME}:latest
						else
						    echo "${RED}✗ Dockerfile not found${NC}"
						fi
 		         fi
		   fi
     fi


}

function docker_log {
	
	draw_line
    APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    export APINAME=$APINAME

    sudo docker logs -f apiseries-api-${APINAME}
    
return    
}



function docker_status {
	
	logo_docker
    APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
	ID=`sudo docker ps | grep apiseries-api-${APINAME}:latest | awk -F ' ' '{print $1}'`
    
    if [ "$ID" == "" ];then

        ID=`sudo docker ps -a --filter "status=exited" | grep apiseries-api-${APINAME}:latest | awk -F ' ' '{print $1}'`
		NAME=`sudo docker ps -a --filter "status=exited" | grep apiseries-api-${APINAME}:latest | awk -F ' ' '{print $2}'`
	    
	    if [ "$ID" = "" ];then 
	         ID="xxxxxxxxxx ";
	    fi

	    if [ "$NAME" = "" ];then 
	         NAME="docker is ";
	    fi

        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
        printf "${BG_RED}✗ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "${ID} ${NAME} DOWN"
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""

    else
		NAME=`sudo docker ps | grep apiseries-api-${APINAME}:latest | awk -F ' ' '{print $2}'`
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
        printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "${ID} ${NAME} UP"
        printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    fi


echo
echo 
return       
}

function docker_inspect {
	
	logo_docker

    APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    export APINAME=$APINAME

    sudo docker image inspect apiseries-api-${APINAME}:latest | fzf

echo        
return
}

function docker_start {
	
	logo_docker

    DOCKER_PORT=`grep 'port:' $conf_dir/gear-server.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    export APINAME=$APINAME

    DOCKER_NAME=`sudo docker start apiseries-api-${APINAME}`
    run_with_spinner
    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "${DOCKER_NAME} start"
    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""

echo   
return     
}

function docker_stop {
	
	logo_docker

    DOCKER_PORT=`grep 'port:' $conf_dir/gear-server.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    APINAME=`grep 'name:' $conf_dir/gear-security.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
    export APINAME=$APINAME

    DOCKER_NAME=`sudo docker stop apiseries-api-${APINAME}`
    run_with_spinner
    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    printf "${BG_RED}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "${DOCKER_NAME} stop"
    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""

echo  
return      
}


function docker_ifconfig {

    LIST=`sudo docker ps | tail -n +2 | awk -F ' ' 'BEGIN{OFS="_"}{print $1, $2}'`
    DOCKERS=($LIST) 
    
	echo ${CIAN}Dockers List:${NC}
	for item in "${DOCKERS[@]}"; do
       echo "${BLUE}$item${NC}"
    done
	echo

    SELECTION=$(printf "%s\n" "${DOCKERS[@]}" | fzf \
    --prompt="filter > " \
    --header="↑↓ Browse | Type to filter | Enter to confirm | Ctrl+C cancel" \
    --reverse \
    --height=40% \
    --layout=default \
    --color=pointer:2)
    
    if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
        echo -e "Exiting..."
        exit 0
    fi

    DOCKER_ID=`echo ${SELECTION} | awk -F '_' '{print $1}'`
    IP=`sudo docker exec ${DOCKER_ID} hostname -i`
    
    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    printf "${BG_GREEN}✓ ${NC}${BG_BLUE}${BOLD}%-${COL}s${RESET}\n" "${SELECTION} : ${IP}"
    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
    
}

function ai {
draw_line	
echo "${BLUE}a i   c o n s o l e${NC}"
echo

claude_app=false
kimi_app=false
qwen_app=false
IAS=()
   
    if ! command -v claude &> /dev/null; then IAS+=(claude); fi
    if ! command -v kimi &> /dev/null; then IAS+=(kimi); fi
    if ! command -v qwen &> /dev/null; then IAS+=(qwen); fi

    MODELS=(haiku sonet opus)
    #LIST=`curl -s https://ollama.com/library | grep '/library/' | awk -F ' ' '{print $2}' | sed 's/href="\/library//g'| sed 's/^.//;s/.$//'`
    #MODELS=($LIST) 
    
	echo ${CIAN}ENV Options:${NC}
	for item in "${MODELS[@]}"; do
       echo "${BLUE}$item${NC}: $item model"
    done
	echo

    SELECTION=$(printf "%s\n" "${MODELS[@]}" | fzf \
    --prompt="filter > " \
    --header="↑↓ Browse | Type to filter | Enter to confirm | Ctrl+C cancel" \
    --reverse \
    --height=40% \
    --layout=default \
    --color=pointer:2)
    
    if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
        echo -e "Exiting..."
        exit 0
    fi
    
    ai_console ${SELECTION}
 
echo
}

function ai_console {

  draw_line 
  sudo claude --model $1

}

function ai_skill {


draw_line	
echo "${BLUE}a i   c o n s o l e   s k i l l   c r e a t o r${NC}"
echo


# Ruta objetivo
SKILLS=()

	for archivo in .claude/skills/*; do
	    SKILLS+=( "$(basename "$archivo")" )
	done

    SELECTION=$(printf "%s\n" "${SKILLS[@]}" | fzf \
    --prompt="filter > " \
    --header="↑↓ Browse | Type to filter | Enter to confirm | ESC to Exit" \
    --reverse \
    --height=40% \
    --layout=default \
    --color=pointer:2)
    
    if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
        echo -e "Exiting..."
        
    fi

    vim .claude/skills/${SELECTION}/SKILL.md

	
}

function ai_agent {


draw_line	
echo "${BLUE}a i   c o n s o l e   s k i l l   c r e a t o r${NC}"
echo


# Ruta objetivo
SKILLS=()

	for archivo in .claude/agents/*; do
	    SKILLS+=( "$(basename "$archivo")" )
	done

    SELECTION=$(printf "%s\n" "${SKILLS[@]}" | fzf \
    --prompt="filter > " \
    --header="↑↓ Browse | Type to filter | Enter to confirm | ESC to Exit" \
    --reverse \
    --height=40% \
    --layout=default \
    --color=pointer:2)
    
    if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
        echo -e "Exiting..."
        
    fi

    vim .claude/skills/${SELECTION}/SKILL.md

	
}

function jwt {
 
group_id="com.gear.keygen"
artifact_id="gear-keygen"
version="latest"  # o "RELEASE", "LATEST"
  
_PORT=8000

	PAYLOAD=`echo '{"username":"gearcli","userid":"12345678","roles":["admin"]}' | jq -c '.'`
    mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
          HASH=`java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "jwt" "SHA-512" ${security_dir}/$keygen_dir ${PAYLOAD}`
          rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
    fi            
	
    echo ${HASH}	
	
	RESPONSE=`curl -s --request POST \
	  --url http://localhost:"${_PORT}"/apis/nodes/token \
	  --header 'Accept: application/json' \
	  --header "Content-Gear-Hash: ${HASH}" \
	  --header 'Content-Type: application/json' \
	  --data ${PAYLOAD}`
	  
	  
	echo ${RESPONSE}  
	run_with_spinner  
  
	HTTP_STATUS=$(echo "$RESPONSE" | jq -r '.status')
	if [ "$HTTP_STATUS" -eq 200 ]; then
	    TOKEN=$(echo "$RESPONSE" | jq -r '.accessToken')
	    REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refreshToken')
	
	    printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "TOKEN: ${TOKEN}"
	    printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "REFRESH TOKEN: ${REFRESH_TOKEN}"
	    
	    rm -f ${JWT}
	    echo "TOKEN=${TOKEN}" > ${JWT}
	    echo "REFRESH_TOKEN=${REFRESH_TOKEN}" >> ${JWT}
	    printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "token saved for your session"
	    
	else
	    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	    printf "${BG_RED}✗ ${NC}${BG_BLUE}%-${COL}s${RESET}\n" "Error in request: $HTTP_STATUS"
	    printf "${BG_BLUE}${BOLD}%-${TCOL}s${RESET}\n" ""
	
	    echo "Error en la petición: $HTTP_STATUS"
	fi 
 
  
echo
}

function apitest {

group_id="com.gear.keygen"
artifact_id="gear-keygen"
version="latest"  # o "RELEASE", "LATEST"

source ${JWT}

	PAYLOAD=""
	echo "payload: ${PAYLOAD}"
    mvn dependency:copy -Dartifact=${group_id}:${artifact_id}:${version}:jar -DoutputDirectory=${security_dir}/${keygen_dir}
    if [[ -n "$security_path/$keygen/${artifact_id}-${version}.jar" ]]; then
          HASH=`java -Djava.security.manager=allow -Djava.security.properties=/dev/null -jar "$security_dir/$keygen_dir/${artifact_id}-${version}.jar" "jwt" "SHA-512" ${security_dir}/$keygen_dir ""`
          rm -f "${security_dir}/$keygen_dir/${artifact_id}-${version}.jar"
    fi            

	DOCKER_PORT=`grep 'port:' $conf_dir/gear-server.yml | tail -n 1 | awk -F ':' '{print $2}' | xargs`
	RESPONSE=`curl -s --request GET \
	  --url "http://localhost:${DOCKER_PORT}/apis/nodes/channel-credentials" \
	  --header 'Accept: application/json' \
	  --header "Content-Gear-Hash: 18020403ff37763e9a8006e053c3f068444a45c3b664bf2a05bda287eeaf91281dcd904a35911e6cf6a838b7b2f77d38d9d9f75c230dba3e5c0f79a3f7b333b5" \
	  --header "Authorization: ${TOKEN}" \
	  --header 'Content-Type: application/json'`
      
      echo "${RESPONSE}" | jq -r '.' | pbcopy
      
      draw_line
      echo ${RESPONSE} | jq -r '.' | fzf \
      --prompt="filter > " \
	  --reverse \
      --height=40% \
      --layout=default \
      --border=rounded \
      --color=pointer:2
      
printf "${BG_GREEN}✓ ${NC}%-${COL}s${RESET}\n" "The answer has been copied to the clipboard."
}


function mvn_deploy {

   mvn clean deploy

}

function mvn_compile {

   mvn clean compile

}

function mvn_package {

   mvn clean package

}

#
#
# localhost Options --------------------------------------------------------------------------------------
#
function init {

#export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --margin=1 --padding=1 --info=inline --prompt='❯ ' --pointer='→' --marker='♡' --color='header:italic' --header='↑↓ Browse | Type to filter | Enter to confirm | Esc to Exit'"
main        
        while true; do

           OPCIONES=(
             refresh
			 start
             stop
             run
             status
             health
             env
             security
             ssl
             docker
             docker-start
             docker-stop
             docker-log
             docker-status
             docker-inspect
             docker-ifconfig
             ai
             ai-subagent
             ai-skill
             scafold
             jwt
             apitest
             mvn-deploy
             mvn-compile
             mvn-package
             help
           )

	        SELECTION=$(printf "%s\n" "${OPCIONES[@]}" | fzf \
	        --prompt="filter > " \
	        --header="↑↓ Browse | Type to filter | Enter to confirm | Ctrl+C cancel" \
	        --reverse \
	        --height=40% \
	        --layout=default \
	        --color=pointer:2)
	        
	        if [ $? -ne 0 ] || [ -z "$SELECTION" ]; then
		        echo -e "Exiting..."
		        exit 0
	        fi
	        
	        case "$SELECTION" in
	         "start") start;;
	         "stop") stop;;
	         "run") run;;
	         "status") status;;
	         "health") health;;
	         "env") envconf;;
	         "security") security;;
	         "ssl") ssl;;
	         "docker") docker;;
	         "docker-start") docker_start;;
	         "docker-stop") docker_stop;;
	         "docker-log") docker_log;;
	         "docker-status") docker_status;;
	         "docker-inspect") docker_inspect;;
	         "docker-ifconfig") docker_ifconfig;;
	         "ai") ai;;
	         "ai-skill") ai_skill;;
	         "help") help;;
	         "scafold") navigate_directories;;
	         "jwt") jwt;;
	         "apitest") apitest;;
	         "mvn-deploy") mvn_deploy;;
	         "mvn-compile") mvn_compile;;
	         "mvn-package") mvn_package;;
	         "refresh") init;;
	        esac
	        
	        read -rsn1 -p "Press any key to continue..."
	        main
	        echo
        done

}


#
# localhost execution options
# options: start | stop | status | run  
# 
# start: Start localhost in service mode
# stop: Stop service
# status: Start localhost service in interactive mode
# run: View process ID
#
#

if [ "$1" == "start" ]; then start; fi
if [ "$1" == "stop" ]; then stop; fi
if [ "$1" == "status" ]; then status; fi
if [ "$1" == "run" ]; then run; fi

#
#
# API Options --------------------------------------------------------------------------------------
#
#
#
# Functions execution options
# options: health | env | keygen | ssl  
# 
# health: Validate service status
# env: Environment variables [getenv | setenv | identify]
# keygen: Create PEM files for the following encryption types: 3DES, Asymmetric Hash
# ssl: Create SSL certificate (Keytool, MakeCert)
#
#

if [ "$1" == "health" ]; then health; fi
if [ "$1" == "env" ]; then envconf; fi
if [ "$1" == "sec" ]; then security;fi
if [ "$1" == "ssl" ]; then ssl; fi
if [ "$1" == "docker" ]; then docker; fi
if [ "$1" == "docker-log" ]; then docker_log; fi
if [ "$1" == "docker-status" ]; then docker_status; fi
if [ "$1" == "docker-inspect" ]; then docker_inspect; fi
if [ "$1" == "docker-start" ]; then docker_start; fi
if [ "$1" == "docker-stop" ]; then docker_stop; fi
if [ "$1" == "ai" ]; then ai; fi
if [ "$1" == "" ]; then init; fi


