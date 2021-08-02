# Multicore_processor_matrix_multiply_Verilog_design
* This is a multi-core processor design for FPGA designed using Verilog language.
* In this design
  * Most of the important variables are parameterized. (Ex:- core-count of the multi-core processor, UART baudrate)
  * Every core can access only the part of the memory allocated to it.
  * Communication between laptop and FPGA happens using UART protocol.
* This is specially designed for matrix multiplication 
  * With current configurations, using single core upto 36x36 matrices can be multiplied.
* Top module (toFpga.v) is designed for DE-115 Altera FPGA board. (To use for a different board, use appropriate input/outputs names in the top module)
* Simulation codes are given for most of the modules. (except for the time count display module, UART system related modules) 
* ModelSim or QuestaSim can be used for simulations.

##Synthesis procedure
1. Set the "CORE_COUNT" in the [toFpga.v](https://github.com/tharinduSamare/Multicore_processor_Matrix_multiply_verilog_design/blob/main/toFpga.v)
2. Compile and upload to the DE2-115 board.
3. Connect the RS-232 cable to the DE2-115. Make sure the "COM PORT" name is correct in [processor_matrix_multiplication_functions.py](https://github.com/tharinduSamare/Multicore_processor_Matrix_multiply_verilog_design/blob/main/python_code_for_synthesis/processor_matrix_multiplication_functions.py)
4. Go to the "UART_INS" state by "KEY[1] push button. 
5. Run the [processor_matrix_multiplication.py]
6. Set the matrix dimensions and number of cores in the multi-core processor. 
7. Wait few seconds for the data transmission and matrix multiplication.
8. Clock counts for the multiplication is visible on the seven-segment display in decemal. 
9. Answer is verified within the laptop using a python function. (If there is an error it will be shown in the terminal.)
10. All the data are saved in text files in the [python_code_for_synthesis](https://github.com/tharinduSamare/Multicore_processor_Matrix_multiply_verilog_design/tree/main/python_code_for_synthesis) folder.

##Simulation procedure
1. 

[Demonstration of the design](https://youtu.be/A8b6QhjnlR8)
