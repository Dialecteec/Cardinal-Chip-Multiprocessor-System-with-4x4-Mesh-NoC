`define DATA_WIDTH 64
`define INST_WIDTH 32
`define ADDR_WIDTH 32

module cardinal_cmp(
    input clk,
    input reset,

    //----------------------------------------------------------------------
    // Instruction inputs for 9 nodes (3×3)
    //----------------------------------------------------------------------
    input [0:`INST_WIDTH-1] node00_inst_in,
    input [0:`INST_WIDTH-1] node01_inst_in,
    input [0:`INST_WIDTH-1] node02_inst_in,

    input [0:`INST_WIDTH-1] node10_inst_in,
    input [0:`INST_WIDTH-1] node11_inst_in,
    input [0:`INST_WIDTH-1] node12_inst_in,

    input [0:`INST_WIDTH-1] node20_inst_in,
    input [0:`INST_WIDTH-1] node21_inst_in,
    input [0:`INST_WIDTH-1] node22_inst_in,

    //----------------------------------------------------------------------
    // Data inputs for 9 nodes
    //----------------------------------------------------------------------
    input [0:`DATA_WIDTH-1] node00_d_in,
    input [0:`DATA_WIDTH-1] node01_d_in,
    input [0:`DATA_WIDTH-1] node02_d_in,

    input [0:`DATA_WIDTH-1] node10_d_in,
    input [0:`DATA_WIDTH-1] node11_d_in,
    input [0:`DATA_WIDTH-1] node12_d_in,

    input [0:`DATA_WIDTH-1] node20_d_in,
    input [0:`DATA_WIDTH-1] node21_d_in,
    input [0:`DATA_WIDTH-1] node22_d_in,

    //----------------------------------------------------------------------
    // CPU outputs for 9 nodes
    //----------------------------------------------------------------------
    output [0:`ADDR_WIDTH-1] node00_pc_out,
    output [0:`ADDR_WIDTH-1] node01_pc_out,
    output [0:`ADDR_WIDTH-1] node02_pc_out,

    output [0:`ADDR_WIDTH-1] node10_pc_out,
    output [0:`ADDR_WIDTH-1] node11_pc_out,
    output [0:`ADDR_WIDTH-1] node12_pc_out,

    output [0:`ADDR_WIDTH-1] node20_pc_out,
    output [0:`ADDR_WIDTH-1] node21_pc_out,
    output [0:`ADDR_WIDTH-1] node22_pc_out,

    output [0:`DATA_WIDTH-1] node00_d_out,
    output [0:`DATA_WIDTH-1] node01_d_out,
    output [0:`DATA_WIDTH-1] node02_d_out,

    output [0:`DATA_WIDTH-1] node10_d_out,
    output [0:`DATA_WIDTH-1] node11_d_out,
    output [0:`DATA_WIDTH-1] node12_d_out,

    output [0:`DATA_WIDTH-1] node20_d_out,
    output [0:`DATA_WIDTH-1] node21_d_out,
    output [0:`DATA_WIDTH-1] node22_d_out,

    output [0:`ADDR_WIDTH-1] node00_addr_out,
    output [0:`ADDR_WIDTH-1] node01_addr_out,
    output [0:`ADDR_WIDTH-1] node02_addr_out,

    output [0:`ADDR_WIDTH-1] node10_addr_out,
    output [0:`ADDR_WIDTH-1] node11_addr_out,
    output [0:`ADDR_WIDTH-1] node12_addr_out,

    output [0:`ADDR_WIDTH-1] node20_addr_out,
    output [0:`ADDR_WIDTH-1] node21_addr_out,
    output [0:`ADDR_WIDTH-1] node22_addr_out,

    output node00_memEn, node01_memEn, node02_memEn,
    output node10_memEn, node11_memEn, node12_memEn,
    output node20_memEn, node21_memEn, node22_memEn,

    output node00_memWrEn, node01_memWrEn, node02_memWrEn,
    output node10_memWrEn, node11_memWrEn, node12_memWrEn,
    output node20_memWrEn, node21_memWrEn, node22_memWrEn
);

// Wires between CPU <-> NIC for 9 nodes
wire [0:`DATA_WIDTH-1] nic_do_00, nic_do_01, nic_do_02;
wire [0:`DATA_WIDTH-1] nic_do_10, nic_do_11, nic_do_12;
wire [0:`DATA_WIDTH-1] nic_do_20, nic_do_21, nic_do_22;

wire [0:`DATA_WIDTH-1] nic_di_00, nic_di_01, nic_di_02;
wire [0:`DATA_WIDTH-1] nic_di_10, nic_di_11, nic_di_12;
wire [0:`DATA_WIDTH-1] nic_di_20, nic_di_21, nic_di_22;

wire nic_En_00, nic_En_01, nic_En_02;
wire nic_En_10, nic_En_11, nic_En_12;
wire nic_En_20, nic_En_21, nic_En_22;

wire nic_WrEn_00, nic_WrEn_01, nic_WrEn_02;
wire nic_WrEn_10, nic_WrEn_11, nic_WrEn_12;
wire nic_WrEn_20, nic_WrEn_21, nic_WrEn_22;

wire [0:1] nic_addr_00, nic_addr_01, nic_addr_02;
wire [0:1] nic_addr_10, nic_addr_11, nic_addr_12;
wire [0:1] nic_addr_20, nic_addr_21, nic_addr_22;

// Wires between NIC <-> mesh
wire net_so_00, net_so_01, net_so_02;
wire net_so_10, net_so_11, net_so_12;
wire net_so_20, net_so_21, net_so_22;

wire net_ro_00, net_ro_01, net_ro_02;
wire net_ro_10, net_ro_11, net_ro_12;
wire net_ro_20, net_ro_21, net_ro_22;

wire [0:`DATA_WIDTH-1] net_do_00, net_do_01, net_do_02;
wire [0:`DATA_WIDTH-1] net_do_10, net_do_11, net_do_12;
wire [0:`DATA_WIDTH-1] net_do_20, net_do_21, net_do_22;

wire net_si_00, net_si_01, net_si_02;
wire net_si_10, net_si_11, net_si_12;
wire net_si_20, net_si_21, net_si_22;

wire net_ri_00, net_ri_01, net_ri_02;
wire net_ri_10, net_ri_11, net_ri_12;
wire net_ri_20, net_ri_21, net_ri_22;

wire [0:`DATA_WIDTH-1] net_di_00, net_di_01, net_di_02;
wire [0:`DATA_WIDTH-1] net_di_10, net_di_11, net_di_12;
wire [0:`DATA_WIDTH-1] net_di_20, net_di_21, net_di_22;

wire net_polarity_00, net_polarity_01, net_polarity_02;
wire net_polarity_10, net_polarity_11, net_polarity_12;
wire net_polarity_20, net_polarity_21, net_polarity_22;


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



// 16 CPU instantiations (one per node)
    // CPU (0,0)
    cardinal_cpu processor_00(
        .clk(clk),
        .reset(reset),
        // Instruction side
        .instr_addr(node00_pc_out),
        .instr_in(node00_inst_in),
        // DMEM side
        .dmem_addr(node00_addr_out),
        .dmem_data_out(node00_d_out),
        .dmem_data_in(node00_d_in),
        .dmem_En(node00_memEn),
        .dmem_WrEn(node00_memWrEn),
        // NIC side
        .nic_addr(nic_addr_00),
        .nic_data_out(nic_di_00),
        .nic_data_in(nic_do_00),
        .nic_En(nic_En_00),
        .nic_WrEn(nic_WrEn_00)
    );

    // CPU (0,1)
    cardinal_cpu processor_01(
        .clk(clk),
        .reset(reset),
        .instr_addr(node01_pc_out),
        .instr_in(node01_inst_in),
        .dmem_addr(node01_addr_out),
        .dmem_data_out(node01_d_out),
        .dmem_data_in(node01_d_in),
        .dmem_En(node01_memEn),
        .dmem_WrEn(node01_memWrEn),
        .nic_addr(nic_addr_01),
        .nic_data_out(nic_di_01),
        .nic_data_in(nic_do_01),
        .nic_En(nic_En_01),
        .nic_WrEn(nic_WrEn_01)
    );

    // CPU (0,2)
    cardinal_cpu processor_02(
        .clk(clk),
        .reset(reset),
        .instr_addr(node02_pc_out),
        .instr_in(node02_inst_in),
        .dmem_addr(node02_addr_out),
        .dmem_data_out(node02_d_out),
        .dmem_data_in(node02_d_in),
        .dmem_En(node02_memEn),
        .dmem_WrEn(node02_memWrEn),
        .nic_addr(nic_addr_02),
        .nic_data_out(nic_di_02),
        .nic_data_in(nic_do_02),
        .nic_En(nic_En_02),
        .nic_WrEn(nic_WrEn_02)
    );

    // CPU (1,0)
    cardinal_cpu processor_10(
        .clk(clk),
        .reset(reset),
        .instr_addr(node10_pc_out),
        .instr_in(node10_inst_in),
        .dmem_addr(node10_addr_out),
        .dmem_data_out(node10_d_out),
        .dmem_data_in(node10_d_in),
        .dmem_En(node10_memEn),
        .dmem_WrEn(node10_memWrEn),
        .nic_addr(nic_addr_10),
        .nic_data_out(nic_di_10),
        .nic_data_in(nic_do_10),
        .nic_En(nic_En_10),
        .nic_WrEn(nic_WrEn_10)
    );

    // CPU (1,1)
    cardinal_cpu processor_11(
        .clk(clk),
        .reset(reset),
        .instr_addr(node11_pc_out),
        .instr_in(node11_inst_in),
        .dmem_addr(node11_addr_out),
        .dmem_data_out(node11_d_out),
        .dmem_data_in(node11_d_in),
        .dmem_En(node11_memEn),
        .dmem_WrEn(node11_memWrEn),
        .nic_addr(nic_addr_11),
        .nic_data_out(nic_di_11),
        .nic_data_in(nic_do_11),
        .nic_En(nic_En_11),
        .nic_WrEn(nic_WrEn_11)
    );

    // CPU (1,2)
    cardinal_cpu processor_12(
        .clk(clk),
        .reset(reset),
        .instr_addr(node12_pc_out),
        .instr_in(node12_inst_in),
        .dmem_addr(node12_addr_out),
        .dmem_data_out(node12_d_out),
        .dmem_data_in(node12_d_in),
        .dmem_En(node12_memEn),
        .dmem_WrEn(node12_memWrEn),
        .nic_addr(nic_addr_12),
        .nic_data_out(nic_di_12),
        .nic_data_in(nic_do_12),
        .nic_En(nic_En_12),
        .nic_WrEn(nic_WrEn_12)
    );

    // CPU (2,0)
    cardinal_cpu processor_20(
        .clk(clk),
        .reset(reset),
        .instr_addr(node20_pc_out),
        .instr_in(node20_inst_in),
        .dmem_addr(node20_addr_out),
        .dmem_data_out(node20_d_out),
        .dmem_data_in(node20_d_in),
        .dmem_En(node20_memEn),
        .dmem_WrEn(node20_memWrEn),
        .nic_addr(nic_addr_20),
        .nic_data_out(nic_di_20),
        .nic_data_in(nic_do_20),
        .nic_En(nic_En_20),
        .nic_WrEn(nic_WrEn_20)
    );

    // CPU (2,1)
    cardinal_cpu processor_21(
        .clk(clk),
        .reset(reset),
        .instr_addr(node21_pc_out),
        .instr_in(node21_inst_in),
        .dmem_addr(node21_addr_out),
        .dmem_data_out(node21_d_out),
        .dmem_data_in(node21_d_in),
        .dmem_En(node21_memEn),
        .dmem_WrEn(node21_memWrEn),
        .nic_addr(nic_addr_21),
        .nic_data_out(nic_di_21),
        .nic_data_in(nic_do_21),
        .nic_En(nic_En_21),
        .nic_WrEn(nic_WrEn_21)
    );

    // CPU (2,2)
    cardinal_cpu processor_22(
        .clk(clk),
        .reset(reset),
        .instr_addr(node22_pc_out),
        .instr_in(node22_inst_in),
        .dmem_addr(node22_addr_out),
        .dmem_data_out(node22_d_out),
        .dmem_data_in(node22_d_in),
        .dmem_En(node22_memEn),
        .dmem_WrEn(node22_memWrEn),
        .nic_addr(nic_addr_22),
        .nic_data_out(nic_di_22),
        .nic_data_in(nic_do_22),
        .nic_En(nic_En_22),
        .nic_WrEn(nic_WrEn_22)
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
`undef INST_WIDTH
`undef ADDR_WIDTH