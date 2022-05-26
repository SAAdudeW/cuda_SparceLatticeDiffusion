#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>
#include <curand_kernel.h>

	// определение параметров GPU
#define THREADS 128
#define BLOCKS 32
#define GENS 32*128

	// определение входных параметров
#define L 200
#define PN 2000
#define SEED 87654321
#define TN 1000
#define P 10


	// проверка ошибок CUDA
#define cudaCheck(cudaf) { cudaCheckInner((cudaf), __FILE__, __LINE__); }
int cudaCheckInner(cudaError_t code, const char* file, int line) {

	if (code != cudaSuccess) {

		fprintf(stderr, "CUDA failed: %s %s %d\n", cudaGetErrorString(code), file, line);
		return 1;

	}
	else return 0;

}


	// структура узел
struct node {
	unsigned int SH;
	unsigned int SV;
};

	// структура частица 
struct particle {
	int x;
	int y;
};


	// инициализация генератора
__global__ void initfGENS(curandStatePhilox4_32_10_t* d_gen) {

	int id = threadIdx.x + blockIdx.x * blockDim.x;
	curand_init(SEED, id, 0, d_gen + id);

}


	// инициализация решетки
__global__ void initfGRID(struct node* d_grid, curandStatePhilox4_32_10_t* d_gen) {

	int id = threadIdx.x + blockIdx.x * blockDim.x;

	for (int i = id; i < L * L; i += GENS) {

		d_grid[i].SH = (curand(&d_gen [id]) % 10) < P;
		d_grid[i].SV = (curand(&d_gen [id]) % 10) < P;

	}

}


	// инициализация частиц
__global__ void initfDOT(struct particle* d_dot, curandStatePhilox4_32_10_t* d_gen) {

	for (int id = threadIdx.x + blockIdx.x * blockDim.x; id < PN; id += GENS) {

		d_dot[id].x = L / 2;
		d_dot[id].y = L / 2;

	}

}


	// шаг
__global__ void step(struct node* d_grid, struct particle* d_dot, int* d_exc, curandStatePhilox4_32_10_t* d_gen) {

	unsigned int r;
	int id = threadIdx.x + blockIdx.x * blockDim.x;

	for (int i = id; i < PN; i += GENS) {

		int xy = d_dot [i].y * L + d_dot [i].x;

			// 1
		if ((d_grid[xy].SH == 1) && (d_grid[xy - 1].SH == 0) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 0)) {
			d_dot[i].x++;
		}
			// 2
		if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 0)) {
			d_dot[i].x--;
		}
			// 3
		if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 0) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 0)) {
			d_dot[i].y++;
		}
			 // 4
		if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 0) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 1)) {
			d_dot[i].y--;
		}
					// 12
				if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 0)) {
					r = curand(&d_gen [id]) % 2;
					if (r == 0) d_dot[i].x++;
					else d_dot[i].x--;
				}
					// 13
				if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 0) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 0)) {
					r = curand(&d_gen [id]) % 2;
					if (r == 0) d_dot[i].x++;
					else d_dot[i].y++;
				}
					// 14
				if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 0) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 1)) {
					r = curand(&d_gen [id]) % 2;
					if (r == 0) d_dot[i].x++;
					else d_dot[i].y--;
				}
					// 23
				if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 0)) {
					r = curand(&d_gen [id]) % 2;
					if (r == 0) d_dot[i].x--;
					else d_dot[i].y++;
				}
					// 24
				if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 1)) {
					r = curand(&d_gen [id]) % 2;
					if (r == 0) d_dot[i].x--;
					else d_dot[i].y--;
				}
					// 34
				if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 0) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 1)) {
					r = curand(&d_gen [id]) % 2;
					if (r == 0) d_dot[i].y++;
					else d_dot[i].y--;
				}
			// 123
		if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 0)) {
			r = curand(&d_gen [id]) % 3;
			if (r == 0) d_dot[i].x++;
			else if (r == 1) d_dot[i].x--;
			else d_dot[i].y++;
		}
			// 124
		if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 0) && (d_grid [xy - L].SV == 1)) {
			r = curand(&d_gen [id]) % 3;
			if (r == 0) d_dot[i].x++;
			else if (r == 1) d_dot[i].x--;
			else d_dot[i].y--;
		}
			// 134
		if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 0) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 1)) {
			r = curand(&d_gen [id]) % 3;
			if (r == 0) d_dot[i].x++;
			else if (r == 1) d_dot[i].y++;
			else d_dot[i].y--;
		}
			// 234
		if ((d_grid [xy].SH == 0) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 1)) {
			r = curand(&d_gen [id]) % 3;
			if (r == 0) d_dot[i].x--;
			else if (r == 1) d_dot[i].y++;
			else d_dot[i].y--;
		}
		
					// 1234
				if ((d_grid [xy].SH == 1) && (d_grid [xy - 1].SH == 1) && (d_grid [xy].SV == 1) && (d_grid [xy - L].SV == 1)) {
					r = curand(&d_gen [id]) % 4;
					if (r == 0) d_dot[i].x++;
					else if (r == 1) d_dot[i].x--;
					else if (r == 2) d_dot[i].y++;
					else d_dot[i].y--;
				}

			// допустимость отклонения
		atomicMax(&d_exc[0], max(abs(d_dot[i].x - L / 2), abs(d_dot[i].y - L / 2)));

	}

}


	// вычисление квадрата отклонения
__global__ void rr(float* d_rsq, struct particle* d_dot) {

	for (int id = threadIdx.x + blockIdx.x * blockDim.x; id < PN; id += GENS) {
		atomicAdd(&d_rsq[0], (d_dot[id].x - L / 2) * (d_dot[id].x - L / 2) + (d_dot[id].y - L / 2) * (d_dot[id].y - L / 2));
	}

}


curandStatePhilox4_32_10_t* d_gen;
struct node* d_grid;
struct particle* d_dot;

int T = 0;
float rsq [1] = {0};
float* d_rsq;
int exc[1] = {0};
int* d_exc;

int main() {

		// инициализация генератора
	cudaCheck(cudaMalloc((void**) &d_gen, GENS * sizeof(curandStatePhilox4_32_10_t)));
	initfGENS << < BLOCKS, THREADS >> > (d_gen);
	cudaCheck(cudaGetLastError());

		// инициализация решетки
	cudaCheck(cudaMalloc((void**) &d_grid, L * L * sizeof(struct node)));
	initfGRID << < BLOCKS, THREADS >> > (d_grid, d_gen);
	cudaCheck(cudaGetLastError());

		// инициализация частиц
	cudaCheck(cudaMalloc((void**) &d_dot, PN * sizeof(struct particle)));
	initfDOT << < BLOCKS, THREADS >> > (d_dot, d_gen);
	cudaCheck(cudaGetLastError());

		// шаги
	cudaCheck(cudaMalloc((void**) &d_rsq, 1 * sizeof(float)));
	cudaCheck(cudaMemset(d_rsq, 0, 1 * sizeof(float)));
	cudaCheck(cudaMalloc((void**) &d_exc, 1 * sizeof(int)));
	cudaCheck(cudaMemset(d_exc, 0, 1 * sizeof(int)));

	FILE* out = fopen("output0.txt", "w");
	if (out != NULL) {

		while (T < TN) {

				// шаг
			step << < BLOCKS, THREADS >> > (d_grid, d_dot, d_exc, d_gen);
			cudaCheck(cudaGetLastError());
			cudaCheck(cudaMemcpy(exc, d_exc, 1 * sizeof(int), cudaMemcpyDeviceToHost));

				// запись кратного / "приошибочного"
			if ((T % 10 == 0) || (exc[0] > L / 2)) {

				cudaCheck(cudaMemset(d_rsq, 0, 1 * sizeof(float)));
				rr << <BLOCKS, THREADS >> > (d_rsq, d_dot);
				cudaCheck(cudaGetLastError());
				cudaCheck(cudaMemcpy(rsq, d_rsq, 1 * sizeof(float), cudaMemcpyDeviceToHost));
				rsq[0] = rsq[0] / PN;

				fprintf(out, "%f", rsq[0]); fprintf(out, " ");
			}

				// проверка на выход за границу
			if (exc[0] > L / 2) {
				break;
			}

			T++;

		}

		fclose(out);
	}
	else printf("Не удалось открыть файл");

		// освобождение памяти 
	cudaCheck(cudaFree(d_gen));
	cudaCheck(cudaFree(d_grid));
	cudaCheck(cudaFree(d_dot));
	cudaCheck(cudaFree(d_rsq));
	cudaCheck(cudaFree(d_exc));

	return 0;
}