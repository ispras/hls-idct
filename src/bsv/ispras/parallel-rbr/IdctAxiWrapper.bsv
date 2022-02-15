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
typedef Vector#(DataDim, OutputType) OutDataRow;

function Integer getRowNum(CountType x);
 return (x == 0) ? 0 :
     ((x == 1) ? 1 :
         ((x == 2) ? 2 :
             ((x == 3) ? 3 :
                 ((x == 4) ? 4 : (x == 5) ? 5 : (x == 6) ? 6 : 7))));
endfunction

interface IdctAxiWrapper_ifc;
  method Action send(InDataRow x);
  method ActionValue#(OutDataRow) recv();
endinterface: IdctAxiWrapper_ifc

(* synthesize *)
module mkIdctAxiWrapper(IdctAxiWrapper_ifc);

  Reg#(CountType) cnt                     <- mkReg(0);
  Reg#(State) state                       <- mkReg(IDLE);
  Idct_ifc#(InDataType, OutDataType) idct <- mkIdct;
  InDataReg inputs                        <- replicateM(mkRegU);
  OutDataReg outputs                      <- replicateM(mkRegU);

  Integer dim = valueOf(DataDim);
  CountType rowNum = fromInteger(dim);

  rule run ((state == IDLE) && (cnt == rowNum));
    OutDataType out <- idct.run(readVReg(inputs));
    writeVReg(outputs, out);
    state <= DONE;
    cnt <= 0;
  endrule

  rule stop_recv ((state == DONE) && (cnt == rowNum));
    cnt <= 0;
    state <= IDLE;
  endrule

  method Action send(InDataRow x) if ((state == IDLE) && (cnt < rowNum));
    for (Integer i = 0; i < dim; i = i + 1) begin
      inputs[getRowNum(cnt) * 8 + i] <= x[i];
    end
    cnt <= cnt + 1;
  endmethod

  method ActionValue#(OutDataRow) recv() if ((state == DONE) && (cnt < rowNum));
    OutDataRow result = newVector;
    for(Integer i = 0; i < dim; i = i + 1) begin
      result[i] = outputs[getRowNum(cnt) * 8 + i];
    end
    cnt <= cnt + 1;
    return result;
  endmethod
endmodule: mkIdctAxiWrapper
endpackage
