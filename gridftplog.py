#!/usr/bin/env python

import sys,string,re,time,datetime

def get_ts(a):
    year=int(a[0:4])
    month=int(a[4:6])
    day=int(a[6:8])
    hour=int(a[8:10])
    minute=int(a[10:12])
    second=int(a[12:14])

    a=datetime.datetime(year,month,day,hour,minute,second)
    ts=long(time.mktime(a.timetuple()))
    return ts

if __name__ == '__main__':
    min_timestamp=sys.maxint
    max_timestamp=0
    nbytes_rd=0
    nbytes_wr=0

    regexp=re.compile('^DATE=([0-9]+)\.([0-9]+)\s.*FTP_INFO START=([0-9]+)\.([0-9]+)\s.*NBYTES=([0-9]+)\s.*TYPE=(RETR|STOR)\s.*')

    try:
        f=open(sys.argv[1],'r')
        list=map(string.strip,f.readlines())
        f.close()
    except:
        sys.stderr.write("Unable to open file\n")

    for line in list:
        match=regexp.match(line)
        if match != None:
            entries=match.groups()
            ts_end=entries[0]
            ms_end=entries[1]
            ts_start=entries[2]
            ms_start=entries[3]
            bytes=long(entries[4])
            type=entries[5]
            secs_end=get_ts(ts_end)
            secs_start=get_ts(ts_start)
            t_end=float('0.'+ms_end)+secs_end
            t_start=float('0.'+ms_start)+secs_start

            min_timestamp=min(min_timestamp,t_start)
            max_timestamp=max(max_timestamp,t_end)
            if type == 'RETR':
               nbytes_rd=nbytes_rd+bytes
            elif type == 'STOR':
               nbytes_wr=nbytes_wr+bytes
            else:
               sys.stderr.write("This should not happen.\n")
               sys.exit(1)
            
    dt=max_timestamp-min_timestamp
    if nbytes_rd>0:
        print str(nbytes_rd)+" read in "+str(dt)+" seconds: "+str((nbytes_rd/1000000.0)/dt)+" MB/s"

    if nbytes_wr>0:
        print str(nbytes_wr)+" written in "+str(dt)+" seconds: "+str((nbytes_wr/1000000.0)/dt)+" MB/s"

    print "timestamp_start: "+str(min_timestamp)
    print "timestamp_end: "+str(max_timestamp)
    
