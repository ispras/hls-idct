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
 * Wrapper for IDCT & idct_test0 input/ouput data.
 */
package IdctTest0Wrapper;

import Idct::*;
import IdctTestbench::*;
import Vector::*;

interface IdctWrapper_iface;
  method Action start();
  method ActionValue#(Bool) result();
endinterface: IdctWrapper_iface

(* synthesize *)
module mkIdctTest0Wrapper(IdctWrapper_iface);

  Idct_iface idct <- mkIdct;
  Reg#(Bool) done <- mkReg(False);

  method Action start() if (!done);
    InDataType in = genWith(idct0_test_init);
    idct.start(in);
    done <= True;
  endmethod

  method ActionValue#(Bool) result() if (done);
    OutDataType out <- idct.result();
    OutDataType want = genWith(idct0_test_want);
    return (out == want);
  endmethod

endmodule: mkIdctTest0Wrapper

endpackage
