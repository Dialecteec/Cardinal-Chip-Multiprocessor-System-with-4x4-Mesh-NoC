`define REGFILE_DEPTH 32
`define REGFILE_WIDTH 64
`define REGFILE_AWIDTH 5

module register_file (
    clk, reset, // sync active high reset
    write_enb, di, sel, addr_wr, // write port
    do_0, addr_rd_0, // read port 0
    do_1, addr_rd_1 // read port 1
);

// I/O declarations
    input  clk, reset; 
    input  write_enb;                     // write enable
    input  [0:2] sel;                    // 3-bit partial-write select signal
    input  [0:`REGFILE_WIDTH - 1] di;    // write data input
    input  [0:`REGFILE_AWIDTH - 1] addr_wr; // write address

    input  [0:`REGFILE_AWIDTH - 1] addr_rd_0, addr_rd_1; // read addresses
    output reg [0:`REGFILE_WIDTH - 1] do_0, do_1; // read data outputs

    // Partial-write modes
    localparam ALL_MODE   = 3'b000,
               UPP_MODE   = 3'b001,
               LOW_MODE   = 3'b010,
               EVEN_BYTES = 3'b011,
               ODD_BYTES  = 3'b100;

    // Main storage
    reg [0:`REGFILE_WIDTH - 1] rf_mem[`REGFILE_DEPTH - 1:1];


// READ + FORWARDING LOGIC
    always @(*) begin
        // ------------------ Read Port 0 ------------------
        if (addr_rd_0 == 0) begin
            // $0 always reads as zero
            do_0 = {`REGFILE_WIDTH{1'b0}};
        end 
        else begin
            // normal read
            do_0 = rf_mem[addr_rd_0];

            // internal forwarding if addresses match and a write is happening
            if ((write_enb == 1'b1) && (addr_wr == addr_rd_0)) begin
                case (sel)
                    ALL_MODE:   do_0 = di;
                    UPP_MODE:   do_0[0:31]  = di[0:31];
                    LOW_MODE:   do_0[32:63] = di[32:63];
                    EVEN_BYTES: begin
                        do_0[0    +: 8]  = di[0    +: 8];
                        do_0[16   +: 8]  = di[16   +: 8];
                        do_0[32   +: 8]  = di[32   +: 8];
                        do_0[48   +: 8]  = di[48   +: 8];
                    end
                    ODD_BYTES:  begin
                        do_0[8    +: 8]  = di[8    +: 8];
                        do_0[24   +: 8]  = di[24   +: 8];
                        do_0[40   +: 8]  = di[40   +: 8];
                        do_0[56   +: 8]  = di[56   +: 8];
                    end
                endcase
            end
        end

        // Read Port 1
        if (addr_rd_1 == 0) begin
            // $0 always reads as zero
            do_1 = {`REGFILE_WIDTH{1'b0}};
        end
        else begin
            // normal read
            do_1 = rf_mem[addr_rd_1];

            // internal forwarding if addresses match and a write is happening
            if ((write_enb == 1'b1) && (addr_wr == addr_rd_1)) begin
                case (sel)
                    ALL_MODE:   do_1 = di;
                    UPP_MODE:   do_1[0:31]  = di[0:31];
                    LOW_MODE:   do_1[32:63] = di[32:63];
                    EVEN_BYTES: begin
                        do_1[0    +: 8]  = di[0    +: 8];
                        do_1[16   +: 8]  = di[16   +: 8];
                        do_1[32   +: 8]  = di[32   +: 8];
                        do_1[48   +: 8]  = di[48   +: 8];
                    end
                    ODD_BYTES:  begin
                        do_1[8    +: 8]  = di[8    +: 8];
                        do_1[24   +: 8]  = di[24   +: 8];
                        do_1[40   +: 8]  = di[40   +: 8];
                        do_1[56   +: 8]  = di[56   +: 8];
                    end
                endcase
            end
        end
    end


// WRITE LOGIC
    always @(posedge clk) begin : mem_update
        reg [0:5] idx;
        if (reset) begin
            // Reset: clear all register contents except $0
            for (idx = 1; idx < `REGFILE_DEPTH; idx = idx + 1) begin
                rf_mem[idx] <= {`REGFILE_WIDTH{1'b0}};
            end
        end
        else if ((write_enb == 1'b1) && (addr_wr != 0)) begin
            case (sel)
                ALL_MODE:   rf_mem[addr_wr]           <= di;             // write full 64
                UPP_MODE:   rf_mem[addr_wr][0   +:32] <= di[0   +:32];   // write upper 32
                LOW_MODE:   rf_mem[addr_wr][32  +:32] <= di[32  +:32];   // write lower 32
                EVEN_BYTES: begin
                    rf_mem[addr_wr][0    +: 8] <= di[0    +: 8];
                    rf_mem[addr_wr][16   +: 8] <= di[16   +: 8];
                    rf_mem[addr_wr][32   +: 8] <= di[32   +: 8];
                    rf_mem[addr_wr][48   +: 8] <= di[48   +: 8];
                end
                ODD_BYTES:  begin
                    rf_mem[addr_wr][8    +: 8] <= di[8    +: 8];
                    rf_mem[addr_wr][24   +: 8] <= di[24   +: 8];
                    rf_mem[addr_wr][40   +: 8] <= di[40   +: 8];
                    rf_mem[addr_wr][56   +: 8] <= di[56   +: 8];
                end
            endcase
        end
    end

endmodule

`undef REGFILE_DEPTH
`undef REGFILE_WIDTH
`undef REGFILE_AWIDTH
