#!/bin/bash
echo 'Start crysadm off'  $(date) >> /tmp/crysadm_down.txt
echo 'Stop Redis-Server'
    /etc/init.d/redis stop
echo 'Stop Python3'
    pkill python3.*
