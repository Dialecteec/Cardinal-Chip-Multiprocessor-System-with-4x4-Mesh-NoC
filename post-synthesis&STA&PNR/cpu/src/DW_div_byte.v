module DW_div_byte (
  input  [7:0] a,
  input  [7:0] b,
  output reg [7:0] quotient,
  output reg [7:0] remainder,
  output reg       divide_by_0
);

  // parameter check (unchanged)
  initial begin : param_chk
    integer err;
    err = 0;
    if (8 < 1) begin err = 1; $display("ERROR: width"); end
    if (err) begin $display("%m: abort"); $finish; end
  end

  // unsigned division
  function [7:0] DWF_div_uns(input [7:0] A, input [7:0] B);
    reg [7:0] q; reg Ax, Bx;
    begin
      if (B==0)                q = {8{1'b1}};
      else                          q = A/B;
      DWF_div_uns = q;
    end
  endfunction

  // signed division
  function [7:0] DWF_div_tc(input [7:0] A, input [7:0] B);
    reg [7:0] Av, Bv, q; reg Ax, Bx;
    begin
      if (B==0) begin
        q = (A[7] ? {1'b1,{7{1'b0}}} : {1'b0,{7{1'b1}}}) >>1;
      end else begin
        Av = A[7]? (~A+1): A;
        Bv = B[7]? (~B+1): B;
        q  = Av/Bv;
        if (A[7]^B[7]) q = ~q+1;
      end
      DWF_div_tc = q;
    end
  endfunction

  // unsigned remainder
  function [7:0] DWF_rem_uns(input [7:0] A, input [7:0] B);
    reg [7:0] r; reg Ax, Bx;
    begin
      if (B==0)                r = A;
      else                          r = A%B;
      DWF_rem_uns = r;
    end
  endfunction

  // signed remainder
  function [7:0] DWF_rem_tc(input [7:0] A, input [7:0] B);
    reg [7:0] Av, Bv, r; reg Ax, Bx; reg [15:0] ext;
    begin
      if (B==0) begin
        ext = {{8{A[7]}},A};
        r   = ext[7:0];
      end else begin
        Av = A[7]? (~A+1): A;
        Bv = B[7]? (~B+1): B;
        r  = Av%Bv;
        if (A[7]) r = ~r+1;
      end
      DWF_rem_tc = r;
    end
  endfunction

  // unsigned modulus (same as rem in Verilog)
  function [7:0] DWF_mod_uns(input [7:0] A, input [7:0] B);
    begin DWF_mod_uns = DWF_rem_uns(A,B); end
  endfunction

  // signed modulus
  function [7:0] DWF_mod_tc(input [7:0] A, input [7:0] B);
    reg [7:0] modv, rv, Av, Bv; reg Ax, Bx; reg [15:0] ext;
    begin
      if (B==0) begin
        ext  = {{8{A[7]}},A};
        modv = ext[7:0];
      end else begin
        Av = A[7]? (~A+1): A;
        Bv = B[7]? (~B+1): B;
        rv = Av%Bv;
        if (A[7]) rv = ~rv+1;
        if (rv==0)       modv = rv;
        else if (!A[7])  modv = rv;
        else              modv = ~rv+1;
        if (A[7]^B[7])   modv = B + modv;
      end
      DWF_mod_tc = modv;
    end
  endfunction

  always @(a or b) begin
    if (0==0) begin
      quotient   = DWF_div_uns(a,b);
      remainder  = DWF_mod_uns(a,b);
    end else begin
      quotient   = DWF_div_tc(a,b);
      remainder  = DWF_mod_tc(a,b);
    end
    divide_by_0 = (b==8'b0);
  end

endmodule
