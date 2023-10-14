#!/bin/bash

set -x

sudo chmod +rwx /home/cc

sudo getent group munge || sudo groupadd -g 1011 munge
sudo id -u munge || sudo useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u 1001 -g munge  -s /sbin/nologin munge
sudo getent group slurm || sudo groupadd -g 1012 slurm
sudo id -u slurm || sudo useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u 1002 -g slurm  -s /bin/bash slurm

sudo umount /home/cc/intel /home/cc/apps /home/cc/hpl /home/my_mounting_point /home/container

mkdir -p /home/cc/container
cc-cloudfuse mount /home/cc/container

if [[ $1 = '--client' ]]; then	
	mkdir -p /home/cc/intel
	sudo mount -t nfs 10.140.81.187:/home/cc/intel /home/cc/intel

	mkdir -p /home/cc/apps
	sudo mount -t nfs 10.140.81.187:/home/cc/apps /home/cc/apps

	mkdir -p /home/cc/hpl
	sudo mount -t nfs 10.140.81.187:/home/cc/hpl /home/cc/hpl

	setupdir=/home/cc/apps/setup
	sudo bash $setupdir/setup-compute-node
fi

