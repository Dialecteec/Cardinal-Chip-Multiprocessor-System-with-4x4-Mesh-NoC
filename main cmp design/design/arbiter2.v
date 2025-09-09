module arbiter2
(
    input  wire       clk,
    input  wire       reset,
    input  wire       polarity,

    // 2 request lines
    input  wire       req_0,
    input  wire       req_1,

    // 2 grant outputs
    output reg        gnt_0,
    output reg        gnt_1
);

    // internal last‑grant state
    reg        last_gnt_v0;
    reg        last_gnt_v1;
    reg        current_last_gnt;

    // debug latches
    reg [1:0]  dbg_lgv0;
    reg [1:0]  dbg_lgv1;

    // sum of requests (2‑bit)
    wire [1:0] req_sum = (req_0 ? 2'd1 : 2'd0)
                       + (req_1 ? 2'd1 : 2'd0);

    // combinational arbitration
    always @(*) begin
        current_last_gnt = polarity ? last_gnt_v1 : last_gnt_v0;

        // rotate request vector
        case (current_last_gnt)
          1'b0: { gnt_0, gnt_1 } = { req_0, req_1 };
          1'b1: { gnt_0, gnt_1 } = { req_1, req_0 };
        endcase

        // encode highest‑priority asserted bit
        if      (gnt_0) { gnt_0, gnt_1 } = 2'b10;
        else if (gnt_1) { gnt_0, gnt_1 } = 2'b01;
        else            { gnt_0, gnt_1 } = 2'b00;
    end

    // sequential update of last granted channel
    always @(posedge clk) begin
        if (reset) begin
            last_gnt_v0 <= 1'b0;
            last_gnt_v1 <= 1'b0;
        end else begin
            if (req_sum == 2'd0) begin
                // no requests → reset to 1'b0
                if (polarity) last_gnt_v1 <= 1'b0;
                else          last_gnt_v0 <= 1'b0;
            end else begin
                // update based on which grant fired
                if (gnt_0) begin
                    if (polarity) last_gnt_v1 <= 1'b0;
                    else          last_gnt_v0 <= 1'b0;
                end else if (gnt_1) begin
                    if (polarity) last_gnt_v1 <= 1'b1;
                    else          last_gnt_v0 <= 1'b1;
                end
            end
        end
    end
endmodule
