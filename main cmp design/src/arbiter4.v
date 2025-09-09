module arbiter4
(
    input  wire        clk,
    input  wire        reset,
    input  wire        polarity,

    // 4 request lines
    input  wire        req_0,
    input  wire        req_1,
    input  wire        req_2,
    input  wire        req_3,

    // 4 grant outputs
    output reg         gnt_0,
    output reg         gnt_1,
    output reg         gnt_2,
    output reg         gnt_3
);

    // Internal state
    reg  [1:0] last_gnt_v0, last_gnt_v1;
    reg  [1:0] current_last_gnt;

    // Rotation & priority encoding
    reg  [3:0] req_prio;
    reg  [3:0] gnt_prio_rotated;

    // Debug latches
    reg  [1:0] dbg_lgv0, dbg_lgv1;

    // Count active requests (3‑bit)
    wire [2:0] req_sum_4 =
        (req_0 ? 3'd1 : 3'd0) +
        (req_1 ? 3'd1 : 3'd0) +
        (req_2 ? 3'd1 : 3'd0) +
        (req_3 ? 3'd1 : 3'd0);

    // ------------------------------------------------------------------------
    // Combinational rotation + priority logic
    // ------------------------------------------------------------------------
    always @(*) begin
        // pick which last_gnt to use
        current_last_gnt = polarity ? last_gnt_v1 : last_gnt_v0;

        // rotate request vector left by current_last_gnt
        case (current_last_gnt) /* synthesis full_case parallel_case */
          2'd0: req_prio = {req_0, req_1, req_2, req_3};
          2'd1: req_prio = {req_1, req_2, req_3, req_0};
          2'd2: req_prio = {req_2, req_3, req_0, req_1};
          2'd3: req_prio = {req_3, req_0, req_1, req_2};
        endcase

        // highest‑bit priority encode (MSB highest)
             if (req_prio[3]) gnt_prio_rotated = 4'b1000;
        else if (req_prio[2]) gnt_prio_rotated = 4'b0100;
        else if (req_prio[1]) gnt_prio_rotated = 4'b0010;
        else if (req_prio[0]) gnt_prio_rotated = 4'b0001;
        else                  gnt_prio_rotated = 4'b0000;

        // un‑rotate grants back to original ordering
        case (current_last_gnt) /* synthesis full_case parallel_case */
          2'd0: {gnt_0, gnt_1, gnt_2, gnt_3} = gnt_prio_rotated;
          2'd1: {gnt_1, gnt_2, gnt_3, gnt_0} = gnt_prio_rotated;
          2'd2: {gnt_2, gnt_3, gnt_0, gnt_1} = gnt_prio_rotated;
          2'd3: {gnt_3, gnt_0, gnt_1, gnt_2} = gnt_prio_rotated;
        endcase
    end

    // ------------------------------------------------------------------------
    // Sequential update of last_gnt
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            last_gnt_v0 <= 2'd0;
            last_gnt_v1 <= 2'd0;
        end else begin
            if (req_sum_4 == 3'd0) begin
                // no requests → reinit
                if (polarity) last_gnt_v1 <= 2'd0;
                else          last_gnt_v0 <= 2'd0;
            end else begin
                // record which channel actually got granted
                if (gnt_0) begin
                    if (polarity) last_gnt_v1 <= 2'd0;
                    else          last_gnt_v0 <= 2'd0;
                end else if (gnt_1) begin
                    if (polarity) last_gnt_v1 <= 2'd1;
                    else          last_gnt_v0 <= 2'd1;
                end else if (gnt_2) begin
                    if (polarity) last_gnt_v1 <= 2'd2;
                    else          last_gnt_v0 <= 2'd2;
                end else if (gnt_3) begin
                    if (polarity) last_gnt_v1 <= 2'd3;
                    else          last_gnt_v0 <= 2'd3;
                end
            end
        end
    end
endmodule
