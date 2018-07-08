#!/bin/bash

Run_crysadm()
{
    echo "move crysadm to /home"
        mv ${cur_dir}/src/crysadm /home/crysadm
        rm -rf ${Crysadm_Home_Dir}/run.sh
        rm -rf ${Crysadm_Home_Dir}/down.sh
        mv ${cur_dir}/conf/run.sh ${Crysadm_Home_Dir}/run.sh
        mv ${cur_dir}/conf/down.sh ${Crysadm_Home_Dir}/down.sh
    echo "python3 run crysadm"
        chmod +x ${Crysadm_Home_Dir}/run.sh
        chmod +x ${Crysadm_Home_Dir}/down.sh
        cd ${Crysadm_Home_Dir}/
        ./run.sh
    echo "Nginx Service Start"
        /etc/init.d/nginx start
    
}

Clean_Src_Dir()
{
    echo "Clean src directory..."
    
        rm -rf ${cur_dir}/src/${Nginx_Ver}
        rm -rf ${cur_dir}/src/${Python_Stable_Ver}
        rm -rf ${cur_dir}/src/${Redis_Stable_Ver}
}

Print_Sucess_Info()
{
    Clean_Src_Dir
    echo "+------------------------------------------------------------------------+"
    echo "|      Crysadm V${crysadm_Ver} for ${DISTRO} Linux Server, Written by Licess      |"
    echo "+------------------------------------------------------------------------+"
    echo "|       For more information please visit https://www.fuzhihui.cn        |"
    echo "+------------------------------------------------------------------------+"
    echo "|               Crysadm directory:/home/crysadm                          |"
    echo "+------------------------------------------------------------------------+"
    echo "|              Crysadm: http://IP/login                                  |"
    echo "|              python : python3.4.5                                      |"
    echo "|              redis  : redis3.0                                         |"
    echo "+------------------------------------------------------------------------+"
    echo "|             脚本作者 :  傅皇Sai.7| x.fuzhihui.cn                         |"
    echo "+------------------------------------------------------------------------+"
    echo "|  Nginx_web directory: ${Default_Website_Dir}                            |"
    echo "+------------------------------------------------------------------------+"
    echo "|                        Powered by fuzhihui.cn                          |"
    echo "+------------------------------------------------------------------------+"
    netstat -ntl
    Echo_Green "Install Crysadm V${crysadm_Ver} completed! enjoy it."
}

Print_Failed_Info()
{
    Echo_Red "Sorry, Failed to install Crysadm!"
    Echo_Red "Please visit https://www.fuzhihui.cn/crysadm_install.html feedback errors and logs."
    Echo_Red "You can download /root/crysadm-install.log from your server,and upload crysadm-install.log to fuzhihui.cn ."
}
