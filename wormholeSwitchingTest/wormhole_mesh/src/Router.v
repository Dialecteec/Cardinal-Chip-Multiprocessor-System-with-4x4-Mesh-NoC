`timescale 1ns/100ps

// Router.v — fully hard-coded widths, no parameters
module Router (
    clk,
    rst,
    // FIFO write enables
    router_in_wr_en_0, router_in_wr_en_1, router_in_wr_en_2, router_in_wr_en_3, router_in_wr_en_4,
    // Back-pressure signals
    router_in_ON_OFF_0, router_in_ON_OFF_1, router_in_ON_OFF_2, router_in_ON_OFF_3, router_in_ON_OFF_4,
    // Incoming flits
    router_in_flit_0, router_in_flit_1, router_in_flit_2, router_in_flit_3, router_in_flit_4,
    // Outgoing flits
    router_out_flit_0, router_out_flit_1, router_out_flit_2, router_out_flit_3, router_out_flit_4,
    // Switch‑allocator write enables
    router_out_wr_en_0, router_out_wr_en_1, router_out_wr_en_2, router_out_wr_en_3, router_out_wr_en_4,
    // One‑cycle delayed full flags
    router_out_full_0, router_out_full_1, router_out_full_2, router_out_full_3, router_out_full_4
);

  // Hard‑coded constants
  // LINK_WIDTH = 8, PORTS = 5, BUFFER_DEPTH = 4, MESH_DIM = 4, ROUTER_ID = 0, OP_SIZE = 3

  input                  clk, rst;

  input                  router_in_wr_en_0;
  input                  router_in_wr_en_1;
  input                  router_in_wr_en_2;
  input                  router_in_wr_en_3;
  input                  router_in_wr_en_4;

  input                  router_in_ON_OFF_0;
  input                  router_in_ON_OFF_1;
  input                  router_in_ON_OFF_2;
  input                  router_in_ON_OFF_3;
  input                  router_in_ON_OFF_4;

  input  [7:0]           router_in_flit_0;
  input  [7:0]           router_in_flit_1;
  input  [7:0]           router_in_flit_2;
  input  [7:0]           router_in_flit_3;
  input  [7:0]           router_in_flit_4;

  output [7:0]           router_out_flit_0;
  output [7:0]           router_out_flit_1;
  output [7:0]           router_out_flit_2;
  output [7:0]           router_out_flit_3;
  output [7:0]           router_out_flit_4;

  output                 router_out_wr_en_0;
  output                 router_out_wr_en_1;
  output                 router_out_wr_en_2;
  output                 router_out_wr_en_3;
  output                 router_out_wr_en_4;

  output reg             router_out_full_0;
  output reg             router_out_full_1;
  output reg             router_out_full_2;
  output reg             router_out_full_3;
  output reg             router_out_full_4;

  // Internal signals
  wire                   fifo_full_0, fifo_full_1, fifo_full_2;
  wire                   fifo_full_3, fifo_full_4;

  wire [7:0]             out_flit_0, out_flit_1, out_flit_2, out_flit_3, out_flit_4;
  wire                   empty_north, empty_east, empty_south, empty_west, empty_local;
  wire                   rd_en_north, rd_en_east, rd_en_south, rd_en_west, rd_en_local;
  wire [2:0]             op_port0, op_port1, op_port2, op_port3, op_port4;

  // Delay full flags by one cycle
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      router_out_full_0 <= 1'b0;
      router_out_full_1 <= 1'b0;
      router_out_full_2 <= 1'b0;
      router_out_full_3 <= 1'b0;
      router_out_full_4 <= 1'b0;
    end else begin
      router_out_full_0 <= fifo_full_0;
      router_out_full_1 <= fifo_full_1;
      router_out_full_2 <= fifo_full_2;
      router_out_full_3 <= fifo_full_3;
      router_out_full_4 <= fifo_full_4;
    end
  end

  // Input FIFOs
  buffer #(
    .DATA_WIDTH(8),
    .RAM_DEPTH (4)
  ) buf0 (
    .rst    (rst),
    .clk    (clk),
    .wr_en  (router_in_wr_en_0),
    .rd_en  (rd_en_north),
    .data_in(router_in_flit_0),
    .data_out(out_flit_0),
    .full   (fifo_full_0),
    .empty  (empty_north)
  );

  buffer #(
    .DATA_WIDTH(8),
    .RAM_DEPTH (4)
  ) buf1 (
    .rst    (rst),
    .clk    (clk),
    .wr_en  (router_in_wr_en_1),
    .rd_en  (rd_en_east),
    .data_in(router_in_flit_1),
    .data_out(out_flit_1),
    .full   (fifo_full_1),
    .empty  (empty_east)
  );

  buffer #(
    .DATA_WIDTH(8),
    .RAM_DEPTH (4)
  ) buf2 (
    .rst    (rst),
    .clk    (clk),
    .wr_en  (router_in_wr_en_2),
    .rd_en  (rd_en_south),
    .data_in(router_in_flit_2),
    .data_out(out_flit_2),
    .full   (fifo_full_2),
    .empty  (empty_south)
  );

  buffer #(
    .DATA_WIDTH(8),
    .RAM_DEPTH (4)
  ) buf3 (
    .rst    (rst),
    .clk    (clk),
    .wr_en  (router_in_wr_en_3),
    .rd_en  (rd_en_west),
    .data_in(router_in_flit_3),
    .data_out(out_flit_3),
    .full   (fifo_full_3),
    .empty  (empty_west)
  );

  buffer #(
    .DATA_WIDTH(8),
    .RAM_DEPTH (4)
  ) buf4 (
    .rst    (rst),
    .clk    (clk),
    .wr_en  (router_in_wr_en_4),
    .rd_en  (rd_en_local),
    .data_in(router_in_flit_4),
    .data_out(out_flit_4),
    .full   (fifo_full_4),
    .empty  (empty_local)
  );

  // Route compute (MESH_DIM=4, ROUTER_ID=0)
  route_compute #(
    .IP_SIZE   (8),
    .OP_SIZE   (3),
    .MESH_DIM  (4),
    .ROUTER_ID (0)
  ) route_compute_inst (
    .clk      (clk),
    .rst      (rst),
    .flit0    (out_flit_0),
    .flit1    (out_flit_1),
    .flit2    (out_flit_2),
    .flit3    (out_flit_3),
    .flit4    (out_flit_4),
    .op_port0 (op_port0),
    .op_port1 (op_port1),
    .op_port2 (op_port2),
    .op_port3 (op_port3),
    .op_port4 (op_port4)
  );

  // Switch allocator (PORTS=5, OP_SIZE=3, FLIT_SIZE=8)
  switch_allocator #(
    .OP_SIZE   (3),
    .NUM_PORTS (5),
    .FLIT_SIZE (8)
  ) switch_allocator_inst (
    .clk                 (clk),
    .rst                 (rst),
    .empty_north         (empty_north),
    .empty_east          (empty_east),
    .empty_south         (empty_south),
    .empty_west          (empty_west),
    .empty_local         (empty_local),
    .ON_OFF_signal_north (router_in_ON_OFF_0),
    .ON_OFF_signal_east  (router_in_ON_OFF_1),
    .ON_OFF_signal_south (router_in_ON_OFF_2),
    .ON_OFF_signal_west  (router_in_ON_OFF_3),
    .ON_OFF_signal_local (router_in_ON_OFF_4),
    .op_port0            (op_port0),
    .op_port1            (op_port1),
    .op_port2            (op_port2),
    .op_port3            (op_port3),
    .op_port4            (op_port4),
    .wr_en_north         (router_out_wr_en_0),
    .wr_en_east          (router_out_wr_en_1),
    .wr_en_south         (router_out_wr_en_2),
    .wr_en_west          (router_out_wr_en_3),
    .wr_en_local         (router_out_wr_en_4),
    .in_buf_north        (out_flit_0),
    .in_buf_east         (out_flit_1),
    .in_buf_south        (out_flit_2),
    .in_buf_west         (out_flit_3),
    .in_buf_local        (out_flit_4),
    .op_flit_north       (router_out_flit_0),
    .op_flit_east        (router_out_flit_1),
    .op_flit_south       (router_out_flit_2),
    .op_flit_west        (router_out_flit_3),
    .op_flit_local       (router_out_flit_4),
    .rd_en_north         (rd_en_north),
    .rd_en_east          (rd_en_east),
    .rd_en_south         (rd_en_south),
    .rd_en_west          (rd_en_west),
    .rd_en_local         (rd_en_local)
  );

endmodule
