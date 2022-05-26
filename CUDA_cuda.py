import matplotlib.pyplot as plt

with open('C:\\Users\\asmis\\source\\repos\\CUDA_25.05_clean\\output0.txt') as datasource:
    P0 = list(map(float, datasource.readline().split()))
with open('C:\\Users\\asmis\\source\\repos\\CUDA_25.05_clean\\output2.txt') as datasource:
    P2 = list(map(float, datasource.readline().split()))
with open('C:\\Users\\asmis\\source\\repos\\CUDA_25.05_clean\\output5.txt') as datasource:
    P5 = list(map(float, datasource.readline().split()))
with open('C:\\Users\\asmis\\source\\repos\\CUDA_25.05_clean\\output8.txt') as datasource:
    P8 = list(map(float, datasource.readline().split()))
with open('C:\\Users\\asmis\\source\\repos\\CUDA_25.05_clean\\output10.txt') as datasource:
    P10 = list(map(float, datasource.readline().split()))

T = []
for i in range(len(P5)):
    T.append(i * 10)

plt.plot(T, P0, T, P2, T, P5, T, P8, T, P10)
plt.xlabel('times number')
plt.ylabel('squared distance')
plt.legend(['p = 0', 'p = 0.2', 'p = 0.5', 'p = 0.8', 'p = 1'], loc='best')
plt.show()
