//===----------------------------------------------------------------------===//
//
// Part of the HLS-IDCT Project, under the Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
// Copyright 2021 ISP RAS (http://www.ispras.ru)
//
//===----------------------------------------------------------------------===//

package ru.ispras.idct

import chisel3._
import chisel3.stage.ChiselStage

class Def

object Def {
  val INPUT_WIDTH  = 12
  val TEMP_WIDTH   = 13
  val OUTPUT_WIDTH = 9

  val W1 = 2841 // 2048*sqrt(2)*cos(1*pi/16)
  val W2 = 2676 // 2048*sqrt(2)*cos(2*pi/16)
  val W3 = 2408 // 2048*sqrt(2)*cos(3*pi/16)
  val W5 = 1609 // 2048*sqrt(2)*cos(5*pi/16)
  val W6 = 1108 // 2048*sqrt(2)*cos(6*pi/16)
  val W7 = 565  // 2048*sqrt(2)*cos(7*pi/16)
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

  /* shortcut */
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
    val x0_0 = (io.row(0) << 11) + 128.S /* for proper rounding in the fourth stage */

    /* first stage */
    val x8_0 = Def.W7.S * (x4_0 + x5_0)
    val x4_1 = x8_0 + (Def.W1.S - Def.W7.S) * x4_0
    val x5_1 = x8_0 - (Def.W1.S + Def.W7.S) * x5_0
    val x8_1 = Def.W3.S * (x6_0 + x7_0)
    val x6_1 = x8_1 - (Def.W3.S - Def.W5.S) * x6_0
    val x7_1 = x8_1 - (Def.W3.S + Def.W5.S) * x7_0
    
    /* second stage */
    val x8_2 = x0_0 + x1_0
    val x0_1 = x0_0 - x1_0
    val x1_1 = Def.W6.S * (x3_0 + x2_0)
    val x2_1 = x1_1 - (Def.W2.S + Def.W6.S) * x2_0
    val x3_1 = x1_1 + (Def.W2.S - Def.W6.S) * x3_0
    val x1_2 = x4_1 + x6_1
    val x4_2 = x4_1 - x6_1
    val x6_2 = x5_1 + x7_1
    val x5_2 = x5_1 - x7_1
    
    /* third stage */
    val x7_2 = x8_2 + x3_1
    val x8_3 = x8_2 - x3_1
    val x3_2 = x0_1 + x2_1
    val x0_2 = x0_1 - x2_1
    val x2_2 = (181.S * (x4_2 + x5_2) + 128.S) >> 8
    val x4_3 = (181.S * (x4_2 - x5_2) + 128.S) >> 8
    
    /* fourth stage */
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

  /* shortcut */
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

    /* first stage */
    val x8_0 = Def.W7.S * (x4_0 + x5_0) + 4.S
    val x4_1 = (x8_0 + (Def.W1.S - Def.W7.S) * x4_0) >> 3
    val x5_1 = (x8_0 - (Def.W1.S + Def.W7.S) * x5_0) >> 3
    val x8_1 = Def.W3.S * (x6_0 + x7_0) + 4.S
    val x6_1 = (x8_1 - (Def.W3.S - Def.W5.S) * x6_0) >> 3
    val x7_1 = (x8_1 - (Def.W3.S + Def.W5.S) * x7_0) >> 3

    /* second stage */
    val x8_2 = x0_0 + x1_0
    val x0_1 = x0_0 - x1_0
    val x1_1 = Def.W6.S * (x3_0 + x2_0) + 4.S
    val x2_1 = (x1_1 - (Def.W2.S + Def.W6.S) * x2_0) >> 3
    val x3_1 = (x1_1 + (Def.W2.S - Def.W6.S) * x3_0) >> 3
    val x1_2 = x4_1 + x6_1
    val x4_2 = x4_1 - x6_1
    val x6_2 = x5_1 + x7_1
    val x5_2 = x5_1 - x7_1

    /* third stage */
    val x7_2 = x8_2 + x3_1
    val x8_3 = x8_2 - x3_1
    val x3_2 = x0_1 + x2_1
    val x0_2 = x0_1 - x2_1
    val x2_2 = (181.S * (x4_2 + x5_2) + 128.S) >> 8
    val x4_3 = (181.S * (x4_2 - x5_2) + 128.S) >> 8

    /* fourth stage */
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
    val iblk = Input(Vec(8*8, SInt(Def.INPUT_WIDTH.W)))
    val oblk = Output(Vec(8*8, SInt(Def.OUTPUT_WIDTH.W)))
  })

  val idctrows = VecInit(Seq.fill(8) { Module(new IDCTRow).io })
  val idctcols = VecInit(Seq.fill(8) { Module(new IDCTCol).io })

  for (i <- 0 to 7) {
    for (j <- 0 to 7) {
      idctrows(i).row(j) := io.iblk(8 * i + j)
      idctcols(j).col(i) := idctrows(i).out(j)
      io.oblk(8 * i + j) := idctcols(j).out(i)
    }
  }
}

object IDCTDriver extends App {
  (new ChiselStage).emitVerilog(new IDCT)
}
