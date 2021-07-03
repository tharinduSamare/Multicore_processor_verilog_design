python_anwer_file = open('6_multiply_answer.txt','r')
fpga_answer_file = open('13_answer_matrix_from_processor.txt','r')

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
