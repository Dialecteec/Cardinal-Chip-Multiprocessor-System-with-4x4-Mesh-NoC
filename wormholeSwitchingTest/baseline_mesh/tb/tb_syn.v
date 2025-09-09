`timescale 1ns/1ns
`include "./include/gscl45nm.v"

module tb_syn;

  // Clock and reset
  reg clk;
  reg reset;

  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // 10 ns period
  end

  initial begin
    reset = 1;
    #25;
    reset = 0;
    $display("[%0t] Reset deasserted", $time);
  end

  // Node signal declarations (only rows 0 and 3 really used, but we keep all)
  reg         node00_pesi, node10_pesi, node20_pesi, node30_pesi;
  reg  [63:0] node00_pedi, node10_pedi, node20_pedi, node30_pedi;
  wire        node00_peri, node10_peri, node20_peri, node30_peri;
  wire        node00_peso, node10_peso, node20_peso, node30_peso;
  wire [63:0] node00_pedo, node10_pedo, node20_pedo, node30_pedo;
  wire        node00_pero, node10_pero, node20_pero, node30_pero;
  wire        node00_polarity, node10_polarity, node20_polarity, node30_polarity;

  reg         node01_pesi, node11_pesi, node21_pesi, node31_pesi;
  reg  [63:0] node01_pedi, node11_pedi, node21_pedi, node31_pedi;
  wire        node01_peri, node11_peri, node21_peri, node31_peri;
  wire        node01_peso, node11_peso, node21_peso, node31_peso;
  wire [63:0] node01_pedo, node11_pedo, node21_pedo, node31_pedo;
  wire        node01_pero, node11_pero, node21_pero, node31_pero;
  wire        node01_polarity, node11_polarity, node21_polarity, node31_polarity;

  reg         node02_pesi, node12_pesi, node22_pesi, node32_pesi;
  reg  [63:0] node02_pedi, node12_pedi, node22_pedi, node32_pedi;
  wire        node02_peri, node12_peri, node22_peri, node32_peri;
  wire        node02_peso, node12_peso, node22_peso, node32_peso;
  wire [63:0] node02_pedo, node12_pedo, node22_pedo, node32_pedo;
  wire        node02_pero, node12_pero, node22_pero, node32_pero;
  wire        node02_polarity, node12_polarity, node22_polarity, node32_polarity;

  reg         node03_pesi, node13_pesi, node23_pesi, node33_pesi;
  reg  [63:0] node03_pedi, node13_pedi, node23_pedi, node33_pedi;
  wire        node03_peri, node13_peri, node23_peri, node33_peri;
  wire        node03_peso, node13_peso, node23_peso, node33_peso;
  wire [63:0] node03_pedo, node13_pedo, node23_pedo, node33_pedo;
  wire        node03_pero, node13_pero, node23_pero, node33_pero;
  wire        node03_polarity, node13_polarity, node23_polarity, node33_polarity;

  // Tie all pero signals high (all nodes always ready)
  assign node00_pero = 1'b1; assign node10_pero = 1'b1; assign node20_pero = 1'b1; assign node30_pero = 1'b1;
  assign node01_pero = 1'b1; assign node11_pero = 1'b1; assign node21_pero = 1'b1; assign node31_pero = 1'b1;
  assign node02_pero = 1'b1; assign node12_pero = 1'b1; assign node22_pero = 1'b1; assign node32_pero = 1'b1;
  assign node03_pero = 1'b1; assign node13_pero = 1'b1; assign node23_pero = 1'b1; assign node33_pero = 1'b1;

  // Instantiate the 4×4 mesh (only PACKET_SIZE used here)
  gold_mesh #(.PACKET_SIZE(64)) uut (
    .clk   (clk),
    .reset (reset),

    // Row 0
    .node00_pesi     (node00_pesi),
    .node00_pedi     (node00_pedi),
    .node00_peri     (node00_peri),
    .node00_peso     (node00_peso),
    .node00_pedo     (node00_pedo),
    .node00_pero     (node00_pero),
    .node00_polarity (node00_polarity),

    // ... (all other rows connections unchanged) ...

    // Row 3, node33
    .node33_pesi     (node33_pesi),
    .node33_pedi     (node33_pedi),
    .node33_peri     (node33_peri),
    .node33_peso     (node33_peso),
    .node33_pedo     (node33_pedo),
    .node33_pero     (node33_pero),
    .node33_polarity (node33_polarity)
  );


  // packet builder & driver tasks (unchanged from your version)
  function [63:0] build_packet(
      input       vc_bit,
      input       horiz_dir,
      input       vert_dir,
      input [3:0] horiz_hop,
      input [3:0] vert_hop,
      input [15:0] src_id,
      input [15:0] dst_id
  );
    build_packet = { vc_bit,
                     horiz_dir,
                     vert_dir,
                     2'b00,            // reserved
                     horiz_hop,
                     vert_hop,
                     src_id,
                     dst_id };
  endfunction

  task send_packet;
    input integer node_idx;
    input [63:0] pkt;
    begin
      case (node_idx)
        0: begin node00_pedi = pkt; node00_pesi = 1; @(posedge clk);
             while (!node00_peri) @(posedge clk);
             @(posedge clk);
             node00_pesi = 0;
             node00_pedi = 0;
           end
        15: begin node33_pedi = pkt; node33_pesi = 1; @(posedge clk);
             while (!node33_peri) @(posedge clk);
             @(posedge clk);
             node33_pesi = 0;
             node33_pedi = 0;
           end
        default: ;
      endcase
    end
  endtask

  task wait_for_packet;
    input integer node_idx;
    begin
      case (node_idx)
        15: begin
              wait (node33_peso);
              $display("[%0t] node33 got 0x%h", $time, node33_pedo);
            end
        default: ;
      endcase
    end
  endtask


  // Single‑packet test
  initial begin

    $sdf_annotate("./netlist/frequency_divider_by3.sdf", freq1,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");	//http://www.pldworld.com/_hdl/2/_ref/se_html/manual_html/c_sdf10.html
    $enable_warnings;
    $log("ncsim.log");

    // wait for reset
    wait (!reset);
    #10;

    // build parameters for node00→node33
    // src=(0,0), dst=(3,3)
    // horiz_dir=0(right), vert_dir=1(north)
    // horiz_hop=(1<<3)-1=3'b111, vert_hop=3'b111
    // src_id=16'h0000, dst_id=16'h000F
    reg [63:0] pkt;
    pkt = build_packet(
      1'b0,           // VC0
      1'b0,           // right
      1'b1,           // north
      4'b0111,        // three hops
      4'b0111,        // three hops
      16'h0000,       // src_id
      16'h000F        // dst_id
    );
    $display("[%0t] sending packet 0x%h from node00→node33", $time, pkt);
    send_packet(0, pkt);
    wait_for_packet(15);

    #20;
    $finish;
  end

endmodule
