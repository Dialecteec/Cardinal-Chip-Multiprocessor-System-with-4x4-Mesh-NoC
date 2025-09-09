////////////////////////////////////////////////////////////////////////////////
// (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.  All rights reserved.
// AUTHOR:    Nitin Mhamunkar    August 1999
// VERSION:   Simulation Architecture
////////////////////////////////////////////////////////////////////////////////

module DW_shifter_halfword (
  input  [15:0] data_in,
  input  [4:0]  sh,
  input         data_tc,
  input         sh_tc,
  input         sh_mode,
  output [15:0] data_out
);

  // synopsys translate_off
  initial begin
    integer param_err_flg;
    param_err_flg = 0;
    if (16 < 2) param_err_flg = 1;
    if (5  < 1) param_err_flg = 1;
    if (param_err_flg) $finish;
  end
  // synopsys translate_on

  // unsigned–unsigned comb shifter
  function [15:0] DWF_shifter_uns_uns(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode
  );
    reg [15:0] data_out;
    integer    j;
    begin
      if (sh_mode)
        DWF_shifter_uns_uns = data_in << sh;
      else begin
        data_out = data_in << (sh % 16);
        for (j = 0; j < (sh % 16); j = j+1)
          data_out[j] = data_in[16 - (sh % 16) + j];
        DWF_shifter_uns_uns = data_out;
      end
    end
  endfunction

  // signed–unsigned comb shifter
  function [15:0] DWF_shifter_tc_uns(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode
  );
    reg [15:0] data_out;
    integer    j;
    begin
      if (sh_mode)
        DWF_shifter_tc_uns = data_in << sh;
      else begin
        data_out = data_in << (sh % 16);
        for (j = 0; j < (sh % 16); j = j+1)
          data_out[j] = data_in[16 - (sh % 16) + j];
        DWF_shifter_tc_uns = data_out;
      end
    end
  endfunction

  // unsigned–signed comb shifter
  function [15:0] DWF_shifter_uns_tc(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode
  );
    reg [15:0] data_out;
    reg [4:0]  sh_abs;
    integer    j;
    begin
      if (sh_mode) begin
        if (!sh[4])
          DWF_shifter_uns_tc = data_in << sh;
        else
          DWF_shifter_uns_tc = data_in >> -sh;
      end else begin
        if (!sh[4]) begin
          data_out = data_in << (sh % 16);
          for (j = 0; j < (sh % 16); j = j+1)
            data_out[j] = data_in[16 - (sh % 16) + j];
          DWF_shifter_uns_tc = data_out;
        end else begin
          sh_abs = -sh;
          data_out = data_in >> sh_abs;
          for (j = 16 - sh_abs; j < 16; j = j+1)
            data_out[j] = data_in[(j + sh_abs) % 16];
          DWF_shifter_uns_tc = data_out;
        end
      end
    end
  endfunction

  // signed–signed comb shifter
  function [15:0] DWF_shifter_tc_tc(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode
  );
    reg [15:0] data_out;
    reg [4:0]  sh_abs;
    reg        data_sign;
    integer    j;
    begin
      if (sh_mode) begin
        if (!sh[4])
          DWF_shifter_tc_tc = data_in << sh;
        else begin
          sh_abs = -sh;
          data_sign = data_in[15];
          data_out = data_in >> sh_abs;
          for (j = 0; j < 16; j = j+1)
            DWF_shifter_tc_tc[j] = (j > 15 - sh_abs) ? data_sign : data_out[j];
        end
      end else begin
        if (!sh[4]) begin
          data_out = data_in << (sh % 16);
          for (j = 0; j < (sh % 16); j = j+1)
            data_out[j] = data_in[16 - (sh % 16) + j];
          DWF_shifter_tc_tc = data_out;
        end else begin
          sh_abs = -sh;
          data_out = data_in >> sh_abs;
          for (j = 16 - sh_abs; j < 16; j = j+1)
            data_out[j] = data_in[(j + sh_abs) % 16];
          DWF_shifter_tc_tc = data_out;
        end
      end
    end
  endfunction

  // rotate–unsigned base
  function [15:0] shift_uns_uns(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode,
    input        padded_value
  );
    reg [15:0] data_out;
    integer    j;
    begin
      if (sh_mode) begin
        data_out = data_in << sh;
        for (j = 0; j < sh; j = j+1)
          data_out[j] = padded_value;
      end else begin
        data_out = data_in << (sh % 16);
        for (j = 0; j < (sh % 16); j = j+1)
          data_out[j] = data_in[16 - (sh % 16) + j];
      end
      shift_uns_uns = data_out;
    end
  endfunction

  // rotate–signed base
  function [15:0] shift_tc_uns(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode,
    input        padded_value
  );
    reg [15:0] data_out;
    reg [4:0]  sh_abs;
    integer    j;
    begin
      if (sh_mode) begin
        if (!sh[4]) begin
          data_out = data_in << sh;
          for (j = 0; j < sh; j = j+1)
            data_out[j] = padded_value;
        end else begin
          sh_abs = -sh;
          data_out = data_in >> sh_abs;
          for (j = 0; j < sh_abs; j = j+1)
            data_out[15 - j] = padded_value;
        end
      end else begin
        if (!sh[4]) begin
          data_out = data_in << (sh % 16);
          for (j = 0; j < (sh % 16); j = j+1)
            data_out[j] = data_in[16 - (sh % 16) + j];
        end else begin
          sh_abs = -sh;
          data_out = data_in >> sh_abs;
          for (j = 0; j < sh_abs; j = j+1)
            data_out[15 - j] = data_in[sh_abs - 1 - j];
        end
      end
      shift_tc_uns = data_out;
    end
  endfunction

  // rotate–unsigned signed pad
  function [15:0] shift_uns_tc(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode,
    input        padded_value
  );
    reg [15:0] data_out;
    integer    j;
    begin
      if (sh_mode) begin
        data_out = data_in << sh;
        for (j = 0; j < sh; j = j+1)
          data_out[j] = padded_value;
      end else begin
        data_out = data_in << (sh % 16);
        for (j = 0; j < (sh % 16); j = j+1)
          data_out[j] = data_in[16 - (sh % 16) + j];
      end
      shift_uns_tc = data_out;
    end
  endfunction

  // rotate–signed signed pad
  function [15:0] shift_tc_tc(
    input [15:0] data_in,
    input [4:0]  sh,
    input        sh_mode,
    input        padded_value
  );
    reg [15:0] data_out;
    reg [4:0]  sh_abs;
    reg        data_sign;
    integer    j;
    begin
      if (sh_mode) begin
        if (!sh[4]) begin
          data_out = data_in << sh;
          for (j = 0; j < sh; j = j+1)
            data_out[j] = padded_value;
        end else begin
          sh_abs = -sh;
          data_sign = data_in[15];
          data_out = data_in >> sh_abs;
          for (j = 0; j < sh_abs; j = j+1)
            data_out[15 - j] = data_sign;
        end
      end else begin
        if (!sh[4]) begin
          data_out = data_in << (sh % 16);
          for (j = 0; j < (sh % 16); j = j+1)
            data_out[j] = data_in[16 - (sh % 16) + j];
        end else begin
          sh_abs = -sh;
          data_out = data_in >> sh_abs;
          for (j = 0; j < sh_abs; j = j+1)
            data_out[15 - j] = data_in[sh_abs - 1 - j];
        end
      end
      shift_tc_tc = data_out;
    end
  endfunction

  // control signals
  wire [4:0] sh_int       = (0 == 0 || 0 == 1) ? sh     : ~sh;
  wire       data_tc_int  = (0 == 0 || 0 == 1) ? data_tc: ~data_tc;
  wire       sh_tc_int    = (0 == 0 || 0 == 1) ? sh_tc  : ~sh_tc;
  wire       padded_value = (0 == 0 || 0 == 2) ? 1'b0   : 1'b1;

  // no-X state, simple selection
  assign data_out =
    ( sh_tc_int==1'b0 && data_tc_int==1'b0 ) ? shift_uns_uns(data_in, sh_int, sh_mode, padded_value) :
    ( sh_tc_int==1'b0 && data_tc_int==1'b1 ) ? shift_uns_tc (data_in, sh_int, sh_mode, padded_value) :
    ( sh_tc_int==1'b1 && data_tc_int==1'b0 ) ? shift_tc_uns (data_in, sh_int, sh_mode, padded_value) :
                                                shift_tc_tc (data_in, sh_int, sh_mode, padded_value);

endmodule
