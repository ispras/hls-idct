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

class IDCTAXI extends Module {
  val io = IO(new Bundle {
    val i_tdata  = Input(SInt(Def.INPUT_WIDTH.W))
    val i_tvalid = Input(Bool())
    val i_tready = Input(Bool())
    val o_tdata  = Output(SInt(Def.OUTPUT_WIDTH.W))
    val o_tvalid = Output(Bool())
    val o_tready = Output(Bool())
  })

  val iblk = Reg(Vec(8*8, SInt(Def.INPUT_WIDTH.W)))
  val oblk = Reg(Vec(8*8, SInt(Def.OUTPUT_WIDTH.W)))

  val iidx = Reg(UInt(6.W))
  val oidx = Reg(UInt(6.W))

  // Transmission has started.
  val send = RegInit(false.B)
  // Ready to get an input element.
  val ready = RegInit(true.B)

  // Combinational 8x8 IDCT core.
  val idct = Module(new IDCT)

  for (i <- 0 to 63) {
    idct.io.iblk(i) := iblk(i)

    // Save the output block as soon as the input block is received.
    when (iidx === 63.U) {
      oblk(i) := idct.io.oblk(i)
    }
  }

  // Receive an input element.
  when (io.i_tvalid & ready) {
    iblk(iidx) := io.i_tdata;
    iidx := iidx + 1.U
  }

  // Previous transmission has not been completed.
  when (iidx === 62.U) {
    ready := ~send
  }

  // Start/stop transmission.
  when (iidx === 63.U || oidx === 63.U) {
    send := (iidx === 63.U)
  }

  // Send an output element.
  when (send & io.i_tready) {
    oidx := oidx + 1.U
  }

  io.o_tdata := oblk(oidx)
  io.o_tvalid := send
  io.o_tready := ready
}

object IDCTAXIDriver extends App {
  (new ChiselStage).emitVerilog(new IDCTAXI)
}
