`include "Fast_IDCT.v"

module testbench();

reg clock = 1'b0;
reg reset = 1'b0;
reg [15:0] input_matrix[0:63];
reg [15:0] output_matrix[0:63];
reg start;
reg [31:0] cycles = 0;

wire [1:0] out_we;
wire [1:0] out_oe;
wire out_done;
wire [9:0] out_data_size;
wire [63:0] out_addr;
wire [31:0] out_data;
wire [31:0] in_data;
wire [15:0] in_data_hi;
wire [15:0] in_data_lo;

wire [1:0] in_data_rdy;
wire read_data_hi;
wire write_data_hi;

wire read_data_lo;
wire write_data_lo;

wire [31:0] matrix_ind_hi;
wire [31:0] matrix_ind_lo;

wire [15:0] mask_hi;
wire [15:0] mask_lo;

wire [31:0] addr_hi;
wire [31:0] addr_lo;

assign in_data = {in_data_hi, in_data_lo};
assign in_data_hi = read_data_hi ? input_matrix[matrix_ind_hi] & mask_hi : 16'b0;
assign in_data_lo = read_data_lo ? input_matrix[matrix_ind_lo] & mask_lo : 16'b0;

assign in_data_rdy = {(out_oe[1] | out_we[1]), (out_oe[0] | out_we[0])};
assign read_data_hi = out_oe[1] & !out_we[1];
assign write_data_hi = !out_oe[1] & out_we[1];

assign read_data_lo = out_oe[0] & !out_we[0];
assign write_data_lo = !out_oe[0] & out_we[0];

assign addr_hi = out_addr[63:32];
assign addr_lo = out_addr[31:0];

assign matrix_ind_hi = addr_hi>>1;
assign matrix_ind_lo = addr_lo>>1;

assign mask_hi = (1 << out_data_size[9:5]) -1;
assign mask_lo = (1 << out_data_size[4:0]) -1; 

initial begin
    input_matrix[0] = -240;
    input_matrix[1] = 8;
    input_matrix[2] = -11;
    input_matrix[3] = 47;
    input_matrix[4] = 26;
    input_matrix[5] = -6;
    input_matrix[6] = 0;
    input_matrix[7] = 5;
    input_matrix[8] = 28;
    input_matrix[9] = -6;
    input_matrix[10] = 85;
    input_matrix[11] = 44;
    input_matrix[12] = -4;
    input_matrix[13] = -25;
    input_matrix[14] = 5;
    input_matrix[15] = 16;
    input_matrix[16] = 21;
    input_matrix[17] = 8;
    input_matrix[18] = 32;
    input_matrix[19] = -16;
    input_matrix[20] = -24;
    input_matrix[21] = 0;
    input_matrix[22] = 30;
    input_matrix[23] = 12;
    input_matrix[24] = -2;
    input_matrix[25] = 18;
    input_matrix[26] = 0;
    input_matrix[27] = -2;
    input_matrix[28] = 0;
    input_matrix[29] = 7;
    input_matrix[30] = 0;
    input_matrix[31] = -15;
    input_matrix[32] = 7;
    input_matrix[33] = 4;
    input_matrix[34] = 15;
    input_matrix[35] = -24;
    input_matrix[36] = 0;
    input_matrix[37] = 9;
    input_matrix[38] = 8;
    input_matrix[39] = -6;
    input_matrix[40] = 4;
    input_matrix[41] = 9;
    input_matrix[42] = 0;
    input_matrix[43] = -5;
    input_matrix[44] = -6;
    input_matrix[45] = 0;
    input_matrix[46] = 0;
    input_matrix[47] = 0;
    input_matrix[48] = -4;
    input_matrix[49] = 0;
    input_matrix[50] = -6;
    input_matrix[51] = 0;
    input_matrix[52] = 0;
    input_matrix[53] = 10;
    input_matrix[54] = -10;
    input_matrix[55] = -8;
    input_matrix[56] = 6;
    input_matrix[57] = 0;
    input_matrix[58] = 0;
    input_matrix[59] = 0;
    input_matrix[60] = 0;
    input_matrix[61] = 0;
    input_matrix[62] = 0;
    input_matrix[63] = -8;

end

initial begin
    forever clock = #10 !clock;
end

initial begin
    reset = 1'b1;
    repeat (3) @(posedge clock);
    reset = 1'b0;
    @(posedge clock) start = 1'b1;
    cycles = 0;
    @(posedge clock) start = 1'b0;
end

always @(posedge clock) begin
    cycles = cycles + 1;
end

always @(posedge clock) begin
    if (reset) begin
        start = 1'b0;
    end
end

always @(posedge clock) begin
    if (write_data_hi) begin
        input_matrix[matrix_ind_hi] = (out_data[31:16] & mask_hi) | (input_matrix[matrix_ind_hi] & ~mask_hi);
    end
    if (write_data_lo) begin
        input_matrix[matrix_ind_lo] = (out_data[15:0] & mask_lo) | (input_matrix[matrix_ind_lo] & ~mask_lo);
    end
end

always @(posedge out_done) begin
    repeat (10) @(posedge clock);
    $finish;
end

Fast_IDCT idct(.clock(clock),
  .reset(!reset),
  .start_port(start),
  .block(32'b0),
  .M_Rdata_ram(in_data),
  .M_DataRdy(in_data_rdy),
  .done_port(out_done),
  .Mout_oe_ram(out_oe),
  .Mout_we_ram(out_we),
  .Mout_addr_ram(out_addr),
  .Mout_Wdata_ram(out_data),
  .Mout_data_ram_size(out_data_size));


endmodule

