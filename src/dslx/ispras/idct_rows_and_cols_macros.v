/*
 * Copyright 2022 ISP RAS (http://www.ispras.ru)
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

 /**********************************************************/
 /* inverse two dimensional DCT, Chen-Wang algorithm       */
 /* (cf. IEEE ASSP-32, pp. 803-816, Aug. 1984)             */
 /* 32-bit integer arithmetic (8 bit coefficients)         */
 /* 11 mults, 29 adds per DCT                              */
 /*                                      sE, 18.8.91       */
 /**********************************************************/
 /* coefficients extended to 12 bit for IEEE1180-1990      */
 /* compliance                           sE,  2.1.94       */
 /**********************************************************/

// Input width
`define WIN 12
// Output width
`define WOUT 9

// Map of 64-element array to the correspondent bit vector
`define ARRAY_TO_BITVECTOR(a) \
 {a[63], a[62], a[61], a[60], a[59], a[58], a[57], a[56],\
  a[55], a[54], a[53], a[52], a[51], a[50], a[49], a[48],\
  a[47], a[46], a[45], a[44], a[43], a[42], a[41], a[40],\
  a[39], a[38], a[37], a[36], a[35], a[34], a[33], a[32],\
  a[31], a[30], a[29], a[28], a[27], a[26], a[25], a[24],\
  a[23], a[22], a[21], a[20], a[19], a[18], a[17], a[16],\
  a[15], a[14], a[13], a[12], a[11], a[10], a[09], a[08],\
  a[07], a[06], a[05], a[04], a[03], a[02], a[01], a[00]}

`define ROW_OF_ARRAY(a, i) \
 {a[i], a[i+1], a[i+2], a[i+3], a[i+4], a[i+5], a[i+6], a[i+7]}
