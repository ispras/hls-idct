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

typedef UInt#(TAdd#(TLog#(DataSize), 1)) CountType;

interface IdctAxiWrapper_iface;
  method Action send(InputType x);
  method ActionValue#(OutputType) recv();
endinterface: IdctAxiWrapper_iface

(* synthesize *)
module mkIdctAxiWrapper(IdctAxiWrapper_iface);

  Reg#(CountType) count    <- mkReg(0);
  Reg#(State) state  <- mkReg(IDLE);
  Idct_iface idct    <- mkIdct;
  InDataReg inputs   <- replicateM(mkRegU);
  OutDataReg outputs <- replicateM(mkRegU);

  CountType size = fromInteger(valueOf(DataSize));

  rule run ((state == IDLE) && (count == size));
    idct.start(readVReg(inputs));
    state <= HAVE_DATA;
  endrule

  rule get_result ((state == HAVE_DATA) && (count == size));
    OutDataType result <- idct.result();
    writeVReg(outputs, result);
    count <= 0;
    state <= DONE;
  endrule

  method Action send(InputType x) if ((state == IDLE) && (count < size));
    inputs[count] <= x;
    count <= count + 1;
  endmethod

  method ActionValue#(OutputType) recv() if ((state == DONE) && (count < size));
    count <= count + 1;
    return outputs[count];
  endmethod
endmodule: mkIdctAxiWrapper

endpackage
