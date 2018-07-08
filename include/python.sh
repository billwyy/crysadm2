#!/bin/bash

Install_Python()
{
    Echo_Blue "[+] Installing ${Python_Stable_Ver}... "

    Tar_Cd ${Python_Stable_Ver}.tgz ${Python_Stable_Ver}
        ./configure
    make && make install
    cd ../
    mkdir $HOME/.pip
    cp ${cur_dir}/conf/pip.conf $HOME/.pip/pip.conf
    # 安装python扩展组件
    pip3 install --upgrade pip
    pip3 install --upgrade redis
    pip3 install --upgrade requests
    pip3 install --upgrade flask
    pip3 install --upgrade flask-mail

}
