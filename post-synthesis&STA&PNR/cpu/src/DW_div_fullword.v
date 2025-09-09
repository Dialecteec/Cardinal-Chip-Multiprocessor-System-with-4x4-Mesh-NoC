////////////////////////////////////////////////////////////////////////////////
//
//   (C) COPYRIGHT 2000 - 2016 SYNOPSYS INC.
//   All rights reserved. Unauthorised use prohibited.
//
//   AUTHOR: Reto Zimmermann, April 12, 2000
//   VERSION: Verilog Simulation Architecture
//   DesignWare_version: 7434024d
//   DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

module DW_div_fullword (
  input  [31:0] a,
  input  [31:0] b,
  output reg [31:0] quotient,
  output reg [31:0] remainder,
  output reg        divide_by_0
);

  // parameter check
  initial begin
    integer err;
    err = 0;
    if (32 < 1) err = 1;
    if (err) begin $display("%m: bad parameter"); $finish; end
  end

  // unsigned divide
  function [31:0] DWF_div_uns(input [31:0] A, input [31:0] B);
    reg [31:0] q; reg Ax, Bx;
    begin
      if (B==0)                q = {32{1'b1}};
      else                          q = A/B;
      DWF_div_uns = q;
    end
  endfunction

  // signed divide
  function [31:0] DWF_div_tc(input [31:0] A, input [31:0] B);
    reg [31:0] Av, Bv, q; reg Ax, Bx;
    begin
      if (B==0) begin
        q = (A[31]? {1'b1,{31{1'b0}}} : {1'b0,{31{1'b1}}}) >> 1;
      end else begin
        Av = A[31]? (~A+1): A;
        Bv = B[31]? (~B+1): B;
        q  = Av/Bv;
        if (A[31]^B[31]) q = ~q + 1;
      end
      DWF_div_tc = q;
    end
  endfunction

  // unsigned remainder
  function [31:0] DWF_rem_uns(input [31:0] A, input [31:0] B);
    reg [31:0] r; reg Ax, Bx;
    begin
      if (B==0)                r = A;
      else                          r = A % B;
      DWF_rem_uns = r;
    end
  endfunction

  // signed remainder
  function [31:0] DWF_rem_tc(input [31:0] A, input [31:0] B);
    reg [31:0] Av, Bv, r; reg Ax, Bx; reg [63:0] ext;
    begin
      if (B==0) begin
        ext = {{32{A[31]}}, A};
        r   = ext[31:0];
      end else begin
        Av = A[31]? (~A+1): A;
        Bv = B[31]? (~B+1): B;
        r  = Av % Bv;
        if (A[31]) r = ~r + 1;
      end
      DWF_rem_tc = r;
    end
  endfunction

  // unsigned mod (same as rem)
  function [31:0] DWF_mod_uns(input [31:0] A, input [31:0] B);
    begin DWF_mod_uns = DWF_rem_uns(A,B); end
  endfunction

  // signed mod
  function [31:0] DWF_mod_tc(input [31:0] A, input [31:0] B);
    reg [31:0] mv, rv, Av, Bv; reg Ax, Bx; reg [63:0] ext;
    begin
      if (B==0) begin
        ext = {{32{A[31]}}, A};
        mv  = ext[31:0];
      end else begin
        Av = A[31]? (~A+1): A;
        Bv = B[31]? (~B+1): B;
        rv = Av % Bv;
        if (A[31]) rv = ~rv + 1;
        mv = (rv==0) ? rv : (A[31]? ~rv+1 : rv);
        if (A[31]^B[31]) mv = B + mv;
      end
      DWF_mod_tc = mv;
    end
  endfunction

  // main logic
  always @(a or b) begin
    quotient    = DWF_div_uns(a,b);
    remainder   = DWF_mod_uns(a,b);
    divide_by_0 = (b == 32'b0);
  end

endmodule
