#!/bin/bash

# This scipt has been tested on Scientific Linux 4 (RHEL4 compatibel).
# It may not work on Solaris without some porting!

# Load a bunch of variables
. settings.sh

# Get the server name from the calling script test_start.sh.
SERVER=$1

# How many transfers should we do? Again, test_start.sh will tell us.
TRANSFERS=$3

. ${GLOBUS_LOCATION}/etc/globus-user-env.sh

usage () {
  echo "This script is supposed to be called from test_start.sh."
  echo "Usage:"
  echo "$0 <hostname> <read|write> <repetitions>"
  exit
}

timer_start () {
  START=`python -c "import time; print time.time()"`
}

timer_stop () {
  STOP=`python -c "import time; print time.time()"`
  python -c "print str($TESTFILE_SIZE_MB*$i)+' MB; '+str($STOP-$START)+' sec; Throughput: '+str($TESTFILE_SIZE_MB*$i/(($STOP-$START)))+' MB/s.'"
}

get_random_file_number () {
  if [ -z "$1" ] ; then 
    echo "Function get_random_file_number needs a max number."
    exit 1
  fi
  a=`expr $RANDOM \* $1`
  b=`expr $a / 32768`
  NUMBER=`expr $b + 1`
  echo $NUMBER
}

test_read () {
  # Client read test (= server write, but we are testing the client)
  timer_start
  for i in `seq 1 $TRANSFERS` ; do
    NUMBER=`get_random_file_number $FILES`
    $GLOBUS_COMMAND $GLOBUS_PARAMETERS $STORAGE_PATH/$TESTFILE-$NUMBER ftp://$SERVER:5000/dev/null
    # In the loop because this child may get killed and we want the last values.
    timer_stop
  done
  # The first child process that has finished with all files, will kill 
  # all other child processes.
  echo "One child has finished. Terminating all other child procs..." 1>&2
  kill_child_procs
}

test_write () {
  # Client write test
  timer_start
  for i in `seq 1 $TRANSFERS` ; do
    $GLOBUS_COMMAND $GLOBUS_PARAMETERS ftp://$SERVER:5000$SERVER_RAMDISK/$TESTFILE $STORAGE_PATH/$TESTFILE-proc$$-$i
    # In the loop because this child may get killed and we want the last values.
    timer_stop
  done
  # The	first child process that has finished with all files, will kill	
  # all	other child processes.                                                        
  echo "One child has finished. Terminating all other child procs..." 1>&2
  kill_child_procs
}

if [ $# -ne 3 ]; then
  usage
  exit 1
fi

test=$2
case $test in
  "read" )
       test_read
       exit 0
       ;;
  "write" )
       test_write
       exit 0
       ;;
  * )
       usage
       exit 1
       ;;
esac

