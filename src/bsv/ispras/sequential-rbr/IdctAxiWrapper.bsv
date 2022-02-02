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
 * IDCT AXI-like wrapper that operates in Row-By-Row (RBR) manner.
 */
package IdctAxiWrapper;

import Idct::*;
import Vector::*;

typedef UInt#(TAdd#(TLog#(DataDim), 1)) CountType;
typedef Vector#(DataDim, InputType) InDataRow;
typedef Vector#(DataDim, OutputType) OutDataRow;

typedef enum { IDLE, SEND, NEXT_SEND, RUN, RECV, NEXT_RECV } AxiState deriving(Bits, Eq);

function Integer getRowNum(CountType x);
  return (x == 0) ? 0 :
      ((x == 1) ? 1 :
          ((x == 2) ? 2 :
              ((x == 3) ? 3 :
                  ((x == 4) ? 4 : (x == 5) ? 5 : (x == 6) ? 6 : 7))));
endfunction

interface IdctAxiWrapper_ifc;
  method Action sendRow(InDataRow x);
  method ActionValue#(OutDataRow) recvRow();
endinterface: IdctAxiWrapper_ifc

(* synthesize *)
module mkIdctAxiWrapper(IdctAxiWrapper_ifc);

  Reg#(CountType) count <- mkReg(0);
  Reg#(AxiState) state     <- mkReg(IDLE);
  Idct_iface idct       <- mkIdct;
  InDataReg inputs      <- replicateM(mkRegU);
  OutDataReg outputs    <- replicateM(mkRegU);

  Integer dim = valueOf(DataDim);
  CountType rowSize = fromInteger(dim);

  rule run ((state == IDLE) && (count == rowSize));
    idct.start(readVReg(inputs));
    count <= 0;
    state <= RUN;
  endrule

  rule write_result ((state == RUN) && (count == 0));
    OutDataType out <- idct.result();
    writeVReg(outputs, out);
    state <= IDLE;
  endrule

  method Action sendRow(InDataRow x) if ((state == IDLE) && (count < rowSize));
    for (Integer i = 0; i < dim; i = i + 1) begin
      inputs[getRowNum(count) * 8 + i] <= x[i];
    end
    count <= count + 1;
  endmethod

  method ActionValue#(OutDataRow) recvRow() if ((state == IDLE) && (count < rowSize));
    OutDataRow result = newVector;
    for(Integer i = 0; i < dim; i = i + 1) begin
      result[i] = outputs[getRowNum(count) * 8 + i];
    end
    count <= count + 1;
    return result;
  endmethod
endmodule: mkIdctAxiWrapper

endpackage
