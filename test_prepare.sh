#!/bin/bash

. settings.sh

echo Creating testfiles. This may take several minutes.
echo Creating testfile for writing.
echo ${STORAGE_PATH}
if [ ! -x ${STORAGE_PATH} ]; then
    mkdir -p ${STORAGE_PATH}
fi
dd if=/dev/zero of=$STORAGE_PATH/$TESTFILE bs=1048576 count=$TESTFILE_SIZE_MB 2>&1 | sed -e "s%^%File $STORAGE_PATH/$TESTFILE: %"
ls -l $STORAGE_PATH/$TESTFILE
echo Uploading testfile into the ram disk of the GridFTP server.
$GLOBUS_COMMAND $STORAGE_PATH/$TESTFILE ftp://$REMOTE_SERVER:5000$SERVER_RAMDISK/$TESTFILE
echo Creating $FILES testfiles for reading. You may want to take a coffee break.
for i in `seq 1 $FILES` ; do
  dd if=/dev/zero of=$STORAGE_PATH/$TESTFILE-$i bs=1048576 count=$TESTFILE_SIZE_MB 2>&1 | sed -e "s%^%File $STORAGE_PATH/$TESTFILE-$i: %"
done
echo Done with preparation.
