#!/bin/bash

cd ~
tar -c -I pigz -f apps.tar.gz apps
tar -c -I pigz -f intel.tar.gz intel
tar -c -I pigz -f cime.tar.gz .cime
