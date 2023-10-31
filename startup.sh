#!/bin/bash

prevpwd=$PWD

sudo dnf update -y
sudo yum install --skip-broken -y $(cat pkglist.txt)
yes | sudo cpan -i XML::LibXML

set -x

sudo chmod +rwx /home/cc

#getent database key OR add new group called munge w GID 1011
sudo getent group munge || sudo groupadd -g 1011 munge
#The "munge" user is created to run the MUNGE service, and it typically has a minimal shell configuration (often set to /sbin/nologin) to prevent interactive logins. This is because the "munge" user is intended to run as a service and doesn't require direct interaction from users.
#a new user account with the name "munge" will be created, associated with the "munge" group, and configured with the specified settings, including the home directory and login shell
sudo id -u munge || sudo useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u 1001 -g munge  -s /sbin/nologin munge
sudo getent group slurm || sudo groupadd -g 1012 slurm
#-d specifies dir, -u specifies user id, -g adds user to group -s specifies its shell
sudo id -u slurm || sudo useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u 1002 -g slurm  -s /bin/bash slurm

#unmount so we can reconfigure from scratch
sudo umount /home/cc/intel /home/cc/apps /home/cc/my_mounting_point /home/cc/container

#if command line arg is client
if [[ $1 = '--client' ]]; then
	#script takes headip's contents as args
	./write-hosts.sh $(cat headip)
 	#pipe hosts's contents to hosts file in /etc
 	cat hosts | sudo tee /etc/hosts
  	#replace .bashrc w bashrc
	cat bashrc > /home/cc/.bashrc

 	#copy first file into second file location
 	sudo cp /home/cc/hosts /etc/hosts
  	cp /home/cc/TP.pem /home/cc/.ssh/TP.pem
	
	sudo rm /usr/bin/python
 	#symbolic link so you can use python to execute both python3 and python2 scripts
	sudo ln -s /usr/bin/python3 /usr/bin/python

	#executes script in current shell. can also do . bashrc
 	#./bashrc is executed in subshell, doesn't effect current/parent shell
	source bashrc

	#-p flag forces parent dir's of /intel to be created if they don't exist
	mkdir -p /home/cc/intel
	mkdir -p /home/cc/apps

  	#mounting to nfs system. mount remote dir (of headip/host) to local dir
	sudo mount -t nfs $(cat headip):/home/cc/intel /home/cc/intel
	sudo mount -t nfs $(cat headip):/home/cc/apps /home/cc/apps

 	
	setupdir=/home/cc/apps/setup
 	#execute bashscript located at path/filename
  	#running w bash does not affect current shell. (why do we do this here?)
	sudo bash $setupdir/setup-compute-node
 
elif [[ $1 = '--host' ]]; then

	mkdir -p /home/cc/intel
	mkdir -p /home/cc/apps
	mkdir -p /home/cc/.cime

	#prompt user, read/store response in ext_tb
	read -p "extract tarball? (y/n): " ext_tb
 	if [[ $ext_tb = 'y' ]]; then
        	tar -x -I pigz -f ~/apps.tar.gz -C ~
		tar -x -I pigz -f ~/intel.tar.gz -C ~
 		tar -x -I pigz -f ~/cime.tar.gz -C ~
  	fi

   	#recursively rm w/ force
	sudo rm -rf /etc/exports
 	sudo touch /etc/exports

	#appends export rules for two directories, "apps" and "intel," to the /etc/exports file
 	for dir in apps intel
  	do
		echo "/home/cc/$dir *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
 	done

  	#When you make modifications to the /etc/exports file, you can use exportfs -a to inform the NFS server to re-read the export table and apply the new configuration.
  	exportfs -a
  	sudo systemctl restart nfs-server

        cd ~/apps

 	read -p "install autoconf? (y/n): " inst_ac
  	if [[ $inst_ac = 'y' ]]; then
 		./scripts/install_autoconf_global.sh
	fi

 	read -p "install cmake? (y/n): " inst_cm
  	if [[ $inst_cm = 'y' ]]; then
 		./scripts/install_cmake_global.sh
 	fi

	sudo rm /usr/bin/python
	sudo ln -s /usr/bin/python3 /usr/bin/python

 	cd $prevpwd
 
	cp workers ~/apps/hostfile
	./write-hosts.sh $(cat headip)
	cat hosts | sudo tee /etc/hosts
	# cat bashrc > /home/cc/.bashrc

	source bashrc

	for ip in $(cat workers); do
 		sudo chmod 0644 /home/cc/TP.pem
		scp /home/cc/TP.pem cc@${ip}:/home/cc/
  		scp hosts cc@${ip}:/home/cc/
	done
 
 	setupdir=/home/cc/apps/setup

	rm -rf $setupdir
 	cp -r setup /home/cc/apps
  
	sudo bash $setupdir/setup-head-node

	sudo systemctl start slurmd
 fi
