# REARP on Amazon EC2 F1
## REAPR
REAPR is short for Reconfigurable Engin for Automata Processing, a flexible a flexible framework that synthesizes RTL for automata processing applications as well as I/O to handle data transfer to and from the kernel.
The original version of REAPR can be found in https://github.com/ted-xie/REAPR.
In this project, we automata the original workflow of the original REAPR and port the work to Amazon EC2 F1 instances.

## Amazon EC2 F1
Amazon EC2 F1 is the first EC2 compute instance with FPGAs. There are two types of F1 instances: f1.2xlarge and f1.16xlarge. In this project, we use the smaller one.
More details about F1 instances can be found in https://aws.amazon.com/ec2/instance-types/f1/.

##Requirements
1. Download original REAPR from https://github.com/ted-xie/REAPR
2. Download AWS FPGA tool kit from https://github.com/aws/aws-fpga
3. Prerequisites for REARR: 
* python3.6+
* virtualenv
* pip

Since AWS FPGA tool kit includes Xilinx Vivado HLS and Xilinx SDAccel, users do not need to pre-install these tools as required by the original REAPR. No licenses are needed.


