#!/bin/sh
# Thankfully HP includes a tool for resetting passwords upon expiry
# which prints the old and new passwords on stdout
PASSW=`/usr/bin/hptc-get-new-password`

