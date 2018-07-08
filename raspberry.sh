#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install crysadm"
    exit 1
fi

Download_Mirror='http://soft.vpser.net'
Default_Website_Dir='/home/wwwroot/default'
Crysadm_Home_Dir='/home/crysadm'

cur_dir=$(pwd)
Stack="Crysadm"

crysadm_Ver='2.1'
. include/main.sh
. include/raspberry-init.sh
. include/version.sh
. include/python.sh
. include/raspberry-redis.sh
. include/nginx.sh
. include/end.sh

Get_Dist_Name

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

clear
echo "+------------------------------------------------------------------------+"
echo "|       Crysadm V${crysadm_Ver} for ${DISTRO} Linux Server, Written by Licess          |"
echo "+------------------------------------------------------------------------+"
echo "|           A tool to auto-compile & install Crysadm on Linux            |"
echo "+------------------------------------------------------------------------+"
echo "|        For more information please visit https://www.fuzhihui.cn       |"
echo "+------------------------------------------------------------------------+"


Init_Install()
{
    Press_Install
    Disable_Selinux
    Check_Download
	CentOS_InstallNTP
	CentOS_Dependent
    Install_Pcre
}
Crysadm_Stack()
{
    Init_Install
    Install_Nginx
    Install_Python
    Install_Redis

    Run_crysadm
    Print_Sucess_Info
}

case "${Stack}" in
    Crysadm)
        Crysadm_Stack 2>&1 | tee /root/crysadm-install.log
        ;;
esac


       
