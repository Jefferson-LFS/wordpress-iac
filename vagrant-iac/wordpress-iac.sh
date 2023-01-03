#! /bin/bash

    echo "Atualizando o sistema"
    sudo apt-get update -y && sudo apt upgrade -y 
    
    echo "Instalando servidor Nginx"
    sudo apt install unzip nginx -y    
    nginx -v 
    sudo chown www-data:www-data /usr/share/nginx/html -R

    echo "Baixando e instalando o banco de dados mariadb e dependencias do PHP 7.4"
    sudo apt install mariadb-server mariadb-client -y
    sudo apt install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common \
     php7.4-json php7.4-opcache php7.4-readline php7.4-mbstring php7.4-xml php7.4-gd php7.4-curl -y 

    echo "Configurações inicias do servidor Nginx"
    sudo rm /etc/nginx/sites-enabled/default
    sudo systemctl reload nginx

    echo "Baixando arquivos do WordPress para diretorio do servidor" 
    sudo wget -P /tmp https://wordpress.org/latest.zip 
    sudo mkdir -p /usr/share/nginx
    sudo unzip /tmp/latest.zip -d /usr/share/nginx/
    sudo mv /usr/share/nginx/wordpress /usr/share/nginx/myblog.com

    echo "Criando banco de dados do WordPress e atribuindo permissão de acesso" 
    sudo mariadb -e "create database wordpress;"
    sudo mariadb -e "grant all privileges on wordpress.* to userblog@localhost identified by '12345678';"
    sudo mariadb -e "flush privileges;"

    echo "Ajustando o arquivo wp-config.php" 
    cd /usr/share/nginx/myblog.com/
    sudo mv wp-config-sample.php wp-config-sample.php.bkp
    sudo cp wp-config-sample.php.bkp wp-config.php
    sudo sed -Ei 's,database_name_here,wordpress,' wp-config.php
    sudo sed -Ei 's,username_here,userblog,' wp-config.php
    sudo sed -Ei 's,password_here,12345678,' wp-config.php

    
    echo "Configurando servidor para o site do WordPress"
    cd /etc/nginx/conf.d/
    sudo cp /vagrant/provision/myblog.com.conf /etc/nginx/conf.d/
    # wget https://gist.githubusercontent.com/Jefferson-LFS/49e303ecf24f1aa0c6d8eb2b58eae152/raw/0e827660d32767161c395f69a58ffc6d634daa84/diegojefferson.com.conf     
    sudo systemctl reload nginx

    server_ip=$(hostname -I | cut -d " " -f 2)
    echo "Acesse termine de configurar pelo navegador de Internet o WordPress http://$server_ip/wp-admin"