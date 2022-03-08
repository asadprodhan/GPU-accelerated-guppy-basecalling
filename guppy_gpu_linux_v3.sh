#!/usr/bin/env bash
guppy_basecaller --disable_pings -i /media/Disk/nanobacto20220211/fast5 -s /media/Disk/nanobacto20220211/basecalls -c dna_r9.4.1_450bps_fast.cfg --qscore_filtering --min_score 7 --recursive -x 'cuda:0' --num_callers 4 --gpu_runners_per_device 8 --chunks_per_runner 1024 --chunk_size 1000 --compress_fastq

