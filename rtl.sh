#!/bin/bash
# Main script for integrating RTL kernels with automaton designs
# Original author: Ted Xie (ted.xie@virginia.edu) and Vinh Dang (vqd8a@virginia.edu)
# Collaborating author: Chunkun Bo (cb2yy@virginia.edu) for automata hook
A2H_PATH=$REAPR_HOME/a2h
TOOL_PATH=$REAPR_HOME/pcie_integration/python_tools
SDACCEL_REPO_PATH=/af5/cb2yy/aws-fpga/SDAccel/examples/xilinx

PROJ_PATH=$REAPR_HOME/pcie_integration

#############################################
#Application-specific and FPGA board settings
#############################################

# set this to the path of your desired ANML file (ex. /tmp/something.anml)
ANML=Examples/brill.anml
# set the output VHDL file name
OUTFILE=brill.vhd
# the entity name for the VHDL entity
ENTITY=brill
# logic=LUT-based transitions, xilinx=Xilinx BRAM
TARGET=logic
# how many reporting elements are there?
REPORT_SIZE=2048
# size in MB of the input file
MAX_DATASIZE_MB=10
# number of DDR banks available to your board
DDR_BANKS=4
# which FPGA device
DEVICE_NAME="xcvu9p-flgb2104-2-i"
# target synthesis frequency - may need to manually change based on timing performance w/ vivado
CLK_FREQ_MHZ=250
#IO_TEST: Set to 1 if running I/O kernel only, otherwise set to 0 for automata module hooking
IO_TEST=0

#
set -e

#Generate automata processing RTL module
if [ $IO_TEST = 0 ]; then
    echo "1.Generate automata processing RTL module"
    cd $A2H_PATH
    python a2h.py -a $ANML -o $OUTFILE -e $ENTITY -t $TARGET
    cp OutputFiles/$OUTFILE $PROJ_PATH/vv_prj/hdl
    cp Resources/ste_sim.vhd $PROJ_PATH/vv_prj/hdl
fi

#Generate host application and I/O C kernel
cd $PROJ_PATH
echo "2.Generate host code (C)"
python $TOOL_PATH/host_gen.py $REPORT_SIZE $DDR_BANKS $IO_TEST

echo "3.Generate copy kernel header (C)"
python $TOOL_PATH/copy_kernel_h_gen.py $REPORT_SIZE $MAX_DATASIZE_MB

echo "4.Generate copy kernel (C)"
python $TOOL_PATH/copy_kernel_c_gen.py $REPORT_SIZE $MAX_DATASIZE_MB

#Generate AXI I/O template kernel (RTL)
echo "5.Generate I/O template script"
python $TOOL_PATH/iotemplatescript_gen.py $DEVICE_NAME $CLK_FREQ_MHZ

cd $PROJ_PATH/vhls_prj
echo "6.Generate I/O template kernel (RTL)"
vivado_hls -f test_io/solution1/iotemplate_script.tcl

if [ $IO_TEST = 0 ]; then
    #Hook automata module to the IO kernel
    echo "7.Hook automata module to the IO kernel"
    python $TOOL_PATH/automatahook.py $REPORT_SIZE test_io/solution1/impl/verilog/bandwidth.v $ENTITY > bandwidth.v
    #Update the IO kernel in the vivado project 
    mv test_io/solution1/impl/verilog/bandwidth.v test_io/solution1/impl/verilog/bandwidth.v_ORIG 
    cp bandwidth.v test_io/solution1/impl/verilog/
    cp test_io/solution1/impl/verilog/*.v $PROJ_PATH/vv_prj/hdl
else
    cp test_io/solution1/impl/verilog/*.v $PROJ_PATH/vv_prj/hdl
fi

#Generate kernel description XML file
cd $PROJ_PATH
echo "8.Generate kernel.xml"
python $TOOL_PATH/kernel_xml_gen.py $REPORT_SIZE

#Generate IP generation script
echo "9.Generate package_kernel.tcl"
python $TOOL_PATH/package_kernel_tcl_gen.py $REPORT_SIZE $IO_TEST

#Generate Makefile
echo "10.Generate Makefile"
python $TOOL_PATH/makefile_gen.py $SDACCEL_REPO_PATH $REPORT_SIZE $DDR_BANKS $IO_TEST

#Compile the project using SDAccel (including generating IP and XO files from the RTL kernel)
echo "11.Compile"
cd $PROJ_PATH/rtl_prj
nohup make all TARGETS=hw DEVICES=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0
