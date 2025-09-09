`timescale 1ns/100ps

// Generic 2D‑mesh NoC generator with flattened IO
module mesh_general #(
    parameter MESH_COLUMNS = 4,
    parameter MESH_ROWS    = 4,
    parameter LINK_WIDTHS  = 8,
    parameter BUFFER_DEPTH = 4,
    parameter PORTS        = 5
)(
    input  clk,
    input  rst,

    // Flattened per‑node inputs
    input  [LINK_WIDTHS*MESH_ROWS*MESH_COLUMNS-1:0] local_in_flit_flat,
    input  [MESH_ROWS*MESH_COLUMNS-1:0]            local_wr_en_flat,
    input  [MESH_ROWS*MESH_COLUMNS-1:0]            local_on_off_flat,

    // Flattened per‑node outputs
    output [LINK_WIDTHS*MESH_ROWS*MESH_COLUMNS-1:0] local_out_flit_flat,
    output [MESH_ROWS*MESH_COLUMNS-1:0]            router_out_full_flat
);

  // Derived parameters
  localparam NUM_ROUTERS = MESH_ROWS * MESH_COLUMNS;
  localparam VERTICAL    = MESH_ROWS * (MESH_COLUMNS + 1);

  //-------------------------------------------------------------------------
  // Internal unpacked nets
  //-------------------------------------------------------------------------
  wire [LINK_WIDTHS-1:0] local_in_flit   [0:NUM_ROUTERS-1];
  wire                  local_wr_en     [0:NUM_ROUTERS-1];
  wire                  local_on_off    [0:NUM_ROUTERS-1];
  wire [LINK_WIDTHS-1:0] local_out_flit  [0:NUM_ROUTERS-1];
  wire                  router_out_full [0:NUM_ROUTERS-1];

  genvar i;
  generate
    for (i = 0; i < NUM_ROUTERS; i = i + 1) begin : UNPACK_IO
      assign local_in_flit[i]    = local_in_flit_flat[(i+1)*LINK_WIDTHS-1 -: LINK_WIDTHS];
      assign local_wr_en[i]      = local_wr_en_flat[i];
      assign local_on_off[i]     = local_on_off_flat[i];
      assign local_out_flit_flat[(i+1)*LINK_WIDTHS-1 -: LINK_WIDTHS] = local_out_flit[i];
      assign router_out_full_flat[i]                               = router_out_full[i];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Cross‑links and control nets
  //-------------------------------------------------------------------------
  wire [LINK_WIDTHS-1:0] l_r_flit [0:NUM_ROUTERS];
  wire [LINK_WIDTHS-1:0] r_l_flit [0:NUM_ROUTERS];
  wire [LINK_WIDTHS-1:0] b_t_flit [0:VERTICAL-1];
  wire [LINK_WIDTHS-1:0] t_b_flit [0:VERTICAL-1];

  wire l_r_wr_en    [0:NUM_ROUTERS];
  wire r_l_wr_en    [0:NUM_ROUTERS];
  wire b_t_wr_en    [0:VERTICAL-1];
  wire t_b_wr_en    [0:VERTICAL-1];

  wire l_r_buf_ctrl [0:NUM_ROUTERS];
  wire r_l_buf_ctrl [0:NUM_ROUTERS];
  wire b_t_buf_ctrl [0:VERTICAL-1];
  wire t_b_buf_ctrl [0:VERTICAL-1];

  //-------------------------------------------------------------------------
  // Instantiate mesh of routers
  //-------------------------------------------------------------------------
  genvar row, column;
  generate
    for (row = 0; row < MESH_ROWS; row = row + 1) begin : GEN_ROW
      for (column = 0; column < MESH_COLUMNS; column = column + 1) begin : GEN_COL
        Router #(
          .LINK_WIDTH   (LINK_WIDTHS),
          .PORTS        (PORTS),
          .BUFFER_DEPTH (BUFFER_DEPTH),
          .MESH_DIM     (MESH_ROWS),
          .ROUTER_ID    (column + MESH_COLUMNS*row)
        ) mesh_router_inst (
          .clk(clk),
          .rst(rst),

          // Write Enables
          .router_out_wr_en_0(b_t_wr_en[column + MESH_COLUMNS*row + MESH_ROWS]),
          .router_out_wr_en_1(l_r_wr_en[column + MESH_COLUMNS*row + 1]),
          .router_out_wr_en_2(t_b_wr_en[column + MESH_COLUMNS*row]),
          .router_out_wr_en_3(r_l_wr_en[column + MESH_COLUMNS*row]),

          // Incoming flits
          .router_in_flit_0  (t_b_flit[column + MESH_COLUMNS*row + MESH_ROWS]),
          .router_in_flit_1  (r_l_flit[column + MESH_COLUMNS*row + 1]),
          .router_in_flit_2  (b_t_flit[column + MESH_COLUMNS*row]),
          .router_in_flit_3  (l_r_flit[column + MESH_COLUMNS*row]),
          .router_in_flit_4  (local_in_flit[column + MESH_COLUMNS*row]),

          // Outgoing flits
          .router_out_flit_0 (b_t_flit[column + MESH_COLUMNS*row + MESH_ROWS]),
          .router_out_flit_1 (l_r_flit[column + MESH_COLUMNS*row + 1]),
          .router_out_flit_2 (t_b_flit[column + MESH_COLUMNS*row]),
          .router_out_flit_3 (r_l_flit[column + MESH_COLUMNS*row]),
          .router_out_flit_4 (local_out_flit[column + MESH_COLUMNS*row]),

          // Input write‑en
          .router_in_wr_en_0 (t_b_wr_en[column + MESH_COLUMNS*row + MESH_ROWS]),
          .router_in_wr_en_1 (r_l_wr_en[column + MESH_COLUMNS*row + 1]),
          .router_in_wr_en_2 (b_t_wr_en[column + MESH_COLUMNS*row]),
          .router_in_wr_en_3 (l_r_wr_en[column + MESH_COLUMNS*row]),
          .router_in_wr_en_4 (local_wr_en[column + MESH_COLUMNS*row]),

          // Buffer‑full outputs
          .router_out_full_0 (b_t_buf_ctrl[column + MESH_COLUMNS*row + MESH_ROWS]),
          .router_out_full_1 (l_r_buf_ctrl[column + MESH_COLUMNS*row + 1]),
          .router_out_full_2 (t_b_buf_ctrl[column + MESH_COLUMNS*row]),
          .router_out_full_3 (r_l_buf_ctrl[column + MESH_COLUMNS*row]),
          .router_out_full_4 (router_out_full[column + MESH_COLUMNS*row]),

          // Backpressure
          .router_in_ON_OFF_0(t_b_buf_ctrl[column + MESH_COLUMNS*row + MESH_ROWS]),
          .router_in_ON_OFF_1(r_l_buf_ctrl[column + MESH_COLUMNS*row + 1]),
          .router_in_ON_OFF_2(b_t_buf_ctrl[column + MESH_COLUMNS*row]),
          .router_in_ON_OFF_3(l_r_buf_ctrl[column + MESH_COLUMNS*row])
        );
      end
    end
  endgenerate

endmodule
