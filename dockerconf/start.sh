#!/bin/bash
CURRENT_PATH=`dirname $0`
cd $CURRENT_PATH
XUNFENG_BASE=`dirname ${CURRENT_PATH}`
XUNFENG_DB=/data
XUNFENG_LOG=/var/log/xunfeng

[ ! -d $XUNFENG_LOG ] && mkdir -p ${XUNFENG_LOG}

nohup mongod --bind_ip 0.0.0.0 --port 65521 --dbpath=${XUNFENG_DB} > ${XUNFENG_LOG}/db.log &

mongo 127.0.0.1:65521/xunfeng < ${XUNFENG_BASE}/dockerconf/mongoauth
if [[ $? != 0 ]]; then
    mongorestore -h 127.0.0.1 --port 65521 -d xunfeng ${XUNFENG_BASE}/db/
    mongo 127.0.0.1:65521/xunfeng < ${XUNFENG_BASE}/dockerconf/mongoauth
fi

nohup python -u ${XUNFENG_BASE}/web.py > ${XUNFENG_LOG}/web.log 2>&1 &
nohup python -u ${XUNFENG_BASE}/aider/aider.py > ${XUNFENG_LOG}/aider.log 2>&1 &
nohup python -u ${XUNFENG_BASE}/nascan/nascan.py > ${XUNFENG_LOG}/scan.log 2>&1 &
nohup python -u ${XUNFENG_BASE}/vulscan/vulscan.py > ${XUNFENG_LOG}/vul.log 2>&1 &

/usr/bin/tail -f /dev/null
