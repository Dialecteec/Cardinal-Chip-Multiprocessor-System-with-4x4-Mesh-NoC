`timescale 1ns/1ps

// tb1 tests all basic routing inside a router from and to all possible direction

module tb1_gold_router;

  //------------------------------------------------------
  // Testbench signals
  //------------------------------------------------------
  reg        clk;
  reg        reset;
  reg        polarity;  // We'll toggle this each cycle

  // ---------------------------
  // gold_router I/O
  // ---------------------------
  // West side (cw input => output to East)
  reg         cwsi;  
  wire        cwri;  
  reg  [63:0] cwdi;  

  wire        cwso;  
  reg         cwro;  
  wire [63:0] cwdo;  

  // East side (ccw input => output to West)
  reg         ccwsi;
  wire        ccwri;
  reg  [63:0] ccwdi;

  wire        ccwso;
  reg         ccwro;
  wire [63:0] ccwdo;

  // North side (nssi => output to South)
  reg         nssi;
  wire        nsri;
  reg  [63:0] nsdi;

  wire        nsso;
  reg         nsro;
  wire [63:0] nsdo;

  // South side (snsi => output to North)
  reg         snsi;
  wire        snri;
  reg  [63:0] sndi;

  wire        snso;
  reg         snro;
  wire [63:0] sndo;

  // Local PE side
  reg         pesi;
  wire        peri;
  reg  [63:0] pedi;
  wire        peso;
  reg         pero;
  wire [63:0] pedo;


  //------------------------------------------------------
  // Instantiate gold_router
  //------------------------------------------------------
  gold_router #(.PACKET_SIZE(64)) DUT (
    .clk      (clk),
    .reset    (reset),
    .polarity (polarity),

    // West->East (CW side)
    .cwsi     (cwsi),
    .cwri     (cwri),
    .cwdi     (cwdi),
    .cwso     (cwso),
    .cwro     (cwro),
    .cwdo     (cwdo),

    // East->West (CCW side)
    .ccwsi    (ccwsi),
    .ccwri    (ccwri),
    .ccwdi    (ccwdi),
    .ccwso    (ccwso),
    .ccwro    (ccwro),
    .ccwdo    (ccwdo),

    // North->South
    .nssi     (nssi),
    .nsri     (nsri),
    .nsdi     (nsdi),
    .nsso     (nsso),
    .nsro     (nsro),
    .nsdo     (nsdo),

    // South->North
    .snsi     (snsi),
    .snri     (snri),
    .sndi     (sndi),
    .snso     (snso),
    .snro     (snro),
    .sndo     (sndo),

    // PE side
    .pesi     (pesi),
    .peri     (peri),
    .pedi     (pedi),
    .peso     (peso),
    .pero     (pero),
    .pedo     (pedo)
  );


  //------------------------------------------------------
  // Clock
  //------------------------------------------------------
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk; 
  end

  //------------------------------------------------------
  // Reset + Polarity Toggling
  //------------------------------------------------------
  initial begin
    reset    = 1'b1;
    polarity = 1'b0;  // initial polarity
    #25;
    reset    = 1'b0;
  end

  // Toggle polarity each cycle
  always @(posedge clk) begin
    if (reset)
      polarity <= 1'b0; 
    else
      polarity <= ~polarity;
  end

  //------------------------------------------------------
  // Initialize handshake signals
  //------------------------------------------------------
  initial begin
    cwsi  = 1'b0;  cwdi  = 64'd0;  cwro  = 1'b1; 
    ccwsi = 1'b0;  ccwdi = 64'd0;  ccwro = 1'b1; 
    nssi  = 1'b0;  nsdi  = 64'd0;  nsro  = 1'b1; 
    snsi  = 1'b0;  sndi  = 64'd0;  snro  = 1'b1; 

    pesi  = 1'b0;  pedi  = 64'd0;  pero  = 1'b1; 
  end

  //------------------------------------------------------
  // Packet-building function
  //   bit 63 = VC bit (0 => v0, 1 => v1, etc.)
  //   bit 62 = horizontal direction (0=>right, 1=>left)
  //   bit 61 = vertical direction   (0=>south, 1=>north)
  //   bits [55:52] = 4-bit horizontal hop
  //   bits [51:48] = 4-bit vertical hop
  //------------------------------------------------------
  function [63:0] build_packet(
      input       vc_bit,
      input       horiz_dir,   // 0 => right, 1 => left
      input       vert_dir,    // 0 => south, 1 => north
      input [3:0] horiz_hop,
      input [3:0] vert_hop,
      input [15:0] src_id,
      input [15:0] dst_id
  );
    reg [63:0] pkt;
    begin
      pkt          = 64'b0;
      pkt[63]      = vc_bit;
      pkt[62]      = horiz_dir;
      pkt[61]      = vert_dir;
      pkt[55:52]   = horiz_hop;
      pkt[51:48]   = vert_hop;
      pkt[47:32]   = src_id;  
      pkt[31:16]   = dst_id;  
      build_packet = pkt;
    end
  endfunction


  //------------------------------------------------------
  // SEND tasks (one for each side)
  //------------------------------------------------------
  task send_from_west(input [63:0] pkt);
    begin
      $display("[%0t] WEST-SEND: 0x%h", $time, pkt);
      cwdi <= pkt;
      cwsi <= 1'b1;
      @(posedge clk);
      while (!cwri) @(posedge clk);
      @(posedge clk);
      cwsi <= 1'b0;
      cwdi <= 64'd0;
      $display("[%0t] WEST-SEND done handshake.", $time);
    end
  endtask

  task send_from_east(input [63:0] pkt);
    begin
      $display("[%0t] EAST-SEND: 0x%h", $time, pkt);
      ccwdi <= pkt;
      ccwsi <= 1'b1;
      @(posedge clk);
      while (!ccwri) @(posedge clk);
      @(posedge clk);
      ccwsi <= 1'b0;
      ccwdi <= 64'd0;
      $display("[%0t] EAST-SEND done handshake.", $time);
    end
  endtask

  task send_from_north(input [63:0] pkt);
    begin
      $display("[%0t] NORTH-SEND: 0x%h", $time, pkt);
      nsdi <= pkt;
      nssi <= 1'b1;
      @(posedge clk);
      while (!nsri) @(posedge clk);
      @(posedge clk);
      nssi <= 1'b0;
      nsdi <= 64'd0;
      $display("[%0t] NORTH-SEND done handshake.", $time);
    end
  endtask

  task send_from_south(input [63:0] pkt);
    begin
      $display("[%0t] SOUTH-SEND: 0x%h", $time, pkt);
      sndi <= pkt;
      snsi <= 1'b1;
      @(posedge clk);
      while (!snri) @(posedge clk);
      @(posedge clk);
      snsi <= 1'b0;
      sndi <= 64'd0;
      $display("[%0t] SOUTH-SEND done handshake.", $time);
    end
  endtask

  task send_from_pe(input [63:0] pkt);
    begin
      $display("[%0t] PE-SEND: 0x%h", $time, pkt);
      pedi <= pkt;
      pesi <= 1'b1;
      @(posedge clk);
      while (!peri) @(posedge clk);
      @(posedge clk);
      pesi <= 1'b0;
      pedi <= 64'd0;
      $display("[%0t] PE-SEND done handshake.", $time);
    end
  endtask


  //------------------------------------------------------
  // RECEIVE tasks (one for each output side)
  //------------------------------------------------------
  task wait_for_packet_east; // watch cwso/cwdo
    begin
      $display("[%0t] WAIT: expecting packet on EAST (cwso/cwdo).",$time);
      @(posedge clk);
      while (!cwso) @(posedge clk);
      $display("[%0t] EAST-RX got 0x%h on cwdo",$time, cwdo);
      @(posedge clk);
    end
  endtask

  task wait_for_packet_west; // watch ccwso/ccwdo
    begin
      $display("[%0t] WAIT: expecting packet on WEST (ccwso/ccwdo).",$time);
      @(posedge clk);
      while (!ccwso) @(posedge clk);
      $display("[%0t] WEST-RX got 0x%h on ccwdo",$time, ccwdo);
      @(posedge clk);
    end
  endtask

  task wait_for_packet_south; // watch nsso/nsdo
    begin
      $display("[%0t] WAIT: expecting packet on SOUTH (nsso/nsdo).",$time);
      @(posedge clk);
      while (!nsso) @(posedge clk);
      $display("[%0t] SOUTH-RX got 0x%h on nsdo",$time, nsdo);
      @(posedge clk);
    end
  endtask

  task wait_for_packet_north; // watch snso/sndo
    begin
      $display("[%0t] WAIT: expecting packet on NORTH (snso/sndo).",$time);
      @(posedge clk);
      while (!snso) @(posedge clk);
      $display("[%0t] NORTH-RX got 0x%h on sndo",$time, sndo);
      @(posedge clk);
    end
  endtask

  task wait_for_packet_pe; // watch peso/pedo
    begin
      $display("[%0t] WAIT: expecting packet on local PE (peso/pedo).",$time);
      @(posedge clk);
      while (!peso) @(posedge clk);
      $display("[%0t] PE-RX got 0x%h on pedo",$time, pedo);
      @(posedge clk);
    end
  endtask


  //------------------------------------------------------
  // Main Test Sequence
  //------------------------------------------------------
  initial begin
    // --------------------------------------------------
    // 0) Basic reset demonstration
    // --------------------------------------------------
    $display("At time %0t, we are in reset...", $time);
    @(negedge reset);
    $display("Time=%0t: Reset de-asserted. Start tests.", $time);

    repeat(2) @(posedge clk);

    //====================================================
    // TEST 1: West->East (cwi->cwo)
    //====================================================
    fork
      begin
        send_from_west(build_packet(
          1'b0,   // vc_bit=0 => v0
          1'b0,   // horizontal_dir=0 => right
          1'b0,   // vertical_dir=0 => south (ignored if horiz_hop!=0)
          4'd3,   // horizontal hops
          4'd0, 
          16'hDEAD, 
          16'hEA57  
        ));
      end
      begin
        wait_for_packet_east;
      end
    join

    //====================================================
    // TEST 2: East->West (ccw->ccwo)
    //====================================================
    fork
      begin
        send_from_east(build_packet(
          1'b0,
          1'b1, // left
          1'b0, 
          4'd3, 
          4'd0,
          16'hE000, 
          16'hBAD0  
        ));
      end
      begin
        wait_for_packet_west;
      end
    join

    //====================================================
    // TEST 3: North->South (nsi->nso)
    //====================================================
    fork
      begin
        send_from_north(build_packet(
          1'b0,
          1'b0, // horizontal_dir=0 => right? (irrelevant if horiz_hop=0)
          1'b0, // vertical_dir=0 => south
          4'd0, 
          4'd1,  // vertical hops
          16'hB000, 
          16'h5000
        ));
      end
      begin
        wait_for_packet_south;
      end
    join

    //====================================================
    // TEST 4: South->North (sni->sno)
    //====================================================
    fork
      begin
        send_from_south(build_packet(
          1'b0,
          1'b0, 
          1'b1, // 1 => north
          4'd0, 
          4'd1, 
          16'h0050, 
          16'h00B0
        ));
      end
      begin
        wait_for_packet_north;
      end
    join

    //====================================================
    // TEST 5: West->PE (cwi->peo)
    //   horizontal_hop=0, vertical_hop=0 => local route
    //====================================================
    fork
      begin
        send_from_west(build_packet(
          1'b0,
          1'b0, // right
          1'b0, // south
          4'd0, // horiz_hop=0 => local
          4'd0, // vert_hop=0 => local
          16'hFACE,
          16'hFEED
        ));
      end
      begin
        wait_for_packet_pe;  // The router outputs at pedo
      end
    join

    //====================================================
    // TEST 6: East->PE (ccw->peo)
    //====================================================
    fork
      begin
        send_from_east(build_packet(
          1'b0,
          1'b0, 
          1'b0,
          4'd0,
          4'd0,
          16'h7777,
          16'h8888
        ));
      end
      begin
        wait_for_packet_pe;
      end
    join
    
    //====================================================
    // TEST 7: West->Sno (cwi->sno)
    //   Suppose we have horizontal_hop=0, vertical_hop=1, vertical_dir=1 => north
    //====================================================

      begin
        send_from_west(build_packet(
          1'b0,
          1'b0,   // horizontal_dir=0 => right, but hop=0 => no horizontal
          1'b1,   // vertical_dir=1 => north
          4'd0, 
          4'd1,   // vertical hop
          16'hAAAA,
          16'hBBBB
        ));
      end
      begin
        wait_for_packet_north; 
      end

    //====================================================
    // TEST 8: East->Nso (ccwi->nso)
    //   horizontal_hop=0, vertical_dir=0 => south, vertical hop=2
    //====================================================

      begin
        send_from_east(build_packet(
          1'b0,
          1'b0, // left or right doesn't matter if horiz_hop=0
          1'b0, // south
          4'd0,
          4'd1,
          16'hEEEE,
          16'hDDDD
        ));
      end
      begin
        wait_for_packet_south;
      end

    //====================================================
    // TEST 9: Local PE -> cwo (pei->cwo)
    //   We'll give a horizontal_dir=0 => right, horiz_hop=2 
    //====================================================
    fork
      begin
        send_from_pe(build_packet(
          1'b0,
          1'b0, // right
          1'b0, 
          4'd1,
          4'd0,
          16'hDEAD,
          16'hBEEF
        ));
      end
      begin
        wait_for_packet_east;
      end
    join

    //====================================================
    // TEST 10: Local PE -> ccwo (pei->ccwo)
    //   horizontal_dir=1 => left
    //====================================================
    fork
      begin
        send_from_pe(build_packet(
          1'b0,
          1'b1, 
          1'b0,
          4'd1,
          4'd0,
          16'h0001,
          16'h0002
        ));
      end
      begin
        wait_for_packet_west;
      end
    join

    //====================================================
    // TEST 11: North->PE (nsi->peo)
    //   No horizontal or vertical hop => local
    //====================================================
    fork
      begin
        send_from_north(build_packet(
          1'b0,
          1'b0,
          1'b0,
          4'd0,
          4'd0,
          16'h1111,
          16'h2222
        ));
      end
      begin
        wait_for_packet_pe;
      end
    join

    //====================================================
    // TEST 12: South->PE (sni->peo)
    //====================================================
    fork
      begin
        send_from_south(build_packet(
          1'b0,
          1'b0,
          1'b0,
          4'd0,
          4'd0,
          16'h3333,
          16'h4444
        ));
      end
      begin
        wait_for_packet_pe;
      end
    join

    $display("[%0t] All tests done. End of simulation.", $time);
    #50;
    $finish;
  end

endmodule
