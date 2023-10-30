#!/bin/bash

cd ~
# cesm has its own backupscripts with more exclusion rules
tar \
	--exclude="apps/cesm" \
	-c -I pigz -f apps.tar.gz apps

cd apps
./cesm/backup.sh # this implicitly writes to ~/cesm.tar.gz instead of the current directory

cd ~
tar -c -I pigz -f intel.tar.gz intel
tar -c -I pigz -f cime.tar.gz .cime
