#!/bin/bash

install_debian() {
    echo "Instalando requisitos en sistemas basados en Debian..."
    sudo apt update
    sudo apt install -y nmap whatweb xclip
}

install_redhat() {
    echo "Instalando requisitos en sistemas basados en Red Hat..."
    sudo yum install -y nmap whatweb xclip
}

if [ -x "$(command -v apt)" ]; then
    install_debian
elif [ -x "$(command -v yum)" ]; then
    install_redhat
else
    echo "No se pudo detectar el gestor de paquetes compatible. Por favor, instala Nmap, WhatWeb y Xclip manualmente."
    exit 1
fi

if [ -x "$(command -v nmap)" ] && [ -x "$(command -v whatweb)" ]; then
    echo "Los requisitos se instalaron correctamente."
else
    echo "¡Hubo un problema durante la instalación de los requisitos!"
fi
