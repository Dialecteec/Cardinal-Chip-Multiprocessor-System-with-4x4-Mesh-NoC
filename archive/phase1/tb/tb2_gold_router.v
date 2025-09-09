`timescale 1ns/1ps

module tb2_gold_router;

  //------------------------------------------------------
  // Testbench signals
  //------------------------------------------------------
  reg        clk;
  reg        reset;

  // We let each router toggle polarity internally if you wish,
  // but for demonstration we also pass an external 'polarity' from TB.
  // If your gold_router internally toggles it, remove or rename it accordingly.
  reg        polarity; 

  //------------------------------------------------------
  // Two routers: router0 on the left, router1 on the right
  // We'll connect router0’s cwo-> router1’s ccwi, etc.
  //------------------------------------------------------

  // ================ Router0 signals ================
  // West side of router0 is testbench-driven
  reg         r0_cwsi;  
  wire        r0_cwri;  
  reg  [63:0] r0_cwdi;  
  wire        r0_cwso;  
  wire [63:0] r0_cwdo;  
  wire        r0_cwro;  // connected from router1

  // East side of router0 is connected to router1's ccw side
  reg         r0_ccwsi;
  wire        r0_ccwri;
  reg  [63:0] r0_ccwdi;
  wire        r0_ccwso;
  wire [63:0] r0_ccwdo;
  wire        r0_ccwro;

  // For brevity, tie off the north/south ports of router0 in this example.
  reg         r0_nssi=0, r0_snsi=0, r0_pesi=0;
  wire        r0_nsri, r0_snri, r0_peri;
  reg  [63:0] r0_nsdi=0, r0_sndi=0, r0_pedi=0;
  wire        r0_nsso, r0_snso, r0_peso;
  wire [63:0] r0_nsdo, r0_sndo, r0_pedo;
  wire        r0_nsro=1, r0_snro=1, r0_pero=1;

  // ================ Router1 signals ================
  // This router's West side is connected to router0's cwo/cwdo
  wire        r1_cwsi;
  wire [63:0] r1_cwdi;
  wire        r1_cwri;
  wire        r1_cwso;
  wire [63:0] r1_cwdo;
  wire        r1_cwro;

  // The East side we tie off in this test, or we can watch if you want a ring.
  reg         r1_ccwsi=0;
  wire        r1_ccwri;
  reg  [63:0] r1_ccwdi=0;
  wire        r1_ccwso;
  wire [63:0] r1_ccwdo;
  wire        r1_ccwro=1;  // let's keep it always ready in this example

  // Tie off router1's north/south/PE as well, or do minimal signals:
  reg         r1_nssi=0, r1_snsi=0, r1_pesi=0;
  wire        r1_nsri, r1_snri, r1_peri;
  reg  [63:0] r1_nsdi=0, r1_sndi=0, r1_pedi=0;
  wire        r1_nsso, r1_snso, r1_peso;
  wire [63:0] r1_nsdo, r1_sndo, r1_pedo;
  wire        r1_nsro=1, r1_snro=1, r1_pero=1;


  //------------------------------------------------------
  // Connect the two routers
  // Router0 => Router1: cwo->ccwi
  //------------------------------------------------------
  assign r1_cwsi = r0_cwso;  // router0's cwo is input to router1's cw
  assign r1_cwdi = r0_cwdo;
  assign r0_cwro = r1_cwro;  // handshake back

  // We do not form a ring for the ccw side:
  //   if you want a ring, you’d connect r1_ccwso => r0_ccwsi, etc.
  // Instead, we keep router0_ccw side test-driven for conflict scenarios.
  // So tie router1_cwso => unused, or watch if you like.

  //------------------------------------------------------
  // Instantiate router0
  //------------------------------------------------------
  gold_router #(.PACKET_SIZE(64)) router0 (
    .clk      (clk),
    .reset    (reset),
    .polarity (polarity),

    // West->East (CW side)
    .cwsi     (r0_cwsi),
    .cwri     (r0_cwri),
    .cwdi     (r0_cwdi),
    .cwso     (r0_cwso),
    .cwro     (r0_cwro),
    .cwdo     (r0_cwdo),

    // East->West (CCW side)
    .ccwsi    (r0_ccwsi),
    .ccwri    (r0_ccwri),
    .ccwdi    (r0_ccwdi),
    .ccwso    (r0_ccwso),
    .ccwro    (r0_ccwro),
    .ccwdo    (r0_ccwdo),

    // north->south
    .nssi     (r0_nssi),
    .nsri     (r0_nsri),
    .nsdi     (r0_nsdi),
    .nsso     (r0_nsso),
    .nsro     (r0_nsro),
    .nsdo     (r0_nsdo),

    // south->north
    .snsi     (r0_snsi),
    .snri     (r0_snri),
    .sndi     (r0_sndi),
    .snso     (r0_snso),
    .snro     (r0_snro),
    .sndo     (r0_sndo),

    // local PE
    .pesi     (r0_pesi),
    .peri     (r0_peri),
    .pedi     (r0_pedi),
    .peso     (r0_peso),
    .pero     (r0_pero),
    .pedo     (r0_pedo)
  );

  //------------------------------------------------------
  // Instantiate router1
  //------------------------------------------------------
  gold_router #(.PACKET_SIZE(64)) router1 (
    .clk      (clk),
    .reset    (reset),
    .polarity (polarity),

    // cw side
    .cwsi     (r1_cwsi),
    .cwri     (r1_cwri),
    .cwdi     (r1_cwdi),
    .cwso     (r1_cwso),
    .cwro     (r1_cwro),
    .cwdo     (r1_cwdo),

    // ccw side
    .ccwsi    (r1_ccwsi),
    .ccwri    (r1_ccwri),
    .ccwdi    (r1_ccwdi),
    .ccwso    (r1_ccwso),
    .ccwro    (r1_ccwro),
    .ccwdo    (r1_ccwdo),

    // north->south
    .nssi     (r1_nssi),
    .nsri     (r1_nsri),
    .nsdi     (r1_nsdi),
    .nsso     (r1_nsso),
    .nsro     (r1_nsro),
    .nsdo     (r1_nsdo),

    // south->north
    .snsi     (r1_snsi),
    .snri     (r1_snri),
    .sndi     (r1_sndi),
    .snso     (r1_snso),
    .snro     (r1_snro),
    .sndo     (r1_sndo),

    // local PE
    .pesi     (r1_pesi),
    .peri     (r1_peri),
    .pedi     (r1_pedi),
    .peso     (r1_peso),
    .pero     (r1_pero),
    .pedo     (r1_pedo)
  );


  //------------------------------------------------------
  // Clock generator
  //------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  //------------------------------------------------------
  // Reset & Polarity
  //------------------------------------------------------
  initial begin
    reset    = 1'b1;
    polarity = 1'b0;
    #25;
    reset    = 1'b0;
  end

  // Let’s toggle polarity each rising edge or each cycle:
  always @(posedge clk) begin
    if (!reset) begin
      polarity <= ~polarity;
    end
  end


  //------------------------------------------------------
  // Arbiter Debug: show priority changes
  // If your arbiter is named e.g. 'arb_cwo' inside the router,
  // you can reference it if the simulator supports hierarchical names.
  // For instance:
  //------------------------------------------------------
  initial begin
    // wait for reset de-assert
    @(negedge reset);
    #1;
    $display("=== Starting to monitor arbiter internal signals ===");
  end

  // Example: If we know inside router0 we have an instance:
  //   arbiter arb_cwo( ... )
  // we can do a hierarchical reference:
  // This requires that arbiter is not declared "generate" or "localparam" name
  // If your simulator allows it, you can do:
  always @(posedge clk) begin
    if (!reset) begin
      // For instance, show the cwo arbiter in router0
      $display("[router0.arb_cwo] pol=%b req_0=%b req_1=%b => gnt_0=%b gnt_1=%b debug_last_gnt_v0=%0d debug_last_gnt_v1=%0d",
        polarity,
        router0.arb_cwo.req_0,
        router0.arb_cwo.req_1,
        router0.arb_cwo.gnt_0,
        router0.arb_cwo.gnt_1,
        router0.arb_cwo.debug_last_gnt_v0,
        router0.arb_cwo.debug_last_gnt_v1
      );
    end
  end


  //------------------------------------------------------
  // Simple tasks to drive cwi side of router0
  //------------------------------------------------------
  task send_packet_r0cw(input [63:0] pkt);
    begin
      $display("[%0t] TB: R0-West-SEND => 0x%h", $time, pkt);
      r0_cwdi <= pkt;
      r0_cwsi <= 1'b1;
      @(posedge clk);
      while (!r0_cwri) @(posedge clk);
      @(posedge clk);
      r0_cwsi <= 1'b0;
      r0_cwdi <= 64'd0;
      $display("[%0t] TB: R0-West-SEND done handshake", $time);
    end
  endtask

  // Similarly for r0_ccw
  task send_packet_r0ccw(input [63:0] pkt);
    begin
      $display("[%0t] TB: R0-East-SEND => 0x%h", $time, pkt);
      r0_ccwdi <= pkt;
      r0_ccwsi <= 1'b1;
      @(posedge clk);
      while (!r0_ccwri) @(posedge clk);
      @(posedge clk);
      r0_ccwsi <= 1'b0;
      r0_ccwdi <= 64'd0;
      $display("[%0t] TB: R0-East-SEND done handshake", $time);
    end
  endtask

  //------------------------------------------------------
  // We'll watch the outputs from router1's cw side
  // If router1 tries to send out cwso => we see it in wave
  // For demonstration, we can do a short wait_for_router1cw
  //------------------------------------------------------
  task wait_for_r1_cw_output;
    begin
      $display("[%0t] WAIT: expecting router1 cwo => cwso/cwdo", $time);
      @(posedge clk);
      while (!r1_cwso) @(posedge clk);
      $display("[%0t] R1-cwo sees data=0x%h", $time, r1_cwdo);
      @(posedge clk);
    end
  endtask


  //------------------------------------------------------
  // Additional function to build 64-bit packets
  //------------------------------------------------------
  function [63:0] build_packet(
    input  vc_bit,
    input  horiz_dir, // bit62
    input  vert_dir,  // bit61
    input [3:0] horiz_hop,
    input [3:0] vert_hop,
    input [15:0] src_id,
    input [15:0] dst_id
  );
    reg [63:0] pkt;
    begin
      pkt             = 64'b0;
      pkt[63]         = vc_bit;
      pkt[62]         = horiz_dir;
      pkt[61]         = vert_dir;
      pkt[55:52]      = horiz_hop;
      pkt[51:48]      = vert_hop;
      pkt[47:32]      = src_id;
      pkt[31:16]      = dst_id;
      build_packet    = pkt;
    end
  endfunction

  //------------------------------------------------------
  // Main Test
  //------------------------------------------------------
  initial begin
    // Wait for reset
    @(negedge reset);
    $display("Time=%0t: Reset de-asserted. Start the multi-router tests.", $time);

    // Let system run a couple cycles
    repeat(2) @(posedge clk);

    //====================================================
    // TEST 1: Simple pass from router0->router1, no blocking
    // We'll do cwi->cwo in router0 => that goes to router1's cw side
    // Then router1 might do something or we just watch wave
    //====================================================
    $display("\n=== TEST1: No blocking. Router0 cwi->cwo => router1 cw side. ===");
    send_packet_r0cw( build_packet(
        1'b0,   // vc=0
        1'b0,   // horiz_dir=0 => right
        1'b0,   // vert_dir=0 => south
        4'd2,   // horiz_hop
        4'd0,
        16'h0001,
        16'h0002
    ));
    // Wait a bit
    repeat(5) @(posedge clk);

    //====================================================
    // TEST 2: Blocking scenario.
    // We'll forcibly hold r1_cwro=0 (router1 not ready) for a few cycles
    // while router0 tries to send. That should cause router0 to stall.
    // Then we re-assert r1_cwro=1 => the handshake completes
    //====================================================
    $display("\n=== TEST2: BLOCKING scenario. Router1 not ready => router0 stalls. ===");

    // Force router1 cw side "not ready"
    force router1.cwro = 1'b0;

    fork
      begin
        send_packet_r0cw( build_packet(
          1'b0,
          1'b0, 
          1'b0,
          4'd2,
          4'd0,
          16'hAAAA,
          16'hBBBB
        ));
        // The above will stall until we release cwro
      end
      begin
        // Wait ~6 cycles, then un-force
        @(posedge clk); @(posedge clk);
        @(posedge clk); @(posedge clk);
        @(posedge clk); @(posedge clk);
        release router1.cwro; // now router1 is ready
      end
    join
    repeat(5) @(posedge clk);

    //====================================================
    // TEST 3: Conflict scenario
    // We want two packets *simultaneously* from r0_cw & r0_ccw
    // both wanting to go to the same output (for example cwo).
    // This triggers the arbiter for cwo in router0.
    // We'll see who gets granted first, watch priority change.
    //====================================================
    $display("\n=== TEST3: Conflict scenario => two packets for same output cwo. ===");
    fork
      begin
        // West side: send a packet that wants to go cwo
        send_packet_r0cw( build_packet(
          1'b0,
          1'b0, // right => cwo
          1'b0,
          4'd3,
          4'd0,
          16'hF1F1,
          16'hF2F2
        ));
      end
      begin
        // East side: simultaneously, send a packet that also wants cwo
        // We do that by setting do_ccwi_v0's direction bits => 0 => right
        send_packet_r0ccw( build_packet(
          1'b0,
          1'b0, // also right => cwo
          1'b0,
          4'd3,
          4'd0,
          16'hF3F3,
          16'hF4F4
        ));
      end
    join
    $display("We expect the arbiter for cwo in router0 to pick one first, update priority, then the second one after the first is accepted.");

    $display("\nAll testcases completed. Simulation will now end.\n");
    #10;
    $finish;
  end

endmodule
