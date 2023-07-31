# GPU-accelerated guppy basecalling

<br />
<br />
<p align="center">
  <img 
    width="795"
    height="397"
    src="https://github.com/asadprodhan/GPU-accelerated-guppy-basecalling/blob/main/MinION_V3.PNG"
  >
</p>

<p align = "center">
Oxford Nanopore Sequencing
</p>




## **Introduction**


The usage of Graphics Processing Unit (GPU) in high performance computing (HPC) has made a paradigm shift in HPC capabilities. At the heart of this performance is the parallel data processing architecture of the GPUs. In brief, a traditional CPU (Central Processing Unit) executes a task sequentially using its 4-8 cores. Unlike CPUs, a GPU breaks a task into smaller components and executes them in a parallel fashion using its thousands of GPU cores. As such, the GPU-powered compute nodes can take on highly data-intensive workloads and accomplish them in an unprecedented speed. 


The GPU-accelerated guppy basecalling is such an example of GPU applications in data-intensive computing. The Oxford Nanopore Technologies (ONT) sequencing platforms generate electronic signals as the raw sequencing data. These signals are converted to the actual DNA/RNA sequences through a process called ‘basecalling’. And guppy is a widely used basecalling algorithm for the ONT sequencing data. However, guppy takes days to complete this basecalling process when it runs on CPU-only computers. On the other hand, GPU-accelerated guppy can accomplish the similar task in hours. 



## **Advantages**


- The GPU-accelerated guppy basecalling enables faster access to the results. This is crucial when the ONT sequencing platforms are used as a disease diagnostic or outbreak surveillance tool requiring quick decision-making.

- Re-basecalling of the previous sequencing data is made easy with GPU- accelerated guppy basecalling
 


## **Requirements**


This tutorial has been written for Ubuntu 18.04 Operating System on Linux.


- NVIDIA GPU device. GPU-accelerated guppy is built around the NVIDIA GPU device. Therefore, your computer must have one or more NVIDIA GPUs


- NVIDIA GPU device driver. Install the NVIDIA GPU device driver. This also automatically installs 'nvidia-smi’, a utility tool to monitor the GPU device performance. ‘smi’ stands for ‘system management interface’


- CUDA (Compute Unified Device Architecture). You must have ‘CUDA’ installed. CUDA is a programming language. It has been used to write the NVIDIA GPU kernel (set of instructions) as well as the codes of the GPU-capable application that will be run on the NVIDIA GPU devices. Therefore, CUDA acts as a bridge between the application (GPU-enabled guppy in this case) and the NVIDIA GPU devices. CUDA issues and manages workloads on the NVIDIA GPU devices. In other words, it orchestrates the parallel computing in the NVIDIA GPUs. Furthermore, CUDA can also be used in other languages such as C, C++, Fortran, Python and MATLAB to develop softwares featuring parallel computing


- GPU-enabled guppy basecaller. 
  - Download the GPU-enabled guppy software from Nanopore community (https://community.nanoporetech.com/downloads)
  - Or, use ‘wget’. For example: ‘ont-guppy_6.0.1_linux64.tar.gz’ for Linux can be downloaded as ‘wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_6.0.1_linux64.tar.gz’
  - Then, tar -zvxf ont-guppy_6.0.1_linux64.tar.gz
  - cd ont-guppy/bin
  - run ./guppy_basecaller -v 
  - If the software is installed successfully, then it will display something like as follows: Guppy Basecalling Software, (C) Oxford Nanopore Technologies, Limited. Version 6.0.1+652ffd1



## **Adding guppy to PATH variable so that it can be run in the terminal without specifying a path**


- Again, cd to ont-guppy/bin

- Then, mv guppy* /bin

- ‘/bin’ is the directory where ‘cat’ ‘sed’ ‘chmod’ etc commands are sitting. Any command sitting in this path, can be executed in the terminal without specifying a path before the command. This is because ‘/bin’ path is included in the PATH variable. To see, echo $PATH



## **GPU-accelerated guppy basecalling script**

 
To optimise the script for an efficient basecalling, some details are needed. For example:


> How many GPUs are there in my Linux computer?

```
sudo lshw -C display
```


> What is the name of my NVIDIA GPU device?


```
nvidia-smi --query-gpu=name --format=csv,noheader
```


> What is the RAM size in my Linux computer?


```
grep MemTotal /proc/meminfo
```


> How many CPUs are there in my Linux computer?


```
lscpu
```


### **The bascalling script**


```
#!/usr/bin/env bash
guppy_basecaller --disable_pings 
  -i /path_to_fast5_directory 
  -s /path_to_ouput_directory 
  -c dna_r9.4.1_450bps_fast.cfg 
  --min_qscore 7 
  --recursive -x 'cuda:0' 
  --num_callers 4 
  --gpu_runners_per_device 8 
  --chunks_per_runner 1024 
  --chunk_size 1000 
  --compress_fastq 
```


* --disable_pings = disable the transmission of telemetry pings. By default, MinKNOW automatically send experiment performance data to Nanopore. 
* -i = path to the fast5 directory
* -s = path to the output (fastq) directory
* -c dna_r9.4.1_450bps_fast.cfg. The '-c' flag assigns the basecalling model. The suitable model for a given library preparation kit can be found using the following command. For example, if the library preparation kit is SQK-LSK110, then 

```
guppy_basecaller --print_workflows | grep SQK-LSK110
```

> **You can also assign the basecalling accuracy level- fast, hac (high accuracy) or sup (supper accuracy)- in the model**

 
* --min_qscore = sets a minimum qscore threshold for the reads to pass  
* --recursive = searches for input files recursively.
* --records_per_fastq = maximum number of records per fastq file, 0 means use a single file
* --flowcell = flow cell name
* --kit = kit name
* -x = name of the parallel computing platform in your gpu device, which is ‘cuda’. Every GPU has an ID starting from zero (0). So, ‘cuda:0’ indicates the cuda-enabled GPU with a physical id ‘0’. The ID can be found using the ‘sudo lshw -C display’ command. If you have more than one cuda GPUs in your computer, then all GPUs can be deployed in GPU-accelerated guppy basecalling by using ‘cuda:all’ option. 
* --compress_fastq = fastq files will be compressed
* --num_callers = number of parallel basecallers to create 
* --gpu_runners_per_device = number of neural network runners to create per CUDA device. Neural network is an algorithm used by guppy to interpret the electric signal data from the nanopore. Increasing this number may improve performance on GPUs with a large number of compute cores but will increase GPU memory use.
* --chunks_per_runner = maximum chunks per runner 
* --chunk_size = stride intervals per chunk	
	
> **All other flags can be found by running ‘guppy_basecaller --help’ command**



### **Basecalling progress**


Once the basecalling starts, it will display a progress status bar till the completion:



<p align="center">
  <img 
    width="799"
    height="193"
    src="https://github.com/asadprodhan/GPU-accelerated-guppy-basecalling/blob/main/guppy_progress_status.png"
  >
</p>

<p align = "center">
Basecalling status
</p>



## **How to find whether my GPU is running in full capacity?**


You can monitor the utilisation efficiency of your GPU device/s as follows:

```
watch -d -n 0.5 nvidia-smi
```


- -d, highlights the changing parameters
- -n, interval period in second


> more details by running ‘man watch’ command in the terminal


An explanation of the ‘nvidia-smi’ command output can be found here (Kaul, 2022). 


--num_callers, --gpu_runners_per_device, --chunks_per_runner and --chunk_size parameters can be optimised based on the GPU device capacity (Benton, 2021)



## **GPU-accelerated guppy demultiplexing**


Demultiplexing using guppy_barcoder 	



### **The demultiplexing script**


```
guppy_barcoder --disable_pings 
  -i /path_to_fast5_directory 
  -s /path_to_ouput_directory 
  --barcode_kits EXP-PBC001 
  -x 'cuda:0' --trim_barcodes 
  --trim_adapters 
  --recursive 
  --compress_fastq
  ```
  
  
 > **All other flags with descriptions can be found by running the ‘guppy_barcoder --help’ command**



### **List supported barcoding kits**



```
guppy_barcoder --print_kits
```


### **Potential errors**



> error while loading shared libraries: libcuda.so.1: cannot open shared object file


See the suggestions below from the Nanopore community:


https://help.nanoporetech.com/en/articles/6627829-what-does-the-error-while-loading-shared-libraries-libcuda-so-1-cannot-open-shared-object-file-message-mean-when-running-the



Nanopore guidelines for installing Guppy:



https://community.nanoporetech.com/docs/prepare/library_prep_protocols/Guppy-protocol/v/gpb_2003_v1_revaw_14dec2018/linux-guppy



### **References**



Benton, M., 2021. Nanopore Guppy GPU basecalling on Windows using WSL2. URL https://hackmd.io/PrSp6UhqS2qxZ_rKOR18-g#Nanopore-Guppy-GPU-basecalling-on-Windows-using-WSL2 (accessed 3.8.22).
Kaul, S., 2022. Explained Output of nvidia-smi Utility. URL https://medium.com/analytics-vidhya/explained-output-of-nvidia-smi-utility-fc4fbee3b124 (accessed 3.8.22).


