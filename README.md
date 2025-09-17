# My experiments with libfabric

Based on https://github.com/abcdabcd987/libfabric-efa-demo

Build the container image:
```bash
docker build -f libfabric.Dockerfile -t libfabric .
```

Convert the container image to an enroot image:
```bash
enroot import -o ./libfabric.sqsh dockerd://libfabric:latest
```

Run fi_info to check the EFA configuration:
```bash
srun --container-image ./libfabric.sqsh libfabric/bin/fi_info -p efa
```

Run the fi_rma_bw test:
```bash
sbatch fi_rma_bw.sbatch
```
