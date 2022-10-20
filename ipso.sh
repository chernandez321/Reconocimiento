#!/bin/bash

#Herramienta para ver en una subred dada las pc que estan activas y su sistema operativo 

################Funciones###############

  ####### 1 Panel de Ayuda ##########

function helpPanel(){
        for i in $(seq 1 80); do echo -n "-"; done;
        echo -e "\n Para usar esta herramienta ejecute  el comando ./ipso y el parametro deseado"
        for i in $(seq 1 80); do echo -n "-"; done;
        echo -e "\n\n   [-p] <ip de la pc a revisar> Ejemplo ./ipso -p 10.0.0.1";
	echo -e "\n   [-s] <Subred a revisar>      Ejemplo ./ipso -s 10.0.0.0/24"; 
        echo -e "\n   [-h] { Panel de ayuda } \n"; 

        exit 1
}

 ######  2 Analizar subred ###### 

function analizarSubred(){

echo 'Ip de la subred  -------------- Sistema Operativo  ------------- Nombre de Dominio'

#fping -g $subred 2>/dev/null | grep "alive" | awk '{print $1}' > ip_activos.txt
nmap -PEMP -sP -n $subred | grep -vE 'Host|Starting|done' | awk '{print $5}' > ip_activos.tmp
while IFS= read -r line
do
ttl=$(ping -c 1 $line 2> /dev/null | grep ttl | awk '{print $6}' | tr 'ttl=' ' ')
domain_name=$(nslookup $line | head -n 1 | awk '{print $4}')

#Codigo para determinar el sistema operativo
        if (( $ttl >= 50 && $ttl <= 70 )); then
           so=Linux;
     elif (( $ttl >= 120 && $ttl <= 140 )); then
 	   so=Windows;
      elif (( $ttl >= 240 && $ttl <= 260 )); then
             so=Solaris;
      else so=Desconocido;
	fi
echo       $line        '      --------------    ' $so  '       ------------- '$domain_name
done < ip_activos.tmp

rm ip_activos.tmp
}

   ######   3   Analizar PC Individual     ####### 

function analizarPc(){

echo 'Ip de la subred  -------------- Sistema Operativo  ------------- Nombre de Dominio'

ttl=$(ping -c 1 $pc 2> /dev/null | grep ttl | awk '{print $6}' | tr 'ttl=' ' ')
domain_name=$(nslookup $pc | head -n 1 | awk '{print $4}')

        if (( $ttl >= 50 && $ttl <= 70 )); then
             so=Linux;
     elif (( $ttl >= 120 && $ttl <= 140 )); then
             so=Windows;
     elif (( $ttl >= 240 && $ttl <= 260 )); then
             so=Solaris;
     elif [ -z $ttl ]; then 
             so=Ninguno;
     else    so=Desconocido;
       fi

echo       $pc        '      --------------    ' $so  '       ------------- '$domain_name
}

##### Para controlar el flujo del programa #####

contador=0; while getopts "p:s:h:" arg; do 
        case $arg in 
		p)pc=$OPTARG;    let contador+=2;;
                s)subred=$OPTARG;let contador+=1;;
                h)helpPanel;  
        esac
done

       if [ $contador -eq 0 ]; then
           helpPanel
else
       if [ $contador -eq 1 ]; then
           analizarSubred
else
       if [ $contador -eq 2 ]; then
	   analizarPc
       fi
     fi
   fi

