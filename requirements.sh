#!/bin/bash


install_debian() {
    echo "Instalando Nmap y WhatWeb en sistemas basados en Debian..."
    sudo apt update
    sudo apt install -y nmap whatweb
}

install_redhat() {
    echo "Instalando Nmap y WhatWeb en sistemas basados en Red Hat..."
    sudo yum install -y nmap whatweb
}

if [ -x "$(command -v apt)" ]; then
    install_debian
elif [ -x "$(command -v yum)" ]; then
    install_redhat
else
    echo "No se pudo detectar el gestor de paquetes compatible. Por favor, instala Nmap y WhatWeb manualmente."
    exit 1
fi

if [ -x "$(command -v nmap)" ] && [ -x "$(command -v whatweb)" ]; then
    echo "Nmap y WhatWeb se instalaron correctamente."
else
    echo "¡Hubo un problema durante la instalación de Nmap y/o WhatWeb!"
fi
