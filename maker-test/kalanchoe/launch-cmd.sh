#!/bin/bash

srun --job-name=$(dd if=/dev/urandom bs=6 count=1 status=none | base64) --cpus-per-task=1 -t 8-00:00:00 --mincpus=1 --mem-per-cpu=3000M --ntasks=64 -o maker-stdout.log -e maker-stderr.log --mpi=pmi2 /data/gpfs/home/dcurdie/scratch/maker-2.31.10/maker/bin/maker -genome /data/gpfs/assoc/pgl/dcurdie/falcon-test/FALCON-examples/run/kalanchoe/4-quiver/cns_output/cns_h_ctg.fasta -base cccc -fix_nucleotides
