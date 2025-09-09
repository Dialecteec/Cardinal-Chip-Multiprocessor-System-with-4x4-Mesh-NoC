// Simulation references for DesignWare components:
`include "../include/DW01_addsub.v"
`include "../include/DW02_mult.v"
`include "../include/DW_div.v"
`include "../include/DW_sqrt.v"
`include "../include/DW_shifter.v"


`define DATA_WIDTH 64

module alu (
    do,      // ALU output
    di_A,        // First ALU operand
    di_B,        // Second ALU operand
    opcode,      // 6-bit function selector
    fieldSelect  // 2-bit sub-field selector
);

    // Port declarations
    input  [0:`DATA_WIDTH - 1] di_A, di_B;
    input  [0:5] opcode;
    input  [0:1] fieldSelect;
    output reg [0:`DATA_WIDTH - 1] do;

    // For DesignWare modules, TC=0 means 'unsigned'; TC=1 means 'signed'
    localparam UNSIGNED = 1'b0;

    // Operation code definitions
    localparam 
       OP_AND  = 6'b000001,
       OP_OR   = 6'b000010,
       OP_XOR  = 6'b000011,
       OP_NOT  = 6'b000100,
       OP_MOVE = 6'b000101,
       OP_ADD  = 6'b000110,
       OP_SUB  = 6'b000111,
       OP_MULE = 6'b001000,
       OP_MULO = 6'b001001,
       OP_SLL  = 6'b001010,
       OP_SRL  = 6'b001011,
       OP_SRA  = 6'b001100,
       OP_ROT  = 6'b001101,
       OP_DIV  = 6'b001110,
       OP_MOD  = 6'b001111,
       OP_SQE  = 6'b010000,
       OP_SQO  = 6'b010001,
       OP_SQRT = 6'b010010;

    // Field selection
    localparam 
       BYTE_MODE   = 2'b00,
       HALF_MODE   = 2'b01,
       WORD_MODE   = 2'b10,
       DBLWORD_MODE= 2'b11;


// Adders and Subtractors
    //    Controlled by the sub-field selection; uses eight 8-bit DW01_addsub.
    wire [0:7] connect_in, connect_out;
    wire add_sub_sel;
    wire [0:63] addsub_out;

    assign add_sub_sel = (opcode == OP_ADD) ? 1'b0 : 1'b1;

    // 8-bit addsub units
    DW01_addsub #( .width(8) ) addsub_unit0 (
       .A(di_A[0:7]),
       .B(di_B[0:7]),
       .CI(connect_in[0]),
       .CO(connect_out[0]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[0:7])
    );

    DW01_addsub #( .width(8) ) addsub_unit1 (
       .A(di_A[8:15]),
       .B(di_B[8:15]),
       .CI(connect_in[1]),
       .CO(connect_out[1]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[8:15])
    );

    DW01_addsub #( .width(8) ) addsub_unit2 (
       .A(di_A[16:23]),
       .B(di_B[16:23]),
       .CI(connect_in[2]),
       .CO(connect_out[2]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[16:23])
    );

    DW01_addsub #( .width(8) ) addsub_unit3 (
       .A(di_A[24:31]),
       .B(di_B[24:31]),
       .CI(connect_in[3]),
       .CO(connect_out[3]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[24:31])
    );

    DW01_addsub #( .width(8) ) addsub_unit4 (
       .A(di_A[32:39]),
       .B(di_B[32:39]),
       .CI(connect_in[4]),
       .CO(connect_out[4]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[32:39])
    );

    DW01_addsub #( .width(8) ) addsub_unit5 (
       .A(di_A[40:47]),
       .B(di_B[40:47]),
       .CI(connect_in[5]),
       .CO(connect_out[5]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[40:47])
    );

    DW01_addsub #( .width(8) ) addsub_unit6 (
       .A(di_A[48:55]),
       .B(di_B[48:55]),
       .CI(connect_in[6]),
       .CO(connect_out[6]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[48:55])
    );

    DW01_addsub #( .width(8) ) addsub_unit7 (
       .A(di_A[56:63]),
       .B(di_B[56:63]),
       .CI(connect_in[7]),
       .CO(connect_out[7]),
       .ADD_SUB(add_sub_sel),
       .SUM(addsub_out[56:63])
    );

    // Ripple-carry connections based on sub-field
    assign connect_in[0] = (fieldSelect == BYTE_MODE) ? 1'b0 : connect_out[1];
    assign connect_in[1] = ((fieldSelect == BYTE_MODE)||(fieldSelect==HALF_MODE)) ? 1'b0 : connect_out[2];
    assign connect_in[2] = (fieldSelect == BYTE_MODE) ? 1'b0 : connect_out[3];
    assign connect_in[3] = ((fieldSelect==BYTE_MODE)||(fieldSelect==HALF_MODE)||(fieldSelect==WORD_MODE)) ? 1'b0 : connect_out[4];
    assign connect_in[4] = (fieldSelect == BYTE_MODE) ? 1'b0 : connect_out[5];
    assign connect_in[5] = ((fieldSelect==BYTE_MODE)||(fieldSelect==HALF_MODE)) ? 1'b0 : connect_out[6];
    assign connect_in[6] = (fieldSelect == BYTE_MODE) ? 1'b0 : connect_out[7];
    assign connect_in[7] = 1'b0;


// Multipliers
    reg [0:31] mulA, mulB;
    wire [0:64] product_b, product_h, product_w;

    // Determine multiplier inputs depending on sub-field and even/odd byte usage
    always @(*) begin
        mulA = 32'bx;
        mulB = 32'bx;
        case(opcode)
          OP_MULE: // Multiply (even units)
            case(fieldSelect)
              BYTE_MODE: begin
                  mulA = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                  mulB = {di_B[0:7], di_B[16:23], di_B[32:39], di_B[48:55]};
              end
              HALF_MODE: begin
                  mulA = {di_A[0:15], di_A[32:47]};
                  mulB = {di_B[0:15], di_B[32:47]};
              end
              WORD_MODE: begin
                  mulA = di_A[0:31];
                  mulB = di_B[0:31];
              end
            endcase

          OP_MULO: // Multiply (odd units)
            case(fieldSelect)
              BYTE_MODE: begin
                  mulA = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                  mulB = {di_B[8:15], di_B[24:31], di_B[40:47], di_B[56:63]};
              end
              HALF_MODE: begin
                  mulA = {di_A[16:31], di_A[48:63]};
                  mulB = {di_B[16:31], di_B[48:63]};
              end
              WORD_MODE: begin
                  mulA = di_A[32:63];
                  mulB = di_B[32:63];
              end
            endcase

          OP_SQE: // Square (even parts)
            case(fieldSelect)
              BYTE_MODE: begin
                  mulA = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                  mulB = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
              end
              HALF_MODE: begin
                  mulA = {di_A[0:15], di_A[32:47]};
                  mulB = {di_A[0:15], di_A[32:47]};
              end
              WORD_MODE: begin
                  mulA = di_A[0:31];
                  mulB = di_A[0:31];
              end
            endcase

          OP_SQO: // Square (odd parts)
            case(fieldSelect)
              BYTE_MODE: begin
                  mulA = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                  mulB = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
              end
              HALF_MODE: begin
                  mulA = {di_A[16:31], di_A[48:63]};
                  mulB = {di_A[16:31], di_A[48:63]};
              end
              WORD_MODE: begin
                  mulA = di_A[32:63];
                  mulB = di_A[32:63];
              end
            endcase
        endcase
    end

    // Byte-mode multipliers
    DW02_mult #( .A_width(8), .B_width(8) ) mult_byte_0 (
       .A(mulA[0:7]),   .B(mulB[0:7]),   .TC(UNSIGNED), .PRODUCT(product_b[0:15])
    );
    DW02_mult #( .A_width(8), .B_width(8) ) mult_byte_1 (
       .A(mulA[8:15]),  .B(mulB[8:15]),  .TC(UNSIGNED), .PRODUCT(product_b[16:31])
    );
    DW02_mult #( .A_width(8), .B_width(8) ) mult_byte_2 (
       .A(mulA[16:23]), .B(mulB[16:23]), .TC(UNSIGNED), .PRODUCT(product_b[32:47])
    );
    DW02_mult #( .A_width(8), .B_width(8) ) mult_byte_3 (
       .A(mulA[24:31]), .B(mulB[24:31]), .TC(UNSIGNED), .PRODUCT(product_b[48:63])
    );

    // Half-word multipliers
    DW02_mult #( .A_width(16), .B_width(16) ) mult_half_0 (
       .A(mulA[0:15]),   .B(mulB[0:15]),   .TC(UNSIGNED), .PRODUCT(product_h[0:31])
    );
    DW02_mult #( .A_width(16), .B_width(16) ) mult_half_1 (
       .A(mulA[16:31]),  .B(mulB[16:31]),  .TC(UNSIGNED), .PRODUCT(product_h[32:63])
    );

    // Word multiplier
    DW02_mult #( .A_width(32), .B_width(32) ) mult_word_0 (
       .A(mulA[0:31]), .B(mulB[0:31]), .TC(UNSIGNED), .PRODUCT(product_w[0:63])
    );


// 3) Dividers
    wire [0:63] div_divisor, div_dividend;
    wire [0:63] q_b, r_b, q_h, r_h, q_w, r_w, q_d, r_d;

    // For safety in simulation, if not dividing, drive divisor high to avoid X
    assign div_dividend[0:63] = di_A[0:63];
    assign div_divisor[0:63]  = ((opcode == OP_DIV)||(opcode == OP_MOD)) ? di_B[0:63] : {64{1'b1}};

    // Byte-mode dividers
    generate
        genvar i_b;
        for (i_b = 0; i_b < 8; i_b = i_b + 1) begin : gen_div_b
            DW_div #( 
                .a_width(8),
                .b_width(8),
                .tc_mode(UNSIGNED),
                .rem_mode(0)
            ) div_byte (
               .a(div_dividend[i_b*8 : i_b*8+7]),
               .b(div_divisor[i_b*8 : i_b*8+7]),
               .quotient(q_b[i_b*8 : i_b*8+7]),
               .remainder(r_b[i_b*8 : i_b*8+7]),
               .divide_by_0()
            );
        end
    endgenerate

    // Half-word dividers
    generate
        genvar i_h;
        for (i_h = 0; i_h < 4; i_h = i_h + 1) begin : gen_div_h
            DW_div #( 
                .a_width(16),
                .b_width(16),
                .tc_mode(UNSIGNED),
                .rem_mode(0)
            ) div_half (
               .a(div_dividend[i_h*16 : i_h*16+15]),
               .b(div_divisor[i_h*16 : i_h*16+15]),
               .quotient(q_h[i_h*16 : i_h*16+15]),
               .remainder(r_h[i_h*16 : i_h*16+15]),
               .divide_by_0()
            );
        end
    endgenerate

    // Word-mode dividers
    generate
        genvar i_w;
        for (i_w = 0; i_w < 2; i_w = i_w + 1) begin : gen_div_w
            DW_div #( 
                .a_width(32),
                .b_width(32),
                .tc_mode(UNSIGNED),
                .rem_mode(0)
            ) div_word (
               .a(div_dividend[i_w*32 : i_w*32+31]),
               .b(div_divisor[i_w*32 : i_w*32+31]),
               .quotient(q_w[i_w*32 : i_w*32+31]),
               .remainder(r_w[i_w*32 : i_w*32+31]),
               .divide_by_0()
            );
        end
    endgenerate

    // Double-word divider
    DW_div #( 
       .a_width(64),
       .b_width(64),
       .tc_mode(UNSIGNED),
       .rem_mode(0)
    ) div_dword (
       .a(div_dividend[0:63]),
       .b(div_divisor[0:63]),
       .quotient(q_d[0:63]),
       .remainder(r_d[0:63]),
       .divide_by_0()
    );


// Square-root
    wire [0:63] rt_b, rt_h, rt_w, rt_d;

    // Byte sub-field square roots
    generate
        genvar j_b;
        for (j_b = 0; j_b < 8; j_b = j_b + 1) begin : gen_sqrt_b
            DW_sqrt #( .width(8), .tc_mode(UNSIGNED) ) sqrt_b (
               .a(di_A[j_b*8 : j_b*8+7]),
               .root(rt_b[j_b*8+4 : j_b*8+7]) // top bits from DW_sqrt
            );
            // Low bits forced to zero
            assign rt_b[j_b*8 : j_b*8+3] = 4'b0;
        end
    endgenerate

    // Half-word square roots
    generate
        genvar j_h;
        for (j_h = 0; j_h < 4; j_h = j_h + 1) begin : gen_sqrt_h
            DW_sqrt #( .width(16), .tc_mode(UNSIGNED) ) sqrt_h (
               .a(di_A[j_h*16 : j_h*16+15]),
               .root(rt_h[j_h*16+8 : j_h*16+15])
            );
            assign rt_h[j_h*16 : j_h*16+7] = 8'b0;
        end
    endgenerate

    // Word square roots
    generate
        genvar j_w;
        for (j_w = 0; j_w < 2; j_w = j_w + 1) begin : gen_sqrt_w
            DW_sqrt #( .width(32), .tc_mode(UNSIGNED) ) sqrt_w (
               .a(di_A[j_w*32 : j_w*32+31]),
               .root(rt_w[j_w*32+16 : j_w*32+31])
            );
            assign rt_w[j_w*32 : j_w*32+15] = 16'b0;
        end
    endgenerate

    // Double-word square root
    DW_sqrt #( .width(64), .tc_mode(UNSIGNED) ) sqrt_dw (
       .a(di_A[0:63]),
       .root(rt_d[32:63])
    );
    assign rt_d[0:31] = 32'b0;


// Shifter
    //    We use signed shift values for left or right shift by doing 2's complement on right shifts.

    // Instead of declaring these inside an always block, we declare them here:
    integer idx_b, idx_h, idx_w;

    reg [0:3] shift_b_val [0:7];
    reg [0:4] shift_h_val [0:3];
    reg [0:5] shift_w_val [0:1];
    reg [0:6] shift_d_val;

    // Determine the shift amounts
    always @(*) begin
        // Initialize to avoid latches
        for (idx_b = 0; idx_b < 8; idx_b = idx_b + 1)
            shift_b_val[idx_b] = 4'bx;
        for (idx_h = 0; idx_h < 4; idx_h = idx_h + 1)
            shift_h_val[idx_h] = 5'bx;
        for (idx_w = 0; idx_w < 2; idx_w = idx_w + 1)
            shift_w_val[idx_w] = 6'bx;
        shift_d_val = 7'bx;

        case(fieldSelect)
          BYTE_MODE: begin
              if(opcode == OP_SLL) begin
                  shift_b_val[0] = {1'b0, di_B[5:7]};
                  shift_b_val[1] = {1'b0, di_B[13:15]};
                  shift_b_val[2] = {1'b0, di_B[21:23]};
                  shift_b_val[3] = {1'b0, di_B[29:31]};
                  shift_b_val[4] = {1'b0, di_B[37:39]};
                  shift_b_val[5] = {1'b0, di_B[45:47]};
                  shift_b_val[6] = {1'b0, di_B[53:55]};
                  shift_b_val[7] = {1'b0, di_B[61:63]};
              end else begin
                  // 2's complement for a right shift
                  shift_b_val[0] = ({1'b0, di_B[5:7]}  ^ 4'b1111) + 1;
                  shift_b_val[1] = ({1'b0, di_B[13:15]} ^ 4'b1111) + 1;
                  shift_b_val[2] = ({1'b0, di_B[21:23]} ^ 4'b1111) + 1;
                  shift_b_val[3] = ({1'b0, di_B[29:31]} ^ 4'b1111) + 1;
                  shift_b_val[4] = ({1'b0, di_B[37:39]} ^ 4'b1111) + 1;
                  shift_b_val[5] = ({1'b0, di_B[45:47]} ^ 4'b1111) + 1;
                  shift_b_val[6] = ({1'b0, di_B[53:55]} ^ 4'b1111) + 1;
                  shift_b_val[7] = ({1'b0, di_B[61:63]} ^ 4'b1111) + 1;
              end
          end
          HALF_MODE: begin
              if(opcode == OP_SLL) begin
                  shift_h_val[0] = {1'b0, di_B[12:15]};
                  shift_h_val[1] = {1'b0, di_B[28:31]};
                  shift_h_val[2] = {1'b0, di_B[44:47]};
                  shift_h_val[3] = {1'b0, di_B[60:63]};
              end else begin
                  shift_h_val[0] = ({1'b0, di_B[12:15]} ^ 5'b1_1111) + 1;
                  shift_h_val[1] = ({1'b0, di_B[28:31]} ^ 5'b1_1111) + 1;
                  shift_h_val[2] = ({1'b0, di_B[44:47]} ^ 5'b1_1111) + 1;
                  shift_h_val[3] = ({1'b0, di_B[60:63]} ^ 5'b1_1111) + 1;
              end
          end
          WORD_MODE: begin
              if(opcode == OP_SLL) begin
                  shift_w_val[0] = {1'b0, di_B[27:31]};
                  shift_w_val[1] = {1'b0, di_B[59:63]};
              end else begin
                  shift_w_val[0] = ({1'b0, di_B[27:31]} ^ 6'b11_1111) + 1;
                  shift_w_val[1] = ({1'b0, di_B[59:63]} ^ 6'b11_1111) + 1;
              end
          end
          DBLWORD_MODE: begin
              if(opcode == OP_SLL)
                  shift_d_val = {1'b0, di_B[58:63]};
              else
                  shift_d_val = ({1'b0, di_B[58:63]} ^ 7'b111_1111) + 1;
          end
        endcase
    end

    // 1 => input data is signed for right shift; 0 => no sign extension
    wire shift_data_tc;
    assign shift_data_tc = (opcode == OP_SRA) ? 1'b1 : 1'b0;

    // Shifter outputs
    wire [0:63] sh_out_b, sh_out_h, sh_out_w, sh_out_d;

    // Byte-mode shifters
    generate
        genvar s_b;
        for (s_b = 0; s_b < 8; s_b = s_b + 1) begin : gen_sh_b
            DW_shifter #(
               .data_width(8),
               .sh_width(4),
               .inv_mode(0)
            ) shift_b (
               .data_in(di_A[s_b*8 : s_b*8+7]),
               .data_tc(shift_data_tc),
               .sh(shift_b_val[s_b]),
               .sh_tc(1'b1),    
               .sh_mode(1'b1), 
               .data_out(sh_out_b[s_b*8 : s_b*8+7])
            );
        end
    endgenerate

    // Half-word shifters
    generate
        genvar s_h;
        for (s_h = 0; s_h < 4; s_h = s_h + 1) begin : gen_sh_h
            DW_shifter #(
               .data_width(16),
               .sh_width(5),
               .inv_mode(0)
            ) shift_h (
               .data_in(di_A[s_h*16 : s_h*16+15]),
               .data_tc(shift_data_tc),
               .sh(shift_h_val[s_h]),
               .sh_tc(1'b1),
               .sh_mode(1'b1),
               .data_out(sh_out_h[s_h*16 : s_h*16+15])
            );
        end
    endgenerate

    // Word-mode shifters
    generate
        genvar s_w;
        for (s_w = 0; s_w < 2; s_w = s_w + 1) begin : gen_sh_w
            DW_shifter #(
               .data_width(32),
               .sh_width(6),
               .inv_mode(0)
            ) shift_w (
               .data_in(di_A[s_w*32 : s_w*32+31]),
               .data_tc(shift_data_tc),
               .sh(shift_w_val[s_w]),
               .sh_tc(1'b1),
               .sh_mode(1'b1),
               .data_out(sh_out_w[s_w*32 : s_w*32+31])
            );
        end
    endgenerate

    // Double-word shifter
    DW_shifter #(
       .data_width(64),
       .sh_width(7),
       .inv_mode(0)
    ) shift_d (
       .data_in(di_A[0:63]),
       .data_tc(shift_data_tc),
       .sh(shift_d_val),
       .sh_tc(1'b1),
       .sh_mode(1'b1),
       .data_out(sh_out_d[0:63])
    );


// do selection
    always @(*) begin
        do = {`DATA_WIDTH{1'bx}}; // default to X to avoid latches

        case (opcode)
          // Bitwise ops
          OP_AND:  do = di_A & di_B;
          OP_OR:   do = di_A | di_B;
          OP_XOR:  do = di_A ^ di_B;
          OP_NOT:  do = ~di_A;
          OP_MOVE: do = di_A;

          // Add / Sub
          OP_ADD:  do = addsub_out;
          OP_SUB:  do = addsub_out;

          // Multiplication (even and odd)
          OP_MULE:
            case(fieldSelect)
              BYTE_MODE: do = product_b[0:63];
              HALF_MODE: do = product_h[0:63];
              WORD_MODE: do = product_w[0:63];
            endcase

          OP_MULO:
            case(fieldSelect)
              BYTE_MODE: do = product_b[0:63];
              HALF_MODE: do = product_h[0:63];
              WORD_MODE: do = product_w[0:63];
            endcase

          // Square (even/odd)
          OP_SQE:
            case(fieldSelect)
              BYTE_MODE: do = product_b[0:63];
              HALF_MODE: do = product_h[0:63];
              WORD_MODE: do = product_w[0:63];
            endcase

          OP_SQO:
            case(fieldSelect)
              BYTE_MODE: do = product_b[0:63];
              HALF_MODE: do = product_h[0:63];
              WORD_MODE: do = product_w[0:63];
            endcase

          // Division
          OP_DIV:
            case(fieldSelect)
              BYTE_MODE:    do = q_b;
              HALF_MODE:    do = q_h;
              WORD_MODE:    do = q_w;
              DBLWORD_MODE: do = q_d;
            endcase

          // Modulo
          OP_MOD:
            case(fieldSelect)
              BYTE_MODE:    do = r_b;
              HALF_MODE:    do = r_h;
              WORD_MODE:    do = r_w;
              DBLWORD_MODE: do = r_d;
            endcase

          // Square root
          OP_SQRT:
            case(fieldSelect)
              BYTE_MODE:    do = rt_b;
              HALF_MODE:    do = rt_h;
              WORD_MODE:    do = rt_w;
              DBLWORD_MODE: do = rt_d;
            endcase

          // Shifts
          OP_SLL, OP_SRL, OP_SRA:
            case(fieldSelect)
              BYTE_MODE:    do = sh_out_b;
              HALF_MODE:    do = sh_out_h;
              WORD_MODE:    do = sh_out_w;
              DBLWORD_MODE: do = sh_out_d;
            endcase

          // Rotate half
          OP_ROT:
            case(fieldSelect)
              BYTE_MODE: begin
                  do[0:7]   = {di_A[4:7],  di_A[0:3]};
                  do[8:15]  = {di_A[12:15],di_A[8:11]};
                  do[16:23] = {di_A[20:23],di_A[16:19]};
                  do[24:31] = {di_A[28:31],di_A[24:27]};
                  do[32:39] = {di_A[36:39],di_A[32:35]};
                  do[40:47] = {di_A[44:47],di_A[40:43]};
                  do[48:55] = {di_A[52:55],di_A[48:51]};
                  do[56:63] = {di_A[60:63],di_A[56:59]};
              end
              HALF_MODE: begin
                  do[0:15]   = {di_A[8:15],  di_A[0:7]};
                  do[16:31]  = {di_A[24:31], di_A[16:23]};
                  do[32:47]  = {di_A[40:47], di_A[32:39]};
                  do[48:63]  = {di_A[56:63], di_A[48:55]};
              end
              WORD_MODE: begin
                  do[0:31]  = {di_A[16:31], di_A[0:15]};
                  do[32:63] = {di_A[48:63], di_A[32:47]};
              end
              DBLWORD_MODE: begin
                  do[0:63] = {di_A[32:63], di_A[0:31]};
              end
            endcase

        endcase
    end

endmodule

`undef DATA_WIDTH
