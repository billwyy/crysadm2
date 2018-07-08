Install_Redis()
{
    echo "====== Installing Redis ======"
    echo "Install ${Redis_Stable_Ver} Stable Version..."

    cd ${cur_dir}/src
    Download_Files http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}.tar.gz
    Tar_Cd ${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}

    if [ "${Is_64bit}" = "y" ] ; then
        make PREFIX=/usr/local/redis install
    else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
    fi
    mkdir -p /usr/local/redis/etc/
    \cp redis.conf  /usr/local/redis/etc/
    sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
    sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/etc/redis.conf
    cd ../
    rm -rf ${cur_dir}/src/${Redis_Stable_Ver}

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -A INPUT -p tcp --dport 6379 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi
    cd ../

    \cp ${cur_dir}/init.d/init.d.redis /etc/init.d/redis
    chmod +x /etc/init.d/redis
    echo "Add to auto start..."
    StartUp redis
    /etc/init.d/redis start

        echo "====== Redis install completed ======"
        echo "Redis installed successfully, enjoy it!"
}
