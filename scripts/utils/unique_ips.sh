LOG_DIR='/var/log/lan-auditor'
cat ${LOG_DIR}/*.txt | grep 'Host is up' -B 1 | grep report | sort | uniq | cut -c 22- | cut -d "(" -f2 | cut -d ")" -f1
