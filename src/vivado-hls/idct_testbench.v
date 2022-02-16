// Input width
`define WIN 12
// Output width
`define WOUT 9

// Map of 64-element array to the correspondent bit vector
`define ARRAY_TO_BITVECTOR(a) \
 {a[63], a[62], a[61], a[60], a[59], a[58], a[57], a[56],\
  a[55], a[54], a[53], a[52], a[51], a[50], a[49], a[48],\
  a[47], a[46], a[45], a[44], a[43], a[42], a[41], a[40],\
  a[39], a[38], a[37], a[36], a[35], a[34], a[33], a[32],\
  a[31], a[30], a[29], a[28], a[27], a[26], a[25], a[24],\
  a[23], a[22], a[21], a[20], a[19], a[18], a[17], a[16],\
  a[15], a[14], a[13], a[12], a[11], a[10], a[09], a[08],\
  a[07], a[06], a[05], a[04], a[03], a[02], a[01], a[00]}

`define ROW_OF_ARRAY(a, i) \
 {a[i+7], a[i+6], a[i+5], a[i+4], a[i+3], a[i+2], a[i+1], a[i]}

// Reference values for tests
`define REF0 {9'h0,   9'h0,   9'h0,   9'h1,   9'h0,   9'h1,   9'h1ff, 9'h6,\
              9'h0,   9'h1ff, 9'h0,   9'h1ff, 9'h1,   9'h1fd, 9'h4,   9'h1f5,\
              9'h1,   9'h2,   9'h0,   9'h3,   9'h1fe, 9'h6,   9'h1f9, 9'h1a,\
              9'h1ff, 9'h1fe, 9'h1,   9'h1fc, 9'h3,   9'h1f8, 9'hb,   9'h1df,\
              9'h2,   9'h4,   9'h1ff, 9'h7,   9'h1fb, 9'hd,   9'h1ef, 9'h3c,\
              9'h1fe, 9'h1fb, 9'h1,   9'h1f7, 9'h7,   9'h1f0, 9'h17,  9'h1b9,\
              9'h5,   9'hc,   9'h1fd, 9'h15,  9'h1f1, 9'h27,  9'h1cc, 9'hb0,\
              9'h1fc, 9'h1f4, 9'h5,   9'h1ea, 9'h13,  9'h1d6, 9'h3f,  9'h153}

`define REF1 {9'h0,   9'h0,   9'h0,   9'h1ff, 9'h0,   9'h1ff, 9'h1,   9'h1fa,\
              9'h0,   9'h1,   9'h0,   9'h1,   9'h1ff, 9'h3,   9'h1fc, 9'hb,\
              9'h1ff, 9'h1fe, 9'h0,   9'h1fd, 9'h2,   9'h1fa, 9'h7,   9'h1e6,\
              9'h1,   9'h2,   9'h1ff, 9'h4,   9'h1fd, 9'h8,   9'h1f5, 9'h21,\
              9'h1fe, 9'h1fc, 9'h1,   9'h1f9, 9'h5,   9'h1f3, 9'h11,  9'h1c4,\
              9'h2,   9'h5,   9'h1ff, 9'h9,   9'h1f9, 9'h10,  9'h1e9, 9'h47,\
              9'h1fb, 9'h1f4, 9'h3,   9'h1eb, 9'hf,   9'h1d9, 9'h34,  9'h150,\
              9'h4,   9'hc,   9'h1fb, 9'h16,  9'h1ed, 9'h2a,  9'h1c1, 9'had}

`define REF2 {9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2,\
              9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h3, 9'h2}

`define REF3 {9'h3, 9'h3, 9'h3, 9'h2, 9'h1, 9'h1, 9'h0, 9'h0,\
              9'h3, 9'h3, 9'h3, 9'h2, 9'h1, 9'h1, 9'h0, 9'h0,\
              9'h3, 9'h3, 9'h2, 9'h2, 9'h1, 9'h1, 9'h0, 9'h0,\
              9'h3, 9'h3, 9'h2, 9'h2, 9'h1, 9'h1, 9'h1, 9'h0,\
              9'h3, 9'h3, 9'h2, 9'h2, 9'h1, 9'h1, 9'h1, 9'h1,\
              9'h3, 9'h2, 9'h2, 9'h2, 9'h1, 9'h1, 9'h1, 9'h1,\
              9'h2, 9'h2, 9'h2, 9'h2, 9'h1, 9'h1, 9'h1, 9'h1,\
              9'h2, 9'h2, 9'h2, 9'h2, 9'h1, 9'h1, 9'h1, 9'h1}

`define REF4 {9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ea, 9'h1e9,\
              9'h1ed, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ea, 9'h1e9,\
              9'h1ed, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ea, 9'h1e9,\
              9'h1ed, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ea, 9'h1e9,\
              9'h1ed, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ea, 9'h1e9,\
              9'h1ec, 9'h1ec, 9'h1eb, 9'h1ec, 9'h1ec, 9'h1eb, 9'h1ea, 9'h1e9,\
              9'h1ec, 9'h1eb, 9'h1eb, 9'h1eb, 9'h1ec, 9'h1eb, 9'h1ea, 9'h1e8,\
              9'h1ec, 9'h1eb, 9'h1eb, 9'h1eb, 9'h1eb, 9'h1eb, 9'h1e9, 9'h1e8}

`define IN5 { -12'd8,   12'd0,   12'd0,   12'd0,   12'd0,   12'd0,   12'd0,   12'd6,\
              -12'd8,  -12'd10,  12'd10,  12'd0,   12'd0,  -12'd6,   12'd0,  -12'd4,\
               12'd0,   12'd0,   12'd0,  -12'd6,  -12'd5,   12'd0,   12'd9,   12'd4,\
              -12'd6,   12'd8,   12'd9,   12'd0,  -12'd24,  12'd15,  12'd4,   12'd7,\
              -12'd15,  12'd0,   12'd7,   12'd0,  -12'd2,   12'd0,   12'd18, -12'd2,\
               12'd12,  12'd30,  12'd0,  -12'd24, -12'd16,  12'd32,  12'd8,   12'd21,\
               12'd16,  12'd5,  -12'd25, -12'd4,   12'd44,  12'd85, -12'd6,   12'd28,\
               12'd5,   12'd0,  -12'd6,   12'd26,  12'd47, -12'd11,  12'd8,  -12'd240}

`define REF5 {9'h1db, 9'h1da, 9'h1df, 9'h1e2, 9'h1f4, 9'h1f7, 9'h1d1, 9'h1d4,\
              9'h1cc, 9'h1d2, 9'h1e6, 9'h1ef, 9'h1f2, 9'h1eb, 9'h1da, 9'h1d8,\
              9'h1be, 9'h1d4, 9'h1df, 9'h1f1, 9'h1fc, 9'h1ce, 9'h1d5, 9'h1d7,\
              9'h1d6, 9'h1d5, 9'h1e1, 9'h1ed, 9'h1f8, 9'h1cb, 9'h1d9, 9'h1e2,\
              9'h1dd, 9'h1df, 9'h1df, 9'h1f4, 9'h1e0, 9'h1cf, 9'h1dc, 9'h1e9,\
              9'h1de, 9'h1ea, 9'h1ee, 9'h1fb, 9'h1d3, 9'h1c3, 9'h1e1, 9'h1f2,\
              9'h1ef, 9'h1e8, 9'h1f2, 9'h1f5, 9'h1b7, 9'h1d1, 9'h1e4, 9'h005,\
              9'h1f8, 9'h1ea, 9'h1ef, 9'h1d5, 9'h1c3, 9'h1e6, 9'h1f6, 9'h015}

`define REPL4(a, i, j) a[i][j], a[i][j], a[i][j], a[i][j]

// Test check
`define TEST(number) \
  clock <= 1; \
  ap_start <= 1; \
  for (i = 0; i < 8; i = i + 1) begin \
    while (~(ibl_tready & ibh_tready)) begin \
      ibl_tvalid <= 0; \
      ibh_tvalid <= 0; \
      #5; clock <= 0; #5; clock <= 1; \
    end \
    ibl_tdata <= {`REPL4(b, i*8+3, 11), b[i*8+3], `REPL4(b, i*8+2, 11), b[i*8+2], \
                  `REPL4(b, i*8+1, 11), b[i*8+1], `REPL4(b, i*8+0, 11), b[i*8+0]}; \
    ibh_tdata <= {`REPL4(b, i*8+7, 11), b[i*8+7], `REPL4(b, i*8+6, 11), b[i*8+6], \
                  `REPL4(b, i*8+5, 11), b[i*8+5], `REPL4(b, i*8+4, 11), b[i*8+4]}; \
    ibl_tvalid <= 1; \
    ibh_tvalid <= 1; \
    #5; \
    clock <= 0; \
    #5; \
    clock <= 1; \
  end \
  ibl_tvalid <= 0; \
  ibh_tvalid <= 0; \
  #5; \
  clock <= 0; \
  obl_tready <= 1; \
  obh_tready <= 1; \
  #5; \
  clock <= 1; \
  for (i = 0; i < 8; i = i + 1) begin \
    while (~(obl_tvalid & obh_tvalid)) begin \
      #5; clock <= 0; #5; clock <= 1; \
    end \
    `ROW_OF_ARRAY(out_reg, i*8) <= {obh_tdata[56:48],obh_tdata[40:32],obh_tdata[24:16],obh_tdata[8:0], \
                                    obl_tdata[56:48],obl_tdata[40:32],obl_tdata[24:16],obl_tdata[8:0]}; \
    #5; \
    clock <= 0; \
    #5; \
    clock <= 1; \
  end \
  obh_tready <= 0; \
  obl_tready <= 0; \
  if (`ARRAY_TO_BITVECTOR(out_reg) != `REF``number) begin \
    $display("[FAIL] test #number:"); \
    $display("expected value is 0x%x\nreceived value is 0x%x", \
             `REF``number, `ARRAY_TO_BITVECTOR(out_reg)); \
    $finish; \
  end

// The test itself
module testbench ();
integer i;
reg signed [`WIN-1:0] b [63:0];
reg [`WOUT-1:0] out_reg [63:0];

reg clock;
reg reset;

reg [63:0] ibl_tdata;
reg [63:0] ibh_tdata;
reg ibl_tvalid;
reg ibh_tvalid;
wire ibl_tready;
wire ibh_tready;
wire [63:0] obl_tdata;
wire [63:0] obh_tdata;
wire obl_tvalid;
wire obh_tvalid;
reg obl_tready;
reg obh_tready;

reg ap_start;
wire ap_done;
wire ap_idle;
wire ap_ready;

Top_Fast_IDCT idct(
  .ap_clk(clock),
  .ap_rst_n(reset),
  .ap_start(ap_start),
  .ap_done(ap_done),
  .ap_idle(ap_idle),
  .ap_ready(ap_ready),
  .ibl_TDATA(ibl_tdata),
  .ibl_TVALID(ibl_tvalid),
  .ibl_TREADY(ibl_tready),
  .ibh_TDATA(ibh_tdata),
  .ibh_TVALID(ibh_tvalid),
  .ibh_TREADY(ibh_tready),
  .obl_TDATA(obl_tdata),
  .obl_TVALID(obl_tvalid),
  .obl_TREADY(obl_tready),
  .obh_TDATA(obh_tdata),
  .obh_TVALID(obh_tvalid),
  .obh_TREADY(obh_tready));

initial begin
  $dumpfile("test.vcd");
  $dumpvars(6, testbench);

  reset <= 0;
  clock <= 0;
  ibl_tdata <= 0;
  ibh_tdata <= 0;
  ibl_tvalid <= 0;
  ibh_tvalid <= 0;
  obl_tready <= 0;
  obh_tready <= 0;
  clock <= 0;
  #5;
  clock <= 1;
  #5;
  clock <= 0;
  reset <= 1;
  #5;

  // TEST 0
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = -1*i;
  end
  `TEST(0);

  // TEST 1
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 1*i;
  end
  `TEST(1);

  // TEST 2
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 0;
  end
  b[0] = 23;
  b[1] = -1;
  b[2] = -2;
  `TEST(2);

  // TEST 3
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 0;
  end
  b[0] = 13;
  b[1] = -7;
  b[9] = 2;
  `TEST(3);
  
  // TEST 4
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 0;
  end
  b[0] = -166;
  b[1] = -7;
  b[2] = -4;
  b[3] = -4;
  b[8] = -2;
  b[16] = -2;
  `TEST(4);

  // TEST 5
  `ARRAY_TO_BITVECTOR(b) = `IN5;
  `TEST(5);

  $display("[SUCCESS] Tests passed!");
end
endmodule // top

