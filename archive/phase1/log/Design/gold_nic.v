module cardinal_nic(
    input  wire [1:0]   addr,
    input  wire [63:0]  d_in,
    output reg  [63:0]  d_out,
    input  wire         nicEn,
    input  wire         nicEnWr,
    input  wire         net_si,
    output reg          net_ri,
    input  wire [63:0]  net_di,
    output wire         net_so,
    input  wire         net_ro,
    output wire [63:0]  net_do,
    input  wire         net_polarity,
    input  wire         clk,
    input  wire         reset
);

  reg [63:0] in_buf;   // Network input channel buffer
  reg        in_full;  // Input buffer full flag (1 when a packet is latched)
  reg [63:0] out_buf;  // Network output channel buffer
  reg        out_full; // Output buffer full flag (1 when a packet is waiting to be sent)

  assign net_so = (out_full && net_ro && net_polarity) ? 1'b1 : 1'b0;
  assign net_do = (net_so) ? out_buf : 64'b0;

  always @(posedge clk) begin
    if (reset) begin
      in_buf   <= 64'b0;
      in_full  <= 1'b0;
      out_buf  <= 64'b0;
      out_full <= 1'b0;
      d_out    <= 64'b0;
    end else begin
      // Network input: latch incoming packet if net_si asserted and buffer is empty.
      if (net_si && !in_full) begin
        in_buf  <= net_di;
        in_full <= 1'b1;
      end

      // Processor memory-mapped operations (only when nicEn is asserted).
      if (nicEn) begin
        if (nicEnWr) begin
          // Write operation: legal only when writing to output buffer (addr = 2'b10).
          case (addr)
            2'b10: begin
              if (!out_full) begin
                out_buf  <= d_in;
                out_full <= 1'b1;
              end
              // If output buffer is already full, ignore the write.
            end
            default: ; // Ignore any writes to other addresses.
          endcase
        end else begin
          // Read operation: return data from the selected register.
          case (addr)
            2'b00: begin
              // Read the network input channel buffer.
              d_out <= in_buf;
              // After a successful read, assume the packet is consumed.
              if (in_full)
                in_full <= 1'b0;
            end
            2'b01: begin
              // Read the network input status register.
              d_out <= {63'd0, in_full};
            end
            2'b10: begin
              // Reading the write-only output buffer returns 0.
              d_out <= 64'd0;
            end
            2'b11: begin
              // Read the network output status register.
              d_out <= {63'd0, out_full};
            end
            default: d_out <= 64'd0;
          endcase
        end
      end else begin
        // If NIC is not enabled, drive processor output to 0.
        d_out <= 64'd0;
      end

      // Output channel: if a packet is waiting and the router signals readiness with correct polarity,
      // send the packet and then clear the output buffer.
      if (out_full && net_ro && net_polarity) begin
        out_full <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (reset)
      net_ri <= 1'b1;
    else
      net_ri <= ~in_full;
  end

endmodule
