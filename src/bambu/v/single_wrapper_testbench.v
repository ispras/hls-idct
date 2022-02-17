`include "bambu_single_ram_axi_wrapper.v"

`define INIT_TEST0 \
    input_matrix[0] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, -12'd2, -12'd1,  12'd23}; \
    input_matrix[1] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, -12'd0,  12'd0}; \
    input_matrix[2] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[3] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0, -12'd0}; \
    input_matrix[4] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[5] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[6] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[7] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0};
    
`define INIT_TEST1 \
    input_matrix[0] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0, -12'd7, 12'd13}; \
    input_matrix[1] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd2, 12'd0}; \
    input_matrix[2] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, 12'd0}; \
    input_matrix[3] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, 12'd0}; \
    input_matrix[4] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, 12'd0}; \
    input_matrix[5] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, 12'd0}; \
    input_matrix[6] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, 12'd0}; \
    input_matrix[7] = {12'd0, 12'd0, 12'd0, 12'd0, 12'd0, 12'd0,  12'd0, 12'd0};
    
`define INIT_TEST2 \
    input_matrix[0] = {12'd0, 12'd0, 12'd0, 12'd0, -12'd4, -12'd4, -12'd7, -12'd166}; \
    input_matrix[1] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0, -12'd2}; \
    input_matrix[2] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0, -12'd2}; \
    input_matrix[3] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[4] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[5] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[6] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0,  12'd0}; \
    input_matrix[7] = {12'd0, 12'd0, 12'd0, 12'd0,  12'd0,  12'd0,  12'd0,  12'd0};

`define INIT_TEST3 \
    input_matrix[0] = { 12'd5,   12'd0,  -12'd6,   12'd26,  12'd47, -12'd11,  12'd8,  -12'd240}; \
    input_matrix[1] = { 12'd16,  12'd5,  -12'd25, -12'd4,   12'd44,  12'd85, -12'd6,   12'd28}; \
    input_matrix[2] = { 12'd12,  12'd30,  12'd0,  -12'd24, -12'd16,  12'd32,  12'd8,   12'd21}; \
    input_matrix[3] = {-12'd15,  12'd0,   12'd7,   12'd0,  -12'd2,   12'd0,   12'd18, -12'd2}; \
    input_matrix[4] = {-12'd6,   12'd8,   12'd9,   12'd0,  -12'd24,  12'd15,  12'd4,   12'd7}; \
    input_matrix[5] = { 12'd0,   12'd0,   12'd0,  -12'd6,  -12'd5,   12'd0,   12'd9,   12'd4}; \
    input_matrix[6] = {-12'd8,  -12'd10,  12'd10,  12'd0,   12'd0,  -12'd6,   12'd0,  -12'd4}; \
    input_matrix[7] = {-12'd8,   12'd0,   12'd0,   12'd0,   12'd0,   12'd0,   12'd0,   12'd6};
    
   
`define TEST0_PASS \
    (output_matrix[0] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[1] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[2] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[3] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[4] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[5] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[6] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2}) \
  & (output_matrix[7] == {9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd2})

`define TEST1_PASS \
    (output_matrix[0] == {9'd2, 9'd2, 9'd2, 9'd2, 9'd1, 9'd1, 9'd1, 9'd1}) \
  & (output_matrix[1] == {9'd2, 9'd2, 9'd2, 9'd2, 9'd1, 9'd1, 9'd1, 9'd1}) \
  & (output_matrix[2] == {9'd3, 9'd2, 9'd2, 9'd2, 9'd1, 9'd1, 9'd1, 9'd1}) \
  & (output_matrix[3] == {9'd3, 9'd3, 9'd2, 9'd2, 9'd1, 9'd1, 9'd1, 9'd1}) \
  & (output_matrix[4] == {9'd3, 9'd3, 9'd2, 9'd2, 9'd1, 9'd1, 9'd1, 9'd0}) \
  & (output_matrix[5] == {9'd3, 9'd3, 9'd2, 9'd2, 9'd1, 9'd1, 9'd0, 9'd0}) \
  & (output_matrix[6] == {9'd3, 9'd3, 9'd3, 9'd2, 9'd1, 9'd1, 9'd0, 9'd0}) \
  & (output_matrix[7] == {9'd3, 9'd3, 9'd3, 9'd2, 9'd1, 9'd1, 9'd0, 9'd0})

`define TEST2_PASS \
    (output_matrix[0] == {-9'd20, -9'd21, -9'd21, -9'd21, -9'd21, -9'd21, -9'd23, -9'd24}) \
  & (output_matrix[1] == {-9'd20, -9'd21, -9'd21, -9'd21, -9'd20, -9'd21, -9'd22, -9'd24}) \
  & (output_matrix[2] == {-9'd20, -9'd20, -9'd21, -9'd20, -9'd20, -9'd21, -9'd22, -9'd23}) \
  & (output_matrix[3] == {-9'd19, -9'd20, -9'd20, -9'd20, -9'd20, -9'd20, -9'd22, -9'd23}) \
  & (output_matrix[4] == {-9'd19, -9'd20, -9'd20, -9'd20, -9'd20, -9'd20, -9'd22, -9'd23}) \
  & (output_matrix[5] == {-9'd19, -9'd20, -9'd20, -9'd20, -9'd20, -9'd20, -9'd22, -9'd23}) \
  & (output_matrix[6] == {-9'd19, -9'd20, -9'd20, -9'd20, -9'd20, -9'd20, -9'd22, -9'd23}) \
  & (output_matrix[7] == {-9'd20, -9'd20, -9'd20, -9'd20, -9'd20, -9'd20, -9'd22, -9'd23})

`define TEST3_PASS \
    (output_matrix[0] == {-9'd8,  -9'd22, -9'd17, -9'd43, -9'd61, -9'd26, -9'd10,  9'd21}) \
  & (output_matrix[1] == {-9'd17, -9'd24, -9'd14, -9'd11, -9'd73, -9'd47, -9'd28,  9'd5}) \
  & (output_matrix[2] == {-9'd34, -9'd22, -9'd18, -9'd5,  -9'd45, -9'd61, -9'd31, -9'd14}) \
  & (output_matrix[3] == {-9'd35, -9'd33, -9'd33, -9'd12, -9'd32, -9'd49, -9'd36, -9'd23}) \
  & (output_matrix[4] == {-9'd42, -9'd43, -9'd31, -9'd19, -9'd8,  -9'd53, -9'd39, -9'd30}) \
  & (output_matrix[5] == {-9'd66, -9'd44, -9'd33, -9'd15, -9'd4,  -9'd50, -9'd43, -9'd41}) \
  & (output_matrix[6] == {-9'd52, -9'd46, -9'd26, -9'd17, -9'd14, -9'd21, -9'd38, -9'd40}) \
  & (output_matrix[7] == {-9'd37, -9'd38, -9'd33, -9'd30, -9'd12, -9'd9,  -9'd47, -9'd44})
    
module testbench();

reg clock = 1'b0;
reg reset = 1'b0;

reg [95:0] input_matrix[0:7];
reg [71:0] output_matrix[0:7];
reg [31:0] cycles = 0;

reg [3:0] input_row_count;
reg [2:0] output_row_count;

reg [95:0] r_master_tdata; 
reg r_master_tvalid; 
reg r_master_tready;
wire w_slave_tready; 
wire [71:0] w_slave_tdata; 
wire w_slave_tvalid; 


initial begin
    forever clock = #10 !clock;
end

initial begin
    reset = 1'b1;
    r_master_tvalid = 1'b0;
    r_master_tready = 1'b0;
    input_row_count = 4'b0;
    output_row_count = 3'b0;
    repeat (3) @(posedge clock);
    reset = 1'b0;
    @(posedge clock);
    r_master_tvalid = 1'b1;
    r_master_tready = 1'b1;
    cycles = 0;
end

initial begin
    `INIT_TEST2
end

always @(negedge w_slave_tvalid) begin
    if (cycles > 1) begin
        repeat (10) @(posedge clock);
        if (`TEST2_PASS) $finish;
        else $fatal;
    end
end

always @(posedge clock) begin
    cycles = cycles + 1;
end


always @(posedge clock) begin
    if (r_master_tvalid & w_slave_tready) begin
        r_master_tdata = input_row_count < 4'd8 ? input_matrix[input_row_count] : 0;
        input_row_count = input_row_count + 1;
    end
end

always @(posedge clock) begin
    if (input_row_count > 4'd8) begin
        r_master_tvalid = 1'b0;
    end
end

always @(posedge clock) begin
    if (w_slave_tvalid & r_master_tready) begin
        output_matrix[output_row_count] = w_slave_tdata;
        output_row_count = output_row_count + 1;
    end
end

bambu_single_ram_axi_wrapper wrapper(.clock(clock), 
    .reset(reset), 
    .master_tdata(r_master_tdata), 
    .master_tvalid(r_master_tvalid), 
    .slave_tready(w_slave_tready), 
    .slave_tdata(w_slave_tdata), 
    .slave_tvalid(w_slave_tvalid), 
    .master_tready(r_master_tready));

endmodule
