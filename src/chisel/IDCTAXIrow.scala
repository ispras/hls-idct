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

// AXI-Stream adapter for row-by-row transmission.
class IDCTAXIrow extends Module {
  val io = IO(new Bundle {
    val i_tdata  = Input(UInt((8*Def.INPUT_WIDTH).W)) // Row F[u,*]
    val i_tvalid = Input(Bool())
    val i_tready = Input(Bool())
    val o_tdata  = Output(UInt((8*Def.OUTPUT_WIDTH).W)) // Row f[i,*]
    val o_tvalid = Output(Bool())
    val o_tready = Output(Bool())
  })

  val iblk = Reg(Vec(8*8, SInt(Def.INPUT_WIDTH.W)))
  val oblk = Reg(Vec(8*8, SInt(Def.OUTPUT_WIDTH.W)))

  val iidx = RegInit(0.U(3.W))
  val oidx = RegInit(0.U(3.W))

  // Copy the output block.
  val copy = RegInit(false.B)
  // Transmission has started.
  val send = RegInit(false.B)
  // Ready to get an input element.
  val ready = RegInit(true.B)

  // Combinational 8x8 IDCT core.
  val idct = Module(new IDCT)

  copy := (iidx === 7.U)

  for (i <- 0 to 63) {
    idct.io.iblk(i) := iblk(i)

    // Save the output block as soon as the input block is received.
    when (copy) {
      oblk(i) := idct.io.oblk(i)
    }
  }

  // Receive an input row.
  val mask = (1.U << Def.INPUT_WIDTH) - 1.U
  when (io.i_tvalid & ready) {
    for (i <- 0 to 7) {
      iblk((iidx << 3) + i.U) := ((io.i_tdata >> (i * Def.INPUT_WIDTH)) & mask).asSInt()
    }
    iidx := iidx + 1.U
  }

  // Previous transmission has not been completed.
  when (iidx === 6.U | ~ready) {
    ready := ~send
  }

  // Start/stop transmission.
  when (copy | oidx === 7.U) {
    send := copy
  }

  // Send an output row.
  when (send & io.i_tready) {
    oidx := oidx + 1.U
  }

  val tdata = Wire(Vec(8, SInt(Def.OUTPUT_WIDTH.W)))
  for (i <- 0 to 7) {
    tdata(i) := oblk((oidx << 3) + i.U)
  }

  io.o_tdata  := tdata.asUInt()
  io.o_tvalid := send
  io.o_tready := ready
}

object IDCTAXIrowDriver extends App {
  (new ChiselStage).emitVerilog(new IDCTAXIrow)
}
