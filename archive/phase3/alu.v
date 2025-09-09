`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW01_addsub.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW02_mult.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_div.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_sqrt.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_shifter.v"
`define DATA_WIDTH 64

module alu (do, di_A, di_B, func_code, subfield_sel);
  input [0:63] di_A, di_B;
  input [0:5] func_code;
  input [0:1] subfield_sel;
  output reg [0:63] do;
  
  localparam TC = 1'b0;
  localparam VAND   = 6'b000001,
             VOR    = 6'b000010,
             VXOR   = 6'b000011,
             VNOT   = 6'b000100,
             VMOV   = 6'b000101,
             VADD   = 6'b000110,
             VSUB   = 6'b000111,
             VMULEU = 6'b001000,
             VMULOU = 6'b001001,
             VSLL   = 6'b001010,
             VSRL   = 6'b001011,
             VSRA   = 6'b001100,
             VRTTH  = 6'b001101,
             VDIV   = 6'b001110,
             VMOD   = 6'b001111,
             VSQEU  = 6'b010000,
             VSQOU  = 6'b010001,
             VSQRT  = 6'b010010;
  localparam b_mode = 2'b00, h_mode = 2'b01, w_mode = 2'b10, d_mode = 2'b11;
  
  // Adders (8-bit units for VADD/VSUB)
  wire [0:7] ci, co;
  wire add_sub;
  wire [0:63] sum_diff;
  assign add_sub = (func_code == VADD) ? 1'b0 : 1'b1;
  DW01_addsub #(.width(8)) as0 (.A(di_A[0:7]),   .B(di_B[0:7]),   .CI(ci[0]), .CO(co[0]), .ADD_SUB(add_sub), .SUM(sum_diff[0:7]));
  DW01_addsub #(.width(8)) as1 (.A(di_A[8:15]),  .B(di_B[8:15]),  .CI(ci[1]), .CO(co[1]), .ADD_SUB(add_sub), .SUM(sum_diff[8:15]));
  DW01_addsub #(.width(8)) as2 (.A(di_A[16:23]), .B(di_B[16:23]), .CI(ci[2]), .CO(co[2]), .ADD_SUB(add_sub), .SUM(sum_diff[16:23]));
  DW01_addsub #(.width(8)) as3 (.A(di_A[24:31]), .B(di_B[24:31]), .CI(ci[3]), .CO(co[3]), .ADD_SUB(add_sub), .SUM(sum_diff[24:31]));
  DW01_addsub #(.width(8)) as4 (.A(di_A[32:39]), .B(di_B[32:39]), .CI(ci[4]), .CO(co[4]), .ADD_SUB(add_sub), .SUM(sum_diff[32:39]));
  DW01_addsub #(.width(8)) as5 (.A(di_A[40:47]), .B(di_B[40:47]), .CI(ci[5]), .CO(co[5]), .ADD_SUB(add_sub), .SUM(sum_diff[40:47]));
  DW01_addsub #(.width(8)) as6 (.A(di_A[48:55]), .B(di_B[48:55]), .CI(ci[6]), .CO(co[6]), .ADD_SUB(add_sub), .SUM(sum_diff[48:55]));
  DW01_addsub #(.width(8)) as7 (.A(di_A[56:63]), .B(di_B[56:63]), .CI(ci[7]), .CO(co[7]), .ADD_SUB(add_sub), .SUM(sum_diff[56:63]));
  assign ci[0] = (subfield_sel == b_mode) ? 1'b0 : co[1];
  assign ci[1] = ((subfield_sel == b_mode) || (subfield_sel == h_mode)) ? 1'b0 : co[2];
  assign ci[2] = (subfield_sel == b_mode) ? 1'b0 : co[3];
  assign ci[3] = ((subfield_sel == b_mode) || (subfield_sel == h_mode) || (subfield_sel == w_mode)) ? 1'b0 : co[4];
  assign ci[4] = (subfield_sel == b_mode) ? 1'b0 : co[5];
  assign ci[5] = ((subfield_sel == b_mode) || (subfield_sel == h_mode)) ? 1'b0 : co[6];
  assign ci[6] = (subfield_sel == b_mode) ? 1'b0 : co[7];
  assign ci[7] = 1'b0;
  
  // Multiplier setup
  reg [0:31] mult_di_A, mult_di_B;
  wire [0:64] product_b, product_h, product_w;
  always @(*) begin
    mult_di_A = 32'bx; mult_di_B = 32'bx;
    case(func_code)
      VMULEU: case(subfield_sel)
                b_mode: begin
                  mult_di_A = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                  mult_di_B = {di_B[0:7], di_B[16:23], di_B[32:39], di_B[48:55]};
                end
                h_mode: begin
                  mult_di_A = {di_A[0:15], di_A[32:47]};
                  mult_di_B = {di_B[0:15], di_B[32:47]};
                end
                w_mode: begin
                  mult_di_A = di_A[0:31];
                  mult_di_B = di_B[0:31];
                end
              endcase
      VMULOU: case(subfield_sel)
                b_mode: begin
                  mult_di_A = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                  mult_di_B = {di_B[8:15], di_B[24:31], di_B[40:47], di_B[56:63]};
                end
                h_mode: begin
                  mult_di_A = {di_A[16:31], di_A[48:63]};
                  mult_di_B = {di_B[16:31], di_B[48:63]};
                end
                w_mode: begin
                  mult_di_A = di_A[32:63];
                  mult_di_B = di_B[32:63];
                end
              endcase
      VSQEU: case(subfield_sel)
                b_mode: begin
                  mult_di_A = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                  mult_di_B = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                end
                h_mode: begin
                  mult_di_A = {di_A[0:15], di_A[32:47]};
                  mult_di_B = {di_A[0:15], di_A[32:47]};
                end
                w_mode: begin
                  mult_di_A = di_A[0:31];
                  mult_di_B = di_A[0:31];
                end
              endcase
      VSQOU: case(subfield_sel)
                b_mode: begin
                  mult_di_A = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                  mult_di_B = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                end
                h_mode: begin
                  mult_di_A = {di_A[16:31], di_A[48:63]};
                  mult_di_B = {di_A[16:31], di_A[48:63]};
                end
                w_mode: begin
                  mult_di_A = di_A[32:63];
                  mult_di_B = di_A[32:63];
                end
              endcase
      default: begin
                  mult_di_A = 32'b0; mult_di_B = 32'b0;
               end
    endcase
  end
  DW02_mult #(.A_width(8), .B_width(8)) m_b0 (.A(mult_di_A[0:7]),   .B(mult_di_B[0:7]),   .TC(TC), .PRODUCT(product_b[0:15]));
  DW02_mult #(.A_width(8), .B_width(8)) m_b1 (.A(mult_di_A[8:15]),  .B(mult_di_B[8:15]),  .TC(TC), .PRODUCT(product_b[16:31]));
  DW02_mult #(.A_width(8), .B_width(8)) m_b2 (.A(mult_di_A[16:23]), .B(mult_di_B[16:23]), .TC(TC), .PRODUCT(product_b[32:47]));
  DW02_mult #(.A_width(8), .B_width(8)) m_b3 (.A(mult_di_A[24:31]), .B(mult_di_B[24:31]), .TC(TC), .PRODUCT(product_b[48:63]));
  DW02_mult #(.A_width(16), .B_width(16)) m_h0 (.A(mult_di_A[0:15]),  .B(mult_di_B[0:15]),  .TC(TC), .PRODUCT(product_h[0:31]));
  DW02_mult #(.A_width(16), .B_width(16)) m_h1 (.A(mult_di_A[16:31]), .B(mult_di_B[16:31]), .TC(TC), .PRODUCT(product_h[32:63]));
  DW02_mult #(.A_width(32), .B_width(32)) m_w0 (.A(mult_di_A[0:31]),  .B(mult_di_B[0:31]),  .TC(TC), .PRODUCT(product_w[0:63]));
  
  // Divider
  wire [0:63] dividend, divisor;
  wire [0:63] quotient_b, quotient_h, quotient_w, quotient_d;
  wire [0:63] remainder_b, remainder_h, remainder_w, remainder_d;
  assign dividend = di_A;
  assign divisor = ((func_code==VDIV)||(func_code==VMOD)) ? di_B : {64{1'b1}};
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b0 (.a(dividend[0:7]),   .b(divisor[0:7]),   .quotient(quotient_b[0:7]),   .remainder(remainder_b[0:7]),   .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b1 (.a(dividend[8:15]),  .b(divisor[8:15]),  .quotient(quotient_b[8:15]),  .remainder(remainder_b[8:15]),  .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b2 (.a(dividend[16:23]), .b(divisor[16:23]), .quotient(quotient_b[16:23]), .remainder(remainder_b[16:23]), .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b3 (.a(dividend[24:31]), .b(divisor[24:31]), .quotient(quotient_b[24:31]), .remainder(remainder_b[24:31]), .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b4 (.a(dividend[32:39]), .b(divisor[32:39]), .quotient(quotient_b[32:39]), .remainder(remainder_b[32:39]), .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b5 (.a(dividend[40:47]), .b(divisor[40:47]), .quotient(quotient_b[40:47]), .remainder(remainder_b[40:47]), .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b6 (.a(dividend[48:55]), .b(divisor[48:55]), .quotient(quotient_b[48:55]), .remainder(remainder_b[48:55]), .divide_by_0());
  DW_div #(.a_width(8), .b_width(8), .tc_mode(TC), .rem_mode(0)) d_b7 (.a(dividend[56:63]), .b(divisor[56:63]), .quotient(quotient_b[56:63]), .remainder(remainder_b[56:63]), .divide_by_0());
  DW_div #(.a_width(16), .b_width(16), .tc_mode(TC), .rem_mode(0)) d_h0 (.a(dividend[0:15]),  .b(divisor[0:15]),  .quotient(quotient_h[0:15]),  .remainder(remainder_h[0:15]),  .divide_by_0());
  DW_div #(.a_width(16), .b_width(16), .tc_mode(TC), .rem_mode(0)) d_h1 (.a(dividend[16:31]), .b(divisor[16:31]), .quotient(quotient_h[16:31]), .remainder(remainder_h[16:31]), .divide_by_0());
  DW_div #(.a_width(16), .b_width(16), .tc_mode(TC), .rem_mode(0)) d_h2 (.a(dividend[32:47]), .b(divisor[32:47]), .quotient(quotient_h[32:47]), .remainder(remainder_h[32:47]), .divide_by_0());
  DW_div #(.a_width(16), .b_width(16), .tc_mode(TC), .rem_mode(0)) d_h3 (.a(dividend[48:63]), .b(divisor[48:63]), .quotient(quotient_h[48:63]), .remainder(remainder_h[48:63]), .divide_by_0());
  DW_div #(.a_width(32), .b_width(32), .tc_mode(TC), .rem_mode(0)) d_w0 (.a(dividend[0:31]),  .b(divisor[0:31]),  .quotient(quotient_w[0:31]),  .remainder(remainder_w[0:31]),  .divide_by_0());
  DW_div #(.a_width(32), .b_width(32), .tc_mode(TC), .rem_mode(0)) d_w1 (.a(dividend[32:63]), .b(divisor[32:63]), .quotient(quotient_w[32:63]), .remainder(remainder_w[32:63]), .divide_by_0());
  DW_div #(.a_width(64), .b_width(64), .tc_mode(TC), .rem_mode(0)) d_d0 (.a(dividend[0:63]),  .b(divisor[0:63]),  .quotient(quotient_d[0:63]),  .remainder(remainder_d[0:63]),  .divide_by_0());
  
  // Sqrt
  wire [0:63] root_b, root_h, root_w, root_d;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b0 (.a(di_A[0:7]),   .root(root_b[4:7]));  assign root_b[0:3] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b1 (.a(di_A[8:15]),  .root(root_b[12:15])); assign root_b[8:11] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b2 (.a(di_A[16:23]), .root(root_b[20:23])); assign root_b[16:19] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b3 (.a(di_A[24:31]), .root(root_b[28:31])); assign root_b[24:27] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b4 (.a(di_A[32:39]), .root(root_b[36:39])); assign root_b[32:35] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b5 (.a(di_A[40:47]), .root(root_b[44:47])); assign root_b[40:43] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b6 (.a(di_A[48:55]), .root(root_b[52:55])); assign root_b[48:51] = 4'b0;
  DW_sqrt #(.width(8),  .tc_mode(TC)) s_b7 (.a(di_A[56:63]), .root(root_b[60:63])); assign root_b[56:59] = 4'b0;
  DW_sqrt #(.width(16), .tc_mode(TC)) s_h0 (.a(di_A[0:15]),  .root(root_h[8:15]));  assign root_h[0:7] = 8'b0;
  DW_sqrt #(.width(16), .tc_mode(TC)) s_h1 (.a(di_A[16:31]), .root(root_h[24:31])); assign root_h[16:23] = 8'b0;
  DW_sqrt #(.width(16), .tc_mode(TC)) s_h2 (.a(di_A[32:47]), .root(root_h[40:47])); assign root_h[32:39] = 8'b0;
  DW_sqrt #(.width(16), .tc_mode(TC)) s_h3 (.a(di_A[48:63]), .root(root_h[56:63])); assign root_h[48:55] = 8'b0;
  DW_sqrt #(.width(32), .tc_mode(TC)) s_w0 (.a(di_A[0:31]),  .root(root_w[16:31])); assign root_w[0:15] = 16'b0;
  DW_sqrt #(.width(32), .tc_mode(TC)) s_w1 (.a(di_A[32:63]), .root(root_w[48:63])); assign root_w[32:47] = 16'b0;
  DW_sqrt #(.width(64), .tc_mode(TC)) s_d0 (.a(di_A[0:63]),  .root(root_d[32:63])); assign root_d[0:31] = 32'b0;
  
  // Shifters
  reg [0:3] shift_b0, shift_b1, shift_b2, shift_b3, shift_b4, shift_b5, shift_b6, shift_b7;
  reg [0:4] shift_h0, shift_h1, shift_h2, shift_h3;
  reg [0:5] shift_w0, shift_w1;
  reg [0:6] shift_d0;
  always @(*) begin
    shift_b0 = 4'bx; shift_b1 = 4'bx; shift_b2 = 4'bx; shift_b3 = 4'bx;
    shift_b4 = 4'bx; shift_b5 = 4'bx; shift_b6 = 4'bx; shift_b7 = 4'bx;
    shift_h0 = 5'bx; shift_h1 = 5'bx; shift_h2 = 5'bx; shift_h3 = 5'bx;
    shift_w0 = 6'bx; shift_w1 = 6'bx;
    shift_d0 = 7'bx;
    case(subfield_sel)
      b_mode: begin
         if(func_code==VSLL) begin
            shift_b0 = {1'b0, di_B[5:7]};
            shift_b1 = {1'b0, di_B[13:15]};
            shift_b2 = {1'b0, di_B[21:23]};
            shift_b3 = {1'b0, di_B[29:31]};
            shift_b4 = {1'b0, di_B[37:39]};
            shift_b5 = {1'b0, di_B[45:47]};
            shift_b6 = {1'b0, di_B[53:55]};
            shift_b7 = {1'b0, di_B[61:63]};
         end else begin
            shift_b0 = ({1'b0, di_B[5:7]} ^ 4'b1111) + 1;
            shift_b1 = ({1'b0, di_B[13:15]} ^ 4'b1111) + 1;
            shift_b2 = ({1'b0, di_B[21:23]} ^ 4'b1111) + 1;
            shift_b3 = ({1'b0, di_B[29:31]} ^ 4'b1111) + 1;
            shift_b4 = ({1'b0, di_B[37:39]} ^ 4'b1111) + 1;
            shift_b5 = ({1'b0, di_B[45:47]} ^ 4'b1111) + 1;
            shift_b6 = ({1'b0, di_B[53:55]} ^ 4'b1111) + 1;
            shift_b7 = ({1'b0, di_B[61:63]} ^ 4'b1111) + 1;
         end
      end
      h_mode: begin
         if(func_code==VSLL) begin
            shift_h0 = {1'b0, di_B[12:15]};
            shift_h1 = {1'b0, di_B[28:31]};
            shift_h2 = {1'b0, di_B[44:47]};
            shift_h3 = {1'b0, di_B[60:63]};
         end else begin
            shift_h0 = ({1'b0, di_B[12:15]} ^ 5'b11111) + 1;
            shift_h1 = ({1'b0, di_B[28:31]} ^ 5'b11111) + 1;
            shift_h2 = ({1'b0, di_B[44:47]} ^ 5'b11111) + 1;
            shift_h3 = ({1'b0, di_B[60:63]} ^ 5'b11111) + 1;
         end
      end
      w_mode: begin
         if(func_code==VSLL) begin
            shift_w0 = {1'b0, di_B[27:31]};
            shift_w1 = {1'b0, di_B[59:63]};
         end else begin
            shift_w0 = ({1'b0, di_B[27:31]} ^ 6'b111111) + 1;
            shift_w1 = ({1'b0, di_B[59:63]} ^ 6'b111111) + 1;
         end
      end
      d_mode: begin
         if(func_code==VSLL)
            shift_d0 = {1'b0, di_B[58:63]};
         else
            shift_d0 = ({1'b0, di_B[58:63]} ^ 7'b1111111) + 1;
      end
    endcase
  end
  
  wire data_tc;
  assign data_tc = (func_code==VSRA) ? 1'b1 : 1'b0;
  wire [0:63] sh_b, sh_h, sh_w, sh_d;
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b0_inst (.data_in(di_A[0:7]),   .data_tc(data_tc), .sh(shift_b0), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[0:7]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b1_inst (.data_in(di_A[8:15]),  .data_tc(data_tc), .sh(shift_b1), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[8:15]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b2_inst (.data_in(di_A[16:23]), .data_tc(data_tc), .sh(shift_b2), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[16:23]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b3_inst (.data_in(di_A[24:31]), .data_tc(data_tc), .sh(shift_b3), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[24:31]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b4_inst (.data_in(di_A[32:39]), .data_tc(data_tc), .sh(shift_b4), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[32:39]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b5_inst (.data_in(di_A[40:47]), .data_tc(data_tc), .sh(shift_b5), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[40:47]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b6_inst (.data_in(di_A[48:55]), .data_tc(data_tc), .sh(shift_b6), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[48:55]));
  DW_shifter #(.data_width(8),  .sh_width(4), .inv_mode(0)) sh_b7_inst (.data_in(di_A[56:63]), .data_tc(data_tc), .sh(shift_b7), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_b[56:63]));
  DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) sh_h0_inst (.data_in(di_A[0:15]),  .data_tc(data_tc), .sh(shift_h0), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_h[0:15]));
  DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) sh_h1_inst (.data_in(di_A[16:31]), .data_tc(data_tc), .sh(shift_h1), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_h[16:31]));
  DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) sh_h2_inst (.data_in(di_A[32:47]), .data_tc(data_tc), .sh(shift_h2), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_h[32:47]));
  DW_shifter #(.data_width(16), .sh_width(5), .inv_mode(0)) sh_h3_inst (.data_in(di_A[48:63]), .data_tc(data_tc), .sh(shift_h3), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_h[48:63]));
  DW_shifter #(.data_width(32), .sh_width(6), .inv_mode(0)) sh_w0_inst (.data_in(di_A[0:31]),  .data_tc(data_tc), .sh(shift_w0), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_w[0:31]));
  DW_shifter #(.data_width(32), .sh_width(6), .inv_mode(0)) sh_w1_inst (.data_in(di_A[32:63]), .data_tc(data_tc), .sh(shift_w1), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_w[32:63]));
  DW_shifter #(.data_width(64), .sh_width(7), .inv_mode(0)) sh_d0_inst (.data_in(di_A[0:63]),  .data_tc(data_tc), .sh(shift_d0), .sh_tc(1'b1), .sh_mode(1'b1), .data_out(sh_d[0:63]));
  
  // Output MUX
  always @(*) begin
    do = 64'bx;
    case(func_code)
      VAND: do = di_A & di_B;
      VOR:  do = di_A | di_B;
      VXOR: do = di_A ^ di_B;
      VNOT: do = ~di_A;
      VMOV: do = di_A;
      VADD: do = sum_diff;
      VSUB: do = sum_diff;
      VMULEU: case(subfield_sel) b_mode: do = product_b; h_mode: do = product_h; w_mode: do = product_w; endcase
      VMULOU: case(subfield_sel) b_mode: do = product_b; h_mode: do = product_h; w_mode: do = product_w; endcase
      VSQEU: case(subfield_sel) b_mode: do = product_b; h_mode: do = product_h; w_mode: do = product_w; endcase
      VSQOU: case(subfield_sel) b_mode: do = product_b; h_mode: do = product_h; w_mode: do = product_w; endcase
      VDIV:  case(subfield_sel) b_mode: do = quotient_b; h_mode: do = quotient_h; w_mode: do = quotient_w; d_mode: do = quotient_d; endcase
      VMOD:  case(subfield_sel) b_mode: do = remainder_b; h_mode: do = remainder_h; w_mode: do = remainder_w; d_mode: do = remainder_d; endcase
      VSQRT: case(subfield_sel) b_mode: do = root_b; h_mode: do = root_h; w_mode: do = root_w; d_mode: do = root_d; endcase
      VSLL:  case(subfield_sel) b_mode: do = sh_b; h_mode: do = sh_h; w_mode: do = sh_w; d_mode: do = sh_d; endcase
      VSRL:  case(subfield_sel) b_mode: do = sh_b; h_mode: do = sh_h; w_mode: do = sh_w; d_mode: do = sh_d; endcase
      VSRA:  case(subfield_sel) b_mode: do = sh_b; h_mode: do = sh_h; w_mode: do = sh_w; d_mode: do = sh_d; endcase
      VRTTH: case(subfield_sel)
               b_mode: begin
                  do[0:7]   = {di_A[4:7],   di_A[0:3]};
                  do[8:15]  = {di_A[12:15], di_A[8:11]};
                  do[16:23] = {di_A[20:23], di_A[16:19]};
                  do[24:31] = {di_A[28:31], di_A[24:27]};
                  do[32:39] = {di_A[36:39], di_A[32:35]};
                  do[40:47] = {di_A[44:47], di_A[40:43]};
                  do[48:55] = {di_A[52:55], di_A[48:51]};
                  do[56:63] = {di_A[60:63], di_A[56:59]};
               end
               h_mode: begin
                  do[0:15]  = {di_A[8:15],  di_A[0:7]};
                  do[16:31] = {di_A[24:31], di_A[16:23]};
                  do[32:47] = {di_A[40:47], di_A[32:39]};
                  do[48:63] = {di_A[56:63], di_A[48:55]};
               end
               w_mode: begin
                  do[0:31]  = {di_A[16:31], di_A[0:15]};
                  do[32:63] = {di_A[48:63], di_A[32:47]};
               end
               d_mode: do = {di_A[32:63], di_A[0:31]};
             endcase
    endcase
  end
  
endmodule
