`timescale 1ns/1ns
`define DW 64                 // data-path width seen by NIC / mesh

// ==========================================================================
//                           T E S T  B E N C H
// ==========================================================================
module tb_noc_1to1;

    //-----------------------------------------------------------------------
    //  USER-SELECTABLE  SOURCE / DESTINATION  tile coordinates (0‥2)
    //-----------------------------------------------------------------------
    localparam integer USER_SRC_X = 0;   // edit here if desired
    localparam integer USER_SRC_Y = 0;
    localparam integer USER_DST_X = 1;
    localparam integer USER_DST_Y = 1;

    // ======================================================================
    //                        CLOCK  &  RESET
    // ======================================================================
    reg clk, reset;
    initial begin
    clk = 1'b0;
    forever #2 clk = ~clk;          // 250 MHz
    end

    initial begin
    reset = 1'b1;
    #25  reset = 1'b0;
    $display("[%0t] Reset de-asserted", $time);
    end

    // ======================================================================
    //                    NIC ⇄ CMP   B U N D L E S   (9 nodes)
    // ======================================================================
    // addr: 00=data_reg  01=in_full  10=write_data  11=out_full
    reg  [1:0]     nic_addr [0:8];
    reg  [`DW-1:0] nic_di   [0:8];
    wire [`DW-1:0] nic_do   [0:8];
    reg            nic_en   [0:8];
    reg            nic_we   [0:8];

    integer i;
    initial begin
    for (i=0;i<9;i=i+1) begin
        nic_addr[i]=2'b00; nic_di[i]=`DW'd0; nic_en[i]=1'b0; nic_we[i]=1'b0;
    end
    end

    // ----------------------------------------------------------------------
    //  Convenient array-to-scalar wiring (node order: row-major 0..8)
    // ----------------------------------------------------------------------
    // row 0
    wire [1:0]     nic_addr_00 = nic_addr[0];
    wire [1:0]     nic_addr_10 = nic_addr[1];
    wire [1:0]     nic_addr_20 = nic_addr[2];
    wire [1:0]     nic_addr_01 = nic_addr[3];
    wire [1:0]     nic_addr_11 = nic_addr[4];
    wire [1:0]     nic_addr_21 = nic_addr[5];
    wire [1:0]     nic_addr_02 = nic_addr[6];
    wire [1:0]     nic_addr_12 = nic_addr[7];
    wire [1:0]     nic_addr_22 = nic_addr[8];

    wire [`DW-1:0] nic_di_00  = nic_di[0];
    wire [`DW-1:0] nic_di_10  = nic_di[1];
    wire [`DW-1:0] nic_di_20  = nic_di[2];
    wire [`DW-1:0] nic_di_01  = nic_di[3];
    wire [`DW-1:0] nic_di_11  = nic_di[4];
    wire [`DW-1:0] nic_di_21  = nic_di[5];
    wire [`DW-1:0] nic_di_02  = nic_di[6];
    wire [`DW-1:0] nic_di_12  = nic_di[7];
    wire [`DW-1:0] nic_di_22  = nic_di[8];

    wire           nic_En_00  = nic_en[0];
    wire           nic_En_10  = nic_en[1];
    wire           nic_En_20  = nic_en[2];
    wire           nic_En_01  = nic_en[3];
    wire           nic_En_11  = nic_en[4];
    wire           nic_En_21  = nic_en[5];
    wire           nic_En_02  = nic_en[6];
    wire           nic_En_12  = nic_en[7];
    wire           nic_En_22  = nic_en[8];

    wire           nic_WrEn_00 = nic_we[0];
    wire           nic_WrEn_10 = nic_we[1];
    wire           nic_WrEn_20 = nic_we[2];
    wire           nic_WrEn_01 = nic_we[3];
    wire           nic_WrEn_11 = nic_we[4];
    wire           nic_WrEn_21 = nic_we[5];
    wire           nic_WrEn_02 = nic_we[6];
    wire           nic_WrEn_12 = nic_we[7];
    wire           nic_WrEn_22 = nic_we[8];

    // DUT – name it as in your project (cardinal_cmp or cardinal_noc)
    cardinal_noc dut (
    .clk(clk), .reset(reset),

    .nic_addr_00(nic_addr_00), .nic_di_00(nic_di_00),
    .nic_En_00(nic_En_00), .nic_WrEn_00(nic_WrEn_00), .nic_do_00(nic_do[0]),

    .nic_addr_01(nic_addr_01), .nic_di_01(nic_di_01),
    .nic_En_01(nic_En_01), .nic_WrEn_01(nic_WrEn_01), .nic_do_01(nic_do[3]),

    .nic_addr_02(nic_addr_02), .nic_di_02(nic_di_02),
    .nic_En_02(nic_En_02), .nic_WrEn_02(nic_WrEn_02), .nic_do_02(nic_do[6]),

    .nic_addr_10(nic_addr_10), .nic_di_10(nic_di_10),
    .nic_En_10(nic_En_10), .nic_WrEn_10(nic_WrEn_10), .nic_do_10(nic_do[1]),

    .nic_addr_11(nic_addr_11), .nic_di_11(nic_di_11),
    .nic_En_11(nic_En_11), .nic_WrEn_11(nic_WrEn_11), .nic_do_11(nic_do[4]),

    .nic_addr_12(nic_addr_12), .nic_di_12(nic_di_12),
    .nic_En_12(nic_En_12), .nic_WrEn_12(nic_WrEn_12), .nic_do_12(nic_do[7]),

    .nic_addr_20(nic_addr_20), .nic_di_20(nic_di_20),
    .nic_En_20(nic_En_20), .nic_WrEn_20(nic_WrEn_20), .nic_do_20(nic_do[2]),

    .nic_addr_21(nic_addr_21), .nic_di_21(nic_di_21),
    .nic_En_21(nic_En_21), .nic_WrEn_21(nic_WrEn_21), .nic_do_21(nic_do[5]),

    .nic_addr_22(nic_addr_22), .nic_di_22(nic_di_22),
    .nic_En_22(nic_En_22), .nic_WrEn_22(nic_WrEn_22), .nic_do_22(nic_do[8])
    );

    // ======================================================================
    //                          PACKET  BUILDER
    // ======================================================================
    function [`DW-1:0] build_packet;
    input        vc_bit, hdir, vdir;
    input  [3:0] hhop, vhop;
    input [15:0] src_id, data;
    reg   [`DW-1:0] p;
    begin
    p             = {`DW{1'b0}};
    p[63]         = vc_bit;
    p[62]         = hdir;
    p[61]         = vdir;
    p[55:52]      = hhop;
    p[51:48]      = vhop;
    p[47:32]      = src_id;
    p[31:16]      = data;
    build_packet  = p;
    end
    endfunction

    // ======================================================================
    //                        H E L P E R   T A S K S
    // ======================================================================
    task drive_clear;
    begin
    for (i=0;i<9;i=i+1) begin
        nic_en[i]   = 0;
        nic_we[i]   = 0;
        nic_addr[i] = 2'b00;
        nic_di[i]   = `DW'd0;
    end
    end
    endtask

    task nic_write_packet;
    input integer idx;
    input [`DW-1:0] payload;
    begin
    nic_di  [idx] = payload;
    nic_addr[idx] = 2'b10;
    nic_en  [idx] = 1'b1;
    nic_we  [idx] = 1'b1;
    @(posedge clk);
    drive_clear();
    end
    endtask

    task nic_get_full_flag;
    input  integer idx;
    output reg flag;
    begin
    nic_addr[idx] = 2'b01;
    nic_en  [idx] = 1'b1;
    @(posedge clk);
    flag = nic_do[idx][0];
    drive_clear();
    end
    endtask

    task nic_read_packet;
    input  integer idx;
    output [`DW-1:0] data_out;
    begin
    nic_addr[idx] = 2'b00;
    nic_en  [idx] = 1'b1;
    @(posedge clk);
    data_out = nic_do[idx];
    drive_clear();
    end
    endtask

    // ======================================================================
    //                           MAIN  TEST
    // ======================================================================
    integer  src_idx, dst_idx;
    integer  diff_x , diff_y;
    reg      horiz_dir, vert_dir;
    reg [3:0] horiz_hop, vert_hop;
    reg [`DW-1:0] packet;
    integer cycles;
    reg     arrived;

    initial begin : run_one_unicast
    // -----------------------------------------------------------
    src_idx = USER_SRC_Y*3 + USER_SRC_X;
    dst_idx = USER_DST_Y*3 + USER_DST_X;

    diff_x  = (USER_DST_X >= USER_SRC_X) ? (USER_DST_X - USER_SRC_X)
                                            : (USER_SRC_X - USER_DST_X);
    diff_y  = (USER_DST_Y >= USER_SRC_Y) ? (USER_DST_Y - USER_SRC_Y)
                                            : (USER_SRC_Y - USER_DST_Y);

    horiz_dir = (USER_DST_X < USER_SRC_X);   // 0 = right , 1 = left
    vert_dir  = (USER_DST_Y > USER_SRC_Y);   // 0 = south , 1 = north

    horiz_hop = (diff_x==0) ? 4'b0000 : ((4'b0001 << diff_x) - 1);
    vert_hop  = (diff_y==0) ? 4'b0000 : ((4'b0001 << diff_y) - 1);

    packet    = build_packet(1'b0, horiz_dir, vert_dir,
                                horiz_hop, vert_hop, 16'hABCD, 16'hABCD);

    $display("[%0t] SRC=(%0d,%0d) DST=(%0d,%0d)  dir(h,v)=%b,%b hop(h,v)=%b,%b",
                $time, USER_SRC_X, USER_SRC_Y, USER_DST_X, USER_DST_Y,
                horiz_dir, vert_dir, horiz_hop, vert_hop);

    wait(!reset);  #20;

    // inject
    nic_write_packet(src_idx, packet);
    $display("[%0t] Packet written to NIC %0d", $time, src_idx);

    // poll
    cycles  = 0;
    arrived = 0;
    while ((cycles < 400) && (arrived == 0)) begin
        nic_get_full_flag(dst_idx, arrived);
        cycles = cycles + 1;
    end

    if (!arrived) begin
        $display("[%0t] ** TIMEOUT ** NIC %0d never filled", $time, dst_idx);
        $finish;
    end

    // read back
    nic_read_packet(dst_idx, packet);
    $display("[%0t] SUCCESS: NIC %0d got packet 0x%h", $time, dst_idx, packet);

    #40 $finish;
    end

endmodule
`undef DW
