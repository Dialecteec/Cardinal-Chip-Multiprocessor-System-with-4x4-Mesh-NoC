`timescale 1ns/100ps
`include "gscl45nm.v"

// Engineers: Akarsh Ningoji Rao Kolekar - akolekar6@gatech.edu
//           Abhishek Upadhyay        - aupadhyay31@gatech.edu
// Modified: Only router (0,0) sends a 7‑flit packet to router (3,3):
//  1 head, 5 bodies (30 bits total), 1 tail (2 bits in MSBs).

module mesh_general_4x4_bc_tb();

  // clock and reset
  reg        clk, rst;

  // per‑node flit inputs, write enables, on/off signals
  reg [7:0]  local_in_flit  [0:15];
  reg        local_wr_en    [0:15];
  reg        local_ON_OFF   [0:15];

  // per‑node outputs from mesh
  wire [7:0] local_out_flit [0:15];
  wire       router_out_full[0:15];

  // mesh parameters
  parameter MESH_COLUMNS = 4;
  parameter MESH_ROWS    = 4;
  parameter BUFFER_DEPTH = 4;
  parameter PORTS        = 5;
  parameter LINK_WIDTHS  = 8;
  parameter RATE         = 1;

  // schedule 7 flits: head + 5 bodies + tail
  localparam FLIT_COUNT = 7;
  localparam CYCLES     = FLIT_COUNT - 1;

  integer i;
  reg [7:0] counter0;

  // example 30‑bit payload and 2‑bit tail field
  reg [29:0] payload   = 30'h3FFFFFF;  // any 30‑bit data
  reg [1:0]  tail_data = 2'b10;        // two bits carried in MSBs of tail

  // clock generator
  always #5 clk = ~clk;

  // reset pulse
  initial begin
    clk = 0; rst = 0;
    #2 rst = 1;
    #6 rst = 0;
  end

  // initialize arrays, finish after 1000 ns
  initial begin

    $sdf_annotate("./netlist/frequency_divider_by3.sdf", freq1,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");	//http://www.pldworld.com/_hdl/2/_ref/se_html/manual_html/c_sdf10.html
    $enable_warnings;
    $log("ncsim.log");

    for (i = 0; i < 16; i = i + 1) begin
      local_wr_en[i]   = 0;
      local_ON_OFF[i]  = 0;
      local_in_flit[i] = 8'b0;
    end
    #1000;
    $finish;
  end

  // only router (0,0) uses counter0
  always @(posedge clk) begin
    if      (rst)           counter0 <= 0;
    else if (router_out_full[0])      counter0 <= counter0;
    else if (counter0 > CYCLES) counter0 <= 0;
    else                     counter0 <= counter0 + 1;
  end

  // injection logic: flit 1=head, 2–6=body, 7=tail
  always @(*) begin
    if (!router_out_full[0]) begin
      case (counter0)
        1: begin
          // head: destination (3,3) encoded in 6 MSBs, type=00
          local_wr_en[0]   = 1;
          local_in_flit[0] = {3'b011, 3'b011, 2'b00};
        end
        2: begin local_wr_en[0]=1; local_in_flit[0]={payload[29:24],2'b01}; end
        3: begin local_wr_en[0]=1; local_in_flit[0]={payload[23:18],2'b01}; end
        4: begin local_wr_en[0]=1; local_in_flit[0]={payload[17:12],2'b01}; end
        5: begin local_wr_en[0]=1; local_in_flit[0]={payload[11:6], 2'b01}; end
        6: begin local_wr_en[0]=1; local_in_flit[0]={payload[5:0],  2'b01}; end
        7: begin
          // tail: 2‑bit data in MSBs, rest don't‑care, type=10
          local_wr_en[0]   = 1;
          local_in_flit[0] = {tail_data, 4'b0000, 2'b10};
        end
        default: begin
          local_wr_en[0]   = 0;
          local_in_flit[0] = 8'hx;
        end
      endcase
    end else begin
      local_wr_en[0]   = 0;
      local_in_flit[0] = 8'hx;
    end
  end

  // instantiate the 4×4 mesh
  mesh_general #(
    .MESH_COLUMNS (MESH_COLUMNS),
    .MESH_ROWS    (MESH_ROWS),
    .LINK_WIDTHS  (LINK_WIDTHS),
    .BUFFER_DEPTH (BUFFER_DEPTH),
    .PORTS        (PORTS)
  ) mesh_4x4_inst (
    .clk            (clk),
    .rst            (rst),
    .local_in_flit  (local_in_flit),
    .local_wr_en    (local_wr_en),
    .local_ON_OFF   (local_ON_OFF),
    .local_out_flit (local_out_flit),
    .router_out_full(router_out_full)
  );

endmodule
