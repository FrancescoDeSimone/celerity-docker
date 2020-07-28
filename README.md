# Celerity

The Celerity distributed runtime and API aims to bring the power and ease of use of SYCL to distributed memory clusters.

Unofficial dockerfile to try out celerity.

# BUILD

```docker build -f Dockerfile.cpu -t celerity . ```

For CPU backend


```docker build -f Dockerfile.cuda -E HIPSYCL_GPU_ARCH=arch -t celerity . ```

For Cuda backend (set the correct gpu architecture)


# RUN

```docker run -it celerity bash ```

Preinstalled you can find vim with some cpp plugin (install with :PluginInstall) and celerity-bench for testing 

# PREBUILD CPU

``` docker run -it fradesi/celerity:cpu-latest bash```


