`timescale 1ns/1ps
`define DW 64        // width seen by the NICs / mesh
//-------------------------------------------------------------
//  Include gate-level net-list + liberty cells (if required)
//-------------------------------------------------------------
`include "./netlist/cardinal_noc_syn.v"
`include "./include/gscl45nm.v"


//======================================================================
//                          TEST-BENCH
//======================================================================
module tb_noc_1to1;

// ---------------- user-selectable source / destination ---------------
localparam integer SRC_X = 0 , SRC_Y = 0 ;   // tile (0,0)
localparam integer DST_X = 1 , DST_Y = 1 ;   // tile (1,1)

// ------------------------------ clock / reset ------------------------
reg clk , reset;
initial begin
  clk = 1'b0;
  forever #5 clk = ~clk;      // 100 MHz
end
initial begin
  reset = 1'b1;
  #25 reset = 1'b0;
  $display("[%0t] reset de-asserted", $time);
end

// ====================================================================
//          per-tile NIC control / data signals  ( 3 × 3  =  9 )
// ====================================================================
reg  [1:0]     nic_addr_00, nic_addr_10, nic_addr_20,
               nic_addr_01, nic_addr_11, nic_addr_21,
               nic_addr_02, nic_addr_12, nic_addr_22;

reg  [`DW-1:0] nic_di_00 , nic_di_10 , nic_di_20 ,
               nic_di_01 , nic_di_11 , nic_di_21 ,
               nic_di_02 , nic_di_12 , nic_di_22;

wire [`DW-1:0] nic_do_00 , nic_do_10 , nic_do_20 ,
               nic_do_01 , nic_do_11 , nic_do_21 ,
               nic_do_02 , nic_do_12 , nic_do_22;

reg            nic_en_00 , nic_en_10 , nic_en_20 ,
               nic_en_01 , nic_en_11 , nic_en_21 ,
               nic_en_02 , nic_en_12 , nic_en_22;

reg            nic_we_00 , nic_we_10 , nic_we_20 ,
               nic_we_01 , nic_we_11 , nic_we_21 ,
               nic_we_02 , nic_we_12 , nic_we_22;

// ------------------------------------------------ init all low -------
initial begin
  {nic_addr_00 ,nic_addr_10 ,nic_addr_20 ,
   nic_addr_01 ,nic_addr_11 ,nic_addr_21 ,
   nic_addr_02 ,nic_addr_12 ,nic_addr_22} = 0;

  {nic_di_00 ,nic_di_10 ,nic_di_20 ,
   nic_di_01 ,nic_di_11 ,nic_di_21 ,
   nic_di_02 ,nic_di_12 ,nic_di_22} = 0;

  {nic_en_00 ,nic_en_10 ,nic_en_20 ,
   nic_en_01 ,nic_en_11 ,nic_en_21 ,
   nic_en_02 ,nic_en_12 ,nic_en_22} = 0;

  {nic_we_00 ,nic_we_10 ,nic_we_20 ,
   nic_we_01 ,nic_we_11 ,nic_we_21 ,
   nic_we_02 ,nic_we_12 ,nic_we_22} = 0;
end

// ====================================================================
//                          DUT  (gate net-list)
// ====================================================================
cardinal_noc dut (
   .clk(clk), .reset(reset),

   .nic_addr_00(nic_addr_00), .nic_di_00(nic_di_00),
   .nic_En_00  (nic_en_00  ), .nic_WrEn_00(nic_we_00), .nic_do_00(nic_do_00),

   .nic_addr_01(nic_addr_01), .nic_di_01(nic_di_01),
   .nic_En_01  (nic_en_01  ), .nic_WrEn_01(nic_we_01), .nic_do_01(nic_do_01),

   .nic_addr_02(nic_addr_02), .nic_di_02(nic_di_02),
   .nic_En_02  (nic_en_02  ), .nic_WrEn_02(nic_we_02), .nic_do_02(nic_do_02),

   .nic_addr_10(nic_addr_10), .nic_di_10(nic_di_10),
   .nic_En_10  (nic_en_10  ), .nic_WrEn_10(nic_we_10), .nic_do_10(nic_do_10),

   .nic_addr_11(nic_addr_11), .nic_di_11(nic_di_11),
   .nic_En_11  (nic_en_11  ), .nic_WrEn_11(nic_we_11), .nic_do_11(nic_do_11),

   .nic_addr_12(nic_addr_12), .nic_di_12(nic_di_12),
   .nic_En_12  (nic_en_12  ), .nic_WrEn_12(nic_we_12), .nic_do_12(nic_do_12),

   .nic_addr_20(nic_addr_20), .nic_di_20(nic_di_20),
   .nic_En_20  (nic_en_20  ), .nic_WrEn_20(nic_we_20), .nic_do_20(nic_do_20),

   .nic_addr_21(nic_addr_21), .nic_di_21(nic_di_21),
   .nic_En_21  (nic_en_21  ), .nic_WrEn_21(nic_we_21), .nic_do_21(nic_do_21),

   .nic_addr_22(nic_addr_22), .nic_di_22(nic_di_22),
   .nic_En_22  (nic_en_22  ), .nic_WrEn_22(nic_we_22), .nic_do_22(nic_do_22)
);

// ====================================================================
//                    HELPER  PROCEDURES / FUNCTIONS
// ====================================================================
function [`DW-1:0] build_packet;
  input        vc , hd , vd;
  input  [3:0] hh , vh;
  input [15:0] sid , dat;
  reg   [`DW-1:0] p;
begin
  p             = 0;
  p[63]         = vc;
  p[62]         = hd;
  p[61]         = vd;
  p[55:52]      = hh;
  p[51:48]      = vh;
  p[47:32]      = sid;
  p[31:16]      = dat;
  build_packet  = p;
end
endfunction

task drive_clear;
begin
  nic_en_00=0; nic_we_00=0; nic_addr_00=2'b00;
  nic_en_01=0; nic_we_01=0; nic_addr_01=2'b00;
  nic_en_02=0; nic_we_02=0; nic_addr_02=2'b00;
  nic_en_10=0; nic_we_10=0; nic_addr_10=2'b00;
  nic_en_11=0; nic_we_11=0; nic_addr_11=2'b00;
  nic_en_12=0; nic_we_12=0; nic_addr_12=2'b00;
  nic_en_20=0; nic_we_20=0; nic_addr_20=2'b00;
  nic_en_21=0; nic_we_21=0; nic_addr_21=2'b00;
  nic_en_22=0; nic_we_22=0; nic_addr_22=2'b00;
end
endtask

// ---- write ------------------------------------------------------------------
task nic_write_packet (input integer idx, input [`DW-1:0] payload);
begin
  case(idx)
    0: begin nic_di_00<=payload; nic_addr_00<=2'b10; nic_en_00<=1; nic_we_00<=1; end
    1: begin nic_di_10<=payload; nic_addr_10<=2'b10; nic_en_10<=1; nic_we_10<=1; end
    2: begin nic_di_20<=payload; nic_addr_20<=2'b10; nic_en_20<=1; nic_we_20<=1; end
    3: begin nic_di_01<=payload; nic_addr_01<=2'b10; nic_en_01<=1; nic_we_01<=1; end
    4: begin nic_di_11<=payload; nic_addr_11<=2'b10; nic_en_11<=1; nic_we_11<=1; end
    5: begin nic_di_21<=payload; nic_addr_21<=2'b10; nic_en_21<=1; nic_we_21<=1; end
    6: begin nic_di_02<=payload; nic_addr_02<=2'b10; nic_en_02<=1; nic_we_02<=1; end
    7: begin nic_di_12<=payload; nic_addr_12<=2'b10; nic_en_12<=1; nic_we_12<=1; end
    8: begin nic_di_22<=payload; nic_addr_22<=2'b10; nic_en_22<=1; nic_we_22<=1; end
  endcase
  @(posedge clk);
  @(posedge clk);
  drive_clear();
end
endtask

// ---- read IN-FULL flag  (bit 0 !) ----------------------------------
task nic_get_full_flag (input integer idx, output reg flag);
begin
  flag = 0;
  case(idx)
    0: begin nic_addr_00=2'b01; nic_en_00=1; end
    1: begin nic_addr_10=2'b01; nic_en_10=1; end
    2: begin nic_addr_20=2'b01; nic_en_20=1; end
    3: begin nic_addr_01=2'b01; nic_en_01=1; end
    4: begin nic_addr_11=2'b01; nic_en_11=1; end
    5: begin nic_addr_21=2'b01; nic_en_21=1; end
    6: begin nic_addr_02=2'b01; nic_en_02=1; end
    7: begin nic_addr_12=2'b01; nic_en_12=1; end
    8: begin nic_addr_22=2'b01; nic_en_22=1; end
  endcase
  @(posedge clk);
  case(idx)
    0: flag = nic_do_00[0];
    1: flag = nic_do_10[0];
    2: flag = nic_do_20[0];
    3: flag = nic_do_01[0];
    4: flag = nic_do_11[0];
    5: flag = nic_do_21[0];
    6: flag = nic_do_02[0];
    7: flag = nic_do_12[0];
    8: flag = nic_do_22[0];
  endcase
  drive_clear();
end
endtask

// ---- read DATA ------------------------------------------------------
task nic_read_packet (input integer idx, output [`DW-1:0] pkt);
begin
  case(idx)
    0: begin nic_addr_00=2'b00; nic_en_00=1; end
    1: begin nic_addr_10=2'b00; nic_en_10=1; end
    2: begin nic_addr_20=2'b00; nic_en_20=1; end
    3: begin nic_addr_01=2'b00; nic_en_01=1; end
    4: begin nic_addr_11=2'b00; nic_en_11=1; end
    5: begin nic_addr_21=2'b00; nic_en_21=1; end
    6: begin nic_addr_02=2'b00; nic_en_02=1; end
    7: begin nic_addr_12=2'b00; nic_en_12=1; end
    8: begin nic_addr_22=2'b00; nic_en_22=1; end
  endcase
  @(posedge clk);
  case(idx)
    0: pkt = nic_do_00;
    1: pkt = nic_do_10;
    2: pkt = nic_do_20;
    3: pkt = nic_do_01;
    4: pkt = nic_do_11;
    5: pkt = nic_do_21;
    6: pkt = nic_do_02;
    7: pkt = nic_do_12;
    8: pkt = nic_do_22;
  endcase
  drive_clear();
end
endtask

// ====================================================================
//                          MAIN SCENARIO
// ====================================================================
integer  src_idx , dst_idx , dx , dy , cycles;
reg      hdir , vdir;
reg [3:0] hhop , vhop;
reg [`DW-1:0] pkt;
reg      arrived;

initial begin
    $sdf_annotate("./netlist/cardinal_noc.sdf", dut,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");
    $enable_warnings;
    $log("ncsim.log");//outputs the log in console to file
end

initial begin : unicast
  //------------------------------------------------------------
  src_idx = SRC_Y*3 + SRC_X;
  dst_idx = DST_Y*3 + DST_X;

  dx   = (DST_X >= SRC_X) ? (DST_X-SRC_X) : (SRC_X-DST_X);
  dy   = (DST_Y >= SRC_Y) ? (DST_Y-SRC_Y) : (SRC_Y-DST_Y);

  hdir = (DST_X < SRC_X);          // 0=right, 1=left
  vdir = (DST_Y > SRC_Y);          // 0=south, 1=north

  hhop = (dx==0)?4'b0:((4'b1<<dx)-1);
  vhop = (dy==0)?4'b0:((4'b1<<dy)-1);

  pkt  = build_packet(1'b0, hdir, vdir, hhop, vhop, 16'hABCD, 16'hABCD);

  $display("[%0t] Send (%0d,%0d)->(%0d,%0d)  dir=%b,%b hop=%b,%b  pkt=0x%h",
           $time,SRC_X,SRC_Y,DST_X,DST_Y,hdir,vdir,hhop,vhop,pkt);

  wait(!reset); #20;

  // 1) inject
  nic_write_packet(src_idx, pkt);
  $display("[%0t] injected into NIC %0d", $time, src_idx);

  // 2) poll destination
  cycles  = 0;  arrived = 0;
  while ((cycles<400) && (!arrived)) begin
    nic_get_full_flag(dst_idx, arrived);
    cycles = cycles + 1;
  end

  if (!arrived) begin
    $display("[%0t] ** TIMEOUT **", $time);
    $finish;
  end

  // 3) read back
  nic_read_packet(dst_idx, pkt);
  $display("[%0t] SUCCESS NIC %0d received 0x%h", $time, dst_idx, pkt);

  #40 $finish;
end

endmodule
`undef DW