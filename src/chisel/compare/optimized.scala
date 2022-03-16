package ru.ispras.idct

import chisel3._
import chisel3.stage.ChiselStage

class Def

object Def {
  val INPUT_WIDTH  = 12
  val TEMP_WIDTH   = 13
  val OUTPUT_WIDTH = 9

  val W1 = 2841
  val W2 = 2676
  val W3 = 2408
  val W5 = 1609
  val W6 = 1108
  val W7 = 565
}

class IDCTRow extends Module {
  val io = IO(new Bundle {
    val row = Input(Vec(8, SInt(Def.INPUT_WIDTH.W)))
    val out = Output(Vec(8, SInt(Def.TEMP_WIDTH.W)))
  })

  val x1_0 = io.row(4) << 11
  val x2_0 = io.row(6)
  val x3_0 = io.row(2)
  val x4_0 = io.row(1)
  val x5_0 = io.row(7)
  val x6_0 = io.row(5)
  val x7_0 = io.row(3)

  when (~(x1_0 | x2_0 | x3_0 | x4_0 | x5_0 | x6_0 | x7_0).asUInt().orR()) {
    val res = io.row(0) << 3

    io.out(0) := res
    io.out(1) := res
    io.out(2) := res
    io.out(3) := res
    io.out(4) := res
    io.out(5) := res
    io.out(6) := res
    io.out(7) := res
  }.otherwise {
    val x0_0 = (io.row(0) << 11) + 128.S

    val x8_0 = Def.W7.S * (x4_0 + x5_0)
    val x4_1 = x8_0 + (Def.W1.S - Def.W7.S) * x4_0
    val x5_1 = x8_0 - (Def.W1.S + Def.W7.S) * x5_0
    val x8_1 = Def.W3.S * (x6_0 + x7_0)
    val x6_1 = x8_1 - (Def.W3.S - Def.W5.S) * x6_0
    val x7_1 = x8_1 - (Def.W3.S + Def.W5.S) * x7_0
    
    val x8_2 = x0_0 + x1_0
    val x0_1 = x0_0 - x1_0
    val x1_1 = Def.W6.S * (x3_0 + x2_0)
    val x2_1 = x1_1 - (Def.W2.S + Def.W6.S) * x2_0
    val x3_1 = x1_1 + (Def.W2.S - Def.W6.S) * x3_0
    val x1_2 = x4_1 + x6_1
    val x4_2 = x4_1 - x6_1
    val x6_2 = x5_1 + x7_1
    val x5_2 = x5_1 - x7_1
    
    val x7_2 = x8_2 + x3_1
    val x8_3 = x8_2 - x3_1
    val x3_2 = x0_1 + x2_1
    val x0_2 = x0_1 - x2_1
    val x2_2 = (181.S * (x4_2 + x5_2) + 128.S) >> 8
    val x4_3 = (181.S * (x4_2 - x5_2) + 128.S) >> 8
    
    io.out(0) := (x7_2 + x1_2) >> 8
    io.out(1) := (x3_2 + x2_2) >> 8
    io.out(2) := (x0_2 + x4_3) >> 8
    io.out(3) := (x8_3 + x6_2) >> 8
    io.out(4) := (x8_3 - x6_2) >> 8
    io.out(5) := (x0_2 - x4_3) >> 8
    io.out(6) := (x3_2 - x2_2) >> 8
    io.out(7) := (x7_2 - x1_2) >> 8
  }
}

class IDCTCol extends Module {
  def iclp(x: SInt): SInt =
    Mux(x < -256.S, -256.S, Mux(x > 255.S, 255.S, x))(Def.OUTPUT_WIDTH - 1, 0).asSInt()

  val io = IO(new Bundle {
    val col = Input(Vec(8, SInt(Def.TEMP_WIDTH.W)))
    val out = Output(Vec(8, SInt(Def.OUTPUT_WIDTH.W)))
  })

  val x1_0 = io.col(4) << 8
  val x2_0 = io.col(6)
  val x3_0 = io.col(2)
  val x4_0 = io.col(1)
  val x5_0 = io.col(7)
  val x6_0 = io.col(5)
  val x7_0 = io.col(3)

  when (~(x1_0 | x2_0 | x3_0 | x4_0 | x5_0 | x6_0 | x7_0).asUInt().orR()) {
    val res = iclp(io.col(0) + 32.S) >> 6
    io.out(0) := res
    io.out(1) := res
    io.out(2) := res
    io.out(3) := res
    io.out(4) := res
    io.out(5) := res
    io.out(6) := res
    io.out(7) := res
  }.otherwise {
    val x0_0 = (io.col(0) << 8) + 8192.S

    val x8_0 = Def.W7.S * (x4_0 + x5_0) + 4.S
    val x4_1 = (x8_0 + (Def.W1.S - Def.W7.S) * x4_0) >> 3
    val x5_1 = (x8_0 - (Def.W1.S + Def.W7.S) * x5_0) >> 3
    val x8_1 = Def.W3.S * (x6_0 + x7_0) + 4.S
    val x6_1 = (x8_1 - (Def.W3.S - Def.W5.S) * x6_0) >> 3
    val x7_1 = (x8_1 - (Def.W3.S + Def.W5.S) * x7_0) >> 3

    val x8_2 = x0_0 + x1_0
    val x0_1 = x0_0 - x1_0
    val x1_1 = Def.W6.S * (x3_0 + x2_0) + 4.S
    val x2_1 = (x1_1 - (Def.W2.S + Def.W6.S) * x2_0) >> 3
    val x3_1 = (x1_1 + (Def.W2.S - Def.W6.S) * x3_0) >> 3
    val x1_2 = x4_1 + x6_1
    val x4_2 = x4_1 - x6_1
    val x6_2 = x5_1 + x7_1
    val x5_2 = x5_1 - x7_1

    val x7_2 = x8_2 + x3_1
    val x8_3 = x8_2 - x3_1
    val x3_2 = x0_1 + x2_1
    val x0_2 = x0_1 - x2_1
    val x2_2 = (181.S * (x4_2 + x5_2) + 128.S) >> 8
    val x4_3 = (181.S * (x4_2 - x5_2) + 128.S) >> 8

    io.out(0) := iclp((x7_2 + x1_2) >> 14)
    io.out(1) := iclp((x3_2 + x2_2) >> 14)
    io.out(2) := iclp((x0_2 + x4_3) >> 14)
    io.out(3) := iclp((x8_3 + x6_2) >> 14)
    io.out(4) := iclp((x8_3 - x6_2) >> 14)
    io.out(5) := iclp((x0_2 - x4_3) >> 14)
    io.out(6) := iclp((x3_2 - x2_2) >> 14)
    io.out(7) := iclp((x7_2 - x1_2) >> 14)
  }
}

class IDCT extends Module {
  val io = IO(new Bundle {
    val i_tdata  = Input(UInt((8*Def.INPUT_WIDTH).W))
    val i_tvalid = Input(Bool())
    val i_tready = Input(Bool())
    val o_tdata  = Output(UInt((8*Def.OUTPUT_WIDTH).W))
    val o_tvalid = Output(Bool())
    val o_tready = Output(Bool())
  })

  val imask = (1.U << Def.INPUT_WIDTH) - 1.U

  val blk_row = Reg(Vec(8*7, SInt(Def.TEMP_WIDTH.W)))
  val blk_tmp = Reg(Vec(8*8, SInt(Def.TEMP_WIDTH.W)))
  val blk_col = Reg(Vec(8*7, SInt(Def.OUTPUT_WIDTH.W)))
  val blk_out = Reg(Vec(8*8, SInt(Def.OUTPUT_WIDTH.W)))

  val idctrow = Module(new IDCTRow)
  val idctcol = Module(new IDCTCol)

  val idx_row = RegInit(0.U(3.W))
  val idx_col = RegInit(0.U(3.W))
  val idx_out = RegInit(0.U(3.W))

  val copy_row_to_tmp_rdy = RegInit(false.B)
  val idct_col_processing = RegInit(false.B)
  val copy_col_to_out_rdy = RegInit(false.B)

  val ready = RegInit(true.B)
  val send  = RegInit(false.B)

  for (i <- 0 to 7) {
    idctrow.io.row(i) := ((io.i_tdata >> (i * Def.INPUT_WIDTH)) & imask).asSInt()
  }
  when (idx_row =/= 7.U) {
    for (i <- 0 to 7) {
      blk_row((idx_row << 3) + i.U) := idctrow.io.out(i)
    }
  }.otherwise {
    for (i <- 0 to 7) {
      blk_tmp(56 + i) := idctrow.io.out(i)
    }
  }
  for (i <- 0 to 7) {
    idctcol.io.col(i) := blk_tmp((i.U << 3) + idx_col)
  }
  when (idx_col =/= 7.U) {
    for (i <- 0 to 7) {
      blk_col((idx_col << 3) + i.U) := idctcol.io.out(i)
    }
  }.otherwise {
    for (i <- 0 to 7) {
      blk_out(56 + i) := idctcol.io.out(i)
    }
  }
  val tdata = Wire(Vec(8, SInt(Def.OUTPUT_WIDTH.W)))
  for (i <- 0 to 7) {
    tdata(i) := blk_out((i.U << 3) + idx_out)
  }

  ready := ~copy_row_to_tmp_rdy | ~idct_col_processing

  when (io.i_tvalid & ready) {
    idx_row := idx_row + 1.U
  }

  when (idx_row === 6.U) {
    copy_row_to_tmp_rdy := true.B
  }
  when (copy_row_to_tmp_rdy & ~idct_col_processing) {
    for (i <- 0 to 55) {
      blk_tmp(i) := blk_row(i)
    }
    copy_row_to_tmp_rdy := false.B
    idct_col_processing := true.B
  }

  when (idct_col_processing) {
    idx_col := idx_col + 1.U
  }

  when (idx_col === 6.U) {
    copy_col_to_out_rdy := true.B
  }
  when (idx_col === 7.U) {
    idct_col_processing := false.B
  }
  when (copy_col_to_out_rdy & ~send) {
    for (i <- 0 to 55) {
      blk_out(i) := blk_col(i)
    }
    copy_col_to_out_rdy := false.B
    send := true.B
  }

  when (send & io.i_tready) {
    idx_out := idx_out + 1.U
  }
  when (idx_out === 7.U) {
    send := false.B
  }

  io.o_tdata  := tdata.asUInt()
  io.o_tvalid := send & io.i_tready
  io.o_tready := ready
}

object IDCTDriver extends App {
  (new ChiselStage).emitVerilog(new IDCT)
}
