`define DATA_WIDTH 64

module cardinal_noc(
    input                    clk,
    input                    reset,

    //----------------------------------------------------------------------
    // NIC interface for 9 nodes (3×3)
    //----------------------------------------------------------------------
    // node00
    input      [0:1]         nic_addr_00,
    input      [0:`DATA_WIDTH-1] nic_di_00,
    input                    nic_En_00,
    input                    nic_WrEn_00,
    output     [0:`DATA_WIDTH-1] nic_do_00,

    // node01
    input      [0:1]         nic_addr_01,
    input      [0:`DATA_WIDTH-1] nic_di_01,
    input                    nic_En_01,
    input                    nic_WrEn_01,
    output     [0:`DATA_WIDTH-1] nic_do_01,

    // node02
    input      [0:1]         nic_addr_02,
    input      [0:`DATA_WIDTH-1] nic_di_02,
    input                    nic_En_02,
    input                    nic_WrEn_02,
    output     [0:`DATA_WIDTH-1] nic_do_02,

    // node10
    input      [0:1]         nic_addr_10,
    input      [0:`DATA_WIDTH-1] nic_di_10,
    input                    nic_En_10,
    input                    nic_WrEn_10,
    output     [0:`DATA_WIDTH-1] nic_do_10,

    // node11
    input      [0:1]         nic_addr_11,
    input      [0:`DATA_WIDTH-1] nic_di_11,
    input                    nic_En_11,
    input                    nic_WrEn_11,
    output     [0:`DATA_WIDTH-1] nic_do_11,

    // node12
    input      [0:1]         nic_addr_12,
    input      [0:`DATA_WIDTH-1] nic_di_12,
    input                    nic_En_12,
    input                    nic_WrEn_12,
    output     [0:`DATA_WIDTH-1] nic_do_12,

    // node20
    input      [0:1]         nic_addr_20,
    input      [0:`DATA_WIDTH-1] nic_di_20,
    input                    nic_En_20,
    input                    nic_WrEn_20,
    output     [0:`DATA_WIDTH-1] nic_do_20,

    // node21
    input      [0:1]         nic_addr_21,
    input      [0:`DATA_WIDTH-1] nic_di_21,
    input                    nic_En_21,
    input                    nic_WrEn_21,
    output     [0:`DATA_WIDTH-1] nic_do_21,

    // node22
    input      [0:1]         nic_addr_22,
    input      [0:`DATA_WIDTH-1] nic_di_22,
    input                    nic_En_22,
    input                    nic_WrEn_22,
    output     [0:`DATA_WIDTH-1] nic_do_22
);

//------------------------------------------------------------------------------
// Internal wires between NIC and mesh
//------------------------------------------------------------------------------
// node00
wire       net_si_00, net_ri_00, net_polarity_00;
wire       net_so_00, net_ro_00;
wire [0:`DATA_WIDTH-1] net_di_00, net_do_00;

// node01
wire       net_si_01, net_ri_01, net_polarity_01;
wire       net_so_01, net_ro_01;
wire [0:`DATA_WIDTH-1] net_di_01, net_do_01;

// node02
wire       net_si_02, net_ri_02, net_polarity_02;
wire       net_so_02, net_ro_02;
wire [0:`DATA_WIDTH-1] net_di_02, net_do_02;

// node10
wire       net_si_10, net_ri_10, net_polarity_10;
wire       net_so_10, net_ro_10;
wire [0:`DATA_WIDTH-1] net_di_10, net_do_10;

// node11
wire       net_si_11, net_ri_11, net_polarity_11;
wire       net_so_11, net_ro_11;
wire [0:`DATA_WIDTH-1] net_di_11, net_do_11;

// node12
wire       net_si_12, net_ri_12, net_polarity_12;
wire       net_so_12, net_ro_12;
wire [0:`DATA_WIDTH-1] net_di_12, net_do_12;

// node20
wire       net_si_20, net_ri_20, net_polarity_20;
wire       net_so_20, net_ro_20;
wire [0:`DATA_WIDTH-1] net_di_20, net_do_20;

// node21
wire       net_si_21, net_ri_21, net_polarity_21;
wire       net_so_21, net_ro_21;
wire [0:`DATA_WIDTH-1] net_di_21, net_do_21;

// node22
wire       net_si_22, net_ri_22, net_polarity_22;
wire       net_so_22, net_ro_22;
wire [0:`DATA_WIDTH-1] net_di_22, net_do_22;


// 16 NIC instantiations (one per node)
    gold_nic nic_00(
        .clk(clk), .reset(reset),
        .addr(nic_addr_00),
        .d_in(nic_di_00),
        .d_out(nic_do_00),
        .nicEn(nic_En_00),
        .nicEnWr(nic_WrEn_00),
        // NoC side
        .net_si(net_si_00),
        .net_ri(net_ri_00),
        .net_di(net_di_00),
        .net_so(net_so_00),
        .net_ro(net_ro_00),
        .net_do(net_do_00),
        .net_polarity(net_polarity_00)
    );

    gold_nic nic_01(
        .clk(clk), .reset(reset),
        .addr(nic_addr_01),
        .d_in(nic_di_01),
        .d_out(nic_do_01),
        .nicEn(nic_En_01),
        .nicEnWr(nic_WrEn_01),
        .net_si(net_si_01),
        .net_ri(net_ri_01),
        .net_di(net_di_01),
        .net_so(net_so_01),
        .net_ro(net_ro_01),
        .net_do(net_do_01),
        .net_polarity(net_polarity_01)
    );

    gold_nic nic_02(
        .clk(clk), .reset(reset),
        .addr(nic_addr_02),
        .d_in(nic_di_02),
        .d_out(nic_do_02),
        .nicEn(nic_En_02),
        .nicEnWr(nic_WrEn_02),
        .net_si(net_si_02),
        .net_ri(net_ri_02),
        .net_di(net_di_02),
        .net_so(net_so_02),
        .net_ro(net_ro_02),
        .net_do(net_do_02),
        .net_polarity(net_polarity_02)
    );

    gold_nic nic_10(
        .clk(clk), .reset(reset),
        .addr(nic_addr_10),
        .d_in(nic_di_10),
        .d_out(nic_do_10),
        .nicEn(nic_En_10),
        .nicEnWr(nic_WrEn_10),
        .net_si(net_si_10),
        .net_ri(net_ri_10),
        .net_di(net_di_10),
        .net_so(net_so_10),
        .net_ro(net_ro_10),
        .net_do(net_do_10),
        .net_polarity(net_polarity_10)
    );

    gold_nic nic_11(
        .clk(clk), .reset(reset),
        .addr(nic_addr_11),
        .d_in(nic_di_11),
        .d_out(nic_do_11),
        .nicEn(nic_En_11),
        .nicEnWr(nic_WrEn_11),
        .net_si(net_si_11),
        .net_ri(net_ri_11),
        .net_di(net_di_11),
        .net_so(net_so_11),
        .net_ro(net_ro_11),
        .net_do(net_do_11),
        .net_polarity(net_polarity_11)
    );

    gold_nic nic_12(
        .clk(clk), .reset(reset),
        .addr(nic_addr_12),
        .d_in(nic_di_12),
        .d_out(nic_do_12),
        .nicEn(nic_En_12),
        .nicEnWr(nic_WrEn_12),
        .net_si(net_si_12),
        .net_ri(net_ri_12),
        .net_di(net_di_12),
        .net_so(net_so_12),
        .net_ro(net_ro_12),
        .net_do(net_do_12),
        .net_polarity(net_polarity_12)
    );

    gold_nic nic_20(
        .clk(clk), .reset(reset),
        .addr(nic_addr_20),
        .d_in(nic_di_20),
        .d_out(nic_do_20),
        .nicEn(nic_En_20),
        .nicEnWr(nic_WrEn_20),
        .net_si(net_si_20),
        .net_ri(net_ri_20),
        .net_di(net_di_20),
        .net_so(net_so_20),
        .net_ro(net_ro_20),
        .net_do(net_do_20),
        .net_polarity(net_polarity_20)
    );

    gold_nic nic_21(
        .clk(clk), .reset(reset),
        .addr(nic_addr_21),
        .d_in(nic_di_21),
        .d_out(nic_do_21),
        .nicEn(nic_En_21),
        .nicEnWr(nic_WrEn_21),
        .net_si(net_si_21),
        .net_ri(net_ri_21),
        .net_di(net_di_21),
        .net_so(net_so_21),
        .net_ro(net_ro_21),
        .net_do(net_do_21),
        .net_polarity(net_polarity_21)
    );

    gold_nic nic_22(
        .clk(clk), .reset(reset),
        .addr(nic_addr_22),
        .d_in(nic_di_22),
        .d_out(nic_do_22),
        .nicEn(nic_En_22),
        .nicEnWr(nic_WrEn_22),
        .net_si(net_si_22),
        .net_ri(net_ri_22),
        .net_di(net_di_22),
        .net_so(net_so_22),
        .net_ro(net_ro_22),
        .net_do(net_do_22),
        .net_polarity(net_polarity_22)
    );


// 3×3 mesh instantiation
gold_mesh #(.PACKET_SIZE(`DATA_WIDTH)) mesh_0 (
    .clk(clk),
    .reset(reset),

    // row y=0
    .node00_pesi(net_so_00), .node00_pero(net_ri_00), .node00_pedi(net_do_00), .node00_peri(net_ro_00), .node00_peso(net_si_00), .node00_pedo(net_di_00), .node00_polarity(net_polarity_00),
    .node10_pesi(net_so_10), .node10_pero(net_ri_10), .node10_pedi(net_do_10), .node10_peri(net_ro_10), .node10_peso(net_si_10), .node10_pedo(net_di_10), .node10_polarity(net_polarity_10),
    .node20_pesi(net_so_20), .node20_pero(net_ri_20), .node20_pedi(net_do_20), .node20_peri(net_ro_20), .node20_peso(net_si_20), .node20_pedo(net_di_20), .node20_polarity(net_polarity_20),

    // row y=1
    .node01_pesi(net_so_01), .node01_pero(net_ri_01), .node01_pedi(net_do_01), .node01_peri(net_ro_01), .node01_peso(net_si_01), .node01_pedo(net_di_01), .node01_polarity(net_polarity_01),
    .node11_pesi(net_so_11), .node11_pero(net_ri_11), .node11_pedi(net_do_11), .node11_peri(net_ro_11), .node11_peso(net_si_11), .node11_pedo(net_di_11), .node11_polarity(net_polarity_11),
    .node21_pesi(net_so_21), .node21_pero(net_ri_21), .node21_pedi(net_do_21), .node21_peri(net_ro_21), .node21_peso(net_si_21), .node21_pedo(net_di_21), .node21_polarity(net_polarity_21),

    // row y=2
    .node02_pesi(net_so_02), .node02_pero(net_ri_02), .node02_pedi(net_do_02), .node02_peri(net_ro_02), .node02_peso(net_si_02), .node02_pedo(net_di_02), .node02_polarity(net_polarity_02),
    .node12_pesi(net_so_12), .node12_pero(net_ri_12), .node12_pedi(net_do_12), .node12_peri(net_ro_12), .node12_peso(net_si_12), .node12_pedo(net_di_12), .node12_polarity(net_polarity_12),
    .node22_pesi(net_so_22), .node22_pero(net_ri_22), .node22_pedi(net_do_22), .node22_peri(net_ro_22), .node22_peso(net_si_22), .node22_pedo(net_di_22), .node22_polarity(net_polarity_22)
);

endmodule

`undef DATA_WIDTH