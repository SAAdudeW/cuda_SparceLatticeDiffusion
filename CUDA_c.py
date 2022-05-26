import matplotlib.pyplot as plt

with open('C:\\Users\\asmis\\source\\repos\\CUDA_c_clean\\CUDAp.txt', 'r') as datasource:
    RRt = list(map(float, datasource.readline().split()))

T = []
for i in range(len(RRt)):
    T.append(i * 10)

plt.plot(T, RRt)
plt.xlabel('times number')
plt.ylabel('squared distance')
plt.show()
