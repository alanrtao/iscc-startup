#!/bin/bash

touch hosts
cat <<LOCALHOST >hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1     	localhost localhost.localdomain localhost6 localhost6.localdomain6
LOCALHOST

var=0

echo $1 tp-head >> hosts

for i in $(cat ~/apps/hostfile); do
	var=$((var+1))
	echo $i tp-worker-$var >> hosts
done
