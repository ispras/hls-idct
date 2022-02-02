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

import Vector::*;

typedef 8 DataDim;
typedef TMul#(DataDim, DataDim) DataSize;

typedef 2841 W1; /* 2048*sqrt(2)*cos(1*pi/16) */
typedef 2676 W2; /* 2048*sqrt(2)*cos(2*pi/16) */
typedef 2408 W3; /* 2048*sqrt(2)*cos(3*pi/16) */
typedef 1609 W5; /* 2048*sqrt(2)*cos(5*pi/16) */
typedef 1108 W6; /* 2048*sqrt(2)*cos(6*pi/16) */
typedef 565 W7;  /* 2048*sqrt(2)*cos(7*pi/16) */
typedef 181 R2;  /* 256/sqrt(2) */

/* Input data */

typedef 12 InputLength;
typedef Int#(InputLength) InputType;
typedef Vector#(DataSize, InputType) InDataType;
typedef Vector#(DataSize, Reg#(InputType)) InDataReg;

/* Internal registers */

typedef 13 DataLength;
typedef Int#(DataLength) DataInt;
typedef Vector#(DataSize, DataInt) DataType;
typedef Vector#(DataSize, Reg#(DataInt)) DataReg;

/* Output data */

typedef 9 OutputLength;
typedef Int#(OutputLength) OutputType;
typedef Vector#(DataSize, OutputType) OutDataType;
typedef Vector#(DataSize, Reg#(OutputType)) OutDataReg;

/* Internal state machine */

typedef enum { IDLE, HAVE_DATA, ROWS_PROCESSED, COLS_PROCESSED, DONE } State
  deriving(Bits, Eq);

function DataInt iclip(int x);
  return truncate((x < -256) ? -256 : ((x > 255) ? 255 : x));
endfunction

interface Idct_iface;
  method Action start(InDataType x);
  method ActionValue#(OutDataType) result();
endinterface: Idct_iface

interface IdctAxiWrapper_iface;
  method Action send(InputType x);
  method ActionValue#(OutputType) recv();
endinterface: IdctAxiWrapper_iface

module mkIdct (Idct_iface);

  DataReg blk       <- replicateM(mkRegU);
  Reg#(State) state <- mkReg(IDLE);

  Integer dataSize = valueOf(DataSize);
  Integer dataDim  = valueOf(DataDim);

  int w1 = fromInteger(valueOf(W1));
  int w2 = fromInteger(valueOf(W2));
  int w3 = fromInteger(valueOf(W3));
  int w5 = fromInteger(valueOf(W5));
  int w6 = fromInteger(valueOf(W6));
  int w7 = fromInteger(valueOf(W7));
  int r2 = fromInteger(valueOf(R2));

  function Action idctrow(Integer idx);
    action
      int x0 = (extend(blk[idx]) << 11) + 128;
      int x1 = extend(blk[idx + 4]) << 11;
      int x2 = extend(blk[idx + 6]);
      int x3 = extend(blk[idx + 2]);
      int x4 = extend(blk[idx + 1]);
      int x5 = extend(blk[idx + 7]);
      int x6 = extend(blk[idx + 5]);
      int x7 = extend(blk[idx + 3]);
      int x8 = 0;

      /* shortcut */
      if ((x1 | x2 | x3 | x4 | x5 | x6 | x7) == 0) begin
        blk[idx]     <= blk[idx] << 3;
        blk[idx + 1] <= blk[idx] << 3;
        blk[idx + 2] <= blk[idx] << 3;
        blk[idx + 3] <= blk[idx] << 3;
        blk[idx + 4] <= blk[idx] << 3;
        blk[idx + 5] <= blk[idx] << 3;
        blk[idx + 6] <= blk[idx] << 3;
        blk[idx + 7] <= blk[idx] << 3;
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
        blk[idx]     <= truncate((x7 + x1) >> 8);
        blk[idx + 1] <= truncate((x3 + x2) >> 8);
        blk[idx + 2] <= truncate((x0 + x4) >> 8);
        blk[idx + 3] <= truncate((x8 + x6) >> 8);
        blk[idx + 4] <= truncate((x8 - x6) >> 8);
        blk[idx + 5] <= truncate((x0 - x4) >> 8);
        blk[idx + 6] <= truncate((x3 - x2) >> 8);
        blk[idx + 7] <= truncate((x7 - x1) >> 8);
      end
    endaction
  endfunction

  function Action idctcol(Integer idx);
    action
      int x0 = (extend(blk[idx + 8 * 0]) << 8) + 8192;
      int x1 = extend(blk[idx + 8 * 4]) << 8;
      int x2 = extend(blk[idx + 8 * 6]);
      int x3 = extend(blk[idx + 8 * 2]);
      int x4 = extend(blk[idx + 8 * 1]);
      int x5 = extend(blk[idx + 8 * 7]);
      int x6 = extend(blk[idx + 8 * 5]);
      int x7 = extend(blk[idx + 8 * 3]);
      int x8 = 0;

      /* shortcut */
      if ((x1 | x2 | x3 | x4 | x5 | x6 | x7) == 0) begin
        int block = extend(blk[idx]);
        blk[idx + 8 * 0] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 1] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 2] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 3] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 4] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 5] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 6] <= iclip((block + 32) >> 6);
        blk[idx + 8 * 7] <= iclip((block + 32) >> 6);
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
        blk[idx + 8 * 0] <= iclip((x7 + x1) >> 14);
        blk[idx + 8 * 1] <= iclip((x3 + x2) >> 14);
        blk[idx + 8 * 2] <= iclip((x0 + x4) >> 14);
        blk[idx + 8 * 3] <= iclip((x8 + x6) >> 14);
        blk[idx + 8 * 4] <= iclip((x8 - x6) >> 14);
        blk[idx + 8 * 5] <= iclip((x0 - x4) >> 14);
        blk[idx + 8 * 6] <= iclip((x3 - x2) >> 14);
        blk[idx + 8 * 7] <= iclip((x7 - x1) >> 14);
      end
    endaction
  endfunction

  function OutputType toOutput(Integer i);
    return truncate(blk[i]);
  endfunction

  rule process_rows (state == HAVE_DATA);

    for (Integer i = 0; i < dataDim; i = i + 1) begin
      idctrow(8 * i);
    end

    state <= ROWS_PROCESSED;
  endrule

  rule process_columns (state == ROWS_PROCESSED);

    for (Integer i = 0; i < dataDim; i = i + 1) begin
      idctcol(i);
    end

    state <= COLS_PROCESSED;
  endrule

  rule stop_processing (state == COLS_PROCESSED);
    state <= DONE;
  endrule

  method Action start(InDataType data) if (state == IDLE);
    writeVReg(blk, map(extend, data));
    state <= HAVE_DATA;
  endmethod

  method ActionValue#(OutDataType) result() if (state == DONE);
    state <= IDLE;
    return genWith(toOutput);
  endmethod

endmodule: mkIdct
endpackage // Idct
