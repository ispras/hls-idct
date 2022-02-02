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
 * IDCT AXI-like wrapper that operates in Symbol-By-Symbol (SBS) manner.
 */
package IdctAxiWrapper;

import Idct::*;
import Vector::*;

interface IdctAxiWrapper_ifc;
  method Action send(InputType x);
  method ActionValue#(OutputType) recv();
endinterface: IdctAxiWrapper_ifc

(* synthesize *)
module mkIdctAxiWrapper(IdctAxiWrapper_ifc);

  Reg#(int) count                         <- mkReg(0);
  Reg#(State) state                       <- mkReg(IDLE);
  Idct_ifc#(InDataType, OutDataType) idct <- mkIdct;
  InDataReg inputs                        <- replicateM(mkRegU);
  OutDataReg outputs                      <- replicateM(mkRegU);

  int size = fromInteger(valueOf(DataSize));

  rule run ((state == HAVE_DATA) && (count == size));
    OutDataType out <- idct.run(readVReg(inputs));
    writeVReg(outputs, out);
    count <= 0;
    state <= DONE;
  endrule

  method Action send(InputType x) if ((state == IDLE) && (count < size));
    inputs[count] <= x;
    count <= count + 1;
    state <= HAVE_DATA;
  endmethod

  method ActionValue#(OutputType) recv() if ((state == DONE) && (count < size));
    count <= count + 1;
    return outputs[count];
  endmethod
endmodule: mkIdctAxiWrapper

endpackage
