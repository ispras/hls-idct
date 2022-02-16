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

/*
 * IDCT single test testbench.
 */

package IdctSingleTestbench;

import Idct::*;
import Vector::*;

(* synthesize *)
module mkIdctSingleTestbench(Empty);

  Reg#(State) state <- mkReg(IDLE);
  Reg#(CountType) count <- mkReg(0);
  Idct_ifc idct <- mkIdct;
  InDataReg in <- replicateM(mkReg(0));
  OutDataReg out <- replicateM(mkReg(0));

  Integer dim = valueOf(DataDim);
  CountType rowSize = fromInteger(dim);

  /* start/end test rules */
  rule prepare_data ((state == IDLE) && (count == 0));

    in[0] <= -240;
    in[1] <= 8;
    in[2] <= -11;
    in[3] <= 47;
    in[4] <= 26;
    in[5] <= -6;
    in[7] <= 5;
    in[8] <= 28;
    in[9] <= -6;
    in[10] <= 85;
    in[11] <= 44;
    in[12] <= -4;
    in[13] <= -25;
    in[14] <= 5;
    in[15] <= 16;
    in[16] <= 21;
    in[17] <= 8;
    in[18] <= 32;
    in[19] <= -16;
    in[20] <= -24;
    in[22] <= 30;
    in[23] <= 12;
    in[24] <= -2;
    in[25] <= 18;
    in[27] <= -2;
    in[29] <= 7;
    in[31] <= -15;
    in[32] <= 7;
    in[33] <= 4;
    in[34] <= 15;
    in[35] <= -24;
    in[37] <= 9;
    in[38] <= 8;
    in[39] <= -6;
    in[40] <= 4;
    in[41] <= 9;
    in[43] <= -5;
    in[44] <= -6;
    in[48] <= -4;
    in[50] <= -6;
    in[53] <= 10;
    in[54] <= -10;
    in[55] <= -8;
    in[56] <= 6;
    in[63] <= -8;

    $dumpvars();
    state <= HAVE_DATA;
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

  rule test_end ((state == DONE) && (count == rowSize));
    OutDataType got = readVReg(out);

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

    state <= IDLE;
    count <= 0;
    if (got == want) begin
      $display("axi_test: OK");
      $finish(0);
    end
    else begin
      $display("axi_test: FAIL");
      $finish(1);
    end
  endrule

endmodule: mkIdctSingleTestbench

endpackage // IdctSingleTestbench
