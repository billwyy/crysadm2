#!/bin/bash
echo 'Start crysadm off'  $(date) >> /tmp/crysadm_down.txt
    echo 'Stop Redis-Server'
        /etc/init.d/redis stop
    echo 'Stop Python3'
        pkill python3.*
    echo '##Plass wait!##'
        BASE_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
        ls ${BASE_DIR}/ >> /tmp/error 2>&1

echo $PATH >> /tmp/error
echo $LD_LIBRARY_PATH >> /tmp/error
    echo 'Start Redis-Server'
        /etc/init.d/redis start
    echo 'Runing Crysadm'
        python3 ${BASE_DIR}/crysadm/crysadm_helper.py >> /tmp/error 2>&1 &
        python3 ${BASE_DIR}/crysadm/crysadm.py >> /tmp/error 2>&1 & 