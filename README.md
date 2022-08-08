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

The current measurements were collected with Renaissance `dde0f7af00738e640ae0acf68ab66decc8249e15` on multiple
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

- **OpenJDK** is the GraalVM Community Edition JVM implementation run with `-XX:-EnableJVMCI -XX:-UseJVMCICompiler` to force the use of the default OpenJDK JIT compiler.

- **GraalVM CE** is GraalVM Community Edition 22.2.0.
```
> java -version
openjdk version "11.0.16" 2022-07-19
OpenJDK Runtime Environment GraalVM CE 22.2.0 (build 11.0.16+8-jvmci-22.2-b06)
OpenJDK 64-Bit Server VM GraalVM CE 22.2.0 (build 11.0.16+8-jvmci-22.2-b06, mixed mode, sharing)
```
```
> java -version
openjdk version "17.0.4" 2022-07-19
OpenJDK Runtime Environment GraalVM CE 22.2.0 (build 17.0.4+8-jvmci-22.2-b06)
OpenJDK 64-Bit Server VM GraalVM CE 22.2.0 (build 17.0.4+8-jvmci-22.2-b06, mixed mode, sharing)
```

- **GraalVM EE** is GraalVM Enterprise Edition 22.2.0.
```
> java -version
java version "11.0.16" 2022-07-19 LTS
Java(TM) SE Runtime Environment GraalVM EE 22.2.0 (build 11.0.16+11-LTS-jvmci-22.2-b05)
Java HotSpot(TM) 64-Bit Server VM GraalVM EE 22.2.0 (build 11.0.16+11-LTS-jvmci-22.2-b05, mixed mode, sharing)
```
```
> java -version
java version "17.0.4" 2022-07-19 LTS
Java(TM) SE Runtime Environment GraalVM EE 22.2.0 (build 17.0.4+11-LTS-jvmci-22.2-b05)
Java HotSpot(TM) 64-Bit Server VM GraalVM EE 22.2.0 (build 17.0.4+11-LTS-jvmci-22.2-b05, mixed mode, sharing)
```

#### Mean Repetition Times

The figure shows the mean repetition time for each benchmark, computed as the average duration of all warm repetitions.
The error bars show 99% confidence intervals for the mean computed using bootstrap.

<p align="center"><img src="https://github.com/renaissance-benchmarks/measurements/raw/master/mean-bar-jdk-11-time.png"/></p>
<p align="center"><img src="https://github.com/renaissance-benchmarks/measurements/raw/master/mean-bar-jdk-17-time.png"/></p>

#### Individual Repetition Times

The figure shows the individual repetition times for each benchmark in a violin plot.
The violin shape is the widest at the height of the most frequent repetition times,
the box inside the shape stretches from the low to the high quartile,
with a mark at the median.
Floating window outlier filtering was used to discard no more than 10% of most extreme observations, to preserve plot scale.

<p align="center"><img src="https://github.com/renaissance-benchmarks/measurements/raw/master/samples-violin-jdk-11-time-warm-inliers.png"/></p>
<p align="center"><img src="https://github.com/renaissance-benchmarks/measurements/raw/master/samples-violin-jdk-17-time-warm-inliers.png"/></p>
