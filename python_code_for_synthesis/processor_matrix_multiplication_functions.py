import random
import serial
import math
import struct
import time

def create_random_matrices(a,b,c,core_count):
    writeFile  = open('1_matrix_in.txt','w')

    writeFile.write(str(a)+"\n"+str(b)+"\n"+str(c)+"\n"+str(core_count)+" //number of cores"+"\n")

    writeFile.write("\n//matrix A\n")
    out = ""
    for x in range(a):
        temp = ""
        for y in range (b):
            temp+=(str(random.randint(-5,5))+" ")
        out+=(temp+"\n")

    print (out)
    writeFile.write(out)

    writeFile.write("\n//matrix B\n")

    out = ""
    for x in range(b):
        temp = ""
        for y in range (c):
            temp+=(str(random.randint(-5,5))+" ")
        out+=(temp+"\n")

    print (out)
    writeFile.write(out)
    writeFile.close()

    return


def decode(instruction):
    isa = {
        'NOP': '00000000',
        'ENDOP': '00000001',
        'CLAC': '00000010',
        'LDIAC': '00000011',
        'LDAC': '00000100',
        'STR': '00000101',
        'STIR': '00000110',
        'JUMP': '00000111',
        'JMPNZ': '00001000',
        'JMPZ': '00001001',
        'MUL': '00001010',
        'ADD': '00001011',
        'SUB': '00001100',
        'INCAC': '00001101',
        'MV_RL_AC': '00011111',
        'MV_RP_AC': '00101111',
        'MV_RQ_AC': '00111111',
        'MV_RC_AC': '01001111',
        'MV_R_AC': '01011111',
        'MV_R1_AC': '01101111',
        'MV_AC_RP': '01111111',
        'MV_AC_RQ': '10001111',
        'MV_AC_RL': '10011111',
    }
    if instruction in isa:
        return isa[instruction]
    else:
        return instruction


def read_assembly_code():

    code = open('2_assembly_code.txt','r')
    txt_code = code.read().strip().split('\n')

    decoded_code = []
    i = 0
    while(i<len(txt_code)):
        if txt_code[i][0]=='/':
            i+=1
            continue
        codewithoutcomments = ''
        for j in txt_code[i]:
            if j!='/':
                codewithoutcomments+=j
            else:
                break
        assert codewithoutcomments[-1]==';','Error! missing ; at the end of the line'
        temp = codewithoutcomments[:-1]
        decoded_int = decode(temp)
        if(temp=='LDIAC'or temp=='STIR' or temp=='JMPNZ' or temp=='JUMP' or temp == 'JMPZ'):
            decoded_code.append(decoded_int)
            address = txt_code[i+1]
            addresswithoutcomments = ''
            for j in address:
                if j!='/':
                    addresswithoutcomments+=j
                else:
                    break
            assert addresswithoutcomments[-1]==';','Error! missing ; at the end of the line'
            decoded_code.append('{0:08b}'.format(int(addresswithoutcomments[:-1])))
            i+=1
        else:
            decoded_code.append(decoded_int)
        i+=1

    return decoded_code

def send_instructions_memory_UART(decoded_code,baud_rate):
    uart_list = []
    for i in range(255,-1,-1):
        if (i<len(decoded_code)):
            value = (128)*int(decoded_code[i][0]) + (64)*int(decoded_code[i][1]) + (32)*int(decoded_code[i][2]) + (16)*int(decoded_code[i][3]) + (8)*int(decoded_code[i][4]) + (4)*int(decoded_code[i][5]) + (2)*int(decoded_code[i][6]) + (1)*int(decoded_code[i][7])
            uart_list.append(value)
        else:
            uart_list.append(0)

    ser = serial.Serial('COM3',baud_rate,bytesize=8)

    ser.write(uart_list[::-1])
    ser.close()


def arrange_and_send_data_memory_to_FPGA(a,b,c,d,core_count,baud_rate):
    data = open('1_matrix_in.txt','r')
    txt_code = data.read().strip().split('\n')

    out = b''

    memWordLength = core_count*12
    byte_count = math.ceil(memWordLength/8)
    full_length = 8*byte_count
    extra_length = full_length - memWordLength

    start_addr_P = 14
    start_addr_Q = start_addr_P + d*b
    start_addr_R = start_addr_Q + b*c + 1 #with extra space
    end_addr_P = start_addr_P + d*b -1
    end_addr_Q = start_addr_Q + b*c -1
    end_addr_R = start_addr_R + d*c - 1

    setup_values = [a, b, c, start_addr_P, start_addr_Q, start_addr_R, end_addr_P, end_addr_Q, end_addr_R, 0, 0, 0, 0, 0]

    memLength = 4096
    filled_memLength = len(setup_values) + (a//core_count + (a % core_count != 0))*b + b*c
    empty_memLength = memLength-filled_memLength

    ############################## to send setup values ############################

    for i in setup_values:
        # print(i)
        temp = '{0:012b}'.format(i)*core_count
        temp = extra_length*'0' + temp
        for x in range(byte_count,0,-1):
            temp2 = int (("0b" + temp[(x-1)*8:x*8]), 2)
            out += struct.pack('!B', temp2)
            

    ############################## to send matrix A values

    i = 4
    while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix A
        i = i+1

    A = []
    for x in range (i,i+a):
        temp2 = []
        temp = txt_code[x].strip().split(" ")
        for j in temp:
            if (int(j)>=0):
                temp2.append('{0:012b}'.format(int(j)))
            else:
                temp2.append(bin((int('1'*12,2)^abs(int(j)))+1)[2:]) ## 2's complement
        A.append(temp2)

    if len(A)%core_count!=0:
        for k in range(core_count-len(A)%core_count):
            temp = ['{0:012b}'.format(int(0)) for i in range(len(A[0]))]
            A.append(temp)

    for x in range(0,len(A),core_count):
        for y in range(len(A[0])):
            temporary_bin = ''
            for k in range(core_count):
                temporary_bin+=A[x+k][y]

            temporary_bin = extra_length*'0' + temporary_bin
            for j in range(byte_count,0,-1):
                temp2 = int (("0b" + temporary_bin[(j-1)*8:j*8]), 2)
                out += struct.pack('!B', temp2)

    ############ to send matrix B values ##########

    i = i + a
    while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix B
        i = i+1

    matrix_B = []
    for x in range (i,i+b):
        temp = txt_code[x].strip().split(" ")
        matrix_B.append(temp)

    for y in range(c):
        for x in range(b):
            temporary_bin = ''
            for k in range(core_count):
                if (int(matrix_B[x][y]) < 0):
                    temporary_bin+= bin((int('1'*12,2)^abs(int(matrix_B[x][y])))+1)[2:] ## 2's complement
                else:
                    temporary_bin+='{0:012b}'.format(int(matrix_B[x][y]))
                
            temporary_bin = extra_length*'0' + temporary_bin
            for j in range(byte_count,0,-1):
                temp2 = int (("0b" + temporary_bin[(j-1)*8:j*8]), 2)
                out += struct.pack('!B', temp2)

    ########### append 0s for last left words

    ser = serial.Serial('COM3',baud_rate,bytesize=8)
    ser.write(out)

def decodeCombinedValues(valueIn,no_of_cores):
    if (no_of_cores == 1):
        return [valueIn]
    
    out = []
    temp = bin(valueIn)[2:]
    temp = format(int(temp), ('0'+str(12*no_of_cores)+'d'))
    for x in range(no_of_cores):
        out.append(int(('0b' + temp[x*12:x*12+12]), 2))
    return out

def convertToCorrectForm(inputMatrix, no_of_cores, a,c,d):

    OutputMatrix = [[0 for x in range(c)] for y in range(a)]

    for x in range(d):
        for y in range(c):
            for z in range(no_of_cores):
                if (x*no_of_cores+z) < a:
                    val = inputMatrix[x*c+y][z]
                    if (val > 2047):
                        val = -4096 + val
                        OutputMatrix[x*no_of_cores+z][y] = "-"+hex(val)[3:]
                    else:
                        OutputMatrix[x*no_of_cores+z][y] = hex(val)[2:]
    return (OutputMatrix)

def receive_answer_matrix_from_FPGA(a,b,c,d,core_count,baud_rate):
    memWordLength = core_count*12
    byte_count = math.ceil(memWordLength/8)
    full_length = 8*byte_count
    extra_length = full_length - memWordLength

    start_addr_P = 14
    start_addr_Q = start_addr_P + d*b
    start_addr_R = start_addr_Q + b*c + 1 #with extra space
    end_addr_P = start_addr_P + d*b -1
    end_addr_Q = start_addr_Q + b*c -1
    end_addr_R = start_addr_R + d*c - 1

    ser = serial.Serial('COM3',baud_rate,bytesize=8)

    ################################# receive dmemory after calculation

    DMem = []
    R_matrix_lenght = end_addr_R - start_addr_R + 1

    for x in range(R_matrix_lenght):
        temp = ''
        for x in range (byte_count):
            in_bin = ser.read()
            temp = '{0:08b}'.format((int.from_bytes(in_bin,byteorder='little'))) + temp
        # print (hex(int("0b"+temp[extra_length:],2)))
        temp = int("0b"+temp[extra_length:],2)
        DMem.append(temp)

    ################################## find R matrix

    matrix_initial = DMem
    matrix_second = []

    for x in matrix_initial:
        matrix_second.append(decodeCombinedValues(x, core_count))

    matrix_R = convertToCorrectForm(matrix_second, core_count, a,c,d)

    writeFile = open('3_answer_matrix_FPGA.txt', 'w')

    for x in (matrix_R):
        for y in (x):
            writeFile.write((6-len(y))*" " + y)
        writeFile.write('\n')
    writeFile.close()

def calculate_answer_matrix_in_PC():

    data = open('1_matrix_in.txt','r')
    txt_code = data.read().strip().split('\n')
    writeFile  = open('4_answer_matrix_PC.txt','w')
    out = []

    a = int(txt_code[0])
    b = int(txt_code[1])
    c = int(txt_code[2])

    # matrix A - a x b 
    # matrix B - b x c
    i = 4
    while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix A
        i = i+1

    A = []
    for x in range (i,i+a):
        temp = txt_code[x].strip().split(" ")
        A.append(temp)
    i = i + a
    while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix B
        i = i+1

    matrix_B = []
    for x in range (i,i+b):
        temp = txt_code[x].strip().split(" ")
        matrix_B.append(temp)

    mul = []

    # begin_time = time.time()

    for i in range(int(a)):
        temp_list= []
        for k in range(int(c)):
            temp_ans = 0
            for j in range(int(b)):
                temp_ans += int(A[i][j])*int(matrix_B[j][k])
                if (temp_ans<0):
                    val = "-"+hex(temp_ans)[3:]
                else:
                    val = hex(temp_ans)[2:]            
            temp_list.append(" "*(5-len(val))+ val)
        mul.append(temp_list)
    out = ' '
    for i in mul:
        temp = ''
        for j in i:
            temp+=(str(j)+' ')
        out+=(temp+'\n ')
    # print(out)
    writeFile.write(out)
    writeFile.close()

    # end_time = time.time()
    # print ((end_time - begin_time)*(2.5*(10**9)))

def compare_answer_matrix_FPGA_and_PC():

    python_anwer_file = open('4_answer_matrix_PC.txt','r')
    fpga_answer_file = open('3_answer_matrix_FPGA.txt','r')

    python_anwer_matrix_temp = python_anwer_file.read().strip().split('\n')
    python_anwer_matrix = []
    for line in python_anwer_matrix_temp:
        python_anwer_matrix.append(line.split())
    python_anwer_file.close()

    fpga_answer_matrix_temp = fpga_answer_file.read().strip().split('\n')
    fpga_answer_matrix = []
    for line in fpga_answer_matrix_temp:
        fpga_answer_matrix.append(line.split())
    fpga_answer_file.close()

    dim_a = len(python_anwer_matrix)
    dim_c = len(python_anwer_matrix[0])

    not_similar = 0
    for x in range (dim_a):
        for y in range (dim_c):
            if (python_anwer_matrix[x][y] != fpga_answer_matrix[x][y]):
                print ("[",x,",",y,"] fpga value = ",fpga_answer_matrix[x][y]," python value = ", python_anwer_matrix[x][y])
                not_similar = 1

    if (not_similar):
        print ("wrong answer")
    else:
        print ("correct answer")