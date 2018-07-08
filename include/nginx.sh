#!/bin/bash

Install_Nginx()
{
    Echo_Blue "[+] Installing ${Nginx_Ver}... "
    groupadd www
    useradd -s /sbin/nologin -g www www

    Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module
    make && make install
    cd ../

    ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx

    rm -f /usr/local/nginx/conf/nginx.conf
    cd ${cur_dir}
    \cp conf/nginx_a.conf /usr/local/nginx/conf/nginx.conf
    \cp conf/proxy.conf /usr/local/nginx/conf/proxy.conf
    \cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
    \cp conf/proxy-pass-php.conf /usr/local/nginx/conf/proxy-pass-php.conf
    \cp conf/enable-ssl-example.conf /usr/local/nginx/conf/enable-ssl-example.conf

    mkdir -p ${Default_Website_Dir}
    chmod +w ${Default_Website_Dir}
    mkdir -p /home/wwwlogs
    chmod 777 /home/wwwlogs

    chown -R www:www ${Default_Website_Dir}

    mkdir /usr/local/nginx/conf/vhost
    \cp conf/crysadm.conf /usr/local/nginx/conf/vhost/crysadm.conf

    if [ "${Default_Website_Dir}" != "/home/wwwroot/default" ]; then
        sed -i "s#/home/wwwroot/default#${Default_Website_Dir}#g" /usr/local/nginx/conf/nginx.conf
    fi

    \cp init.d/init.d.nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    
    echo "Run nginx Set Nginx on service"	
		StartUp nginx
		/etc/init.d/nginx start



}
