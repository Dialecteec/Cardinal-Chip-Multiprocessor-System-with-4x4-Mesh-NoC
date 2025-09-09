////////////////////////////////////////////////////////////////////////////////
// (C) COPYRIGHT 2000‐2016 SYNOPSYS INC.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////

module DW_div_halfword (
  input  [15:0] a,
  input  [15:0] b,
  output reg [15:0] quotient,
  output reg [15:0] remainder,
  output reg        divide_by_0
);

  // parameter check
  initial begin
    if (16 < 1) begin
      $display("%m: bad parameter"); $finish;
    end
  end

  // unsigned divide
  function [15:0] DWF_div_uns(input [15:0] A, input [15:0] B);
    reg [15:0] q; reg Ax, Bx;
    begin
      if (B==0)                     q = {16{1'b1}};
      else                               q = A / B;
      DWF_div_uns = q;
    end
  endfunction

  // signed divide
  function [15:0] DWF_div_tc(input [15:0] A, input [15:0] B);
    reg [15:0] Av, Bv, q; reg Ax, Bx;
    begin
      if (B==0) begin
        q = (A[15] ? {1'b1,{15{1'b0}}} : {1'b0,{15{1'b1}}}) >> 1;
      end else begin
        Av = A[15]? (~A+1): A;
        Bv = B[15]? (~B+1): B;
        q  = Av / Bv;
        if (A[15]^B[15]) q = ~q + 1;
      end
      DWF_div_tc = q;
    end
  endfunction

  // unsigned remainder
  function [15:0] DWF_rem_uns(input [15:0] A, input [15:0] B);
    reg [15:0] r; reg Ax, Bx;
    begin
      if (B==0)                     r = A;
      else                               r = A % B;
      DWF_rem_uns = r;
    end
  endfunction

  // signed remainder
  function [15:0] DWF_rem_tc(input [15:0] A, input [15:0] B);
    reg [15:0] Av, Bv, r; reg Ax, Bx; reg [31:0] ext;
    begin
      if (B==0) begin
        ext = {{16{A[15]}}, A};
        r   = ext[15:0];
      end else begin
        Av = A[15]? (~A+1): A;
        Bv = B[15]? (~B+1): B;
        r  = Av % Bv;
        if (A[15]) r = ~r + 1;
      end
      DWF_rem_tc = r;
    end
  endfunction

  // unsigned modulus
  function [15:0] DWF_mod_uns(input [15:0] A, input [15:0] B);
    begin
      DWF_mod_uns = DWF_rem_uns(A, B);
    end
  endfunction

  // signed modulus
  function [15:0] DWF_mod_tc(input [15:0] A, input [15:0] B);
    reg [15:0] mv, rv, Av, Bv; reg Ax, Bx; reg [31:0] ext;
    begin
      if (B==0) begin
        ext = {{16{A[15]}}, A};
        mv  = ext[15:0];
      end else begin
        Av = A[15]? (~A+1): A;
        Bv = B[15]? (~B+1): B;
        rv = Av % Bv;
        if (A[15]) rv = ~rv + 1;
        mv = (rv == 0) ? rv : (A[15]? ~rv+1 : rv);
        if (A[15]^B[15]) mv = B + mv;
      end
      DWF_mod_tc = mv;
    end
  endfunction

  // compute
  always @(*) begin
    quotient    = DWF_div_uns(a, b);
    remainder   = DWF_mod_uns(a, b);
    divide_by_0 = (b == 16'b0);
  end

endmodule
