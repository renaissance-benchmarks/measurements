## Renaissance Benchmark Suite

<p align="center"><img height="180px" src="https://github.com/renaissance-benchmarks/renaissance/raw/master/website/resources/images/mona-lisa-round.png"/></p>

The Renaissance Benchmark Suite is an open source collaborative benchmark project where the community can propose and improve benchmark workloads.
This repository serves to track and process measurement results for the suite.
Included here are the performance measurement summaries, for full data see the
[Renaissance Benchmark Results Repository](https://zenodo.org/communities/renaissance).

Please note that performance measurements depend on many complex factors and therefore YMMV.
**The results given here serve only as examples, you should always collect your own measurements.**
(But do let us know if your results are significantly different from the results given here so that we can look.)

### Measurement information

The current measurements were collected with Renaissance 0.15.0 `87358d94a06920c1f66e08dca3869bf96004d115` on multiple
8 core Intel Xeon E5-2620 v4 machines at 2100 GHz with 64 GB RAM,
running bare metal Fedora Linux 35 with kernel 5.16.11.

Each benchmark was run multiple times, each run was executed in a new JVM instance and terminated after 10 minutes.
The durations of all repetitions were collected and are included in the data,
but only the second half of each run is used in the plots as warm data.

As a shared setting, the JVM implementations were executed with the `-Xms12G -Xmx12G` command line options,
which serve to fix the heap size and reduce variability due to heap sizing.
Except as noted below, other settings were left at default values.

### Measurement results

The JVM implementations referenced in the results are:

- **OpenJDK** is the GraalVM Community JVM implementation run with `-XX:-EnableJVMCI -XX:-UseJVMCICompiler` to force the use of the default OpenJDK JIT compiler.

- **GraalVM Community** is the GraalVM Community JVM implementation.
```
> java -version
openjdk version "17.0.9" 2023-10-17
OpenJDK Runtime Environment GraalVM CE 17.0.9+9.1 (build 17.0.9+9-jvmci-23.0-b22)
OpenJDK 64-Bit Server VM GraalVM CE 17.0.9+9.1 (build 17.0.9+9-jvmci-23.0-b22, mixed mode, sharing)
```
```
> java -version
openjdk version "21.0.1" 2023-10-17
OpenJDK Runtime Environment GraalVM CE 21.0.1+12.1 (build 21.0.1+12-jvmci-23.1-b19)
OpenJDK 64-Bit Server VM GraalVM CE 21.0.1+12.1 (build 21.0.1+12-jvmci-23.1-b19, mixed mode, sharing)
```

- **Oracle GraalVM EE** is the Oracle GraalVM JVM implementation.
```
> java -version
java version "17.0.9" 2023-10-17 LTS
Java(TM) SE Runtime Environment Oracle GraalVM 17.0.9+11.1 (build 17.0.9+11-LTS-jvmci-23.0-b21)
Java HotSpot(TM) 64-Bit Server VM Oracle GraalVM 17.0.9+11.1 (build 17.0.9+11-LTS-jvmci-23.0-b21, mixed mode, sharing)
```
```
> java -version
java version "21.0.1" 2023-10-17
Java(TM) SE Runtime Environment Oracle GraalVM 21.0.1+12.1 (build 21.0.1+12-jvmci-23.1-b19)
Java HotSpot(TM) 64-Bit Server VM Oracle GraalVM 21.0.1+12.1 (build 21.0.1+12-jvmci-23.1-b19, mixed mode, sharing)
```

#### Individual Repetition Times

The figures show the individual repetition times for each benchmark in a violin plot.
The violin shape is the widest at the height of the most frequent repetition times,
the box inside the shape stretches from the low to the high quartile,
with a mark at the median.
Floating window outlier filtering was used to discard no more than 10% of most extreme observations, to preserve plot scale.

<p align="center"><img src="https://github.com/renaissance-benchmarks/measurements/raw/master/violin-jdk-17.png"/></p>
<p align="center"><img src="https://github.com/renaissance-benchmarks/measurements/raw/master/violin-jdk-21.png"/></p>

To generate the figures from the data, use the `download.sh` script to get the data from the
[Renaissance Benchmark Results Repository](https://zenodo.org/communities/renaissance)
and then run the `plot_website_stripes` and `plot_website_violins` functions from the
[rren](https://github.com/renaissance-benchmarks/utilities-r) package
in the corresponding directory.
