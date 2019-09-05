LOG_DIR='./logs/'
cat ${LOG_DIR}*.txt | grep 'Host is up' -B 1 | grep report | sort | uniq | cut -c 22-
