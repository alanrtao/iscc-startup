#!/bin/bash

# PREREQS:
# We need gcc & openmpi-gcc as modules
# and cmake 3.18.4

module purge
ml gcc
ml openmpi-gcc

wget https://ftp.gromacs.org/gromacs/gromacs-2023.1.tar.gz

cmake .. -DGMX_MPI=ON -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DMPI_C_COMPILER=mpicc -DMPI_CXX_COMPILER=mpicxx -DGMX_BUILD_OWN_FFTW=ON  -DGMX_GPU=OFF -DGMX_SIMD=AVX_512 -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=/home/cc/apps/gromacs


make -j24
make -j24 check
make install

source /home/cc/apps/gromacs/bin/GMXRC
