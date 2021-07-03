import math

data = open('2_matrix_in.txt','r')
txt_code = data.read().strip().split('\n')
machine_code = open('4_data_mem_tb.txt','w')

out = []

a = int(txt_code[0])
b = int(txt_code[1])
c = int(txt_code[2])

cores = int(txt_code[3][0])

d = math.ceil(a/cores)  #(number of raws reduces)

start_addr_P = 14
start_addr_Q = start_addr_P + d*b
start_addr_R = start_addr_Q + b*c + 1 #with extra space
end_addr_P = start_addr_P + d*b -1
end_addr_Q = start_addr_Q + b*c -1
end_addr_R = start_addr_R + d*c - 1

out.append('{0:012b}'.format(a)*cores)
out.append('{0:012b}'.format(b)*cores)
out.append('{0:012b}'.format(c)*cores)

out.append('{0:012b}'.format(start_addr_P)*cores)
out.append('{0:012b}'.format(start_addr_Q)*cores)
out.append('{0:012b}'.format(start_addr_R)*cores)
out.append('{0:012b}'.format(end_addr_P)*cores)
out.append('{0:012b}'.format(end_addr_Q)*cores)
out.append('{0:012b}'.format(end_addr_R)*cores)

out.append('{0:012b}'.format(0)*cores)
out.append('{0:012b}'.format(0)*cores)
out.append('{0:012b}'.format(0)*cores)
out.append('{0:012b}'.format(0)*cores)
out.append('{0:012b}'.format(0)*cores)

i = 4
while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix A
    i = i+1

A = []
for x in range (i,i+a):
    temp = txt_code[x].strip().split(" ")
    temp = ['{0:012b}'.format(int(j)) for j in temp]
    A.append(temp)
    #for j in temp:
     #   out.append('{0:012b}'.format(int(j)))
if len(A)%cores!=0:
    for k in range(cores-len(A)%cores):
        temp = ['{0:012b}'.format(int(0)) for i in range(len(A[0]))]
        A.append(temp)

for x in range(0,len(A),cores):
    for y in range(len(A[0])):
        temporary_bin = ''
        for k in range(cores):
            temporary_bin+=A[x+k][y]
        out.append(temporary_bin)
i = i + a
while (txt_code[i] == '' or  txt_code[i][0] == '/'): #to find the start of matrix B
    i = i+1

matrix_B = []
for x in range (i,i+b):
    temp = txt_code[x].strip().split(" ")
    matrix_B.append(temp)

for y in range(c):
    for x in range(b):
        temp_bin = ''
        for k in range(cores):
            temp_bin+='{0:012b}'.format(int(matrix_B[x][y]))
        out.append(temp_bin)
        
for i in range(0,4096,1):
    if (i<len(out)):
        machine_code.write(out[i]+'\n')
    else:
        no_xx = "000000000000"*cores
        machine_code.write(no_xx +"\n")
machine_code.close()

