module DW_shifter_doubleword (
  input  [63:0] data_in,
  input  [6:0]  sh,
  input         data_tc,
  input         sh_tc,
  input         sh_mode,
  output [63:0] data_out
);

  // unsigned–unsigned comb shifter
  function [63:0] DWF_shifter_uns_uns(
    input [63:0] d,
    input [6:0]  s,
    input        m
  );
    reg [63:0] out;
    integer    j;
    begin
      if (m)
        DWF_shifter_uns_uns = d << s;
      else begin
        out = d << (s % 64);
        for (j = 0; j < (s % 64); j = j+1)
          out[j] = d[64 - (s % 64) + j];
        DWF_shifter_uns_uns = out;
      end
    end
  endfunction

  // signed–unsigned comb shifter
  function [63:0] DWF_shifter_tc_uns(
    input [63:0] d,
    input [6:0]  s,
    input        m
  );
    reg [63:0] out;
    integer    j;
    begin
      if (m)
        DWF_shifter_tc_uns = d << s;
      else begin
        out = d << (s % 64);
        for (j = 0; j < (s % 64); j = j+1)
          out[j] = d[64 - (s % 64) + j];
        DWF_shifter_tc_uns = out;
      end
    end
  endfunction

  // unsigned–signed comb shifter
  function [63:0] DWF_shifter_uns_tc(
    input [63:0] d,
    input [6:0]  s,
    input        m
  );
    reg [63:0] out;
    reg [6:0]  sa;
    integer    j;
    begin
      if (m) begin
        if (!s[6])
          DWF_shifter_uns_tc = d << s;
        else
          DWF_shifter_uns_tc = d >> -s;
      end else begin
        if (!s[6]) begin
          out = d << (s % 64);
          for (j = 0; j < (s % 64); j = j+1)
            out[j] = d[64 - (s % 64) + j];
          DWF_shifter_uns_tc = out;
        end else begin
          sa = -s;
          out = d >> sa;
          // copy last sa entries
          for (j = 0; j < sa; j = j+1)
            out[64-sa+j] = d[j];
          DWF_shifter_uns_tc = out;
        end
      end
    end
  endfunction

  // signed–signed comb shifter
  function [63:0] DWF_shifter_tc_tc(
    input [63:0] d,
    input [6:0]  s,
    input        m
  );
    reg [63:0] out;
    reg [6:0]  sa;
    reg        sign;
    integer    j;
    begin
      if (m) begin
        if (!s[6])
          DWF_shifter_tc_tc = d << s;
        else begin
          sa = -s;
          sign = d[63];
          out = d >> sa;
          for (j = 0; j < 64; j = j+1)
            DWF_shifter_tc_tc[j] = (j > 63-sa) ? sign : out[j];
        end
      end else begin
        if (!s[6]) begin
          out = d << (s % 64);
          for (j = 0; j < (s % 64); j = j+1)
            out[j] = d[64 - (s % 64) + j];
          DWF_shifter_tc_tc = out;
        end else begin
          sa = -s;
          out = d >> sa;
          // copy last sa entries
          for (j = 0; j < sa; j = j+1)
            out[64-sa+j] = d[j];
          DWF_shifter_tc_tc = out;
        end
      end
    end
  endfunction

  // rotate–unsigned base
  function [63:0] shift_uns_uns(
    input [63:0] d,
    input [6:0]  s,
    input        m,
    input        p
  );
    reg [63:0] out;
    integer    j;
    begin
      if (m) begin
        out = d << s;
        for (j = 0; j < s; j = j+1) out[j] = p;
      end else begin
        out = d << (s % 64);
        for (j = 0; j < (s % 64); j = j+1)
          out[j] = d[64 - (s % 64) + j];
      end
      shift_uns_uns = out;
    end
  endfunction

  // rotate–signed base
  function [63:0] shift_tc_uns(
    input [63:0] d,
    input [6:0]  s,
    input        m,
    input        p
  );
    reg [63:0] out;
    reg [6:0]  sa;
    integer    j;
    begin
      if (m) begin
        if (!s[6]) begin
          out = d << s;
          for (j = 0; j < s; j = j+1) out[j] = p;
        end else begin
          sa = -s;
          out = d >> sa;
          for (j = 0; j < sa; j = j+1) out[63-j] = p;
        end
      end else begin
        if (!s[6]) begin
          out = d << (s % 64);
          for (j = 0; j < (s % 64); j = j+1)
            out[j] = d[64 - (s % 64) + j];
        end else begin
          sa = -s;
          out = d >> sa;
          for (j = 0; j < sa; j = j+1) out[63-j] = d[sa-1-j];
        end
      end
      shift_tc_uns = out;
    end
  endfunction

  // rotate–unsigned signed pad
  function [63:0] shift_uns_tc(
    input [63:0] d,
    input [6:0]  s,
    input        m,
    input        p
  );
    reg [63:0] out;
    integer    j;
    begin
      if (m) begin
        out = d << s;
        for (j = 0; j < s; j = j+1) out[j] = p;
      end else begin
        out = d << (s % 64);
        for (j = 0; j < (s % 64); j = j+1)
          out[j] = d[64 - (s % 64) + j];
      end
      shift_uns_tc = out;
    end
  endfunction

  // rotate–signed signed pad
  function [63:0] shift_tc_tc(
    input [63:0] d,
    input [6:0]  s,
    input        m,
    input        p
  );
    reg [63:0] out;
    reg [6:0]  sa;
    reg        sign;
    integer    j;
    begin
      if (m) begin
        if (!s[6]) begin
          out = d << s;
          for (j = 0; j < s; j = j+1) out[j] = p;
        end else begin
          sa = -s;
          sign = d[63];
          out = d >> sa;
          for (j = 0; j < sa; j = j+1) out[63-j] = sign;
        end
      end else begin
        if (!s[6]) begin
          out = d << (s % 64);
          for (j = 0; j < (s % 64); j = j+1)
            out[j] = d[64 - (s % 64) + j];
        end else begin
          sa = -s;
          out = d >> sa;
          for (j = 0; j < sa; j = j+1) out[63-j] = d[sa-1-j];
        end
      end
      shift_tc_tc = out;
    end
  endfunction

  wire [6:0] sh_int       = (0==0||0==1) ? sh     : ~sh;
  wire       data_tc_int  = (0==0||0==1) ? data_tc: ~data_tc;
  wire       sh_tc_int    = (0==0||0==1) ? sh_tc  : ~sh_tc;
  wire       padded_value = (0==0||0==2) ? 1'b0   : 1'b1;

  assign data_out =
    (sh_tc_int==1'b0 && data_tc_int==1'b0) ? shift_uns_uns (data_in, sh_int, sh_mode, padded_value) :
    (sh_tc_int==1'b0 && data_tc_int==1'b1) ? shift_tc_uns  (data_in, sh_int, sh_mode, padded_value) :
    (sh_tc_int==1'b1 && data_tc_int==1'b0) ? DWF_shifter_uns_tc(data_in, sh_int, sh_mode) :
                                             DWF_shifter_tc_tc(data_in, sh_int, sh_mode);

endmodule
