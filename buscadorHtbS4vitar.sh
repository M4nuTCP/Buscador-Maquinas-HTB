#!/bin/bash

function ctrl_c(){
        echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
        tput cnorm && exit 1

}

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#ctrl+c
trap ctrl_c INT

#Variables locales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Panel de Ayuda${endColour}\n"
        echo -e "\t${purpleColour}u)${endColour} Actualizar Archivos"
        echo -e "\t${purpleColour}m)${endColour} Buscar Máquina | -m <Name>"
        echo -e "\t${purpleColour}i)${endColour} Buscar por dirección IP | -i <Ip>"
        echo -e "\t${purpleColour}d)${endColour} Buscar por dificultas | -d <Dificultad>"
        echo -e "\t${purpleColour}o)${endColour} Buscar por sistema operativo | -o <OS>"
        echo -e "\t${purpleColour}s)${endColour} Buscar por Skills | -i <Skills>"
        echo -e "\t${purpleColour}y)${endColour} Obtener link de la reslución de la máquina | -y <Name>"
        echo -e "\t${purpleColour}h)${endColour} Mostrar panel de ayuda"
}

function searchMachine(){
        machineName="$1"
 
        machineName_check="$(cat bundle.js| awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d  ',' | sed 's/^ *//')"

        if [ "$machineName_check" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina $machineName${endColour}\n"

        cat bundle.js| awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d  ',' | sed 's/^ *//'
        else
                echo -e "${redColour}\n[!] La máquina $machineName no existe${endColour}"
        fi
}

function searchIP(){
        ipAddress="$1"

        machineName="$(cat bundle.js| grep "ip: \"$ipAddress\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

        if [ "$machineName" ]; then

                echo -e "\n${purpleColour}[+]${endColour}${grayColour} La Máquina correspondiente para la IP${endColour}${blueColour} $ipAddress ${endColour}${grayColour}es${endColour}${blueColour} $machineName ${endColour}"

                searchMachine $machineName
        else
                echo -e "\n${redColour}[!] La dirección IP $ipAddress no existe${endColour}"
        fi
}


function searchLink(){
        machineName="$1"

        linkYT="$(cat bundle.js| awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d  ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

        if [ "$linkYT" ]; then
                echo -e "\n${yellowColour}[+]${endColour}${grayColour} EL link de YT es:${endColour}${blueColour} $linkYT ${endColour}"
        else
                echo -e "${redColour}\n[!] La máquina $machineName no existe${endColour}"
        fi
}

function searchDificultad(){
        dificul="$1"

        dificultad="$(cat bundle.js | grep "dificultad: \"$dificul\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

        if [ "$dificultad" ]; then
                echo -e "\n${yellowColour}[+]${endColour}${grayColour} La Máquinas dificultad${endColour} ${blueColour}$dificul${endColour}${grayColour}:${endColour}"
                echo -e "\n$dificultad"
        else
                echo -e "${redColour}\n[!] La dificultad $dificul no existe (Fácil|Media|Difícil|Insane)${endColour}"
        fi

}

function searchOS(){
        os="$1"

        os_Check="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: "  | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

        if [ "$os_Check" ]; then
                echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con sistema operativo ${endColour}${blueColour}$os${endColour}${grayColour}:${endColour}"
                echo -e "\n$os_Check"
        else
                echo -e "${redColour}\n[!] El sistema operativo $os no existe (Linux|Windows)${endColour}"
        fi
}

function searchSkills(){
        skills="$1"

        check="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

        if [ "$check" ]; then
                echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con la Skill ${endColour}${blueColour}$skills${endColour}${grayColour}:${endColour}\n"
                echo -e "$check"
        else
                echo -e "${redColour}\n[!] La Skill $skills no existe (SQLI , XSS , Active Directory , etc)${endColour}"
        fi
}


function updateFiles(){ tput civis
if [ ! -f bundle.js ]; then
        tput civis
        echo -e "\n${redColour}[!]${endColour} Descargando Archivos..."
        curl -s -X GET $main_url | js-beautify > bundle.js
        echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Archivo actualizado${endColour}"
        tput cnorm
else
        curl -s -X GET $main_url | js-beautify > bundle_temp.js
        md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_original_value=$(md5sum bundle.js | awk '{print $1}')
        echo -e "\n${redColour}[!]${endColour} Comprobando si hay actualizaciones"
        if [ "$md5_temp_value" == "$md5_original_value" ]; then
                echo -e "\n${purpleColour}[+]${endColour}${grayColour} Archivos Actualizados${endColour}"
                rm bundle_temp.js
        else
                cat bundle_temp.js > bundle.js
                echo -e "\n${purpleColour}[+]${endColour}${grayColour} Archivos Actualizados${endColour}"
                rm bundle_temp.js
        fi

fi
tput cnorm
}

function searchDificultadOs(){
        dificultad="$1"
        os="$2"
        check="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

        if [ "$check" ]; then 
                echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con sistema operativo ${endColour}${blueColour}$os${endColour}${grayColour} y dificultad ${endColour}${blueColour}$dificultad${endColour}${grayColour}:${endColour}\n"
                echo -e "$check"
        else
                echo -e "${redColour}\n[!] El sistema operativo $os no existe (Linux|Windows) o la dificultad $dificultad no existe (Fácil|Media|Difícil|Insane)${endColour}"
        fi
}



# Indicadores 

declare -i parameter_counter=0

# Chivatos

declare -i chivato_dificultad=0;
declare -i chivato_os=0;

while getopts "m:ui:y:d:o:i:s:h" arg; do
        case $arg in 
         m) machineName=$OPTARG; let parameter_counter+=1;;
         u) let parameter_counter+=2;;
         i) ipAddress=$OPTARG; let parameter_counter+=3;;
         y) machineName=$OPTARG; let parameter_counter+=4;;
         d) dificul=$OPTARG; chivato_dificultad=1; let parameter_counter+=5;;
         o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
         s) skills=$OPTARG; let parameter_counter+=7;;
         h) ;;
        esac
done 

#Redireccion a los usuarios al panel de ayuda cuando se equivocan 

if [ $parameter_counter -eq 1 ]; then 
   searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
   updateFiles
elif [ $parameter_counter -eq 3 ]; then
   searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
   searchLink $machineName
elif [ $parameter_counter -eq 5 ]; then
   searchDificultad $dificul
elif [ $parameter_counter -eq 6 ]; then
   searchOS $os
elif [ $chivato_dificultad -eq 1 ] && [ $chivato_os -eq 1 ]; then
   searchDificultadOs $dificul $os
elif [ $parameter_counter -eq 7 ]; then
   searchSkills "$skills"
else
   helpPanel
fi
   