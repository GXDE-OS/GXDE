#!/bin/bash
bottlePath=./system-bottle
#gitPath=
sudo chroot $bottlePath bash -c "cd $gitPath ; $*"