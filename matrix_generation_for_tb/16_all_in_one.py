import random
import serial
import math
import struct
import time

##############create 2 matrices #########################

# matrix A - a x b  
# matrix B - b x c
a = int(input("give a: ")) 
b = int(input("give b: "))
c = int(input("give c: "))
d = int(input("give number of cores: "))

writeFile  = open('2_matrix_in.txt','w')

writeFile.write(str(a)+"\n"+str(b)+"\n"+str(c)+"\n"+str(d)+" //number of cores"+"\n")

writeFile.write("\n//matrix A\n")
out = ""
for x in range(a):
    temp = ""
    for y in range (b):
        temp+=(str(random.randint(0,5))+" ")
    out+=(temp+"\n")

print (out)
writeFile.write(out)

writeFile.write("\n//matrix B\n")

out = ""
for x in range(b):
    temp = ""
    for y in range (c):
        temp+=(str(random.randint(0,10))+" ")
    out+=(temp+"\n")

print (out)
writeFile.write(out)
writeFile.close()

############## create and send machine code ############

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

code = open('7_assembly_code.txt','r')
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

####################### SEND THROUGH UART ###########################
uart_list = []
for i in range(255,-1,-1):
    if (i<len(decoded_code)):
        # print ("    "+str(i)+" :   "+decoded_code[i]+";") #for checking
        value = (128)*int(decoded_code[i][0]) + (64)*int(decoded_code[i][1]) + (32)*int(decoded_code[i][2]) + (16)*int(decoded_code[i][3]) + (8)*int(decoded_code[i][4]) + (4)*int(decoded_code[i][5]) + (2)*int(decoded_code[i][6]) + (1)*int(decoded_code[i][7])
        uart_list.append(value)
    else:
        # print ("    "+str(i)+" :   "+ "XXXXXXXX"+";") #for checking
        uart_list.append(0)

uart_list[0] = 255
uart_list[50] = 255
uart_list[100] = 255
uart_list[150] = 255

# for i in range (len(uart_list)-1,-1,-1): #for checking
#     print (255-i, " " ,hex(uart_list[i])),

# ser = serial.Serial('COM10',9600,bytesize=8)
ser = serial.Serial('COM10',115200,bytesize=8)

ser.write(uart_list[::-1])
ser.close()

time.sleep(1) ## time gap between insMem, dataMem transmission

################# send data memory receive answer matrix ################ 
################## and convert it into matrix form ############

##############################################################
def decodeCombinedValues(valueIn,no_of_cores):
    if (no_of_cores == 1):
        return [valueIn]
    
    out = []
    temp = bin(valueIn)[2:]
    temp = format(int(temp), ('0'+str(12*no_of_cores)+'d'))
    for x in range(no_of_cores):
        out.append(int(('0b' + temp[x*12:x*12+12]), 2))
    return out

##################################################################
def convertToCorrectForm(inputMatrix, no_of_cores, a,c,d):

    OutputMatrix = [[0 for x in range(c)] for y in range(a)]

    for x in range(d):
        for y in range(c):
            for z in range(no_of_cores):
                if (x*no_of_cores+z) < a:
                        OutputMatrix[x*no_of_cores+z][y] = hex(inputMatrix[x*c+y][z])[2:]
    return (OutputMatrix)

###############################################################



data = open('2_matrix_in.txt','r')
txt_code = data.read().strip().split('\n')

out = b''

a = int(txt_code[0])
b = int(txt_code[1])
c = int(txt_code[2])

cores = int(txt_code[3][0])

d = math.ceil(a/cores)  #(number of raws reduces)

memWordLength = cores*12
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
filled_memLength = len(setup_values) + (a//cores + (a % cores != 0))*b + b*c
empty_memLength = memLength-filled_memLength

############################## to send setup values ############################
# print('{0:012b}'.format(start_addr_P))


for i in setup_values:
    # print(i)
    temp = '{0:012b}'.format(i)*cores
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
    temp = txt_code[x].strip().split(" ")
    temp = ['{0:012b}'.format(int(j)) for j in temp]
    A.append(temp)

if len(A)%cores!=0:
    for k in range(cores-len(A)%cores):
        temp = ['{0:012b}'.format(int(0)) for i in range(len(A[0]))]
        A.append(temp)

for x in range(0,len(A),cores):
    for y in range(len(A[0])):
        temporary_bin = ''
        for k in range(cores):
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
    # print ("")
    for x in range(b):
        # print ("")
        temporary_bin = ''
        for k in range(cores):
            temporary_bin+='{0:012b}'.format(int(matrix_B[x][y]))
            # print ((int("0b"+'{0:012b}'.format(int(matrix_B[x][y])),2)),end = " ")

        temporary_bin = extra_length*'0' + temporary_bin
        for j in range(byte_count,0,-1):
            temp2 = int (("0b" + temporary_bin[(j-1)*8:j*8]), 2)
            out += struct.pack('!B', temp2)

########### append 0s for last left words

# print (out)
# ser = serial.Serial('COM10',9600,bytesize=8)
ser = serial.Serial('COM10',115200,bytesize=8)

ser.write(out)

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

# for x in  (DMem[0:100]):
#     print (hex(int(x)))

################################## find R matrix

# matrix_initial = DMem[start_addr_R:end_addr_R+1]
matrix_initial = DMem
matrix_second = []

for x in matrix_initial:
    matrix_second.append(decodeCombinedValues(x, cores))

matrix_R = convertToCorrectForm(matrix_second, cores, a,c,d)

writeFile = open('15_answer_matrix_from_processor(UART).txt', 'w')

for x in (matrix_R):
    for y in (x):
        writeFile.write(y + (6-len(y))*" ")
    writeFile.write('\n')
writeFile.close()
print(matrix_R)

######################## calculate answer matrix within pc using python ######

data = open('2_matrix_in.txt','r')
txt_code = data.read().strip().split('\n')
writeFile  = open('6_multiply_answer.txt','w')
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

begin_time = time.time()


for i in range(int(a)):
    temp_list= []
    for k in range(int(c)):
        temp_ans = 0
        for j in range(int(b)):
            temp_ans += int(A[i][j])*int(matrix_B[j][k])
            val = hex(temp_ans)[2:]
        temp_list.append(val + " "*(5-len(val)))
    mul.append(temp_list)
out = ''
for i in mul:
    temp = ''
    for j in i:
        temp+=(str(j)+' ')
    out+=(temp+'\n')
# print(out)
writeFile.write(out)
writeFile.close()

end_time = time.time()

# print ((end_time - begin_time)*(2.5*(10**9)))