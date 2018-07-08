#!/bin/bash

Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

CentOS_InstallNTP()
{
    Echo_Blue "[+] Installing ntp..."
    yum install -y ntp
    ntpdate -u pool.ntp.org
    date
}

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Xen_Hwcap_Setting()
{
    if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
        sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
    fi
}

Check_Hosts()
{
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        echo "Hosts: ok."
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
    ping -c1 www.fuzhihui.cn
    if [ $? -eq 0 ] ; then
        echo "DNS...ok"
    else
        echo "DNS...fail"
        echo -e "nameserver 223.5.5.5\nnameserver 114.114.114.114" > /etc/resolv.conf
    fi
}

CentOS_Dependent()
{
    cp /etc/yum.conf /etc/yum.conf.fuzhihui
    sed -e 's:exclude=.*:exclude=:g' /etc/yum.conf

    Echo_Blue "[+] Yum installing dependent packages..."
    for packages in make cmake gcc gcc-c++ gcc-g77 flex file autoconf kernel-devel patch wget zlib zlib-devel unzip tar bzip2 bzip2-devel curl curl-devel libcurl libcurl-devel openssl openssl-devel vim-minimal unzip net-tools expat-devel gdbm-devel readline-devel sqlite-devel;
    do yum -y install $packages; done

    mv -f /etc/yum.conf.fuzhihui /etc/yum.conf
}


Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.gz ${Pcre_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    Download_Files http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}.tar.gz
}

Install_Pcre()
{
    Cur_Pcre_Ver=`pcre-config --version`
    if echo "${Cur_Pcre_Ver}" | grep -vEqi '^8.';then
        Echo_Blue "[+] Installing ${Pcre_Ver}"
        Tar_Cd ${Pcre_Ver}.tar.gz ${Pcre_Ver}
        ./configure
        make && make install
        cd ${cur_dir}/src/
        rm -rf ${cur_dir}/src/${Pcre_Ver}
    fi
}

    ldconfig

    cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

    echo "fs.file-max=65535" >> /etc/sysctl.conf
}
