// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Single-port RAM with 1 cycle read/write delay, 32 bit words
 */
module ram_64KB (
    input               clk_i,
    input               rst_ni,

    input               req_i,
    input               we_i,
    input        [ 3:0] be_i,
    input        [31:0] addr_i,
    input        [31:0] wdata_i,
    output logic        rvalid_o,
    output logic [31:0] rdata_o
);

  // SPRAM signals
  logic [7:0] maskwren;
  logic       standby  = 1'b0;
  logic       sleep    = 1'b0;
  logic       poweroff = 1'b1;

  assign maskwren[7:6] = {2{be_i[3]}};
  assign maskwren[5:4] = {2{be_i[2]}};
  assign maskwren[3:2] = {2{be_i[1]}};
  assign maskwren[1:0] = {2{be_i[0]}};

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= '0;
    end else begin
      rvalid_o <= req_i;
    end
  end

  SP256K ramfn_inst1 (
    .AD        (addr_i[13:0]),
    .DI        (wdata_i[31:16]),
    .MASKWE    (maskwren[7:4]),
    .WE        (we_i),
    .CS        (req_i),
    .CK        (clk_i),
    .STDBY     (standby),
    .SLEEP     (sleep),
    .PWROFF_N  (poweroff),
    .DO        (rdata_o[31:16])
  );

  SP256K ramfn_inst2 (
    .AD        (addr_i[13:0]),
    .DI        (wdata_i[15:0]),
    .MASKWE    (maskwren[3:0]),
    .WE        (we_i),
    .CS        (req_i),
    .CK        (clk_i),
    .STDBY     (standby),
    .SLEEP     (sleep),
    .PWROFF_N  (poweroff),
    .DO        (rdata_o[15:0])
  );

  `ifdef VERILATOR
    // Task for loading 'mem' with SystemVerilog system task $readmemh()
    export "DPI-C" task simutil_verilator_memload;
    // Function for setting a specific 32 bit element in |mem|
    // Returns 1 (true) for success, 0 (false) for errors.
    export "DPI-C" function simutil_verilator_set_mem;

    task simutil_verilator_memload;
      input string file;
      $readmemh(file, mem);
    endtask

    // TODO: Allow 'val' to have other widths than 32 bit
    function int simutil_verilator_set_mem(input int index,
                                           input logic[31:0] val);
      if (index >= Depth) begin
        return 0;
      end

      mem[index] = val;
      return 1;
    endfunction
  `endif

  `ifdef SRAM_INIT_FILE
    localparam MEM_FILE = `"`SRAM_INIT_FILE`";
    initial begin
      $display("Initializing SRAM from %s", MEM_FILE);
      $readmemh(MEM_FILE, mem);
    end
  `endif
endmodule
