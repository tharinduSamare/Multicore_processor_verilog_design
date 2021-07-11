## Generated SDC file "matrix_multiply.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Wed Jul 07 10:03:40 2021"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  3.000 [get_ports {KEY[0]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {KEY[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  3.000 [get_ports {KEY[1]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {KEY[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  3.000 [get_ports {UART_RXD}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {UART_RXD}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX0[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX0[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX1[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX1[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX2[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX2[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX3[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX3[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX4[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX4[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX5[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX5[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX6[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX6[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[2]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[3]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[4]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[5]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {HEX7[6]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {HEX7[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {LEDG[0]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {LEDG[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {LEDG[1]}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {LEDG[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {UART_TXD}]
set_output_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  1.000 [get_ports {UART_TXD}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

