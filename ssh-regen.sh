#!/bin/bash

sudo systemctl stop sshd

rm /etc/ssh/ssh_host_*
ssh-keygen -f /etc/ssh/ssh_host_rsa_key     -N '' -q -t rsa
ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key   -N '' -q -t ecdsa
ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -q -t ed25519

sshd -t
systemctl restart sshd
