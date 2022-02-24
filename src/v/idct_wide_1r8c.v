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

module Fast_IDCT_Wide_1R8C(input [`WIN*8-1:0] in, output [`WOUT*8*8-1:0] out, input clock, input reset_n, input valid_in, output done);

wire [`WIM*8-1:0] rtc;
reg  [`WIM*8*8-1:0] rtc_reg;
wire [`WOUT*8*8-1:0] out;
reg  [2:0] row_index;
reg  valid_in_reg;
wire done;
reg  done_reg;

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

genvar i;
generate for (i=1; i<=8; i=i+1) begin
    idctcol ic(rtc_reg[(i+8*0)*`WIM-1 : (i-1+8*0)*`WIM],
               rtc_reg[(i+8*1)*`WIM-1 : (i-1+8*1)*`WIM],
               rtc_reg[(i+8*2)*`WIM-1 : (i-1+8*2)*`WIM],
               rtc_reg[(i+8*3)*`WIM-1 : (i-1+8*3)*`WIM],
               rtc_reg[(i+8*4)*`WIM-1 : (i-1+8*4)*`WIM],
               rtc_reg[(i+8*5)*`WIM-1 : (i-1+8*5)*`WIM],
               rtc_reg[(i+8*6)*`WIM-1 : (i-1+8*6)*`WIM],
               rtc_reg[(i+8*7)*`WIM-1 : (i-1+8*7)*`WIM],
               out[(i+8*0)*`WOUT-1 : (i-1+8*0)*`WOUT],
               out[(i+8*1)*`WOUT-1 : (i-1+8*1)*`WOUT],
               out[(i+8*2)*`WOUT-1 : (i-1+8*2)*`WOUT],
               out[(i+8*3)*`WOUT-1 : (i-1+8*3)*`WOUT],
               out[(i+8*4)*`WOUT-1 : (i-1+8*4)*`WOUT],
               out[(i+8*5)*`WOUT-1 : (i-1+8*5)*`WOUT],
               out[(i+8*6)*`WOUT-1 : (i-1+8*6)*`WOUT],
               out[(i+8*7)*`WOUT-1 : (i-1+8*7)*`WOUT]);
end
endgenerate

always @(posedge clock) begin
  if (~reset_n) begin
    rtc_reg <= 0;
    row_index <= 0;
    done_reg <= 0;
  end else if (valid_in || valid_in_reg) begin
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
    7: begin rtc_reg[(8)*8*`WIM-1 : 7*8*`WIM] <= rtc; done_reg <= 1; end
    endcase
  end
  if (done_reg) begin
    done_reg <= 0;
  end
end
assign done = done_reg;

endmodule // Fast_IDCT_Wide_Pipe

module wide_axi_stream_wrappered_1r8c_idct(output [`WOUT*8-1:0] master_tdata, output master_tvalid, input master_tready,
                                           input [`WIN*8-1:0] slave_tdata, input slave_tvalid, output slave_tready,
                                           input clock, input reset_n);
reg [`WOUT-1:0] out_buff [63:0];
reg [2:0] in_counter;
reg [2:0] out_counter;
reg [2:0] sample_out;
reg start_out;
reg ready;
wire [`WOUT*8*8-1:0] out;
wire done;
reg done_reg;
Fast_IDCT_Wide_1R8C idct(slave_tdata, out, clock, reset_n, slave_tvalid, done);
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
                              out[`WOUT*5-1:`WOUT*4], out[`WOUT*6-1:`WOUT*5], out[`WOUT*7-1:`WOUT*6], out[`WOUT*8-1:`WOUT*7]} :
                      done_reg ? `ROW_OF_ARRAY(out_buff, 0) :
                      start_out ? `ROW_OF_ARRAY(out_buff, out_counter*8) : 0;
assign master_tvalid = (start_out || done || done_reg) ? 1 : 0;
assign slave_tready = ready;
endmodule
