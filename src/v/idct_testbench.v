`include "idct_rows_and_cols.v"
`include "idct.v"
`include "idct_wide.v"

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


// Test check
`define TEST(number) \
  clock <= 1; \
  for (i = 0; i < 64; i = i + 1) begin \
    s_tdata <= b[i]; \
    s_tvalid <= 1; \
    #5; \
    clock <= 0; \
    #5; \
    clock <= 1; \
  end \
  s_tvalid <= 0; \
  #5; \
  clock <= 0; \
  m_tready <= 1; \
  #5; \
  clock <= 1; \
  for (i = 0; i < 64; i = i + 1) begin \
    if (m_tvalid) begin \
      out_reg[i] <= m_tdata; \
    end \
    #5; \
    clock <= 0; \
    #5; \
    clock <= 1; \
  end \
  m_tready <= 0; \
  if (`ARRAY_TO_BITVECTOR(out_reg) != `REF``number) begin \
    $display("[FAIL] test #number:"); \
    $display("expected value is 0x%x\nreceived value is 0x%x", \
             `REF``number, `ARRAY_TO_BITVECTOR(out_reg)); \
    $finish; \
  end else begin \
    $display("[OK] test #number: out_reg is 0x%x", `ARRAY_TO_BITVECTOR(out_reg)); \
  end

// Test check
`define TEST_WIDE(number) \
  clock <= 1; \
  for (i = 0; i < 8; i = i + 1) begin \
    s_tdata_wide <= `ROW_OF_ARRAY(b, i*8); \
    s_tvalid_wide <= 1; \
    #5; \
    clock <= 0; \
    #5; \
    clock <= 1; \
  end \
  s_tvalid_wide <= 0; \
  #5; \
  clock <= 0; \
  m_tready_wide <= 1; \
  #5; \
  clock <= 1; \
  for (i = 0; i < 8; i = i + 1) begin \
    if (m_tvalid_wide) begin \
      `ROW_OF_ARRAY(out_reg, i*8) <= m_tdata_wide; \
    end \
    #5; \
    clock <= 0; \
    #5; \
    clock <= 1; \
  end \
  m_tready_wide <= 0; \
  if (`ARRAY_TO_BITVECTOR(out_reg) != `REF``number) begin \
    $display("[FAIL] wtest #number:"); \
    $display("expected value is 0x%x\nreceived value is 0x%x", \
             `REF``number, `ARRAY_TO_BITVECTOR(out_reg)); \
    $finish; \
  end else begin \
    $display("[OK] wtest #number: out_reg is 0x%x", `ARRAY_TO_BITVECTOR(out_reg)); \
  end


// The test itself
module testbench ();
integer i;
reg signed [`WIN-1:0] b [63:0];
reg [`WOUT-1:0] out_reg [63:0];

reg signed [`WIN-1:0] s_tdata;
reg s_tvalid;
wire s_tready;
wire signed [`WOUT-1:0] m_tdata;
wire m_tvalid;
reg m_tready;
reg clock;
reg reset;

reg signed [`WIN*8-1:0] s_tdata_wide;
reg s_tvalid_wide;
wire s_tready_wide;
wire signed [`WOUT*8-1:0] m_tdata_wide;
wire m_tvalid_wide;
reg m_tready_wide;


axi_stream_wrappered_idct idct(m_tdata, m_tvalid, m_tready,
                               s_tdata, s_tvalid, s_tready, clock, reset);

wide_axi_stream_wrappered_idct idct_wide(m_tdata_wide, m_tvalid_wide, m_tready_wide,
                                         s_tdata_wide, s_tvalid_wide, s_tready_wide, clock, reset);

initial begin
  $dumpfile("test.vcd");
  $dumpvars(6, testbench);

  reset <= 0;
  clock <= 0;
  s_tdata <= 0;
  s_tvalid <= 0;
  m_tready <= 0;
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
  `TEST_WIDE(0);

  // TEST 1
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 1*i;
  end
  `TEST(1);
  `TEST_WIDE(1);

  // TEST 2
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 0;
  end
  b[0] = 23;
  b[1] = -1;
  b[2] = -2;
  `TEST(2);
  `TEST_WIDE(2);

  // TEST 3
  for (i = 0; i < 64; i = i + 1) begin
    b[i] = 0;
  end
  b[0] = 13;
  b[1] = -7;
  b[9] = 2;
  `TEST(3);
  `TEST_WIDE(3);
  
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
  `TEST_WIDE(4);

  // TEST 5
  `ARRAY_TO_BITVECTOR(b) = `IN5;
  `TEST(5);
  `TEST_WIDE(5);

  $display("[SUCCESS] Tests passed!");
end
endmodule // top

