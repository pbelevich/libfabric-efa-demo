#!/bin/bash

#SBATCH --job-name=fi_rma_bw
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1

# set -x

export MASTER_IP=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n 1)

# mpirun -N 1 bash -c 'echo $(hostname): $(cat /sys/devices/virtual/dmi/id/board_asset_tag | tr -d " ")'

srun -l \
  --container-image ./libfabric.sqsh \
  bash -lc '
    /workspace/build/libfabric/bin/fi_info --verbose

    if [ "$SLURM_PROCID" -eq 1 ]; then
      sleep 1;
      EXTRA_FLAGS="$MASTER_IP"
    fi

    exec /workspace/build/fabtests/bin/fi_rma_bw -p efa -o write -E -D cuda -S l:1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824 $EXTRA_FLAGS
  '
