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

### 1. Compile on local machine
One can either compile REAPR on local machines or any Amazon instances. We choose to use the local machine so we do not need to pay for the compute hours for comilation.

1.1 Set sdaccel (provided by AWS FPGA tool kit) path in .bash_profile.

Example:
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

Example:
```
SDACCEL_REPO_PATH=/af5/cb2yy/aws-fpga/SDAccel/examples/xilinx
```
* set ANML file path, more ANML files can be found in ANMLZoo https://github.com/jackwadden/ANMLZoo.

Example
```
 ANML=Examples/brill.anml
```
* set output VHDL file name

Example
```
 OUTFILE=brill.vhd
```
* set entity name for the VHDL entity

Example
```
  ENTITY=snort
```
* set report size

Example
```
  REPORT_SIZE=221
```
* set DDRbanks available in the FPGA board

Example
```
  DDR_BANKS=4
```
* set FPGA device name

Example
```
  DEVICE_NAME="xcvu9p-flgb2104-2-i"
```
* set the target synthesis frequency

Example
```
  CLK_FREQ_MHZ=250
```
* change the device in the last statement to compile for the right device
```
  nohup make all TARGETS=hw DEVICES=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0
```

One example of rtl.sh is provided. After modifying the file, users can run the following the command to start compiling. The whole workflow in included in the script and will output all the information in nohup.txt.
```
./rtl.sh
```

This whole process could take hours (depending on the ANML file size) and after it finishes, it will generate several new files and folders. In order to the application on AWS F1, we need the executale (io_globle) and the .xclbin file (\xclbin\bandwidth.hw.xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4_0.xclbin). Upload these two files to your F1 instance.

### 2. Run on F1 instance
2.1 In the F1 instance, download AWS F1 tool kit and set up the environment.
```
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR  
cd $AWS_FPGA_REPO_DIR                                         
source sdaccel_setup.sh
source $XILINX_SDX/settings64.sh 
```
2.2 Create Amazon FPGA Image (AFI)
This sccript is provided to facilitate AFI creation from a Xilinx FPGA Binary. Users need to provide the .xclbin file, which we already upload from local machine in the first step. Users also need to provide the s3 locations to store certain output. The way to setup AWS_CLI and S3_Bucket can be found in https://github.com/aws/aws-fpga/blob/master/SDAccel/docs/Setup_AWS_CLI_and_S3_Bucket.md.

Example:
```
$SDACCEL_DIR/tools/create_sdaccel_afi.sh -xclbin=bandwidth.hw.xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4_0.xclbin -o=bandwidth.hw.xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4_0 -s3_bucket=sda_brill -s3_dcp_key=sda_brill_dcp -s3_logs_key=sda_brill_logs
```
Running this command will generate an AWS FPGA Binary ended with awsxclbin and some text file containing the AFI id. 
2.3 Check availabity of the AFI

The AFI is not created immediatly, so users can use the following command to check the status using the AFI id in the text files.
```
aws ec2 describe-fpga-images --fpga-image-ids <AFI ID>
```
If it outputs information like this, the AFI is ready to be used.
```
                ...
                "State": {
                    "Code": "available"
                },
		...
```


2.4 Run the application
In the folder where you store the AWS FPGA Binary and the executable, run the following command.
```
sudo sh
source /opt/Xilinx/SDx/2017.1.rte/setup.sh 
./executable input_file_name
```
Your application using REAPR now is runnable on AWS F1.



