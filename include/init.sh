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

Deb_InstallNTP()
{
    apt-get update -y
    Echo_Blue "[+] Installing ntp..."
    apt-get install -y ntpdate
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

RHEL_Modify_Source()
{
    Get_RHEL_Version
    \cp ${cur_dir}/conf/CentOS-Base-163.repo /etc/yum.repos.d/CentOS-Base-163.repo
    sed -i "s/\$releasever/${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
    sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
    yum clean all
    yum makecache
}

Ubuntu_Modify_Source()
{
    CodeName=''
    if grep -Eqi "10.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.10'; then
        CodeName='maverick'
    elif grep -Eqi "11.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.04'; then
        CodeName='natty'
    elif  grep -Eqi "11.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.10'; then
        CodeName='oneiric'
    elif grep -Eqi "12.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.10'; then
        CodeName='quantal'
    elif grep -Eqi "13.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.04'; then
        CodeName='raring'
    elif grep -Eqi "13.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.10'; then
        CodeName='saucy'
    elif grep -Eqi "10.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.04'; then
        CodeName='lucid'
    elif grep -Eqi "14.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.10'; then
        Ubuntu_Deadline utopic
    elif grep -Eqi "15.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.04'; then
        Ubuntu_Deadline vivid
    elif grep -Eqi "12.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.04'; then
        Ubuntu_Deadline precise
    elif grep -Eqi "15.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.10'; then
        Ubuntu_Deadline wily
    fi
    if [ "${CodeName}" != "" ]; then
        \cp /etc/apt/sources.list /etc/apt/sources.list.$(date +"%Y%m%d")
        cat > /etc/apt/sources.list<<EOF
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName} main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-security main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-updates main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-proposed main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-backports main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName} main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-security main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-updates main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-proposed main restricted universe multiverse
deb-src http://old-releases.ubuntu.com/ubuntu/ ${CodeName}-backports main restricted universe multiverse
EOF
    fi

    sed -e 's/us.archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list
}

Check_Old_Releases_URL()
{
    OR_Status=`wget --spider --server-response http://old-releases.ubuntu.com/ubuntu/dists/$1/Release 2>&1 | awk '/^  HTTP/{print $2}'`
    if [ ${OR_Status} != "404" ]; then
        echo "Ubuntu old-releases status: ${OR_Status}";
        CodeName=$1
    fi
}

Ubuntu_Deadline()
{
    utopic_deadline=`date -d "2015-10-1 00:00:00" +%s`
    vivid_deadline=`date -d "2016-2-24 00:00:00" +%s`
    precise_deadline=`date -d "2017-5-27 00:00:00" +%s`
    wily_deadline=`date -d "2016-7-22 00:00:00" +%s`
    cur_time=`date  +%s`
    case "$1" in
        utopic)
            if [ ${cur_time} -gt ${utopic_deadline} ]; then
                echo "${cur_time} > ${utopic_deadline}"
                Check_Old_Releases_URL utopic
            fi
            ;;
        vivid)
            if [ ${cur_time} -gt ${vivid_deadline} ]; then
                echo "${cur_time} > ${vivid_deadline}"
                Check_Old_Releases_URL vivid
            fi
            ;;
        precise)
            if [ ${cur_time} -gt ${precise_deadline} ]; then
                echo "${cur_time} > ${precise_deadline}"
                Check_Old_Releases_URL precise
            fi
            ;;
        wily)
            if [ ${cur_time} -gt ${wily_deadline} ]; then
                echo "${cur_time} > ${wily_deadline}"
                Check_Old_Releases_URL wily
            fi
            ;;
    esac
}

CentOS_Dependent()
{
    cp /etc/yum.conf /etc/yum.conf.fuzhihui
    sed -e 's:exclude=.*:exclude=:g' /etc/yum.conf

    Echo_Blue "[+] Yum installing dependent packages..."
    for packages in make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel;
    do yum -y install $packages; done

    mv -f /etc/yum.conf.fuzhihui /etc/yum.conf
}

Deb_Dependent()
{
    Echo_Blue "[+] Apt-get installing dependent packages..."
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y build-essential gcc g++ make
    for packages in build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev libkrb5-dev curl libcurl3 libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libjpeg-dev libpng12-dev libxml2-dev libcap-dev ca-certificates debian-keyring debian-archive-keyring libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libc-client-dev;
    do apt-get install -y $packages --force-yes; done
}

Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/mhash/${Mash_Ver}.tar.gz ${Mash_Ver}.tar.gz
    Download_Files ${Download_Mirror}/lib/curl/${Curl_Ver}.tar.gz ${Curl_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.gz ${Pcre_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    Download_Files http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}.tar.gz
}

Install_Mhash()
{
    Echo_Blue "[+] Installing ${Mash_Ver}"
    Tar_Cd ${Mash_Ver}.tar.gz ${Mash_Ver}
    ./configure
    make && make install
    ln -sf /usr/local/lib/libmhash.a /usr/lib/libmhash.a
    ln -sf /usr/local/lib/libmhash.la /usr/lib/libmhash.la
    ln -sf /usr/local/lib/libmhash.so /usr/lib/libmhash.so
    ln -sf /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
    ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
    ldconfig
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Mash_Ver}
}

Install_Curl()
{
    Echo_Blue "[+] Installing ${Curl_Ver}"
    Tar_Cd ${Curl_Ver}.tar.gz ${Curl_Ver}
    ./configure --prefix=/usr/local/curl --enable-ares --without-nss --with-ssl
    make && make install
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Curl_Ver}
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

CentOS_Lib_Opt()
{
    if [ "${Is_64bit}" = "y" ] ; then
        ln -sf /usr/lib64/libpng.* /usr/lib/
        ln -sf /usr/lib64/libjpeg.* /usr/lib/
    fi

    ulimit -v unlimited

    if [ `grep -L "/lib"    '/etc/ld.so.conf'` ]; then
        echo "/lib" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib" >> /etc/ld.so.conf
        #echo "/usr/lib/openssl/engines" >> /etc/ld.so.conf
    fi

    if [ -d "/usr/lib64" ] && [ `grep -L '/usr/lib64'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib64" >> /etc/ld.so.conf
        #echo "/usr/lib64/openssl/engines" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi

    ldconfig

    cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

    echo "fs.file-max=65535" >> /etc/sysctl.conf
}

Deb_Lib_Opt()
{
    if [ "${Is_64bit}" = "y" ] ; then
        ln -sf /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
    else
        ln -sf /usr/lib/i386-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
        ln -sf /usr/include/i386-linux-gnu/asm /usr/include/asm
    fi

    ulimit -v unlimited

    if [ `grep -L "/lib"    '/etc/ld.so.conf'` ]; then
        echo "/lib" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib" >> /etc/ld.so.conf
    fi

    if [ -d "/usr/lib64" ] && [ `grep -L '/usr/lib64'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib64" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi

    ldconfig

    cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

    echo "fs.file-max=65535" >> /etc/sysctl.conf
}
