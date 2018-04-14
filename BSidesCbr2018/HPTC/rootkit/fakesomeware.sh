#!/bin/sh
export DISPLAY=:0.0
hptc-dialog --no-decorations \
            --stays-on-top \
            --vwidget=label \
            --pixmap=./matrix.jpeg \
            --scaled=true \
            --okay
