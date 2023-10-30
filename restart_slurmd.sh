#!/bin/bash

ips=''

if [[ $1 = 'all' ]]; then
	ips=$(cat workers)
else
	ips="${@}";
fi

for ip in echo $ips; do
	ssh cc@$ip bash -c "sudo systemctl restart slurmd"
done
