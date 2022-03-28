/*
 * Copyright 2021 ISP RAS (http://www.ispras.ru)
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See
 * the License for the specific language governing permissions and limitations
 * under the License.
 */

#include <stdint.h>
#include <stdlib.h>
#include <MaxSLiCInterface.h>
#include "IDCTopt2.h"

#define SIZE 8
#define DATA_DIM (SIZE * SIZE)
#define DATA_DOUBLE (DATA_DIM * 2)

void transform_output(short result[], short out[]);

int compare_arrays(short a[], short b[], int size) {
  int i;
  for ( i = 0; i < size; i++) {
    if (a[i] != b[i]) return 0;
  }
  return 1;
}

void print_array(char *msg, short a[], int size) {
  int i, j;

  printf("%s\n", msg);

  for (i = 0; i < size; i++) {
    printf("    ");
    for (j = 0; j < size; j++) {
      printf(" %4d", a[j + i * size]);
    }
    printf("\n");
  }
}

void idct_test(const char *test_name, short in[], short want[]) {
  print_array("in = ", in, SIZE);
  print_array("want = ", want, SIZE);

  const int vectorSize = 8;
  const int streamSize = 8 * 2 + 1;
  size_t sizeBytes = 64 * sizeof(short);
  short *outVector = malloc(sizeBytes);

  IDCTopt2(streamSize, in, sizeBytes*2, outVector, sizeBytes);

  short *res = malloc(sizeBytes);
  transform_output(res, outVector);

  print_array("got = ", /*outVector*/ res, SIZE);

  if (compare_arrays(/*outVector*/ res, want, DATA_DIM)) {
    printf("%s is PASSED\n", test_name);
  } else {
    printf("%s is FAILED\n", test_name);
  }
}

void transform_output(short result[], short outVector[]) {
	for (int i = 0; i < SIZE; i++) {
		for (int j = 0; j < SIZE; j++) {
			result[8*j + i] = outVector[8*i +j];
		}
	}
}

void idct0_test() {
  short in[DATA_DIM] = { 23, -1, -2 };
  short want[DATA_DIM] = { [0 ... (DATA_DIM - 1)] = 3 };
  want[0] = want[8] = want[16] =
      want[24] = want[32] = want[40] = want[48] = want[56] = 2;
  idct_test(__func__, in, want);
}

void idct1_test() {
  short in[DATA_DIM] = {13, -7, 0, 0, 0, 0, 0, 0, 0, 2 };
  short want[DATA_DIM] =
    {1,  1,  1,  1,  2,  2,  2,  2,
     1,  1,  1,  1,  2,  2,  2,  2,
     1,  1,  1,  1,  2,  2,  2,  3,
     1,  1,  1,  1,  2,  2,  3,  3,
     0,  1,  1,  1,  2,  2,  3,  3,
     0,  0,  1,  1,  2,  2,  3,  3,
     0,  0,  1,  1,  2,  3,  3,  3,
     0,  0,  1,  1,  2,  3,  3,  3};
  idct_test(__func__, in, want);
}

void idct2_test() {
  short in[DATA_DIM] =
    {-166, -7, -4, -4, 0, 0, 0, 0, -2, 0, 0, 0, 0, 0, 0, 0, -2 };
  short want[DATA_DIM] =
    {-24, -23, -21, -21, -21, -21, -21, -20,
     -24, -22, -21, -20, -21, -21, -21, -20,
     -23, -22, -21, -20, -20, -21, -20, -20,
     -23, -22, -20, -20, -20, -20, -20, -19,
     -23, -22, -20, -20, -20, -20, -20, -19,
     -23, -22, -20, -20, -20, -20, -20, -19,
     -23, -22, -20, -20, -20, -20, -20, -19,
     -23, -22, -20, -20, -20, -20, -20, -20};
  idct_test(__func__, in, want);
}

void idct3_test() {
  short in[DATA_DOUBLE] =
    {-240,  8, -11,  47,  26,  -6,   0,   5,
       28, -6,  85,  44,  -4, -25,   5,  16,
       21,  8,  32, -16, -24,   0,  30,  12,
       -2, 18,   0,  -2,   0,   7,   0, -15,
        7,  4,  15, -24,   0,   9,   8,  -6,
        4,  9,   0,  -5,  -6,   0,   0,   0,
       -4,  0,  -6,   0,   0,  10, -10,  -8,
        6,  0,   0,   0,   0,   0,   0,  -8,
		0,  0,   0,   0,   0,   0,   0,  0};
  short want[DATA_DIM] =
    {21, -10, -26, -61, -43, -17, -22,  -8,
      5, -28, -47, -73, -11, -14, -24, -17,
    -14, -31, -61, -45,  -5, -18, -22, -34,
    -23, -36, -49, -32, -12, -33, -33, -35,
    -30, -39, -53,  -8, -19, -31, -43, -42,
    -41, -43, -50,  -4, -15, -33, -44, -66,
    -40, -38, -21, -14, -17, -26, -46, -52,
    -44, -47,  -9, -12, -30, -33, -38, -37};
  idct_test(__func__, in, want);
}

int main(void)
{
	idct0_test();
	idct1_test();
	idct2_test();
	idct3_test();

    printf("Done!\n");

    return 0;
}
