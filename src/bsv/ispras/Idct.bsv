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

 /* this code assumes >> to be a two's-complement arithmetic */
 /* right shift: (-2)>>1 == -1 , (-3)>>1 == -2               */

package Idct;

import Vector::*;

`define SIZE 8

typedef 8 DataDim;
typedef TMul#(DataDim, DataDim) DataSize;

typedef 8 BitsInByte;

typedef 2841 W1; /* 2048*sqrt(2)*cos(1*pi/16) */
typedef 2676 W2; /* 2048*sqrt(2)*cos(2*pi/16) */
typedef 2408 W3; /* 2048*sqrt(2)*cos(3*pi/16) */
typedef 1609 W5; /* 2048*sqrt(2)*cos(5*pi/16) */
typedef 1108 W6; /* 2048*sqrt(2)*cos(6*pi/16) */
typedef 565 W7;  /* 2048*sqrt(2)*cos(7*pi/16) */
typedef 181 R2;  /* 256/sqrt(2) */

typedef TMul#(BitsInByte, 2) ShortLength;
typedef Int#(ShortLength) ShortType;
typedef Reg#(ShortType) ShortReg;

typedef Vector#(DataSize, ShortType) DataType;
typedef Vector#(DataSize, ShortReg) DataReg;

typedef enum { IDLE, HAVE_DATA, ROWS_PROCESSED, COLS_PROCESSED, DONE } State
  deriving(Bits, Eq);

function ShortType iclip (ShortType x);
  return (x < -256) ? -256 : ((x > 255) ? 255 : x);
endfunction

function Action printVector(String s, DataType data);
  action
    Integer dataDim = valueOf(DataDim);
    $display(s);
    for (Integer i = 0; i < dataDim; i = i + 1) begin
      $write ("    ");
      for (Integer j = 0; j < dataDim; j = j + 1)
        $write (" %d", data[j + i * dataDim]);
      $display ("");
    end
  endaction
endfunction

interface Idct_iface#(type aType);
  method Action start(aType x);
  method ActionValue#(aType) result();
endinterface: Idct_iface

(* synthesize *)
module mkIdct (Idct_iface#(DataType));

  DataReg blk          <- replicateM(mkRegU);
  Reg#(Bool) have_data <- mkReg(False);
  Reg#(State) state    <- mkReg(IDLE);

  Integer dataSize = valueOf(DataSize);
  Integer dataDim  = valueOf(DataDim);

  int w1 = fromInteger(valueOf(W1));
  int w2 = fromInteger(valueOf(W2));
  int w3 = fromInteger(valueOf(W3));
  int w5 = fromInteger(valueOf(W5));
  int w6 = fromInteger(valueOf(W6));
  int w7 = fromInteger(valueOf(W7));
  int r2 = fromInteger(valueOf(R2));

  function Action idctrow(Integer idx);
    action
      int x0 = (extend(blk[idx]) << 11) + 128;
      int x1 = extend(blk[idx + 4]) << 11;
      int x2 = extend(blk[idx + 6]);
      int x3 = extend(blk[idx + 2]);
      int x4 = extend(blk[idx + 1]);
      int x5 = extend(blk[idx + 7]);
      int x6 = extend(blk[idx + 5]);
      int x7 = extend(blk[idx + 3]);
      int x8 = 0;

      /* shortcut */
      if ((x1 | x2 | x3 | x4 | x5 | x6 | x7) == 0) begin
        blk[idx]     <= blk[idx] << 3;
        blk[idx + 1] <= blk[idx] << 3;
        blk[idx + 2] <= blk[idx] << 3;
        blk[idx + 3] <= blk[idx] << 3;
        blk[idx + 4] <= blk[idx] << 3;
        blk[idx + 5] <= blk[idx] << 3;
        blk[idx + 6] <= blk[idx] << 3;
        blk[idx + 7] <= blk[idx] << 3;
      end
      else begin
        /* first stage */
        x8 = w7 * (x4 + x5);
        x4 = x8 + (w1 - w7) * x4;
        x5 = x8 - ((w1 + w7) * x5);
        x8 = w3 * (x6 + x7);
        x6 = x8 - (w3 - w5) * x6;
        x7 = x8 - (w3 + w5) * x7;

        /* second stage */
        x8 = x0 + x1;
        x0 = x0 - x1;
        x1 = w6 * (x3 + x2);
        x2 = x1 - (w2 + w6) * x2;
        x3 = x1 + (w2 - w6) * x3;
        x1 = x4 + x6;
        x4 = x4 - x6;
        x6 = x5 + x7;
        x5 = x5 - x7;

        /* third stage */
        x7 = x8 + x3;
        x8 = x8 - x3;
        x3 = x0 + x2;
        x0 = x0 - x2;
        x2 = (r2 * (x4 + x5) + 128) >> 8;
        x4 = (r2 * (x4 - x5) + 128) >> 8;

        /* fourth stage */
        blk[idx]     <= truncate((x7 + x1) >> 8);
        blk[idx + 1] <= truncate((x3 + x2) >> 8);
        blk[idx + 2] <= truncate((x0 + x4) >> 8);
        blk[idx + 3] <= truncate((x8 + x6) >> 8);
        blk[idx + 4] <= truncate((x8 - x6) >> 8);
        blk[idx + 5] <= truncate((x0 - x4) >> 8);
        blk[idx + 6] <= truncate((x3 - x2) >> 8);
        blk[idx + 7] <= truncate((x7 - x1) >> 8);
      end
    endaction
  endfunction

  function Action idctcol(Integer idx);
    action
      int x0 = (extend(blk[idx + 8 * 0]) << 8) + 8192;
      int x1 = extend(blk[idx + 8 * 4]) << 8;
      int x2 = extend(blk[idx + 8 * 6]);
      int x3 = extend(blk[idx + 8 * 2]);
      int x4 = extend(blk[idx + 8 * 1]);
      int x5 = extend(blk[idx + 8 * 7]);
      int x6 = extend(blk[idx + 8 * 5]);
      int x7 = extend(blk[idx + 8 * 3]);
      int x8 = 0;

      /* shortcut */
      if ((x1 | x2 | x3 | x4 | x5 | x6 | x7) == 0) begin
        blk[idx + 8 * 0] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 1] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 2] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 3] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 4] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 5] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 6] <= iclip((blk[idx] + 32) >> 6);
        blk[idx + 8 * 7] <= iclip((blk[idx] + 32) >> 6);
      end
      else begin
        /* first stage */
        x8 = w7 * (x4 + x5) + 4;
        x4 = (x8 + (w1 - w7) * x4) >> 3;
        x5 = (x8 - (w1 + w7) * x5) >> 3;
        x8 = w3 * (x6 + x7) + 4;
        x6 = (x8 - (w3 - w5) * x6) >> 3;
        x7 = (x8 - (w3 + w5) * x7) >> 3;

        /* second stage */
        x8 = x0 + x1;
        x0 = x0 - x1;
        x1 = w6 * (x3 + x2) + 4;
        x2 = (x1 - (w2 + w6) * x2) >> 3;
        x3 = (x1 + (w2 - w6) * x3) >> 3;
        x1 = x4 + x6;
        x4 = x4 - x6;
        x6 = x5 + x7;
        x5 = x5 - x7;

        /* third stage */
        x7 = x8 + x3;
        x8 = x8 - x3;
        x3 = x0 + x2;
        x0 = x0 - x2;
        x2 = (181 * (x4 + x5) + 128) >> 8;
        x4 = (181 * (x4 - x5) + 128) >> 8;

        /* fourth stage */
        blk[idx + 8 * 0] <= iclip(truncate((x7 + x1) >> 14));
        blk[idx + 8 * 1] <= iclip(truncate((x3 + x2) >> 14));
        blk[idx + 8 * 2] <= iclip(truncate((x0 + x4) >> 14));
        blk[idx + 8 * 3] <= iclip(truncate((x8 + x6) >> 14));
        blk[idx + 8 * 4] <= iclip(truncate((x8 - x6) >> 14));
        blk[idx + 8 * 5] <= iclip(truncate((x0 - x4) >> 14));
        blk[idx + 8 * 6] <= iclip(truncate((x3 - x2) >> 14));
        blk[idx + 8 * 7] <= iclip(truncate((x7 - x1) >> 14));
      end
    endaction
  endfunction

  rule process_rows (state == HAVE_DATA);

    for (Integer i = 0; i < dataDim; i = i + 1) begin
      idctrow(8 * i);
    end

    state <= ROWS_PROCESSED;
  endrule

  rule process_columns (state == ROWS_PROCESSED);

    for (Integer i = 0; i < dataDim; i = i + 1) begin
      idctcol(i);
    end

    state <= COLS_PROCESSED;
  endrule

  rule stop_processing (state == COLS_PROCESSED);
    state <= DONE;
  endrule

  method Action start(DataType data) if (state == IDLE);
    writeVReg(blk, data);
    state <= HAVE_DATA;
  endmethod

  method ActionValue#(DataType) result() if (state == DONE);
    state <= IDLE;
    return readVReg(blk);
  endmethod

endmodule: mkIdct

(* synthesize *)
module mkTbench(Empty);

  Reg#(int) testNum <- mkReg(0);
  Idct_iface#(DataType) idct <- mkIdct;

  /* init/result test data functions */

  function ShortType idct0_test_init(Integer x);
    return fromInteger((x == 0) ? 23 : ((x == 1) ? -1 : ((x == 2) ? -2 : 0)));
  endfunction

  function ShortType idct0_test_want(Integer x);
    return fromInteger((x % 8 == 0) ? 2 : 3);
  endfunction

  function ShortType idct1_test_init(Integer x);
    return fromInteger((x == 0) ? 13 : ((x == 1) ? -7 : (x == 9) ? 2 : 0));
  endfunction

  function ShortType idct1_test_want(Integer x);
    Integer y;
    if ((x == 32) || (x == 40) || (x == 41) || (x == 48)
        || (x == 49) || (x == 56) || (x == 57)) begin
      y = 0;
    end
    else if ((x == 23) || (x == 30)
        || (x == 31) || (x == 38)
        || (x == 39) || (x == 46)
        || (x == 47) || (x == 53)
        || (x == 54) || (x == 55)
        || (x == 61) || (x == 62) || (x == 63)) begin
      y = 3;
    end
    else begin
      y = (x % 8 < 4) ? 1 : 2;
    end

    return fromInteger(y);
  endfunction

  function ShortType idct2_test_init(Integer x);
    return fromInteger((x == 0) ? -166
        : (x == 1) ? -7
        : (x == 2 || x == 3) ? -4
        : (x == 8 || x == 16) ? -2 : 0);
  endfunction

  function ShortType idct2_test_want(Integer x);
    return fromInteger((x == 0 || x == 8) ? -24
        : (x == 31 || x == 39 || x == 47 || x == 55) ? -19
        : (x == 1 || x == 16 || x == 24 || x == 32
            || x == 40 || x == 48 || x == 56) ? -23
        : (x == 9 || x == 17 || x == 25 || x == 33
            || x == 41 || x == 49 || x == 57) ? -22
        : (x == 2 || x == 3 || x == 4 || x == 5 || x == 6
            || x == 10 || x == 12 || x == 13
            || x == 14 || x == 18 || x == 21) ? -21 : -20);
  endfunction

  /* start/end test rules */

  rule idct0_test_start (testNum == 0);

    DataType in = genWith(idct0_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct0_test_end (testNum == 0);
    DataType got <- idct.result();
    DataType want = genWith(idct0_test_want);

    testNum <= testNum + 1;

    if (got == want) begin
      $display("idct0_test: OK");
    end
    else begin
      $display("idct0_test: FAIL");
      $finish(1);
    end
  endrule

  rule idct1_test_start (testNum == 1);

    DataType in = genWith(idct1_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct1_test_end (testNum == 1);
    DataType got <- idct.result();
    DataType want = genWith(idct1_test_want);

    testNum <= testNum + 1;

    if (got == want) begin
      $display("idct1_test: OK");
    end
    else begin
      $display("idct1_test: FAIL");
      $finish(1);
    end
  endrule

  rule idct2_test_start (testNum == 2);

    DataType in = genWith(idct2_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct2_test_end (testNum == 2);

    DataType got <- idct.result();
    DataType want = genWith(idct2_test_want);

    testNum <= testNum + 1;

    if (got == want) begin
      $display("idct2_test: OK");
    end
    else begin
      $display("idct2_test: FAIL");
      $finish(1);
    end
  endrule

  rule idct3_test_start (testNum == 3);

    DataType in = replicate(0);
    in[0] = -240;
    in[1] = 8;
    in[2] = -11;
    in[3] = 47;
    in[4] = 26;
    in[5] = -6;
    in[7] = 5;
    in[8] = 28;
    in[9] = -6;
    in[10] = 85;
    in[11] = 44;
    in[12] = -4;
    in[13] = -25;
    in[14] = 5;
    in[15] = 16;
    in[16] = 21;
    in[17] = 8;
    in[18] = 32;
    in[19] = -16;
    in[20] = -24;
    in[22] = 30;
    in[23] = 12;
    in[24] = -2;
    in[25] = 18;
    in[27] = -2;
    in[29] = 7;
    in[31] = -15;
    in[32] = 7;
    in[33] = 4;
    in[34] = 15;
    in[35] = -24;
    in[37] = 9;
    in[38] = 8;
    in[39] = -6;
    in[40] = 4;
    in[41] = 9;
    in[43] = -5;
    in[44] = -6;
    in[48] = -4;
    in[50] = -6;
    in[53] = 10;
    in[54] = -10;
    in[55] = -8;
    in[56] = 6;
    in[63] = -8;

    $dumpvars();
    idct.start(in);
  endrule

  rule idct3_test_end (testNum == 3);
    DataType got <- idct.result();

    DataType want = newVector;
    want[0] = 21;
    want[1] = -10;
    want[2] = -26;
    want[3] = -61;
    want[4] = -43;
    want[5] = -17;
    want[6] = -22;
    want[7] = -8;
    want[8] = 5;
    want[9] = -28;
    want[10] = -47;
    want[11] = -73;
    want[12] = -11;
    want[13] = -14;
    want[14] = -24;
    want[15] = -17;
    want[16] = -14;
    want[17] = -31;
    want[18] = -61;
    want[19] = -45;
    want[20] = -5;
    want[21] = -18;
    want[22] = -22;
    want[23] = -34;
    want[24] = -23;
    want[25] = -36;
    want[26] = -49;
    want[27] = -32;
    want[28] = -12;
    want[29] = -33;
    want[30] = -33;
    want[31] = -35;
    want[32] = -30;
    want[33] = -39;
    want[34] = -53;
    want[35] = -8;
    want[36] = -19;
    want[37] = -31;
    want[38] = -43;
    want[39] = -42;
    want[40] = -41;
    want[41] = -43;
    want[42] = -50;
    want[43] = -4;
    want[44] = -15;
    want[45] = -33;
    want[46] = -44;
    want[47] = -66;
    want[48] = -40;
    want[49] = -38;
    want[50] = -21;
    want[51] = -14;
    want[52] = -17;
    want[53] = -26;
    want[54] = -46;
    want[55] = -52;
    want[56] = -44;
    want[57] = -47;
    want[58] = -9;
    want[59] = -12;
    want[60] = -30;
    want[61] = -33;
    want[62] = -38;
    want[63] = -37;

    if (got == want) begin
      $display("idct3_test: OK");
      $finish(0);
    end
    else begin
      $display("idct3_test: FAIL");
      $finish(1);
    end
  endrule

endmodule: mkTbench

endpackage // Idct
