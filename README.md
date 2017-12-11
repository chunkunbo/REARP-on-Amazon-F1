# REARP on Amazon EC2 F1
## REAPR
REAPR is short for Reconfigurable Engin for Automata Processing, a flexible a flexible framework that synthesizes RTL for automata processing applications as well as I/O to handle data transfer to and from the kernel.
The original version of REAPR can be found in https://github.com/ted-xie/REAPR.
In this project, we automata the original workflow of the original REAPR and port the work to Amazon EC2 F1 instances.

## Amazon EC2 F1
Amazon EC2 F1 is the first EC2 compute instance with FPGAs. There are two types of F1 instances: f1.2xlarge and f1.16xlarge. In this project, we use the smaller one.
More details about F1 instances can be found in https://aws.amazon.com/ec2/instance-types/f1/.

## Requirements
1. Download original REAPR from https://github.com/ted-xie/REAPR
2. Download AWS FPGA tool kit from https://github.com/aws/aws-fpga
3. Prerequisites for REARR: 
* python3.6+
* virtualenv
* pip

Since AWS FPGA tool kit includes Xilinx Vivado HLS and Xilinx SDAccel, users do not need to pre-install these tools as required by the original REAPR. No licenses are needed.

## Usage
1. Compile on local machine
One can either compile REAPR on local machines or any Amazon instances. We choose to use the local machine so we do not need to pay for the compute hours for comilation.
1.1 Set sdaccel (provided by AWS FPGA tool kit) path in .bash_profile.
#### Example
Add the the following statement to .bash_profile.
```
source /localtmp/AWS_F1_Xilinx/SDx/2017.1.op/settings64.sh
```
1.2 Compile REAPR
1.2.1 In the original REAPR folder, run the following command to setup environment variables.
```
source source_me.sh
```
1.2.2 Under pcie_integration/rtl_prj/ folder, find the rtl.sh and modify the file.
Major changes:
* set SDACCEL_REPO_PATH to where you actrually store aws-fpga SDAccel
#### Example
```
SDACCEL_REPO_PATH=/af5/cb2yy/aws-fpga/SDAccel/examples/xilinx
```



