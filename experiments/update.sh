#!/bin/bash

rsync --partial --info=progress2 -v -r -a -h \
    'seirl@granet.internal.softwareheritage.org:ssd/topology/*' .
