module arbiter
#(
    parameter NUM_REQ   = 4,    // Supported: 2 or 4
    parameter INIT_PRIO = 0     // Initial highest-priority channel
)
(
    input  clk,
    input  reset,
    input  polarity,

    // Up to 4 request lines
    input  req_0, 
    input  req_1, 
    input  req_2, 
    input  req_3,

    // 4 grant outputs (in 2-req mode, we only drive gnt_0/gnt_1)
    output reg gnt_0, 
    output reg gnt_1, 
    output reg gnt_2, 
    output reg gnt_3,

    // 2-bit debug outputs (always 2 bits, but in 2-req mode we only store 1 real bit)
    output [1:0] debug_last_gnt_v0,
    output [1:0] debug_last_gnt_v1
);

    reg [1:0] dbg_lgv0;   // "debug" for last_gnt_v0 domain
    reg [1:0] dbg_lgv1;   // "debug" for last_gnt_v1 domain

    // Make them available as outputs
    assign debug_last_gnt_v0 = dbg_lgv0;
    assign debug_last_gnt_v1 = dbg_lgv1;


    // ------------------------------------------------------------------------
    // 2) Generate block to handle either 2-request or 4-request scenario
    // ------------------------------------------------------------------------
    generate
    if (NUM_REQ == 2) begin : TWO_REQUEST_ARBITER
        // For 2 requests, we only have 1 bit for each domain
        reg last_gnt_v0, last_gnt_v1;
        reg current_last_gnt; // used combinationally

        // We'll sum up the 2 requests
        wire [1:0] req_sum_2 = (req_0 ? 1 : 0) + (req_1 ? 1 : 0);

        reg [1:0] req_prio;  // rotated requests
        reg [1:0] gnt_prio;  // rotated grants

        // ---------------- Combinational priority logic ----------------
        always @(*) begin
            // Decide which last_gnt we use this cycle
            current_last_gnt = (polarity) ? last_gnt_v1 : last_gnt_v0;

            // Rotate the requests
            case (current_last_gnt)
              1'b0: req_prio = {req_0, req_1}; 
              1'b1: req_prio = {req_1, req_0}; 
            endcase

            // Priority-encode in rotated space (MSB has highest priority)
            if (req_prio[1]) 
                gnt_prio = 2'b10;
            else if (req_prio[0]) 
                gnt_prio = 2'b01;
            else 
                gnt_prio = 2'b00;

            // Un-rotate the grant
            case (current_last_gnt)
              1'b0: {gnt_0, gnt_1} = gnt_prio;
              1'b1: {gnt_1, gnt_0} = gnt_prio;
            endcase

            // In 2-req mode, gnt_2/gnt_3 are always zero
            gnt_2 = 1'b0;
            gnt_3 = 1'b0;
        end

        // ---------------- Sequential update for last_gnt ----------------
        always @(posedge clk) begin
            if (reset) begin
                last_gnt_v0 <= INIT_PRIO[0];  // Use the LSB of INIT_PRIO
                last_gnt_v1 <= INIT_PRIO[0];
            end
            else begin
                // Re-init if no requests
                if (req_sum_2 == 0) begin
                    if (polarity)
                        last_gnt_v1 <= INIT_PRIO[0];
                    else
                        last_gnt_v0 <= INIT_PRIO[0];
                end
                else begin
                    // If channel0 is granted => last_gnt=0
                    // If channel1 is granted => last_gnt=1
                    if (gnt_0) begin
                        if (polarity)
                            last_gnt_v1 <= 1'b0;
                        else
                            last_gnt_v0 <= 1'b0;
                    end
                    else if (gnt_1) begin
                        if (polarity)
                            last_gnt_v1 <= 1'b1;
                        else
                            last_gnt_v0 <= 1'b1;
                    end
                end
            end
        end

        // ---------------- Debug: map local 1-bit regs to 2-bit debug outputs ----------------
        always @(*) begin
            // We only have 1 bit in last_gnt_v0, so place it in the LSB of dbg_lgv0
            dbg_lgv0 = {1'b0, last_gnt_v0}; 
            dbg_lgv1 = {1'b0, last_gnt_v1};
        end

    end else if (NUM_REQ == 4) begin : FOUR_REQUEST_ARBITER

        // For 4 requests, we keep 2 bits for each domain
        reg [1:0] last_gnt_v0, last_gnt_v1;
        reg [1:0] current_last_gnt;

        // We sum up the 4 requests
        wire [2:0] req_sum_4 = (req_0?1:0) + (req_1?1:0) + (req_2?1:0) + (req_3?1:0);

        reg [3:0] req_prio;
        reg [3:0] gnt_prio_rotated;

        // ---------------- Combinational logic ----------------
        always @(*) begin
            current_last_gnt = (polarity) ? last_gnt_v1 : last_gnt_v0;

            // Rotate request bits
            case (current_last_gnt)
              2'd0: req_prio = {req_0, req_1, req_2, req_3};
              2'd1: req_prio = {req_1, req_2, req_3, req_0};
              2'd2: req_prio = {req_2, req_3, req_0, req_1};
              2'd3: req_prio = {req_3, req_0, req_1, req_2};
              default: req_prio = {req_0, req_1, req_2, req_3};
            endcase

            // Priority-encode MSB->LSB
            if (req_prio[3])         
                gnt_prio_rotated = 4'b1000;
            else if (req_prio[2])    
                gnt_prio_rotated = 4'b0100;
            else if (req_prio[1])    
                gnt_prio_rotated = 4'b0010;
            else if (req_prio[0])    
                gnt_prio_rotated = 4'b0001;
            else
                gnt_prio_rotated = 4'b0000;

            // Un-rotate the grant
            case (current_last_gnt)
              2'd0: {gnt_0, gnt_1, gnt_2, gnt_3} = gnt_prio_rotated;
              2'd1: {gnt_1, gnt_2, gnt_3, gnt_0} = gnt_prio_rotated;
              2'd2: {gnt_2, gnt_3, gnt_0, gnt_1} = gnt_prio_rotated;
              2'd3: {gnt_3, gnt_0, gnt_1, gnt_2} = gnt_prio_rotated;
              default: {gnt_0, gnt_1, gnt_2, gnt_3} = gnt_prio_rotated;
            endcase
        end

        // ---------------- last_gnt update ----------------
        always @(posedge clk) begin
            if (reset) begin
                last_gnt_v0 <= INIT_PRIO[1:0];
                last_gnt_v1 <= INIT_PRIO[1:0];
            end
            else begin
                if (req_sum_4 == 0) begin
                    // no requests => reinit
                    if (polarity)
                        last_gnt_v1 <= INIT_PRIO[1:0];
                    else
                        last_gnt_v0 <= INIT_PRIO[1:0];
                end
                else begin
                    if (gnt_0) begin
                        if (polarity) last_gnt_v1 <= 2'd0;
                        else          last_gnt_v0 <= 2'd0;
                    end
                    else if (gnt_1) begin
                        if (polarity) last_gnt_v1 <= 2'd1;
                        else          last_gnt_v0 <= 2'd1;
                    end
                    else if (gnt_2) begin
                        if (polarity) last_gnt_v1 <= 2'd2;
                        else          last_gnt_v0 <= 2'd2;
                    end
                    else if (gnt_3) begin
                        if (polarity) last_gnt_v1 <= 2'd3;
                        else          last_gnt_v0 <= 2'd3;
                    end
                end
            end
        end

        // ---------------- Debug signals ----------------
        always @(*) begin
            dbg_lgv0 = last_gnt_v0;  // direct 2 bits
            dbg_lgv1 = last_gnt_v1;
        end

    end else begin : UNSUPPORTED_NUM
        // For a case where NUM_REQ != 2 and != 4
        initial begin
            $error("arbiter: This design only supports NUM_REQ=2 or 4 (got %0d).", NUM_REQ);
        end
        always @(*) begin
            gnt_0 = 1'b0; 
            gnt_1 = 1'b0; 
            gnt_2 = 1'b0; 
            gnt_3 = 1'b0;
        end
        // debug signals => 0
        always @(*) begin
            dbg_lgv0 = 2'b00;
            dbg_lgv1 = 2'b00;
        end
    end
    endgenerate

endmodule
