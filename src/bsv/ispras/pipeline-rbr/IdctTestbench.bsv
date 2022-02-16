/*
 * Copyright 2021-2022 ISP RAS (http://www.ispras.ru)
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

/*
 * IDCT testbench.
 */

package IdctTestbench;

import Idct::*;
import Vector::*;

function Action printVector(String s, OutDataType data);
  action
    Integer dim = valueOf(DataDim);
    $display(s);
    for (Integer i = 0; i < dim; i = i + 1) begin
      $write("    ");
      for (Integer j = 0; j < dim; j = j + 1)
        $write(" %b", data[j + i * dim]);
      $display("");
    end
  endaction
endfunction

function InDataRow getRow(InDataType data, Integer j);
  InDataRow row = newVector;
  Integer dim = valueOf(DataDim);
    for (Integer i = 0; i < dim; i = i + 1) begin
      row[i] = data[dim * j + i];
    end
  return row;
endfunction

/* init/result test data functions */

function InputType idct0_test_init(Integer x);
  return fromInteger((x == 0) ? 23 : ((x == 1) ? -1 : ((x == 2) ? -2 : 0)));
endfunction

function OutputType idct0_test_want(Integer x);
  return fromInteger((x % 8 == 0) ? 2 : 3);
endfunction

function InputType idct1_test_init(Integer x);
  return fromInteger((x == 0) ? 13 : ((x == 1) ? -7 : (x == 9) ? 2 : 0));
endfunction

function OutputType idct1_test_want(Integer x);
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

function InputType idct2_test_init(Integer x);
  return fromInteger((x == 0) ? -166
      : (x == 1) ? -7
      : (x == 2 || x == 3) ? -4
      : (x == 8 || x == 16) ? -2 : 0);
endfunction

function OutputType idct2_test_want(Integer x);
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

function InDataType idct3_test_init;
  InDataType in = replicate(0);
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
  return in;
endfunction

function OutDataType idct3_test_want;
  OutDataType want = newVector;
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
  return want;
endfunction

(* synthesize *)
module mkIdctTestbench(Empty);

  Reg#(State) state <- mkReg(IDLE);
  Reg#(CountType) count <- mkReg(0);
  Reg#(CountType) test <- mkReg(0);
  Idct_ifc idct <- mkIdct;
  InDataReg in <- replicateM(mkReg(0));
  OutDataReg out <- replicateM(mkReg(0));

  Integer dim = valueOf(DataDim);
  CountType rowSize = fromInteger(dim);

  /* start/end test rules */
  rule test0_start ((state == IDLE) && (count == 0) && (test == 0));
    writeVReg(in, genWith(idct0_test_init));
    $dumpvars();
    state <= HAVE_DATA;
  endrule

  rule test0_end ((state == DONE) && (count == rowSize) && (test == 0));
    OutDataType got = readVReg(out);
    OutDataType want = genWith(idct0_test_want);

    state <= IDLE;
    count <= 0;
    test <= test + 1;
    if (got == want) begin
      $display("test0: OK");
    end
    else begin
      $display("test0: FAIL");
      $finish(1);
    end
  endrule

  rule test1_start ((state == IDLE) && (count == 0) && (test == 1));
    writeVReg(in, genWith(idct1_test_init));
    state <= HAVE_DATA;
  endrule

  rule test1_end ((state == DONE) && (count == rowSize) && (test == 1));
    OutDataType got = readVReg(out);
    OutDataType want = genWith(idct1_test_want);

    state <= IDLE;
    count <= 0;
    test <= test + 1;
    if (got == want) begin
      $display("test1: OK");
    end
    else begin
      $display("test1: FAIL");
      $finish(1);
    end
  endrule

  rule test2_start ((state == IDLE) && (count == 0) && (test == 2));
    writeVReg(in, genWith(idct2_test_init));
    state <= HAVE_DATA;
  endrule

  rule test2_end ((state == DONE) && (count == rowSize) && (test == 2));
    OutDataType got = readVReg(out);
    OutDataType want = genWith(idct2_test_want);

    state <= IDLE;
    count <= 0;
    test <= test + 1;
    if (got == want) begin
      $display("test2: OK");
    end
    else begin
      $display("test2: FAIL");
      $finish(1);
    end
  endrule

  rule test3_start ((state == IDLE) && (count == 0) && (test == 3));
    writeVReg(in, idct3_test_init);
    state <= HAVE_DATA;
  endrule

  rule test3_end ((state == DONE) && (count == rowSize) && (test == 3));
    OutDataType got = readVReg(out);
    OutDataType want = idct3_test_want;

    state <= IDLE;
    count <= 0;
    test <= 0;
    if (got == want) begin
      $display("test3: OK");
      $finish(0);
    end
    else begin
      $display("test3: FAIL");
      $finish(1);
    end
  endrule

  rule send_row ((state == HAVE_DATA) && (count < rowSize));
    InDataRow row = newVector;
    for (Integer i = 0; i < dim; i = i + 1) begin
      row[i] = in[getNum(count) * dim + i];
    end
    idct.send(row);
    count <= count + 1;
  endrule

  rule ready_to_recv ((state == HAVE_DATA) && (count == rowSize));
    count <= 0;
    state <= DONE;
  endrule

  rule recv_row ((state == DONE) && (count < rowSize));
    OutDataRow row <- idct.recv();
    for (Integer i = 0; i < dim; i = i + 1) begin
      out[getNum(count) * dim + i] <= row[i];
    end
    count <= count + 1;
  endrule
endmodule: mkIdctTestbench

endpackage // IdctTestbench
