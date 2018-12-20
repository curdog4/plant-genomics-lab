#!/bin/bash

[ -z $VIRTUAL_ENV ] && source /data/gpfs/assoc/pgl/dcurdie/repet-test/.env/bin/activate

##
# MySQL DB stuff
REPET_HOST=134.197.50.140
REPET_USER=root
REPET_PW=root
REPET_DB=test_dc1
REPET_PORT=3306
REPET_JOBS=MySQL

##
# Scheduler / Job manager
REPET_JOB_MANAGER=SLURM
REPET_QUEUE=SLURM

##
# OS / Python paths...
REPET_PATH=/data/gpfs/home/dcurdie/scratch/repet-2.5/REPET_linux-x64-2.5
PYTHONPATH=$REPET_PATH
##
# May also need other paths
PATH=$REPET_PATH/bin:/data/gpfs/home/dcurdie/scratch/recon-1.08/RECON-1.08/bin:/data/gpfs/home/dcurdie/scratch/recon-1.08/RECON-1.08/scripts:/data/gpfs/home/dcurdie/scratch/RepeatMasker-open-4.0.8/RepeatMasker:/data/gpfs/assoc/pgl/bin/REPET/squid-1.9g:/data/gpfs/assoc/pgl/bin/REPET/mcl-14-137/bin:/data/gpfs/assoc/pgl/bin/REPET/mcl-14-137/scripts:/data/gpfs/home/dcurdie/scratch/RepeatMasker-open-4.0.8/RepeatMasker/util:/data/gpfs/home/dcurdie/scratch/hmmer-3.2.1/bin:/data/gpfs/home/dcurdie/scratch/genometools-1.5.10/gt-1.5.10-Linux_x86_64-64bit-complete/bin:/data/gpfs/home/dcurdie/scratch/blast2-2.2.26-20120620-10-amd64/bin:/data/gpfs/home/dcurdie/scratch/blast+-2.7.1/ncbi-blast-2.7.1+/bin:/data/gpfs/home/dcurdie/scratch/PILER:/data/gpfs/home/dcurdie/scratch/TRF-4.09:$PATH
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/gpfs/home/dcurdie/scratch/blast2-2.2.26-20120620-10-amd64/lib/x86_64-linux-gnu:/data/gpfs/home/dcurdie/scratch/cppunit-1.12.1/lib

export REPET_HOST REPET_USER REPET_PW REPET_DB REPET_PORT REPET_JOBS REPET_JOB_MANAGER REPET_QUEUE REPET_PATH PYTHONPATH PATH LD_LIBRARY_PATH
