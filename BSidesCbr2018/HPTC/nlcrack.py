#!/usr/bin/python

import sys
import base64

# do the key schedule. return a byte array for the main algorithm
# k can be a list of numbers or a string
def init(k):
    # if key is a string, convert it to array of ASCII codes
    if isinstance(k, str):
        k = map(ord, k)
    # create and initialise S
    s = bytearray(256)
    i = 0
    while i < 256:
        s[i] = i
        i = i + 1
    # process S using the key data
    j = 0
    kl = len(k)
    i = 0
    while i < 256:
        j = (j + s[i] + k[i % kl]) & 0xff
        s[i], s[j] = s[j], s[i]
        i = i + 1
    return s

# encrypt/decrypt a string using RC4
def rc4(s, val):
    l = len(val)
    buf = bytearray(l)
    i = 0
    j = 0
    idx = 0
    while idx < l:
        i = (i + 1) & 0xff
        j = (j + s[i]) & 0xff
        s[i], s[j] = s[j], s[i]
        k = s[(s[i] + s[j]) & 0xff]
        buf[idx] = (ord(val[idx])) ^ k
        idx = idx + 1
    return str(buf)

kb = init("MaNTiCoreRC4Key")

if(not sys.argv[1].startswith('NLCR.1')):
    print "Usage: nlcrack.py <NLCR.1password>"
    quit()

print rc4(kb, base64.b64decode(sys.argv[1][6:]))
