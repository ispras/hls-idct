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

interface IdctAxiWrapper_ifc;
  method Action sendRow(InDataRow x);
  method ActionValue#(OutDataCol) recvRow();
endinterface: IdctAxiWrapper_ifc

(* synthesize *)
module mkIdctAxiWrapper(IdctAxiWrapper_ifc);

  Reg#(CountType) count                   <- mkReg(0);
  Reg#(State) state                       <- mkReg(IDLE);
  Idct_ifc#(InDataType, OutDataType) idct <- mkIdct;
  InDataReg inputs                        <- replicateM(mkRegU);
  OutDataReg outputs                      <- replicateM(mkRegU);

  Integer dim = valueOf(DataDim);
  CountType rowSize = fromInteger(dim);

  function Integer getRowNum(CountType x);
    return (x == 0) ? 0 :
        ((x == 1) ? 1 :
            ((x == 2) ? 2 :
                ((x == 3) ? 3 :
                    ((x == 4) ? 4 : (x == 5) ? 5 : (x == 6) ? 6 : 7))));
  endfunction

  rule run ((state == HAVE_DATA) && (count == rowSize));
    OutDataType out <- idct.run(readVReg(inputs));
    writeVReg(outputs, out);
    count <= 0;
    state <= DONE;
  endrule

  method Action sendRow(InDataRow x) if ((state == IDLE) && (count < rowSize));
    for (Integer i = 0; i < dim; i = i + 1) begin
      inputs[getRowNum(count) * 8 + i] <= x[i];
    end
    count <= count + 1;
    state <= HAVE_DATA;
  endmethod

  method ActionValue#(OutDataCol) recvRow() if ((state == DONE) && (count < rowSize));
    OutDataCol result = newVector;
    for(Integer i = 0; i < dim; i = i + 1) begin
      result[i] = outputs[getRowNum(count) * 8 + i];
    end
    count <= count + 1;
    state <= IDLE;
    return result;
  endmethod
endmodule: mkIdctAxiWrapper

endpackage
