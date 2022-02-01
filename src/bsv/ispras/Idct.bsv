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

import Typedefs::*;
import Vector::*;

typedef 8 DataDim;
typedef TMul#(DataDim, DataDim) DataSize;
typedef UInt#(TAdd#(TLog#(DataDim), 1)) CountType;

/* Input data */

typedef 12 InputLength;
typedef Int#(InputLength) InputType;
typedef Vector#(DataDim, InputType) InDataRow;
typedef Vector#(DataSize, InputType) InDataType;
typedef Vector#(DataSize, Reg#(InputType)) InDataReg;

/* Internal registers */

typedef 13 DataLength;
typedef Int#(DataLength) DataInt;
typedef Vector#(DataDim, DataInt) DataFrag;
typedef Vector#(DataSize, DataInt) DataType;
typedef Vector#(DataSize, Reg#(DataInt)) DataReg;

/* Output data */

typedef 9 OutputLength;
typedef Int#(OutputLength) OutputType;
typedef Vector#(DataDim, OutputType) OutDataCol;
typedef Vector#(DataSize, OutputType) OutDataType;
typedef Vector#(DataSize, Reg#(OutputType)) OutDataReg;

/* Row/column processors */

typedef Vector#(DataDim, Idct_ifc#(InDataRow, DataFrag)) RowProcessors;
typedef Vector#(DataDim, Idct_ifc#(DataFrag, OutDataCol)) ColProcessors;

/* AXI-like wrapper state machine */

typedef enum { IDLE, HAVE_DATA, DONE } State deriving(Bits, Eq);

interface Idct_ifc#(type iType, type oType);
  method ActionValue#(oType) run(iType x);
endinterface

interface IdctAxiWrapper_ifc;
  method Action sendRow(InDataRow x);
  method ActionValue#(OutDataCol) recvRow();
endinterface: IdctAxiWrapper_ifc

module mkIdctRow(Idct_ifc#(InDataRow, DataFrag));

  method ActionValue#(DataFrag) run(InDataRow x);

    DataFrag out = newVector;

    int x0 = (extend(x[0]) << 11) + 128;
    int x1 = extend(x[4]) << 11;
    int x2 = extend(x[6]);
    int x3 = extend(x[2]);
    int x4 = extend(x[1]);
    int x5 = extend(x[7]);
    int x6 = extend(x[5]);
    int x7 = extend(x[3]);
    int x8 = 0;

    /* shortcut */
    if ((x1 | x2 | x3 | x4 | x5 | x6 | x7) == 0) begin
      DataInt res = extend(x[0] << 3);
      out = replicate(res);
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
      out[0] = truncate((x7 + x1) >> 8);
      out[1] = truncate((x3 + x2) >> 8);
      out[2] = truncate((x0 + x4) >> 8);
      out[3] = truncate((x8 + x6) >> 8);
      out[4] = truncate((x8 - x6) >> 8);
      out[5] = truncate((x0 - x4) >> 8);
      out[6] = truncate((x3 - x2) >> 8);
      out[7] = truncate((x7 - x1) >> 8);
    end
    return out;
  endmethod
endmodule: mkIdctRow

module mkIdctCol(Idct_ifc#(DataFrag, OutDataCol));

  function OutputType iclip(int x);
    return truncate((x < -256) ? -256 : ((x > 255) ? 255 : x));
  endfunction

  method ActionValue#(OutDataCol) run(DataFrag x);

    OutDataCol out = newVector;

    int x0 = (extend(x[0]) << 8) + 8192;
    int x1 = extend(x[4]) << 8;
    int x2 = extend(x[6]);
    int x3 = extend(x[2]);
    int x4 = extend(x[1]);
    int x5 = extend(x[7]);
    int x6 = extend(x[5]);
    int x7 = extend(x[3]);
    int x8 = 0;

    /* shortcut */
    if ((x1 | x2 | x3 | x4 | x5 | x6 | x7) == 0) begin
      OutputType res = iclip((extend(x[0]) + 32) >> 6);
      out = replicate(res);
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
      out[0] = iclip((x7 + x1) >> 14);
      out[1] = iclip((x3 + x2) >> 14);
      out[2] = iclip((x0 + x4) >> 14);
      out[3] = iclip((x8 + x6) >> 14);
      out[4] = iclip((x8 - x6) >> 14);
      out[5] = iclip((x0 - x4) >> 14);
      out[6] = iclip((x3 - x2) >> 14);
      out[7] = iclip((x7 - x1) >> 14);
    end
    return out;
  endmethod
endmodule: mkIdctCol

module mkIdct (Idct_ifc#(InDataType, OutDataType));

  RowProcessors rows <- replicateM(mkIdctRow);
  ColProcessors cols <- replicateM(mkIdctCol);

  Integer dataDim  = valueOf(DataDim);

  function DataFrag getCol(DataType data, Integer i);
    DataFrag res = newVector;
    for (Integer j = 0; j < dataDim; j = j + 1) begin
      res[j] = data[i + 8 * j];
    end
    return res;
  endfunction

  method ActionValue#(OutDataType) run(InDataType data);

    DataType tmp = newVector;
    OutDataType res = newVector;

    for (Integer i = 0; i < dataDim; i = i + 1) begin
      InDataRow frag = takeAt(8 * i, data);
      DataFrag dataFrag <- rows[i].run(frag);
      for (Integer j = 0; j < dataDim; j = j + 1) begin
        tmp[8 * i + j] = dataFrag[j];
      end
    end

    for (Integer i = 0; i < dataDim; i = i + 1) begin
      OutDataCol outFrag <- cols[i].run(getCol(tmp, i));
      for (Integer j = 0; j < dataDim; j = j + 1) begin
        res[i + 8 * j] = outFrag[j];
      end
    end
    return res;
  endmethod

endmodule: mkIdct

/* AXI-like wrapper (for synthesis only) */

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

endpackage // Idct
