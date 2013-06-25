#!/bin/bash

CURDIR=`pwd`
REPORPM=`cd ${CURDIR}; ls Glob*rpm`

clean () {
    stop

    tmpfile=`mktemp`
    if [ ! -f /etc/yum.conf ]; then
        echo "yum config not found"
        exit 1
    else
        cp /etc/yum.conf /etc/yum.conf.saved
    fi
    cat /etc/yum.conf | grep -v clean_requirements_on_remove > ${tmpfile}
    echo "clean_requirements_on_remove=1" >> ${tmpfile}
    mv ${tmpfile} /etc/yum.conf

    yum remove -y globus-gridftp

    mv -f /etc/yum.conf.saved /etc/yum.conf

    rm -f ${CURDIR}/setenv.sh
    rm -f ${CURDIR}/*.txt
}

install () {
    cd $CURDIR
    clean

  
    rpm -i --force ${REPORPM}
    
    yum install -y globus-gridftp
    
    echo ". /usr/share/globus/globus-script-initializer" >>$CURDIR/setenv.sh
}

start () {
    . /usr/share/globus/globus-script-initializer
    . settings.sh
    echo 1>&2 -n "Starting globus-gridftp server..."
    DATE=`date '+%Y%m%d%H%M%S'`
    pid=`ps -A | grep globus | awk '{print $1}'`
    if [ -z $pid ]; then
        globus-gridftp-server -anonymous-user $USER -disable-usage-stats -aa -Z ${CURDIR}/gridftplog_${DATE}.txt -S -p 5000
        if [ "x$?" == "x0" ]; then
            echo 1>&2 "globus-gridftp-server started successfully"
        else
            echo 1>&2 "globus-gridftp-server failed to start"
        fi
    else
        echo 1>&2 "globus-gridftp-server is already running"
        exit 1
    fi
}

stop () {
    echo 1>&2 -n "Stopping globus-gridftp server..."
    pid=`ps -A | grep globus | awk '{print $1}'`
    if [ ! -z $pid ]; then
        kill -15 ${pid}
        if [ "x$?" == "x0" ]; then
            echo 1>&2 "globus-gridtp-server stopped successfully"
        else
            echo 1>&2 "globus-gridtp-server failed to stop"
        fi
    else
        echo 1>&2 "globus-gridtp-server is not running"
    fi
}

status () {
    pid=`ps -A | grep globus | awk '{print $1}'`
    if [ ! -z $pid ]; then
        echo 1>&2 "globus-gridtp-server is running"
    else
        echo 1>&2 "globus-gridtp-server is not running"
    fi
}

if [ ! -f /etc/redhat-release ]; then
    echo 1>&2 "The unix version that you are running is not supported"
    exit 1
fi
distr=`cat /etc/redhat-release | awk '{print $1 $2}'`
if [ "x`echo $version | awk '{print $1}'`" == "xCentOS" ]; then
    distr="CentOS"
fi
case "$distr" in
"CentOS")
    ;;
"*")
    echo 1>&2 "The unix version that you are running is not supported"
    exit 1
    ;;
esac
version=`cat /etc/redhat-release | sed 's/.*release\s//' | sed 's/\..*//'`
case "$version" in
"6")
    ;;
"*")
    echo 1>&2 "The version that you are running is not supported"
    exit 1
    ;;
esac
    
    
case "$1" in
    install)
        install
        ;;
    clean)
        clean
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    *)
        echo 2>&1 "Usage: $0 {install|clean|start|stop|status}"
        ;;
esac
