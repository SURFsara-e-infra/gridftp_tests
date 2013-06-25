#!/bin/bash

. setenv.sh

# If you change the values below, you may need to do a test_prepare.sh!

# Specify the remote server to gridftp to and from
REMOTE_SERVER=

# Local storage path where the test files are.
STORAGE_PATH=

# Anonymous user to read and write the files. This is not allowed to be root.
USER=

#The stuff below you can leave as is.
#----------------------------------------------------

if [ -z ${REMOTE_SERVER} ]; then
    echo "Please specify REMOTE_SERVER in settings.sh"
    exit 1
fi

if [ -z ${STORAGE_PATH} ]; then
    echo "Please specify STORAGE_PATH in settings.sh"
    exit 1
fi

if [ -z ${USER} ]; then
    echo "Please specify USER in settings.sh"
    exit 1
fi

# Writing (reading from server) is done from memory, so that the server disks are no bottleneck.
SERVER_RAMDISK=/dev/shm

# Command to run GridFTP, relative from current directory.
GLOBUS_COMMAND=globus-url-copy

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

# Number of files (not nessecerily same as number of transfers)
FILES=1000

get_last_line () {
  tail -n 1 $1
}

kill_child_procs () {
  echo "One child has finished. Terminating all other child procs..." 1>&2
  killall -9 test_child.sh
}
