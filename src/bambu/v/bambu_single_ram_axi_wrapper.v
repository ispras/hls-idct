`include "Fast_IDCT.v"

module bambu_single_ram_axi_wrapper(clock, reset, master_tdata, master_tvalid, slave_tready, slave_tdata, slave_tvalid, master_tready);

input wire clock;
input wire reset;
input wire [95:0] master_tdata;
input wire master_tvalid;
input wire master_tready;

output reg [71:0] slave_tdata;
output reg slave_tvalid;
output wire slave_tready;

reg [15:0] internal_matrix[0:63];
reg [8:0] output_matrix[0:63];

reg [3:0] input_row_count;
reg [3:0] output_row_count;
reg busy;

wire dev_out_write, dev_out_read, out_done, full, finished;
wire [31:0] dev_out_addr;
wire [15:0] dev_out_data;
wire [4:0] out_data_size;
wire [15:0] mask;

assign mask = (1 << out_data_size) -1;
assign slave_tready = ~busy;
assign full = input_row_count > 4'd7;
assign finished = output_row_count > 4'd7;

genvar i;
generate
for (i = 0; i < 64; i = i + 1) begin
    always @(posedge clock) if (out_done) output_matrix[i] = internal_matrix[i][8:0];
end
endgenerate

always @(posedge clock) begin
    if (reset) slave_tvalid <= 1'b0;
    else begin
        if (out_done) slave_tvalid <= 1'b1;
        if (finished) slave_tvalid <= 1'b0;
    end
end

always @(posedge clock) begin
    if (reset) begin
        output_row_count <= 4'b0;
        slave_tdata <= 72'b0;
    end else begin
        if ((out_done | slave_tvalid) & master_tready & !full) begin
            slave_tdata <= {output_matrix[output_row_count*8 + 7], output_matrix[output_row_count*8 + 6], output_matrix[output_row_count*8 + 5], output_matrix[output_row_count*8 + 4], output_matrix[output_row_count*8 + 3], output_matrix[output_row_count*8 + 2], output_matrix[output_row_count*8 + 1], output_matrix[output_row_count*8 + 0]};
            output_row_count <= output_row_count + 4'b1;
        end else if (finished) output_row_count <= 4'b0;
    end
end

always @(posedge clock) begin
    if (reset) begin
        input_row_count <= 4'b0;
        busy <= 1'b0;
    end else begin
        if (master_tvalid & slave_tready) begin
            internal_matrix[input_row_count*8 + 0] <= {{4{master_tdata[11]}}, master_tdata[11:0]};
            internal_matrix[input_row_count*8 + 1] <= {{4{master_tdata[23]}}, master_tdata[23:12]};
            internal_matrix[input_row_count*8 + 2] <= {{4{master_tdata[35]}}, master_tdata[35:24]};
            internal_matrix[input_row_count*8 + 3] <= {{4{master_tdata[47]}}, master_tdata[47:36]};
            internal_matrix[input_row_count*8 + 4] <= {{4{master_tdata[59]}}, master_tdata[59:48]};
            internal_matrix[input_row_count*8 + 5] <= {{4{master_tdata[71]}}, master_tdata[71:60]};
            internal_matrix[input_row_count*8 + 6] <= {{4{master_tdata[83]}}, master_tdata[83:72]};
            internal_matrix[input_row_count*8 + 7] <= {{4{master_tdata[95]}}, master_tdata[95:84]};
            input_row_count <= input_row_count + 4'b1;
        end else if (busy & !dev_out_read & dev_out_write) internal_matrix[dev_out_addr >> 1] <= dev_out_data & mask;
        
        if (full) begin
            input_row_count <= 4'b0;
            busy <= 1'b1;
        end

    end
end

Fast_IDCT idct(.clock(clock), .reset(~reset), .start_port(full), .block(32'b0), .M_Rdata_ram((dev_out_read & !dev_out_write) ? internal_matrix[dev_out_addr >> 1] & mask : 16'b0), .M_DataRdy((dev_out_read | dev_out_write) ? 1'b1 : 1'b0), .done_port(out_done), .Mout_oe_ram(dev_out_read), .Mout_we_ram(dev_out_write), .Mout_addr_ram(dev_out_addr), .Mout_Wdata_ram(dev_out_data), .Mout_data_ram_size(out_data_size));

endmodule

