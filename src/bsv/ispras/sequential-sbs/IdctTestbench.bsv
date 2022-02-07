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
    Integer dataDim = valueOf(DataDim);
    $display(s);
    for (Integer i = 0; i < dataDim; i = i + 1) begin
      $write("    ");
      for (Integer j = 0; j < dataDim; j = j + 1)
        $write(" %b", data[j + i * dataDim]);
      $display("");
    end
  endaction
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

function InputType idct4_test_init(Integer x);
  return fromInteger(x);
endfunction

function InputType idct5_test_init(Integer x);
  return fromInteger(-x);
endfunction

(* synthesize *)
module mkIdctTestbench(Empty);

  Reg#(int) testNum <- mkReg(0);
  Idct_iface idct <- mkIdct;

  /* start/end test rules */

  rule idct0_test_start (testNum == 0);

    InDataType in = genWith(idct0_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct0_test_end (testNum == 0);
    OutDataType got <- idct.result();
    OutDataType want = genWith(idct0_test_want);

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

    InDataType in = genWith(idct1_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct1_test_end (testNum == 1);
    OutDataType got <- idct.result();
    OutDataType want = genWith(idct1_test_want);

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

    InDataType in = genWith(idct2_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct2_test_end (testNum == 2);

    OutDataType got <- idct.result();
    OutDataType want = genWith(idct2_test_want);

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

    $dumpvars();
    idct.start(in);
  endrule

  rule idct3_test_end (testNum == 3);
    OutDataType got <- idct.result();

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

    if (got == want) begin
      $display("idct3_test: OK");
      testNum <= testNum + 1;
    end
    else begin
      $display("idct3_test: FAIL");
      printVector("want=", want);
      printVector("got=", got);
      $finish(1);
    end
  endrule

  rule idct4_test_start (testNum == 4);

    InDataType in = genWith(idct4_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct4_test_end (testNum == 4);
    OutDataType got <- idct.result();

    OutDataType want = newVector;
    want[0] = 9'had;
    want[1] = 9'h1c1;
    want[2] = 9'h2a;
    want[3] = 9'h1ed;
    want[4] = 9'h16;
    want[5] = 9'h1fb;
    want[6] = 9'hc;
    want[7] = 9'h4;
    want[8] = 9'h150;
    want[9] = 9'h34;
    want[10] = 9'h1d9;
    want[11] = 9'hf;
    want[12] = 9'h1eb;
    want[13] = 9'h3;
    want[14] = 9'h1f4;
    want[15] = 9'h1fb;
    want[16] = 9'h47;
    want[17] = 9'h1e9;
    want[18] = 9'h10;
    want[19] = 9'h1f9;
    want[20] = 9'h9;
    want[21] = 9'h1ff;
    want[22] = 9'h5;
    want[23] = 9'h2;
    want[24] = 9'h1c4;
    want[25] = 9'h11;
    want[26] = 9'h1f3;
    want[27] = 9'h5;
    want[28] = 9'h1f9;
    want[29] = 9'h1;
    want[30] = 9'h1fc;
    want[31] = 9'h1fe;
    want[32] = 9'h21;
    want[33] = 9'h1f5;
    want[34] = 9'h8;
    want[35] = 9'h1fd;
    want[36] = 9'h4;
    want[37] = 9'h1ff;
    want[38] = 9'h2;
    want[39] = 9'h1;
    want[40] = 9'h1e6;
    want[41] = 9'h7;
    want[42] = 9'h1fa;
    want[43] = 9'h2;
    want[44] = 9'h1fd;
    want[45] = 9'h0;
    want[46] = 9'h1fe;
    want[47] = 9'h1ff;
    want[48] = 9'hb;
    want[49] = 9'h1fc;
    want[50] = 9'h3;
    want[51] = 9'h1ff;
    want[52] = 9'h1;
    want[53] = 9'h0;
    want[54] = 9'h1;
    want[55] = 9'h0;
    want[56] = 9'h1fa;
    want[57] = 9'h1;
    want[58] = 9'h1ff;
    want[59] = 9'h0;
    want[60] = 9'h1ff;
    want[61] = 9'h0;
    want[62] = 9'h0;
    want[63] = 9'h0;

    if (got == want) begin
      $display("idct4_test: OK");
      testNum <= testNum + 1;
    end
    else begin
      $display("idct4_test: FAIL");
      printVector("want=", want);
      printVector("got=", got);
      $finish(1);
    end
  endrule

  rule idct5_test_start (testNum == 5);

    InDataType in = genWith(idct5_test_init);
    $dumpvars();
    idct.start(in);
  endrule

  rule idct5_test_end (testNum == 5);
    OutDataType got <- idct.result();

    OutDataType want = newVector;
    want[0] = 9'h153;
    want[1] = 9'h3f;
    want[2] = 9'h1d6;
    want[3] = 9'h13;
    want[4] = 9'h1ea;
    want[5] = 9'h5;
    want[6] = 9'h1f4;
    want[7] = 9'h1fc;
    want[8] = 9'hb0;
    want[9] = 9'h1cc;
    want[10] = 9'h27;
    want[11] = 9'h1f1;
    want[12] = 9'h15;
    want[13] = 9'h1fd;
    want[14] = 9'hc;
    want[15] = 9'h5;
    want[16] = 9'h1b9;
    want[17] = 9'h17;
    want[18] = 9'h1f0;
    want[19] = 9'h7;
    want[20] = 9'h1f7;
    want[21] = 9'h1;
    want[22] = 9'h1fb;
    want[23] = 9'h1fe;
    want[24] = 9'h3c;
    want[25] = 9'h1ef;
    want[26] = 9'hd;
    want[27] = 9'h1fb;
    want[28] = 9'h7;
    want[29] = 9'h1ff;
    want[30] = 9'h4;
    want[31] = 9'h2;
    want[32] = 9'h1df;
    want[33] = 9'hb;
    want[34] = 9'h1f8;
    want[35] = 9'h3;
    want[36] = 9'h1fc;
    want[37] = 9'h1;
    want[38] = 9'h1fe;
    want[39] = 9'h1ff;
    want[40] = 9'h1a;
    want[41] = 9'h1f9;
    want[42] = 9'h6;
    want[43] = 9'h1fe;
    want[44] = 9'h3;
    want[45] = 9'h0;
    want[46] = 9'h2;
    want[47] = 9'h1;
    want[48] = 9'h1f5;
    want[49] = 9'h4;
    want[50] = 9'h1fd;
    want[51] = 9'h1;
    want[52] = 9'h1ff;
    want[53] = 9'h0;
    want[54] = 9'h1ff;
    want[55] = 9'h0;
    want[56] = 9'h6;
    want[57] = 9'h1ff;
    want[58] = 9'h1;
    want[59] = 9'h0;
    want[60] = 9'h1;
    want[61] = 9'h0;
    want[62] = 9'h0;
    want[63] = 9'h0;

    if (got == want) begin
      $display("idct5_test: OK");
      $finish(0);
    end
    else begin
      $display("idct5_test: FAIL");
      printVector("want=", want);
      printVector("got=", got);
      $finish(1);
    end
  endrule
endmodule: mkIdctTestbench

endpackage // IdctTestbench
