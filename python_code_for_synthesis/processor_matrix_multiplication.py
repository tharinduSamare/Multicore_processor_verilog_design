import math
import time

from processor_matrix_multiplication_functions import *
baud_rate = 115200

# matrix A - a x b  
# matrix B - b x c
a = int(input("give a: ")) 
b = int(input("give b: "))
c = int(input("give c: "))
core_count = int(input("give number of cores: "))
d = math.ceil(a/core_count)  #(number of raws per one core)

create_random_matrices(a,b,c,core_count)

decoded_code = read_assembly_code()
send_instructions_memory_UART(decoded_code,baud_rate)

time.sleep(1) ## time gap between insMem, dataMem transmission

arrange_and_send_data_memory_to_FPGA(a,b,c,d,core_count,baud_rate)

receive_answer_matrix_from_FPGA(a,b,c,d,core_count,baud_rate)

calculate_answer_matrix_in_PC()

compare_answer_matrix_FPGA_and_PC()


