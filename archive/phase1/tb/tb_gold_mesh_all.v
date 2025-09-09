`timescale 1ns/1ns
module tb_gold_mesh_all;

// Clock and reset
  reg clk;
  reg reset;
  
  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // 10 ns period
  end
  
  initial begin
    reset = 1;
    #25;
    reset = 0;
    $display("[%0t] Reset deasserted", $time);
  end


// Node signal declarations (16 nodes)
  // Using the following mapping:
  // Row 0: node00 (index 0), node10 (index 1), node20 (index 2), node30 (index 3)
  // Row 1: node01 (index 4), node11 (index 5), node21 (index 6), node31 (index 7)
  // Row 2: node02 (index 8), node12 (index 9), node22 (index 10), node32 (index 11)
  // Row 3: node03 (index 12), node13 (index 13), node23 (index 14), node33 (index 15)

  // Row 0:
  reg         node00_pesi, node10_pesi, node20_pesi, node30_pesi;
  reg  [63:0] node00_pedi, node10_pedi, node20_pedi, node30_pedi;
  wire        node00_peri, node10_peri, node20_peri, node30_peri;
  wire        node00_peso, node10_peso, node20_peso, node30_peso;
  wire [63:0] node00_pedo, node10_pedo, node20_pedo, node30_pedo;
  wire        node00_pero, node10_pero, node20_pero, node30_pero;
  wire        node00_polarity, node10_polarity, node20_polarity, node30_polarity;
  
  // Row 1:
  reg         node01_pesi, node11_pesi, node21_pesi, node31_pesi;
  reg  [63:0] node01_pedi, node11_pedi, node21_pedi, node31_pedi;
  wire        node01_peri, node11_peri, node21_peri, node31_peri;
  wire        node01_peso, node11_peso, node21_peso, node31_peso;
  wire [63:0] node01_pedo, node11_pedo, node21_pedo, node31_pedo;
  wire        node01_pero, node11_pero, node21_pero, node31_pero;
  wire        node01_polarity, node11_polarity, node21_polarity, node31_polarity;
  
  // Row 2:
  reg         node02_pesi, node12_pesi, node22_pesi, node32_pesi;
  reg  [63:0] node02_pedi, node12_pedi, node22_pedi, node32_pedi;
  wire        node02_peri, node12_peri, node22_peri, node32_peri;
  wire        node02_peso, node12_peso, node22_peso, node32_peso;
  wire [63:0] node02_pedo, node12_pedo, node22_pedo, node32_pedo;
  wire        node02_pero, node12_pero, node22_pero, node32_pero;
  wire        node02_polarity, node12_polarity, node22_polarity, node32_polarity;
  
  // Row 3:
  reg         node03_pesi, node13_pesi, node23_pesi, node33_pesi;
  reg  [63:0] node03_pedi, node13_pedi, node23_pedi, node33_pedi;
  wire        node03_peri, node13_peri, node23_peri, node33_peri;
  wire        node03_peso, node13_peso, node23_peso, node33_peso;
  wire [63:0] node03_pedo, node13_pedo, node23_pedo, node33_pedo;
  wire        node03_pero, node13_pero, node23_pero, node33_pero;
  wire        node03_polarity, node13_polarity, node23_polarity, node33_polarity;
  

// Initialize all node PESI signals to 0.
  initial begin
    node00_pesi = 0; node10_pesi = 0; node20_pesi = 0; node30_pesi = 0;
    node01_pesi = 0; node11_pesi = 0; node21_pesi = 0; node31_pesi = 0;
    node02_pesi = 0; node12_pesi = 0; node22_pesi = 0; node32_pesi = 0;
    node03_pesi = 0; node13_pesi = 0; node23_pesi = 0; node33_pesi = 0;
  end
  

// Tie all pero signals high (all nodes are always ready)
  assign node00_pero = 1'b1;
  assign node10_pero = 1'b1;
  assign node20_pero = 1'b1;
  assign node30_pero = 1'b1;
  
  assign node01_pero = 1'b1;
  assign node11_pero = 1'b1;
  assign node21_pero = 1'b1;
  assign node31_pero = 1'b1;
  
  assign node02_pero = 1'b1;
  assign node12_pero = 1'b1;
  assign node22_pero = 1'b1;
  assign node32_pero = 1'b1;
  
  assign node03_pero = 1'b1;
  assign node13_pero = 1'b1;
  assign node23_pero = 1'b1;
  assign node33_pero = 1'b1;


// Instantiate the 4x4 mesh.
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
    
    .node10_pesi     (node10_pesi),
    .node10_pedi     (node10_pedi),
    .node10_peri     (node10_peri),
    .node10_peso     (node10_peso),
    .node10_pedo     (node10_pedo),
    .node10_pero     (node10_pero),
    .node10_polarity (node10_polarity),
    
    .node20_pesi     (node20_pesi),
    .node20_pedi     (node20_pedi),
    .node20_peri     (node20_peri),
    .node20_peso     (node20_peso),
    .node20_pedo     (node20_pedo),
    .node20_pero     (node20_pero),
    .node20_polarity (node20_polarity),
    
    .node30_pesi     (node30_pesi),
    .node30_pedi     (node30_pedi),
    .node30_peri     (node30_peri),
    .node30_peso     (node30_peso),
    .node30_pedo     (node30_pedo),
    .node30_pero     (node30_pero),
    .node30_polarity (node30_polarity),
    
    // Row 1
    .node01_pesi     (node01_pesi),
    .node01_pedi     (node01_pedi),
    .node01_peri     (node01_peri),
    .node01_peso     (node01_peso),
    .node01_pedo     (node01_pedo),
    .node01_pero     (node01_pero),
    .node01_polarity (node01_polarity),
    
    .node11_pesi     (node11_pesi),
    .node11_pedi     (node11_pedi),
    .node11_peri     (node11_peri),
    .node11_peso     (node11_peso),
    .node11_pedo     (node11_pedo),
    .node11_pero     (node11_pero),
    .node11_polarity (node11_polarity),
    
    .node21_pesi     (node21_pesi),
    .node21_pedi     (node21_pedi),
    .node21_peri     (node21_peri),
    .node21_peso     (node21_peso),
    .node21_pedo     (node21_pedo),
    .node21_pero     (node21_pero),
    .node21_polarity (node21_polarity),
    
    .node31_pesi     (node31_pesi),
    .node31_pedi     (node31_pedi),
    .node31_peri     (node31_peri),
    .node31_peso     (node31_peso),
    .node31_pedo     (node31_pedo),
    .node31_pero     (node31_pero),
    .node31_polarity (node31_polarity),
    
    // Row 2
    .node02_pesi     (node02_pesi),
    .node02_pedi     (node02_pedi),
    .node02_peri     (node02_peri),
    .node02_peso     (node02_peso),
    .node02_pedo     (node02_pedo),
    .node02_pero     (node02_pero),
    .node02_polarity (node02_polarity),
    
    .node12_pesi     (node12_pesi),
    .node12_pedi     (node12_pedi),
    .node12_peri     (node12_peri),
    .node12_peso     (node12_peso),
    .node12_pedo     (node12_pedo),
    .node12_pero     (node12_pero),
    .node12_polarity (node12_polarity),
    
    .node22_pesi     (node22_pesi),
    .node22_pedi     (node22_pedi),
    .node22_peri     (node22_peri),
    .node22_peso     (node22_peso),
    .node22_pedo     (node22_pedo),
    .node22_pero     (node22_pero),
    .node22_polarity (node22_polarity),
    
    .node32_pesi     (node32_pesi),
    .node32_pedi     (node32_pedi),
    .node32_peri     (node32_peri),
    .node32_peso     (node32_peso),
    .node32_pedo     (node32_pedo),
    .node32_pero     (node32_pero),
    .node32_polarity (node32_polarity),
    
    // Row 3
    .node03_pesi     (node03_pesi),
    .node03_pedi     (node03_pedi),
    .node03_peri     (node03_peri),
    .node03_peso     (node03_peso),
    .node03_pedo     (node03_pedo),
    .node03_pero     (node03_pero),
    .node03_polarity (node03_polarity),
    
    .node13_pesi     (node13_pesi),
    .node13_pedi     (node13_pedi),
    .node13_peri     (node13_peri),
    .node13_peso     (node13_peso),
    .node13_pedo     (node13_pedo),
    .node13_pero     (node13_pero),
    .node13_polarity (node13_polarity),
    
    .node23_pesi     (node23_pesi),
    .node23_pedi     (node23_pedi),
    .node23_peri     (node23_peri),
    .node23_peso     (node23_peso),
    .node23_pedo     (node23_pedo),
    .node23_pero     (node23_pero),
    .node23_polarity (node23_polarity),
    
    .node33_pesi     (node33_pesi),
    .node33_pedi     (node33_pedi),
    .node33_peri     (node33_peri),
    .node33_peso     (node33_peso),
    .node33_pedo     (node33_pedo),
    .node33_pero     (node33_pero),
    .node33_polarity (node33_polarity)
  );
  

// Packet-building function
  function [63:0] build_packet(
      input       vc_bit,
      input       horiz_dir,   // 0 => right, 1 => left
      input       vert_dir,    // 0 => south, 1 => north
      input [3:0] horiz_hop,
      input [3:0] vert_hop,
      input [15:0] src_id,
      input [15:0] data
  );
    reg [63:0] pkt;
    begin
      pkt           = 64'b0;
      pkt[63]       = vc_bit;
      pkt[62]       = horiz_dir;
      pkt[61]       = vert_dir;
      pkt[55:52]    = horiz_hop;
      pkt[51:48]    = vert_hop;
      pkt[47:32]    = src_id;
      pkt[31:16]    = data;
      build_packet  = pkt;
    end
  endfunction
  

// Task: send a packet from a given source node.
  // This drives the appropriate node's PEDI/PESI for one cycle,
  // waits for the handshake (PERI) and then deasserts.
  task send_packet;
    input integer src;
    input [63:0] pkt;
    begin
      case (src)
        0: begin node00_pedi = pkt; node00_pesi = 1'b1; @(posedge clk); while(!node00_peri) @(posedge clk); @(posedge clk); node00_pesi = 1'b0; node00_pedi = 64'd0; end
        1: begin node10_pedi = pkt; node10_pesi = 1'b1; @(posedge clk); while(!node10_peri) @(posedge clk); @(posedge clk); node10_pesi = 1'b0; node10_pedi = 64'd0; end
        2: begin node20_pedi = pkt; node20_pesi = 1'b1; @(posedge clk); while(!node20_peri) @(posedge clk); @(posedge clk); node20_pesi = 1'b0; node20_pedi = 64'd0; end
        3: begin node30_pedi = pkt; node30_pesi = 1'b1; @(posedge clk); while(!node30_peri) @(posedge clk); @(posedge clk); node30_pesi = 1'b0; node30_pedi = 64'd0; end
        4: begin node01_pedi = pkt; node01_pesi = 1'b1; @(posedge clk); while(!node01_peri) @(posedge clk); @(posedge clk); node01_pesi = 1'b0; node01_pedi = 64'd0; end
        5: begin node11_pedi = pkt; node11_pesi = 1'b1; @(posedge clk); while(!node11_peri) @(posedge clk); @(posedge clk); node11_pesi = 1'b0; node11_pedi = 64'd0; end
        6: begin node21_pedi = pkt; node21_pesi = 1'b1; @(posedge clk); while(!node21_peri) @(posedge clk); @(posedge clk); node21_pesi = 1'b0; node21_pedi = 64'd0; end
        7: begin node31_pedi = pkt; node31_pesi = 1'b1; @(posedge clk); while(!node31_peri) @(posedge clk); @(posedge clk); node31_pesi = 1'b0; node31_pedi = 64'd0; end
        8: begin node02_pedi = pkt; node02_pesi = 1'b1; @(posedge clk); while(!node02_peri) @(posedge clk); @(posedge clk); node02_pesi = 1'b0; node02_pedi = 64'd0; end
        9: begin node12_pedi = pkt; node12_pesi = 1'b1; @(posedge clk); while(!node12_peri) @(posedge clk); @(posedge clk); node12_pesi = 1'b0; node12_pedi = 64'd0; end
        10: begin node22_pedi = pkt; node22_pesi = 1'b1; @(posedge clk); while(!node22_peri) @(posedge clk); @(posedge clk); node22_pesi = 1'b0; node22_pedi = 64'd0; end
        11: begin node32_pedi = pkt; node32_pesi = 1'b1; @(posedge clk); while(!node32_peri) @(posedge clk); @(posedge clk); node32_pesi = 1'b0; node32_pedi = 64'd0; end
        12: begin node03_pedi = pkt; node03_pesi = 1'b1; @(posedge clk); while(!node03_peri) @(posedge clk); @(posedge clk); node03_pesi = 1'b0; node03_pedi = 64'd0; end
        13: begin node13_pedi = pkt; node13_pesi = 1'b1; @(posedge clk); while(!node13_peri) @(posedge clk); @(posedge clk); node13_pesi = 1'b0; node13_pedi = 64'd0; end
        14: begin node23_pedi = pkt; node23_pesi = 1'b1; @(posedge clk); while(!node23_peri) @(posedge clk); @(posedge clk); node23_pesi = 1'b0; node23_pedi = 64'd0; end
        15: begin node33_pedi = pkt; node33_pesi = 1'b1; @(posedge clk); while(!node33_peri) @(posedge clk); @(posedge clk); node33_pesi = 1'b0; node33_pedi = 64'd0; end
        default: ;
      endcase
    end
  endtask


// Task: wait for a packet at a given destination node.
  // This task waits until the destination's peso goes high (up to a timeout)
  // and prints a success message immediately.

  task wait_for_packet;
    input integer dst;
    integer timeout;
    reg success;
    begin
      timeout = 0;
      success = 0;
      while ((timeout < 200) && (!success)) begin
        @(posedge clk);
        timeout = timeout + 1;
        case (dst)
          0: if (node00_peso) success = 1;
          1: if (node10_peso) success = 1;
          2: if (node20_peso) success = 1;
          3: if (node30_peso) success = 1;
          4: if (node01_peso) success = 1;
          5: if (node11_peso) success = 1;
          6: if (node21_peso) success = 1;
          7: if (node31_peso) success = 1;
          8: if (node02_peso) success = 1;
          9: if (node12_peso) success = 1;
          10: if (node22_peso) success = 1;
          11: if (node32_peso) success = 1;
          12: if (node03_peso) success = 1;
          13: if (node13_peso) success = 1;
          14: if (node23_peso) success = 1;
          15: if (node33_peso) success = 1;
          default: ;
        endcase
        if (success) begin
          case (dst)
            0: $display("[%0t] SUCCESS: node00 received packet=0x%h", $time, node00_pedo);
            1: $display("[%0t] SUCCESS: node10 received packet=0x%h", $time, node10_pedo);
            2: $display("[%0t] SUCCESS: node20 received packet=0x%h", $time, node20_pedo);
            3: $display("[%0t] SUCCESS: node30 received packet=0x%h", $time, node30_pedo);
            4: $display("[%0t] SUCCESS: node01 received packet=0x%h", $time, node01_pedo);
            5: $display("[%0t] SUCCESS: node11 received packet=0x%h", $time, node11_pedo);
            6: $display("[%0t] SUCCESS: node21 received packet=0x%h", $time, node21_pedo);
            7: $display("[%0t] SUCCESS: node31 received packet=0x%h", $time, node31_pedo);
            8: $display("[%0t] SUCCESS: node02 received packet=0x%h", $time, node02_pedo);
            9: $display("[%0t] SUCCESS: node12 received packet=0x%h", $time, node12_pedo);
            10: $display("[%0t] SUCCESS: node22 received packet=0x%h", $time, node22_pedo);
            11: $display("[%0t] SUCCESS: node32 received packet=0x%h", $time, node32_pedo);
            12: $display("[%0t] SUCCESS: node03 received packet=0x%h", $time, node03_pedo);
            13: $display("[%0t] SUCCESS: node13 received packet=0x%h", $time, node13_pedo);
            14: $display("[%0t] SUCCESS: node23 received packet=0x%h", $time, node23_pedo);
            15: $display("[%0t] SUCCESS: node33 received packet=0x%h", $time, node33_pedo);
            default: $display("Unknown destination %0d", dst);
          endcase
        end
      end
      if (!success) begin
        case (dst)
          0: $display("[%0t] FAILURE: node00 did not receive", $time);
          1: $display("[%0t] FAILURE: node10 did not receive", $time);
          2: $display("[%0t] FAILURE: node20 did not receive", $time);
          3: $display("[%0t] FAILURE: node30 did not receive", $time);
          4: $display("[%0t] FAILURE: node01 did not receive", $time);
          5: $display("[%0t] FAILURE: node11 did not receive", $time);
          6: $display("[%0t] FAILURE: node21 did not receive", $time);
          7: $display("[%0t] FAILURE: node31 did not receive", $time);
          8: $display("[%0t] FAILURE: node02 did not receive", $time);
          9: $display("[%0t] FAILURE: node12 did not receive", $time);
          10: $display("[%0t] FAILURE: node22 did not receive", $time);
          11: $display("[%0t] FAILURE: node32 did not receive", $time);
          12: $display("[%0t] FAILURE: node03 did not receive", $time);
          13: $display("[%0t] FAILURE: node13 did not receive", $time);
          14: $display("[%0t] FAILURE: node23 did not receive", $time);
          15: $display("[%0t] FAILURE: node33 did not receive", $time);
          default: $display("Unknown destination %0d", dst);
        endcase
      end
    end
  endtask
  

// Main Test Loop: For each source node, send a packet to every other node.
  // Compute directions and hop counts based on coordinates.
  // Also, alternate vc_bit for each transfer.

integer src, dst;
reg [63:0] packet;
integer total;
// Coordinates and computed signals:
integer src_x, src_y, dst_x, dst_y;
reg horiz_dir;
reg vert_dir;
reg [3:0] horiz_hop;
reg [3:0] vert_hop;
reg vc; // vc_bit toggles
integer diff_x, diff_y;

// New registers to hold 16-bit unique coordinate fields:
reg [15:0] src_coord, dst_coord;

initial begin : all_test
  total = 0;
  vc = 1'b0; // start with vc_bit = 0
  
  // Wait for reset deassertion
  wait(!reset);
  #10;
  
  for (src = 0; src < 16; src = src + 1) begin
    // Compute source coordinates (x = src % 4, y = src / 4)
    src_x = src % 4;
    src_y = src / 4;
    
    for (dst = 0; dst < 16; dst = dst + 1) begin
      if (src != dst) begin
        total = total + 1;
        
        // Compute destination coordinates
        dst_x = dst % 4;
        dst_y = dst / 4;
        
        // Determine horizontal direction:
        if (dst_x > src_x)
          horiz_dir = 1'b0;  // 0 => right
        else if (dst_x < src_x)
          horiz_dir = 1'b1;  // 1 => left
        else
          horiz_dir = 1'b0;  // default if equal
        
        // Determine vertical direction:
        if (dst_y > src_y)
          vert_dir = 1'b1;   // 1 => north
        else if (dst_y < src_y)
          vert_dir = 1'b0;   // 0 => south
        else
          vert_dir = 1'b0;   // default if equal
        
        // Compute differences in coordinates:
        if (dst_x >= src_x)
          diff_x = dst_x - src_x;
        else
          diff_x = src_x - dst_x;
          
        if (dst_y >= src_y)
          diff_y = dst_y - src_y;
        else
          diff_y = src_y - dst_y;
        
        // Compute hop counts as a mask of diff ones.
        // If diff==0, then hop field = 0. Otherwise, (1 << diff) - 1.
        if (diff_x == 0)
          horiz_hop = 4'b0000;
        else
          horiz_hop = (4'b0001 << diff_x) - 1;
        
        if (diff_y == 0)
          vert_hop = 4'b0000;
        else
          vert_hop = (4'b0001 << diff_y) - 1;
        
        // Create unique coordinate fields.
        // Here we encode the source coordinates in a 16-bit field as:
        //  { 14'b0, src_y (2 bits), src_x (2 bits) }.
        // Similarly, for the destination:
        //  { 14'b0, dst_y (2 bits), dst_x (2 bits) }.
        // This makes the lower 32 bits of the overall packet unique per src-dst pair.
        src_coord = {14'b0, src_y[1:0], src_x[1:0]};
        dst_coord = {14'b0, dst_y[1:0], dst_x[1:0]};
        
        // Build the packet using the computed parameters and 
        // the unique coordinate fields instead of the constant 16'hABCD.
        packet = build_packet(vc, horiz_dir, vert_dir, horiz_hop, vert_hop, src_coord, dst_coord);
          $display("[%0t] Sending from node %0d (coord=(%0d,%0d)) to node %0d (coord=(%0d,%0d)) with VC=%b, horiz_hop=%b, vert_hop=%b: Packet=0x%h",
                   $time, src, src_x, src_y, dst, dst_x, dst_y, vc, horiz_hop, vert_hop, packet);
          send_packet(src, packet);
          wait_for_packet(dst);
          // Toggle VC bit for next transfer.
          vc = ~vc;
          // Wait a couple of cycles before next injection.
          @(posedge clk); @(posedge clk);
        end
      end
    end
    $display("Total transfers attempted: %0d", total);
    #50;
    $finish;
  end

endmodule
