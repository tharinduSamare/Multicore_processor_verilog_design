import time

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
