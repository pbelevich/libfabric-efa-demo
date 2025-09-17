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
srun --container-image ./libfabric.sqsh build/libfabric/bin/fi_info -p efa
```

Run the fi_rma_bw test:
```bash
sbatch fi_rma_bw.sbatch
```

Build 4_hello:
```bash
srun --container-image ./libfabric.sqsh --container-mounts ./src:/workspace/src,./out:/workspace/out \
    g++ -Wall -Werror -std=c++17 -O2 -g \
        -I./build/libfabric/include \
        -o out/4_hello src/4_hello.cpp \
        -L./build/libfabric/lib -lfabric
```

Run 4_hello:
```bash
srun --container-image ./libfabric.sqsh --container-mounts ./src:/workspace/src,./out:/workspace/out out/4_hello
```

Sample output:
```
domain:  rdmap85s0-rdm, nic:  rdmap85s0, fabric: efa, link: 200Gbps
domain:  rdmap86s0-rdm, nic:  rdmap86s0, fabric: efa, link: 200Gbps
domain:  rdmap87s0-rdm, nic:  rdmap87s0, fabric: efa, link: 200Gbps
domain:  rdmap88s0-rdm, nic:  rdmap88s0, fabric: efa, link: 200Gbps
domain: rdmap110s0-rdm, nic: rdmap110s0, fabric: efa, link: 200Gbps
domain: rdmap111s0-rdm, nic: rdmap111s0, fabric: efa, link: 200Gbps
domain: rdmap112s0-rdm, nic: rdmap112s0, fabric: efa, link: 200Gbps
domain: rdmap113s0-rdm, nic: rdmap113s0, fabric: efa, link: 200Gbps
domain: rdmap135s0-rdm, nic: rdmap135s0, fabric: efa, link: 200Gbps
domain: rdmap136s0-rdm, nic: rdmap136s0, fabric: efa, link: 200Gbps
domain: rdmap137s0-rdm, nic: rdmap137s0, fabric: efa, link: 200Gbps
domain: rdmap138s0-rdm, nic: rdmap138s0, fabric: efa, link: 200Gbps
domain: rdmap160s0-rdm, nic: rdmap160s0, fabric: efa, link: 200Gbps
domain: rdmap161s0-rdm, nic: rdmap161s0, fabric: efa, link: 200Gbps
domain: rdmap162s0-rdm, nic: rdmap162s0, fabric: efa, link: 200Gbps
domain: rdmap163s0-rdm, nic: rdmap163s0, fabric: efa, link: 200Gbps
```
