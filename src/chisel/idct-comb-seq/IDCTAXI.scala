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

// AXI-Stream adapter for element-by-element transmission.
class IDCTAXI extends Module {
  val io = IO(new Bundle {
    val i_tdata  = Input(SInt(Def.INPUT_WIDTH.W)) // Element F[u,v]
    val i_tvalid = Input(Bool())
    val i_tready = Input(Bool())
    val o_tdata  = Output(SInt(Def.OUTPUT_WIDTH.W)) // Element f[i,j]
    val o_tvalid = Output(Bool())
    val o_tready = Output(Bool())
  })

  val iblk = Reg(Vec(8*8, SInt(Def.INPUT_WIDTH.W)))
  val oblk = Reg(Vec(8*8, SInt(Def.OUTPUT_WIDTH.W)))

  val iidx = RegInit(0.U(6.W))
  val oidx = RegInit(0.U(6.W))

  // Copy the output block.
  val copy = RegInit(false.B)
  // Transmission has started.
  val send = RegInit(false.B)
  // Ready to get an input element.
  val ready = RegInit(true.B)

  // Combinational 8x8 IDCT core.
  val idct = Module(new IDCT)

  copy := (iidx === 63.U)

  for (i <- 0 to 63) {
    idct.io.iblk(i) := iblk(i)

    // Save the output block as soon as the input block is received.
    when (copy) {
      oblk(i) := idct.io.oblk(i)
    }
  }

  // Receive an input element.
  when (io.i_tvalid & ready) {
    iblk(iidx) := io.i_tdata;
    iidx := iidx + 1.U
  }

  // Previous transmission has not been completed.
  when (iidx === 62.U | ~ready) {
    ready := ~send
  }

  // Start/stop transmission.
  when (copy | oidx === 63.U) {
    send := copy
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
