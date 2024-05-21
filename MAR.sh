#!/bin/bash

IP="$1"

if [[ "$1" == '-h' ]] || [[ -z "$1"  ]]; then 
	echo Usage ---\> ./script.sh [ip]
	exit 0
fi

ipFormatChecker () {
	regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
	if ! [[ "$IP" =~ $regex ]]; then
    		echo "$1" " no tiene formato de dirección IP"
		exit 1
	fi
}
connectionChecker (){
	lostPaquet=$(echo $pingResul | tail -2 | head -n 1 | awk '{print $6}' FS=' ' | sed 's/%//')

	if [[ $lostPaquet -eq 0 ]]; then
		echo -e '\e[32m[+] Tiene conexion con esta maquina.\e[0m'
	elif [[ $lostPaquet -gt 0 ]] && [[ $lostPaquet -lt 100 ]]; then
		echo -e '\e[33m[!] Tiene conexion con la maquina pero se an perdido algunos paquetes.\e[0m'
	else
		echo -e '\e[31m[-] No tiene conexion con la maquina.\e[0m'
		exit 1
	fi
}

ttlChecker (){
	ttl=$(echo $pingResul | grep ttl | awk '{print $6}' FS=' ' | sed 's/ttl=//')
	if [[ $ttl -le 64 ]]; then
		echo -e '[+] El sistema operativo de la maquina es \e[32mLinux\e[0m'
	else
		echo -e '[+] El sistema operativo de la maquina es \e[34mWindows\e[0m'
	fi
}

header (){
    clear
    echo "            ████╗   ████╗     ████╗     ██████╗ "
    echo "            ██║██╗ ██║██║    ██║ ██╗    ██╔══██╗"
    echo "            ██║ ████║ ██║   ████████╗   ██████╔╝"
    echo "            ██║  ██║  ██║   ██║   ██║   ██╔══██╗"
    echo "            ██║       ██║██║██║   ██║██║██║  ██║"
    echo " -------------------------------------------------------------"
    echo "        Bienvenido a MachineAutoRecon - Versión 1.0          "
    echo " -------------------------------------------------------------"
    echo "                   Menú Principal                             "
    echo " -------------------------------------------------------------"
    echo ""
}

menu (){
	echo
	echo 'Opciones:'
	echo
	echo '1) Lanzar un escaneo de puertos'
	echo '2) Lanzar un escaneo de servicios'
	echo '3) Lanzar escaneo completo'
	echo '4) Lanzar un escaneo de herramientas de desarrollo'
	echo 'e) Salir'
	echo
	read -p 'Que escaneo desea realizar? ' OPCION

	case "$OPCION" in
        	1) portScan;;
        	2) serviceScan;;
        	3) completeScan;;
		4) whatWeb;;
		e) close;;
	esac
}

headerMenu (){
	clear
	header
	connectionChecker
	ttlChecker
	menu
}

portScan (){
	PORTS=$(sudo nmap -sS --open -p- --min-rate 5000 -vvv -n -Pn "$IP" | grep open | grep -v Discovered | awk '{print $1}' FS="/" | tr '\n' ',' | sed 's/,$//')
	echo "==============================================="
        echo "Escaneo de puertos"
        echo "==============================================="
	echo
	echo "[+] Los puertos que se han encontrado abiertos son los siguientes: $PORTS"
	echo "$PORTS" | xclip -selection clipboard
	echo
        echo "[+] Los puertos se te guardado en la clipboard"
	echo
	read -p "Desea guardarlo en el archivo portScan? s(si)/cualquier otra tecla(no): " -n 1 SAVEPORTSCAN
	if [ "$SAVEPORTSCAN" == "s" || "$SAVEPORTSCAN" == "S" ]; then
		$PORTS > portScan
	fi
}

serviceScan (){
	read -p "Introduce los puertos de los cuales quieres hacer el escaneo de servicios (por defecto se hara a todos): " PORTS
	echo "==============================================="
	echo "Escaneo de servicios"
	echo "==============================================="
	echo
	if [[ ! -z "$PORTS" ]]; then
		sudo nmap -p"$PORTS" -sCV "$IP" -vvv
	else
		sudo nmap -p- -sCV "$IP" -vvv
	fi
	echo
        read -p "Desea guardarlo en el archivo serviceScan? s(si)/cualquier otra tecla(no): " -n 1 SAVESERVICESCAN
        if [ "$SAVESERVICESCAN" == "s" || "$SAVESERVICESCAN" == "S" ]; then
                $PORTS > serviceScan
        fi
}

completeScan (){
	echo "==============================================="
        echo "Escaneo completo"
        echo "==============================================="
        echo
	echo "-------Escaneando puertos-------"
	echo
	PORTS=$(sudo nmap -sS --open -p- --min-rate 5000 -vvv -n -Pn "$IP" | grep open | grep -v Discovered | awk '{print $1}' FS="/" | tr '\n' ',' | sed 's/,$//')
	echo "[+] Los puertos que se han encontrado abiertos son los siguientes: $PORTS"
	echo
	echo "-------Escaneando servicios-------"
	echo
	sudo nmap -p"$PORTS" -sCV "$IP" -vvv
        read -p "Desea guardarlo en el archivo serviceScan? s(si)/cualquier otra tecla(no): " -n 1 SAVESERVICESCAN
	if [ "$SAVESERVICESCAN" == "s" || "$SAVESERVICESCAN" == "S" ]; then
                $PORTS > serviceScan
        fi
}

whatWeb (){
	PORTS=$(sudo nmap -sS --open -p- --min-rate 5000 -vvv -n -Pn "$IP" | grep open | grep -v Discovered | awk '{print $1}' FS="/" | tr '\n' ',' | sed 's/,$//')
	if echo "$PORTS" | grep -q '\b80\b'; then
		whatweb "$IP"
	else
    		echo ""
	fi
	echo
  	read -p "Pulse cualquier tecla para continuar" -n 1
}

close (){
	exit 0
}

ipFormatChecker "$1"
pingResul=$(ping -c 1 "$1")
header
connectionChecker
ttlChecker

while true; do
	headerMenu
done
