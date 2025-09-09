module DW_div_doubleword (
  input  [63:0] a,
  input  [63:0] b,
  output reg [63:0] quotient,
  output reg [63:0] remainder,
  output reg        divide_by_0
);

  // parameter check
  initial begin
    integer err;
    err = 0;
    if (64 < 1)        begin err = 1; $display("ERROR: width<1"); end
    if (err)           begin $display("%m: abort"); $finish;    end
  end

  // unsigned divide
  function [63:0] DWF_div_uns(input [63:0] A, input [63:0] B);
    reg [63:0] q; reg Ax, Bx;
    begin
      if (B==0)                q = {64{1'b1}};
      else                          q = A/B;
      DWF_div_uns = q;
    end
  endfunction

  // signed divide
  function [63:0] DWF_div_tc(input [63:0] A, input [63:0] B);
    reg [63:0] Av, Bv, q; reg Ax, Bx;
    begin
      if (B==0) begin
        q = (A[63]? {1'b1,{63{1'b0}}} : {1'b0,{63{1'b1}}}) >> 1;
      end else begin
        Av = A[63]? (~A+1): A;
        Bv = B[63]? (~B+1): B;
        q  = Av/Bv;
        if (A[63]^B[63]) q = ~q + 1;
      end
      DWF_div_tc = q;
    end
  endfunction

  // unsigned remainder
  function [63:0] DWF_rem_uns(input [63:0] A, input [63:0] B);
    reg [63:0] r; reg Ax, Bx;
    begin
      if (B==0)                r = A;
      else                          r = A % B;
      DWF_rem_uns = r;
    end
  endfunction

  // signed remainder
  function [63:0] DWF_rem_tc(input [63:0] A, input [63:0] B);
    reg [63:0] Av, Bv, r; reg Ax, Bx; reg [127:0] ext;
    begin
      if (B==0) begin
        ext = {{64{A[63]}}, A};
        r   = ext[63:0];
      end else begin
        Av = A[63]? (~A+1): A;
        Bv = B[63]? (~B+1): B;
        r  = Av % Bv;
        if (A[63]) r = ~r + 1;
      end
      DWF_rem_tc = r;
    end
  endfunction

  // unsigned modulus (alias of rem)
  function [63:0] DWF_mod_uns(input [63:0] A, input [63:0] B);
    begin DWF_mod_uns = DWF_rem_uns(A, B); end
  endfunction

  // signed modulus
  function [63:0] DWF_mod_tc(input [63:0] A, input [63:0] B);
    reg [63:0] modv, rv, Av, Bv; reg Ax, Bx; reg [127:0] ext;
    begin
      if (B==0) begin
        ext   = {{64{A[63]}}, A};
        modv  = ext[63:0];
      end else begin
        Av = A[63]? (~A+1): A;
        Bv = B[63]? (~B+1): B;
        rv = Av % Bv;
        if (A[63]) rv = ~rv + 1;
        modv = (rv==0) ? rv : (A[63]? ~rv+1 : rv);
        if (A[63]^B[63]) modv = B + modv;
      end
      DWF_mod_tc = modv;
    end
  endfunction

  // main compute
  always @(a or b) begin
    // choose unsigned path
    quotient   = DWF_div_uns(a, b);
    remainder  = DWF_mod_uns(a, b);
    divide_by_0 = (b == 64'b0);
  end

endmodule
