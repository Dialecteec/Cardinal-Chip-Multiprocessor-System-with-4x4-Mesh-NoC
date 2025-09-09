`timescale 1ns/1ns

module tb_cardinal_nic;
  reg  [1:0]   addr;
  reg  [63:0]  d_in;
  wire [63:0]  d_out;
  reg          nicEn;
  reg          nicEnWr;
  reg          net_si;
  wire         net_ri;
  reg  [63:0]  net_di;
  wire         net_so;
  reg          net_ro;
  wire [63:0]  net_do;
  reg          net_polarity;
  reg          clk;
  reg          reset;

  cardinal_nic dut (
    .addr(addr),
    .d_in(d_in),
    .d_out(d_out),
    .nicEn(nicEn),
    .nicEnWr(nicEnWr),
    .net_si(net_si),
    .net_ri(net_ri),
    .net_di(net_di),
    .net_so(net_so),
    .net_ro(net_ro),
    .net_do(net_do),
    .net_polarity(net_polarity),
    .clk(clk),
    .reset(reset)
  );

  initial begin
    clk = 0;
    forever #2 clk = ~clk;
  end

  initial begin
    reset        = 1;
    nicEn        = 0;
    nicEnWr      = 0;
    addr         = 2'b00;
    d_in         = 64'd0;
    net_si       = 0;
    net_di       = 64'd0;
    net_ro       = 0;
    net_polarity = 0;

    // --- Test 1: Reset Operation ---
    // Hold reset for a few cycles.
    #10;
    reset = 0;
    nicEn = 1;
    $display("Reset deasserted at time %0t", $time);
    #4;
    $display("After reset: net_ri = %b (expected 1)", net_ri);

    // --- Test 2: NIC-Router Handshake (Non-blocking) ---
    // Scenario: Processor writes a packet to the output buffer, and router is immediately ready.
    // Expectation: NIC sends packet immediately.
    $display("\n--- NIC-Router Handshake: Non-blocking ---");
    // Ensure output buffer is empty.
    nicEnWr = 0;
    addr    = 2'b11;  // Read output status.
    #4;
    $display("Initial output status = %h (expected 0)", d_out);

    // Write a packet to output buffer.
    nicEnWr = 1;
    addr    = 2'b10;  // Write to output buffer.
    d_in    = 64'hDEADBEEFDEADBEEF;
    #4;
    nicEnWr = 0;
    $display("After store: Output status (should be 1) read from addr 11:");
    addr = 2'b11;
    #4;
    $display("Output status = %h", d_out);

    // Set router ready signals so NIC can send.
    net_ro = 1;
    net_polarity = 1;
    #4; // Allow one cycle for transmission.
    $display("During handshake: net_so = %b, net_do = %h (expected net_so=1 and data=DEADBEEFDEADBEEF)", 
              net_so, net_do);
    // Check output status has cleared.
    addr = 2'b11;
    #4;
    $display("Output status after send = %h (expected 0)", d_out);

    // --- Test 3: NIC-Router Handshake (Blocking) ---
    // Scenario: Processor writes a packet, but router is not ready initially.
    // Expectation: NIC holds packet until router becomes ready.
    $display("\n--- NIC-Router Handshake: Blocking ---");
    // Write a packet to output buffer.
    nicEnWr = 1;
    addr    = 2'b10;  
    d_in    = 64'hCAFEBABECAFEBABE;
    #4;
    nicEnWr = 0;
    // Initially, set router not ready.
    net_ro = 0;
    net_polarity = 1;  // Polarity correct but ro is low.
    #8;
    // Verify that net_so is not asserted.
    $display("While blocking: net_so = %b (expected 0)", net_so);
    // Now, set router ready.
    net_ro = 1;
    #4;
    $display("After unblocking: net_so = %b, net_do = %h (expected net_so=1 and data=CAFEBABECAFEBABE)",
              net_so, net_do);
    // Check output status cleared.
    addr = 2'b11;
    #4;
    $display("Output status after unblocking send = %h (expected 0)", d_out);

    // --- Test 4: Processor Load Operations ---
    // Case 1: Load operation when input buffer is available.
    $display("\n--- Processor Load: Buffer Available ---");
    // Simulate router sending a packet.
    net_di = 64'hA5A5A5A5A5A5A5A5;
    net_si = 1;
    #4;
    net_si = 0;
    // Read input status (should be 1).
    addr = 2'b01;  
    #4;
    $display("Input status = %h (expected 1)", d_out);
    // Read input buffer (should return packet and clear flag).
    addr = 2'b00;
    #4;
    $display("Input buffer data = %h (expected A5A5A5A5A5A5A5A5)", d_out);
    // Verify status now cleared.
    addr = 2'b01;
    #4;
    $display("Input status after read = %h (expected 0)", d_out);

    // Case 2: Load operation when input buffer is NOT available.
    $display("\n--- Processor Load: Buffer Unavailable ---");
    // Without any new packet, read input status.
    addr = 2'b01;
    #4;
    $display("Input status = %h (expected 0)", d_out);
    // Read input buffer (should return previous value or 0, design-dependent).
    addr = 2'b00;
    #4;
    $display("Input buffer data = %h (undefined, as no new packet arrived)", d_out);

    // --- Test 5: Processor Store Operations ---
    // Case 3: Store operation when output buffer is available.
    $display("\n--- Processor Store: Buffer Available ---");
    // Ensure output buffer is empty.
    addr = 2'b11;
    #4;
    $display("Output status before store = %h (expected 0)", d_out);
    // Write a packet.
    nicEnWr = 1;
    addr    = 2'b10;
    d_in    = 64'h0123456789ABCDEF;
    #4;
    nicEnWr = 0;
    addr = 2'b11;
    #4;
    $display("Output status after store = %h (expected 1)", d_out);

    // Case 4: Store operation when output buffer is NOT available.
    $display("\n--- Processor Store: Buffer Unavailable ---");
    // Attempt to write while output buffer is still full.
    // Since the previous packet hasn't been sent yet, this store should be ignored.
    nicEnWr = 1;
    addr    = 2'b10;
    d_in    = 64'hFFFFFFFFFFFFFFFF;
    #4;
    nicEnWr = 0;
    // Read output buffer status.
    addr = 2'b11;
    #4;
    $display("Output status after attempted store to full buffer = %h (expected still 1)", d_out);

    #20;
    $finish;
  end

endmodule
