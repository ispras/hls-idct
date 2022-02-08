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

`include "idct_s1.v"
`include "idct_rows_and_cols_macros.v"

module wide_axi_stream_wrappered_idct(output [`WOUT*8-1:0] master_tdata, output master_tvalid, input master_tready,
                                      input [`WIN*8-1:0] slave_tdata, input slave_tvalid, output slave_tready,
                                      input clock, input reset_n);
reg [`WIN-1:0] in_buff [63:0];
reg [`WOUT-1:0] out_buff [63:0];
reg [3:0] in_counter;
reg [2:0] out_counter;
reg sample_out;
reg start_out;
reg ready;
wire [`WOUT*8*8-1:0] out;

__idct__idct idct(clock, `ARRAY_TO_BITVECTOR(in_buff), out);

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
    if (slave_tvalid && ready || (in_counter == 8) || (in_counter == 9)) begin
      if (in_counter == 9) begin
        if (~start_out) begin
          sample_out <= 1;
          in_counter <= 0;
        end else begin
          ready <= 0;
        end
      end
      else begin
        in_counter <= in_counter + 1;
        if (in_counter < 8) begin
          `ROW_OF_ARRAY(in_buff, in_counter*8) <= slave_tdata;
        end
      end
    end
    if (start_out) begin
      if (master_tready) begin
        out_counter <= out_counter + 1;
        if (out_counter == 7) begin
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
assign master_tdata = start_out ? `ROW_OF_ARRAY(out_buff, out_counter*8) : 0;
assign master_tvalid = start_out ? 1 : 0;
assign slave_tready = ready;
endmodule
