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

module Fast_IDCT_Wide_1R1C(input [`WIN*8-1:0] in, output [`WOUT*8*8-1:0] out, input clock, input reset_n,
  input valid_in, output done, output [`WOUT*8-1:0] last_col);

wire [`WIM*8-1:0] rtc;
reg  [`WIM*8*8-1:0] rtc_reg;
reg  [`WIM*8*8-1:0] rtc_reg2;
wire [`WOUT*8*8-1:0] out;
reg  [`WOUT*8*8-1:0] out_reg;
reg  [2:0] row_index;
reg  [2:0] col_index;
reg  valid_in_reg;
wire done;
reg  done_reg;
reg  rd_reg;
reg  [`WIM*8-1:0] rtc_col_reg;
wire [`WOUT*8-1:0] out_col;
wire [`WOUT*8-1:0] last_col;

idctrow ir(in[8*`WIN-1 : 7*`WIN],
           in[7*`WIN-1 : 6*`WIN],
           in[6*`WIN-1 : 5*`WIN],
           in[5*`WIN-1 : 4*`WIN],
           in[4*`WIN-1 : 3*`WIN],
           in[3*`WIN-1 : 2*`WIN],
           in[2*`WIN-1 : 1*`WIN],
           in[1*`WIN-1 : 0*`WIN],
           rtc[1*`WIM-1 : 0*`WIM],
           rtc[2*`WIM-1 : 1*`WIM],
           rtc[3*`WIM-1 : 2*`WIM],
           rtc[4*`WIM-1 : 3*`WIM],
           rtc[5*`WIM-1 : 4*`WIM],
           rtc[6*`WIM-1 : 5*`WIM],
           rtc[7*`WIM-1 : 6*`WIM],
           rtc[8*`WIM-1 : 7*`WIM]);

`define COLUMN(name, index, width) \
  { name[(index+1+8*7)*``width-1 : (index+8*7)*``width],\
    name[(index+1+8*6)*``width-1 : (index+8*6)*``width],\
    name[(index+1+8*5)*``width-1 : (index+8*5)*``width],\
    name[(index+1+8*4)*``width-1 : (index+8*4)*``width],\
    name[(index+1+8*3)*``width-1 : (index+8*3)*``width],\
    name[(index+1+8*2)*``width-1 : (index+8*2)*``width],\
    name[(index+1+8*1)*``width-1 : (index+8*1)*``width],\
    name[(index+1+8*0)*``width-1 : (index+8*0)*``width] }

`define COL_OF_ARRAY(a, i) \
 {a[i+8*7], a[i+8*6], a[i+8*5], a[i+8*4], a[i+8*3], a[i+8*2], a[i+8*1], a[i+8*0]}

idctcol ic(rtc_col_reg[1*`WIM-1 : 0*`WIM],
           rtc_col_reg[2*`WIM-1 : 1*`WIM],
           rtc_col_reg[3*`WIM-1 : 2*`WIM],
           rtc_col_reg[4*`WIM-1 : 3*`WIM],
           rtc_col_reg[5*`WIM-1 : 4*`WIM],
           rtc_col_reg[6*`WIM-1 : 5*`WIM],
           rtc_col_reg[7*`WIM-1 : 6*`WIM],
           rtc_col_reg[8*`WIM-1 : 7*`WIM],
           out_col[1*`WOUT-1 : 0*`WOUT],
           out_col[2*`WOUT-1 : 1*`WOUT],
           out_col[3*`WOUT-1 : 2*`WOUT],
           out_col[4*`WOUT-1 : 3*`WOUT],
           out_col[5*`WOUT-1 : 4*`WOUT],
           out_col[6*`WOUT-1 : 5*`WOUT],
           out_col[7*`WOUT-1 : 6*`WOUT],
           out_col[8*`WOUT-1 : 7*`WOUT]);

always @(posedge clock) begin
  if (~reset_n) begin
    rtc_reg <= 0;
    row_index <= 0;
    col_index <= 0;
    rd_reg <= 0;
    done_reg <= 0;
    out_reg <= 0;
  end else begin
    if (valid_in || valid_in_reg) begin
      valid_in_reg <= valid_in;
      if (valid_in_reg) begin
        row_index <= row_index + 1;
      end
      case(row_index)
      0: rtc_reg[(1)*8*`WIM-1 : 0*8*`WIM] <= rtc;
      1: rtc_reg[(2)*8*`WIM-1 : 1*8*`WIM] <= rtc;
      2: rtc_reg[(3)*8*`WIM-1 : 2*8*`WIM] <= rtc;
      3: rtc_reg[(4)*8*`WIM-1 : 3*8*`WIM] <= rtc;
      4: rtc_reg[(5)*8*`WIM-1 : 4*8*`WIM] <= rtc;
      5: rtc_reg[(6)*8*`WIM-1 : 5*8*`WIM] <= rtc;
      6: rtc_reg[(7)*8*`WIM-1 : 6*8*`WIM] <= rtc;
      7: begin rtc_reg2[(7)*8*`WIM-1:0] <= rtc_reg[(7)*8*`WIM-1:0];
               rtc_reg2[(8)*8*`WIM-1 : 7*8*`WIM] <= rtc;
               rd_reg <= 1;
               rtc_col_reg <= { rtc    [(1)*`WIM-1 : (0)*`WIM],
                                rtc_reg[(1+8*6)*`WIM-1 : (8*6)*`WIM],
                                rtc_reg[(1+8*5)*`WIM-1 : (8*5)*`WIM],
                                rtc_reg[(1+8*4)*`WIM-1 : (8*4)*`WIM],
                                rtc_reg[(1+8*3)*`WIM-1 : (8*3)*`WIM],
                                rtc_reg[(1+8*2)*`WIM-1 : (8*2)*`WIM],
                                rtc_reg[(1+8*1)*`WIM-1 : (8*1)*`WIM],
                                rtc_reg[(1+8*0)*`WIM-1 : (8*0)*`WIM]};
        end
      endcase
    end
    if (rd_reg) begin
      case(col_index)
      0: begin rtc_col_reg <= `COLUMN(rtc_reg2, 1, `WIM); `COLUMN(out_reg, 0, `WOUT) <= out_col; end
      1: begin rtc_col_reg <= `COLUMN(rtc_reg2, 2, `WIM); `COLUMN(out_reg, 1, `WOUT) <= out_col; end
      2: begin rtc_col_reg <= `COLUMN(rtc_reg2, 3, `WIM); `COLUMN(out_reg, 2, `WOUT) <= out_col; end
      3: begin rtc_col_reg <= `COLUMN(rtc_reg2, 4, `WIM); `COLUMN(out_reg, 3, `WOUT) <= out_col; end
      4: begin rtc_col_reg <= `COLUMN(rtc_reg2, 5, `WIM); `COLUMN(out_reg, 4, `WOUT) <= out_col; end
      5: begin rtc_col_reg <= `COLUMN(rtc_reg2, 6, `WIM); `COLUMN(out_reg, 5, `WOUT) <= out_col; end
      6: begin rtc_col_reg <= `COLUMN(rtc_reg2, 7, `WIM); `COLUMN(out_reg, 6, `WOUT) <= out_col; done_reg <= 1; end
      7: begin if (row_index != 7) rd_reg <= 0;           `COLUMN(out_reg, 7, `WOUT) <= out_col; done_reg <= 0; end
      endcase
      col_index <= col_index + 1;
    end
  end
end
assign done = done_reg;
assign last_col = out_col;
assign out = out_reg;

endmodule // Fast_IDCT_Wide_Pipe

module wide_axi_stream_wrappered_1r1c_idct(output [`WOUT*8-1:0] master_tdata, output master_tvalid, input master_tready,
                                           input [`WIN*8-1:0] slave_tdata, input slave_tvalid, output slave_tready,
                                           input clock, input reset_n);
reg [`WOUT-1:0] out_buff [63:0];
wire [`WOUT*8*8-1:0] outt;
reg [2:0] in_counter;
reg [2:0] out_counter;
reg [2:0] sample_out;
reg start_out;
reg ready;
wire [`WOUT*8*8-1:0] out;
wire [`WOUT*8-1:0] last_col;
wire done;
reg done_reg;
assign outt = `ARRAY_TO_BITVECTOR(out_buff);
Fast_IDCT_Wide_1R1C idct(slave_tdata, out, clock, reset_n, slave_tvalid, done, last_col);
always @(posedge clock) begin
  if (~reset_n) begin
    `ARRAY_TO_BITVECTOR(out_buff) <= 0;
    in_counter <= 0;
    out_counter <= 0;
    sample_out <= 0;
    start_out <= 0;
    ready <= 1;
    done_reg <= 0;
  end else begin
    if (done || done_reg) begin
      if (~start_out) begin
        `ARRAY_TO_BITVECTOR(out_buff) <= out;
        `COL_OF_ARRAY(out_buff, 7) <= last_col;
        start_out <= 1;
        ready <= 1;
        done_reg <= 0;
        out_counter <= out_counter + 1;
      end else begin
        ready <= 0;
        done_reg <= 1;
      end
    end
    if (start_out) begin
      if (master_tready) begin
        out_counter <= out_counter + 1;
        if (out_counter == 7) begin
          start_out <= 0;
        end
      end
    end
  end
end
assign master_tdata = done ? {out[`WOUT-1:0], out[`WOUT*2-1:`WOUT], out[`WOUT*3-1:`WOUT*2], out[`WOUT*4-1:`WOUT*3],
                              out[`WOUT*5-1:`WOUT*4], out[`WOUT*6-1:`WOUT*5], out[`WOUT*7-1:`WOUT*6], last_col[`WOUT-1:0]} :
                      done_reg ? `ROW_OF_ARRAY(out_buff, 0) :
                      start_out ? `ROW_OF_ARRAY(out_buff, out_counter*8) : 0;
assign master_tvalid = (start_out || done || done_reg) ? 1 : 0;
assign slave_tready = ready;
endmodule
