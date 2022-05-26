#define _CRT_SECURE_NO_WARNINGS

#include <locale.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "mtwist.h"

void move(unsigned int N, unsigned int M);

int main() {

    setlocale(LC_ALL, "rus");
    setlocale(LC_NUMERIC, "eng");

    unsigned int N, M;
    printf(" Сколько ходов? "); scanf(" %u", &N);
    printf(" Сколько запусков? "); scanf(" %u", &M);

    uint32_t Seed;
    printf(" Какое зерно? "); scanf(" %u", &Seed);
    mt_seed32(Seed);

    move(N, M);

    return 0;
}

void move(unsigned int N, unsigned int M) {

    unsigned int i, j;

    int direction;
    int x = 0, y = 0;

    unsigned int R;
    unsigned int Rsize = N / 10;
    float* Raverage = calloc(Rsize, sizeof(float));

    for (j = 0; j < M; j++) {

        x = 0;
        y = 0;

        for (i = 0; i < N; i++) {

            if (i % 10 == 0) {
                R = x * x + y * y;
                Raverage [i / 10] = Raverage [i / 10] + R;
            }

            direction = mt_lrand() % 4;

            switch (direction) {
                case 0: // ход вверх
                    y++;
                    break;
                case 1: // ход вправо
                    x++;
                    break;
                case 2: // ход вниз
                    y--;
                    break;
                case 3: // ход влево
                    x--;
                    break;
            }

        }

    }

    FILE* CUDAp = fopen("CUDAp.txt", "w");
    if (CUDAp != NULL) {

        for (j = 0; j < Rsize; j++) {
            Raverage [j] = Raverage [j] / (float) M;
            fprintf(CUDAp, "%f", Raverage [j]); fprintf(CUDAp, " ");
        }

        fclose(CUDAp);
    }
    else printf("Не удалось открыть файл");

}