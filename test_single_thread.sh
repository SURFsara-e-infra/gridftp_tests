#!/bin/bash

# This test script is added for convenience; however, acceptance tests will be done with test_start.sh.

# Debugging
#set -x

# Load lots of variables
. settings.sh

# You may want to change this value to speak to the right interface of the server (internal, external).
SERVER=$SERVER_IF_EXTERNAL

# Number of transfers (less or equal to $FILES please)
TRANSFERS=3

timer_start () {
  START=`python -c "import time; print time.time()"`
}

timer_stop () {
  STOP=`python -c "import time; print time.time()"`
  python -c "print 'Throughput: '+str($TESTFILE_SIZE_MB*$TRANSFERS/(($STOP-$START)))+' MB/s.'"
}

get_random_file_number () {
  if [ -z "$1" ] ; then 
    echo "Function get_random_file_number needs a max number."
    exit 1
  fi
  # $RANDOM generates a random number from 0 to 32767.
  let "a = $1 * $RANDOM / 32768"
  expr $a + 1
}

test_read () {
  # Client read test (= server write, but we are testing the client)
  echo "Local read test with $TRANSFERS randomly chosen files of size $TESTFILE_SIZE_MB MB."
  timer_start
  for i in `seq 1 $TRANSFERS` ; do
    NUMBER=`get_random_file_number $FILES`
    echo -n "$i:$NUMBER "
    $GLOBUS_COMMAND $GLOBUS_PARAMETERS $STORAGE_PATH/$TESTFILE-$NUMBER ftp://$SERVER:5000/dev/null
  done
  echo
  timer_stop
}

test_write () {
  # Client write test
  echo "Local write test with file size $TESTFILE_SIZE_MB MB, $TRANSFERS repetitions."
  timer_start
  for i in `seq 1 $TRANSFERS` ; do
    echo -n "$i "
    $GLOBUS_COMMAND $GLOBUS_PARAMETERS ftp://$SERVER:5000$SERVER_RAMDISK/$TESTFILE $STORAGE_PATH/$TESTFILE-proc$$-$i
  done
  echo
  timer_stop
  echo -n "Cleaning up... "
  rm -f $STORAGE_PATH/$TESTFILE-$$-*
  echo "Done."
}


test=$1
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
       echo "Unrecognized option."
       echo "Available options are:"
       echo "read = test reading speed from this client"
       echo "write = test writing speed to this client"
       exit 0
       ;;
esac
