# Use the ip address of this machine to determine the local network

LOG_DIR='./logs/'
LOCAL_IP_RANGE=`ip -o -f inet addr show | awk '/scope global/ {print $4}'`
nmap -sn $LOCAL_IP_RANGE -oN ${LOG_DIR}nmap-hosts-`date '+%Y%m%d%H%M%S'`.txt
