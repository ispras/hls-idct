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
// Width of communication channel between calculators for rows and columns
`define WIM 13
// Output width
`define WOUT 9
// IDCT coefficients
`define W1 2841
`define W2 2676
`define W3 2408
`define W5 1609
`define W6 1108
`define W7 565

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

module idctrow(input [`WIN-1:0] i0, input [`WIN-1:0] i1, input [`WIN-1:0] i2, input [`WIN-1:0] i3,
               input [`WIN-1:0] i4, input [`WIN-1:0] i5, input [`WIN-1:0] i6, input [`WIN-1:0] i7,
               output [`WIM-1:0] b0, output [`WIM-1:0] b1, output [`WIM-1:0] b2, output [`WIM-1:0] b3,
               output [`WIM-1:0] b4, output [`WIM-1:0] b5, output [`WIM-1:0] b6, output [`WIM-1:0] b7);

// zeroth stage
`define X00 (($signed(i0) << 11) + 128)
`define X10 ($signed(i4) << 11)
`define X20 ($signed(i6))
`define X30 ($signed(i2))
`define X40 ($signed(i1))
`define X50 ($signed(i7))
`define X60 ($signed(i5))
`define X70 ($signed(i3))

`define BR (!(`X10 | `X20 | `X30 | `X40 | `X50 | `X60 | `X70))

// first stage
`define X01 `X00
`define X11 `X10
`define X21 `X20
`define X31 `X30
`define TMP0 ($signed(`W7 * (`X40 + `X50)))
`define X41 (`TMP0 + (`W1 - `W7) * `X40)
`define X51 (`TMP0 - (`W1 + `W7) * `X50)
`define TMP1 ($signed(`W3 * (`X60 + `X70)))
`define X61 (`TMP1 - (`W3 - `W5) * `X60)
`define X71 (`TMP1 - (`W3 + `W5) * `X70)

// second stage
`define X02 (`X01 - `X11)
`define X12 (`X41 + `X61)
`define TMP2 ($signed(`W6 * (`X31 + `X21)))
`define X22 (`TMP2 - (`W2 + `W6) * `X21)
`define X32 (`TMP2 + (`W2 - `W6) * `X31)
`define X42 (`X41 - `X61)
`define X52 (`X51 - `X71)
`define X62 (`X51 + `X71)
`define X72 `X71
`define TMP3 ($signed(`X01 + `X11))

// third stage
`define X03 (`X02 - `X22)
`define X13 `X12
`define X23 ((181 * (`X42 + `X52) + 128) >>> 8)
`define X33 (`X02 + `X22)
`define X43 ((181 * (`X42 - `X52) + 128) >>> 8)
`define X53 `X52
`define X63 `X62
`define X73 (`TMP3 + `X32)
`define TMP4 ($signed(`TMP3 - `X32))

// fourth stage
`define TMP5 ($signed(i0) << 3)
assign b0 = `BR ? `TMP5 : (`X73 + `X13) >>> 8;
assign b1 = `BR ? `TMP5 : (`X33 + `X23) >>> 8;
assign b2 = `BR ? `TMP5 : (`X03 + `X43) >>> 8;
assign b3 = `BR ? `TMP5 : (`TMP4 + `X63) >>> 8;
assign b4 = `BR ? `TMP5 : (`TMP4 - `X63) >>> 8;
assign b5 = `BR ? `TMP5 : (`X03 - `X43) >>> 8;
assign b6 = `BR ? `TMP5 : (`X33 - `X23) >>> 8;
assign b7 = `BR ? `TMP5 : (`X73 - `X13) >>> 8;

endmodule // idctrow

module idctcol(input [`WIM-1:0] i0, input [`WIM-1:0] i1, input [`WIM-1:0] i2, input [`WIM-1:0] i3,
               input [`WIM-1:0] i4, input [`WIM-1:0] i5, input [`WIM-1:0] i6, input [`WIM-1:0] i7,
               output [`WOUT-1:0] b0, output [`WOUT-1:0] b1, output [`WOUT-1:0] b2, output [`WOUT-1:0] b3,
               output [`WOUT-1:0] b4, output [`WOUT-1:0] b5, output [`WOUT-1:0] b6, output [`WOUT-1:0] b7);

// zeroth stage
`define X00 (($signed(i0) << 8) + 8192)
`define X10 ($signed(i4) << 8)
`define X20 ($signed(i6))
`define X30 ($signed(i2))
`define X40 ($signed(i1))
`define X50 ($signed(i7))
`define X60 ($signed(i5))
`define X70 ($signed(i3))

`define BR (!(`X10 | `X20 | `X30 | `X40 | `X50 | `X60 | `X70))

// first stage
//wire signed [`WIM*2-1:0] tmp0;
//wire signed [`WIM*2-1:0] tmp1;
`define X01 `X00
`define X11 `X10
`define X21 `X20
`define X31 `X30
`define TMP0 ($signed(`W7 * (`X40 + `X50) + 4))
`define X41 ((`TMP0 + (`W1 - `W7) * `X40) >>> 3)
`define X51 ((`TMP0 - (`W1 + `W7) * `X50) >>> 3)
`define TMP1 ($signed(`W3 * (`X60 + `X70) + 4))
`define X61 ((`TMP1 - (`W3 - `W5) * `X60) >>> 3)
`define X71 ((`TMP1 - (`W3 + `W5) * `X70) >>> 3)

// second stage
//wire signed [`WIM*2-1:0] tmp2;
//wire signed [`WIM*2-1:0] tmp3;
`define X02 (`X01 - `X11)
`define X12 (`X41 + `X61)
`define TMP2 ($signed(`W6 * (`X31 + `X21) + 4))
`define X22 ((`TMP2 - (`W2 + `W6) * `X21) >>> 3)
`define X32 ((`TMP2 + (`W2 - `W6) * `X31) >>> 3)
`define X42 (`X41 - `X61)
`define X52 (`X51 - `X71)
`define X62 (`X51 + `X71)
`define X72 `X71
`define TMP3 ($signed(`X01 + `X11))

// third stage
//wire signed [`WIM*2-1:0] tmp4;
`define X03 (`X02 - `X22)
`define X13 `X12
`define X23 ((181 * (`X42 + `X52) + 128) >>> 8)
`define X33 (`X02 + `X22)
`define X43 ((181 * (`X42 - `X52) + 128) >>> 8)
`define X53 `X52
`define X63 `X62
`define X73 (`TMP3 + `X32)
`define TMP4 ($signed(`TMP3 - `X32))

// fourth stage
//wire signed [`WOUT-1:0] tmp5 = iclp13(($signed(i0) + 32) >>> 6);
`define TMP5 ($signed(iclp13(($signed(i0) + 32) >>> 6)))
assign b0 = `BR ? `TMP5 : iclp13((`X73 + `X13) >>> 14);
assign b1 = `BR ? `TMP5 : iclp13((`X33 + `X23) >>> 14);
assign b2 = `BR ? `TMP5 : iclp13((`X03 + `X43) >>> 14);
assign b3 = `BR ? `TMP5 : iclp13((`TMP4 + `X63) >>> 14);
assign b4 = `BR ? `TMP5 : iclp13((`TMP4 - `X63) >>> 14);
assign b5 = `BR ? `TMP5 : iclp13((`X03 - `X43) >>> 14);
assign b6 = `BR ? `TMP5 : iclp13((`X33 - `X23) >>> 14);
assign b7 = `BR ? `TMP5 : iclp13((`X73 - `X13) >>> 14);

function [`WOUT-1:0] iclp13;
  input [12:0] in;
  begin
    if (in[12] == 1 && in[11:8] != 4'hF)
      iclp13 = `WOUT'h80;
    else if (in[12] == 0 && in[11:8] != 0)
      iclp13 = `WOUT'h7F;
    else
      iclp13 = in[`WOUT-1:0];
  end
endfunction

endmodule // idctcol

