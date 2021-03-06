
    Version: 2017-06-07 - Replaced the Globus-5.2 repo rpm with the repo rpm pointing to the latest version.
    Version: 2013-06-24 - Fixed documentation and adapted the script for a new feature in globus gridftp which does not allow the anonymous user to be root.
    Version: 2013-06-05 - Removed tarball and replaced this with a repo file. Updated information.
    Version: 2011-04-07 - gt5.0.3 gridftp server. removed solaris stuff.
    Version: 2009-07-24 - some info on gridftp performance tuning added
    Version: 2009-07-23 - test_* scripts added

Introduction
============

This package contains a script, gridftp.sh, that can be used to build the globus
gridftp server and client and to start and stop the gridftp daemon. The globus 
gridftp daemon is run in so-called anonymous mode, which means that there is no
security whatsoever. Therefore we would encourage you not to run this software
on a machine that is on an open network. 

For the acceptance test, the host being tested should run the <u>test_start.sh</u> 
script, while another host acts as gridftp server. In case multiple hosts 
share the same storage, they should run the test simultaneously, each talking 
to a different gridftp server.

The <u>gridftp.sh</u> script will run the gridftp daemon on a non-priviledged port 
(5000) so there is no need to run the daemon as root. 

We have tested this software on x86_64 architectures running CentOS 7.3.

Please refer to the document "Acceptance Tests" for
additional information.


Installation
============

The gridftp software can be installed by running:

`./gridftp.sh install`

The port **5000** and port range **20000-25000** should be open for incoming traffic. All outgoing traffic should be allowed.



Starting and Stopping the gridftp server
========================================

The gridftp server can be started and stopped by running:

`./gridftp.sh <start|stop>`


Testing the throughput
======================

On the host of which the throughput needs to be tested, the following scripts
are important:

**settings.sh**

This file contains variables that are common to the scripts. You need to specify the following:
  >**REMOTE_SERVER** - the name or ip number of the remote gridftp server.
  
  >**STORAGE_PATH** - the path to the place where on this machine the test files are stored.
  
  >**USER** - the (non root) name of the user that is used for anonymous gridftp access.

**test_prepare.sh**

This script creates files to test with, both locally and on the server.
  Run this after starting gridftp on the server, and before doing any tests.

**test_single_thread.sh**

  This is a simple and quick test script that can be useful for tuning.
  The acceptance test, however, is done with <u>test_start.sh</u>.

**test_start.sh**

  This is the main test script. Don't forget to run <u>test_prepare.sh</u> 
  first!!!! test_start.sh starts a number of child processes
  that each do reading or writing of multiple files. This script
  starts up read and write processes in a ratio of 2:1.
  How many of these transfer sets are done simultanueously is 
  determined by the variable **NUMBER_OF_2R1W_OPERATIONS** (default is 4).

  When the first child process is finished with all transfers, all 
  other childs are terminated, and then some calculations are done 
  with the last throughput numbers that each child had written to a 
  result file. The last, broken transfer of each child is not counted 
  (neither bytes nor time).
  The average throughput of each transfer type is printed.

**test_child.sh**

  This script is started from <u>test_start.sh</u> and is not intended to be 
  started stand-alone.
  Within this script, there is a loop that does gridftp transfers.
  When sending files, the files are randomly selected to prevent 
  file caching. Sending should be done from the local storage file 
  system. On the remote server files are written to /dev/null so
  that the remote file system does not become a bottleneck.
  When writing to the local file system, the source file is read 
  from the ram disk of the server, /dev/shm ; again to avoid a 
  remote bottleneck.

**result.sh**

  Script that can be used to print intermediate results.

Please beware, that if the storage is shared by more than one node,
all attached nodes need to run <u>test_start.sh</u> simultaneously! 
Each of the attached nodes should talk to a different gridftp server, 
to ensure that the server does not become a bottleneck.

A typical test
==============

Typically you need to perform the following steps. This needs to be in place on two servers. Here **server1** is the server from where the tests are going to be 
run. **Server2** just performs as the remote gridftp server.

On server2:

 1. ./gridftp.sh install
 1. set the correct value for **USER** in settings.sh and set **STORAGE_PATH** and **REMOTE_SERVER** to some dummy values. 
 1. ./gridftp.sh start
 
On server1:

 1. ./gridftp.sh install
 1. provide settings.sh on this nodewith the proper values for **REMOTE_SERVER**, **STORAGE_PATH** and **USER**.
 1. ./gridftp.sh start
 1. ./test_prepare.sh
 1. Have a long long long coffee break
 1. ./test_start.sh
 1. Have a long coffee break
 1. You may run result.sh, just to get an idea about the performance.
 1. Collect the output of the test_start.sh script.
 

Performance tuning
==================

Globus gridftp has a number of parameters that influence its performance.
Information about this can be found on these pages:
[http://toolkit.globus.org/toolkit/docs/latest-stable/gridftp/#gridftp](URL)

In <u>settings.sh</u>, there are a few variables for tuning:

**STREAMS=1**

  >If TCP packets don't come through, they are resent with half the speed.
  If this happens a lot, it can be worthwhile to spliut the transfer in 
  several streams, so that only one stream is reduced in speed.
  (`globus-url-copy -p`)

**TCP_BUFFERSIZE=1048576**

  >This value depends on the network bandwidth. Use this formula:
  [TCP Buffer size (bytes) = 1024 * Bandwidth (Mbs) * Round trip delay time(ms) / 8]
  (`globus-url-copy -tcp-bs`)

**GRIDFTP_BLOCKSIZE=131072**

  >Specifies the size (in bytes) of the buffer to be used by the
  underlying transfer methods.
  (`globus-url-copy -bs`)

-------------------------------------------

For questions about this storage test suite, please contact us.
