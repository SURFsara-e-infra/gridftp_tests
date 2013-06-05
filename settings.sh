#!/bin/bash

. setenv.sh

# If you change the values below, you may need to do a test_prepare.sh!

# You may want to change this value to speak to the right interface of the server (internal, external).
SERVER_IF_EXTERNAL=bee22
SERVER_IF_INTERNAL=i-bee22

# Writing (reading from server) is done from memory, so that the server disks are no bottleneck.
SERVER_RAMDISK=/dev/shm

# Local storage path.
STORAGE_PATH=/space

# Command to run GridFTP, relative from current directory.
GLOBUS_COMMAND=$GLOBUS_LOCATION/bin/globus-url-copy

# Performance tuning, see http://globus.org/toolkit/data/gridftp/faq.html
STREAMS=1
# [TCP Buffer size (bytes) = 1024 * Bandwidth (Mbs) * Round trip delay time(ms) / 8]
#TCP_BUFFERSIZE=1048576
TCP_BUFFERSIZE=179200
GRIDFTP_BLOCKSIZE=150000
GLOBUS_PARAMETERS="-p $STREAMS -tcp-bs $TCP_BUFFERSIZE -bs $GRIDFTP_BLOCKSIZE"

# Properties of the files to test with.
TESTFILE=testfile
# Don't change this value without consulting SARA.
TESTFILE_SIZE_MB=2048

# Loading Globus environment
. ${GLOBUS_LOCATION}/etc/globus-user-env.sh

# Number of files (not nessecerily same as number of transfers)
FILES=1000


# Now solve some Solaris compatibility issues
if [ "`uname -s`" = "SunOS" ] ; then

  seq () {
    i=$1
    s=""
    while [ $i -le $2 ]
    do
        s=$s"$i "
        i=`expr $i + 1`
    done
    echo $s
  }

  get_last_line () {
    tail -1 $1
  }

  kill_child_procs () {
    echo "One child has finished. Terminating all other child procs..." 1>&2
    pkill -9 test_child.sh
  }

else 
  # Not Solaris, must be Linux then.

  get_last_line () {
    tail -n 1 $1
  }

  kill_child_procs () {
    echo "One child has finished. Terminating all other child procs..." 1>&2
    killall -9 test_child.sh
  }

fi
