# Multicore_processor_Matrix_multiply_verilog_design

* This is a multi-core processor design for FPGA
* A parameterized verilog design
* Mainly designed for DE-115 Altera FPGA board.
* Simulation codes are given for codes except for the codes used for UART system and show clock count on the HEX display on the FPGA board. 
* Questa-sim (and probably modelsim) can be used for simulations.
* This is specially designed for matrix multiplication
* In this design
  * Core-count can be changed as wished
  * Every core can access only the part of the memory allocated to it.
  * Communication happens by UART between PC and FPGA.
