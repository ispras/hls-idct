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

module Fast_IDCT(input [`WIN*8*8-1:0] in, output [`WOUT*8*8-1:0] out);

wire [`WIM*8*8-1:0] rtc;
wire [`WOUT*8*8-1:0] out;

genvar i;
generate for (i=1; i<8*8; i=i+8) begin
    idctrow ir(in[(i+0)*`WIN-1 : (i-1)*`WIN],
               in[(i+1)*`WIN-1 : (i+0)*`WIN],
               in[(i+2)*`WIN-1 : (i+1)*`WIN],
               in[(i+3)*`WIN-1 : (i+2)*`WIN],
               in[(i+4)*`WIN-1 : (i+3)*`WIN],
               in[(i+5)*`WIN-1 : (i+4)*`WIN],
               in[(i+6)*`WIN-1 : (i+5)*`WIN],
               in[(i+7)*`WIN-1 : (i+6)*`WIN],
               rtc[(i+0)*`WIM-1 : (i-1)*`WIM],
               rtc[(i+1)*`WIM-1 : (i+0)*`WIM],
               rtc[(i+2)*`WIM-1 : (i+1)*`WIM],
               rtc[(i+3)*`WIM-1 : (i+2)*`WIM],
               rtc[(i+4)*`WIM-1 : (i+3)*`WIM],
               rtc[(i+5)*`WIM-1 : (i+4)*`WIM],
               rtc[(i+6)*`WIM-1 : (i+5)*`WIM],
               rtc[(i+7)*`WIM-1 : (i+6)*`WIM]);
end
endgenerate
generate for (i=1; i<=8; i=i+1) begin
    idctcol ic(rtc[(i+8*0)*`WIM-1 : (i-1+8*0)*`WIM],
               rtc[(i+8*1)*`WIM-1 : (i-1+8*1)*`WIM],
               rtc[(i+8*2)*`WIM-1 : (i-1+8*2)*`WIM],
               rtc[(i+8*3)*`WIM-1 : (i-1+8*3)*`WIM],
               rtc[(i+8*4)*`WIM-1 : (i-1+8*4)*`WIM],
               rtc[(i+8*5)*`WIM-1 : (i-1+8*5)*`WIM],
               rtc[(i+8*6)*`WIM-1 : (i-1+8*6)*`WIM],
               rtc[(i+8*7)*`WIM-1 : (i-1+8*7)*`WIM],
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
endmodule // Fast_IDCT

module axi_stream_wrappered_idct(output [`WOUT-1:0] master_tdata, output master_tvalid, input master_tready,
                                 input [`WIN-1:0] slave_tdata, input slave_tvalid, output slave_tready,
                                 input clock, input reset_n);
reg [`WIN-1:0] in_buff [63:0];
reg [`WOUT-1:0] out_buff [63:0];
reg [5:0] in_counter;
reg [5:0] out_counter;
reg sample_out;
reg start_out;
reg ready;
wire [`WOUT*8*8-1:0] out;
Fast_IDCT idct(`ARRAY_TO_BITVECTOR(in_buff), out);
always @(posedge clock) begin
  if (~reset_n) begin
    `ARRAY_TO_BITVECTOR(in_buff) <= 0;
    `ARRAY_TO_BITVECTOR(out_buff) <= 0;
    in_counter <= 0;
    out_counter <= 0;
    sample_out <= 0;
    start_out <= 0;
    ready <= 1;
  end else begin
    if (sample_out) begin
      `ARRAY_TO_BITVECTOR(out_buff) <= out;
      sample_out <= 0;
      start_out <= 1;
    end
    if (slave_tvalid && ready) begin
      in_buff[in_counter] <= slave_tdata;
      in_counter <= in_counter + 1;
      if (in_counter == 6'h3f) begin
        if (~start_out) begin
          sample_out <= 1;
        end else begin
          ready <= 0;
        end
      end
    end
    if (start_out) begin
      if (master_tready) begin
        out_counter <= out_counter + 1;
        if (out_counter == 6'h3f) begin
          start_out <= 0;
        end
      end
    end else begin
      if (~ready) begin
        sample_out <= 1;
        ready <= 1;
      end
    end
  end
end
assign master_tdata = start_out ? out_buff[out_counter] : 0;
assign master_tvalid = start_out ? 1 : 0;
assign slave_tready = ready;
endmodule
