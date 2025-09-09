`define DATA_WIDTH 64
`define INST_WIDTH 32
`define ADDR_WIDTH 32

module cardinal_cmp(
    input clk,
    input reset,

    //----------------------------------------------------------------------
    // Instruction inputs for 16 nodes
    //----------------------------------------------------------------------
    input [0:`INST_WIDTH - 1] node00_inst_in,
    input [0:`INST_WIDTH - 1] node01_inst_in,
    input [0:`INST_WIDTH - 1] node02_inst_in,
    input [0:`INST_WIDTH - 1] node03_inst_in,

    input [0:`INST_WIDTH - 1] node10_inst_in,
    input [0:`INST_WIDTH - 1] node11_inst_in,
    input [0:`INST_WIDTH - 1] node12_inst_in,
    input [0:`INST_WIDTH - 1] node13_inst_in,

    input [0:`INST_WIDTH - 1] node20_inst_in,
    input [0:`INST_WIDTH - 1] node21_inst_in,
    input [0:`INST_WIDTH - 1] node22_inst_in,
    input [0:`INST_WIDTH - 1] node23_inst_in,

    input [0:`INST_WIDTH - 1] node30_inst_in,
    input [0:`INST_WIDTH - 1] node31_inst_in,
    input [0:`INST_WIDTH - 1] node32_inst_in,
    input [0:`INST_WIDTH - 1] node33_inst_in,

    //----------------------------------------------------------------------
    // Data inputs for 16 nodes
    //----------------------------------------------------------------------
    input [0:`DATA_WIDTH - 1] node00_d_in,
    input [0:`DATA_WIDTH - 1] node01_d_in,
    input [0:`DATA_WIDTH - 1] node02_d_in,
    input [0:`DATA_WIDTH - 1] node03_d_in,

    input [0:`DATA_WIDTH - 1] node10_d_in,
    input [0:`DATA_WIDTH - 1] node11_d_in,
    input [0:`DATA_WIDTH - 1] node12_d_in,
    input [0:`DATA_WIDTH - 1] node13_d_in,

    input [0:`DATA_WIDTH - 1] node20_d_in,
    input [0:`DATA_WIDTH - 1] node21_d_in,
    input [0:`DATA_WIDTH - 1] node22_d_in,
    input [0:`DATA_WIDTH - 1] node23_d_in,

    input [0:`DATA_WIDTH - 1] node30_d_in,
    input [0:`DATA_WIDTH - 1] node31_d_in,
    input [0:`DATA_WIDTH - 1] node32_d_in,
    input [0:`DATA_WIDTH - 1] node33_d_in,

    //----------------------------------------------------------------------
    // CPU outputs: PC out, data out, address out, memEn, memWrEn for 16 nodes
    //----------------------------------------------------------------------
    output [0:`ADDR_WIDTH - 1] node00_pc_out,
    output [0:`ADDR_WIDTH - 1] node01_pc_out,
    output [0:`ADDR_WIDTH - 1] node02_pc_out,
    output [0:`ADDR_WIDTH - 1] node03_pc_out,

    output [0:`ADDR_WIDTH - 1] node10_pc_out,
    output [0:`ADDR_WIDTH - 1] node11_pc_out,
    output [0:`ADDR_WIDTH - 1] node12_pc_out,
    output [0:`ADDR_WIDTH - 1] node13_pc_out,

    output [0:`ADDR_WIDTH - 1] node20_pc_out,
    output [0:`ADDR_WIDTH - 1] node21_pc_out,
    output [0:`ADDR_WIDTH - 1] node22_pc_out,
    output [0:`ADDR_WIDTH - 1] node23_pc_out,

    output [0:`ADDR_WIDTH - 1] node30_pc_out,
    output [0:`ADDR_WIDTH - 1] node31_pc_out,
    output [0:`ADDR_WIDTH - 1] node32_pc_out,
    output [0:`ADDR_WIDTH - 1] node33_pc_out,

    output [0:`DATA_WIDTH - 1] node00_d_out,
    output [0:`DATA_WIDTH - 1] node01_d_out,
    output [0:`DATA_WIDTH - 1] node02_d_out,
    output [0:`DATA_WIDTH - 1] node03_d_out,

    output [0:`DATA_WIDTH - 1] node10_d_out,
    output [0:`DATA_WIDTH - 1] node11_d_out,
    output [0:`DATA_WIDTH - 1] node12_d_out,
    output [0:`DATA_WIDTH - 1] node13_d_out,

    output [0:`DATA_WIDTH - 1] node20_d_out,
    output [0:`DATA_WIDTH - 1] node21_d_out,
    output [0:`DATA_WIDTH - 1] node22_d_out,
    output [0:`DATA_WIDTH - 1] node23_d_out,

    output [0:`DATA_WIDTH - 1] node30_d_out,
    output [0:`DATA_WIDTH - 1] node31_d_out,
    output [0:`DATA_WIDTH - 1] node32_d_out,
    output [0:`DATA_WIDTH - 1] node33_d_out,

    output [0:`ADDR_WIDTH - 1] node00_addr_out,
    output [0:`ADDR_WIDTH - 1] node01_addr_out,
    output [0:`ADDR_WIDTH - 1] node02_addr_out,
    output [0:`ADDR_WIDTH - 1] node03_addr_out,

    output [0:`ADDR_WIDTH - 1] node10_addr_out,
    output [0:`ADDR_WIDTH - 1] node11_addr_out,
    output [0:`ADDR_WIDTH - 1] node12_addr_out,
    output [0:`ADDR_WIDTH - 1] node13_addr_out,

    output [0:`ADDR_WIDTH - 1] node20_addr_out,
    output [0:`ADDR_WIDTH - 1] node21_addr_out,
    output [0:`ADDR_WIDTH - 1] node22_addr_out,
    output [0:`ADDR_WIDTH - 1] node23_addr_out,

    output [0:`ADDR_WIDTH - 1] node30_addr_out,
    output [0:`ADDR_WIDTH - 1] node31_addr_out,
    output [0:`ADDR_WIDTH - 1] node32_addr_out,
    output [0:`ADDR_WIDTH - 1] node33_addr_out,

    output node00_memEn,  output node01_memEn,  output node02_memEn,  output node03_memEn,
    output node10_memEn,  output node11_memEn,  output node12_memEn,  output node13_memEn,
    output node20_memEn,  output node21_memEn,  output node22_memEn,  output node23_memEn,
    output node30_memEn,  output node31_memEn,  output node32_memEn,  output node33_memEn,

    output node00_memWrEn, output node01_memWrEn, output node02_memWrEn, output node03_memWrEn,
    output node10_memWrEn, output node11_memWrEn, output node12_memWrEn, output node13_memWrEn,
    output node20_memWrEn, output node21_memWrEn, output node22_memWrEn, output node23_memWrEn,
    output node30_memWrEn, output node31_memWrEn, output node32_memWrEn, output node33_memWrEn
);


// Wires between CPU <--> NIC for each node
    wire [0:`DATA_WIDTH - 1] nic_do_00, nic_do_01, nic_do_02, nic_do_03;
    wire [0:`DATA_WIDTH - 1] nic_do_10, nic_do_11, nic_do_12, nic_do_13;
    wire [0:`DATA_WIDTH - 1] nic_do_20, nic_do_21, nic_do_22, nic_do_23;
    wire [0:`DATA_WIDTH - 1] nic_do_30, nic_do_31, nic_do_32, nic_do_33;

    wire [0:`DATA_WIDTH - 1] nic_di_00, nic_di_01, nic_di_02, nic_di_03;
    wire [0:`DATA_WIDTH - 1] nic_di_10, nic_di_11, nic_di_12, nic_di_13;
    wire [0:`DATA_WIDTH - 1] nic_di_20, nic_di_21, nic_di_22, nic_di_23;
    wire [0:`DATA_WIDTH - 1] nic_di_30, nic_di_31, nic_di_32, nic_di_33;

    wire nic_En_00,  nic_En_01,  nic_En_02,  nic_En_03;
    wire nic_En_10,  nic_En_11,  nic_En_12,  nic_En_13;
    wire nic_En_20,  nic_En_21,  nic_En_22,  nic_En_23;
    wire nic_En_30,  nic_En_31,  nic_En_32,  nic_En_33;

    wire nic_WrEn_00, nic_WrEn_01, nic_WrEn_02, nic_WrEn_03;
    wire nic_WrEn_10, nic_WrEn_11, nic_WrEn_12, nic_WrEn_13;
    wire nic_WrEn_20, nic_WrEn_21, nic_WrEn_22, nic_WrEn_23;
    wire nic_WrEn_30, nic_WrEn_31, nic_WrEn_32, nic_WrEn_33;

    // Example: keep these at 2 bits if consistent with your older design
    // or adjust as needed
    wire [0:1] nic_addr_00, nic_addr_01, nic_addr_02, nic_addr_03;
    wire [0:1] nic_addr_10, nic_addr_11, nic_addr_12, nic_addr_13;
    wire [0:1] nic_addr_20, nic_addr_21, nic_addr_22, nic_addr_23;
    wire [0:1] nic_addr_30, nic_addr_31, nic_addr_32, nic_addr_33;


// Wires between NIC <--> gold_mesh NoC
    // NIC -> mesh
    wire net_so_00, net_so_01, net_so_02, net_so_03;
    wire net_so_10, net_so_11, net_so_12, net_so_13;
    wire net_so_20, net_so_21, net_so_22, net_so_23;
    wire net_so_30, net_so_31, net_so_32, net_so_33;

    wire net_ro_00, net_ro_01, net_ro_02, net_ro_03;
    wire net_ro_10, net_ro_11, net_ro_12, net_ro_13;
    wire net_ro_20, net_ro_21, net_ro_22, net_ro_23;
    wire net_ro_30, net_ro_31, net_ro_32, net_ro_33;

    wire [0:`DATA_WIDTH - 1] net_do_00, net_do_01, net_do_02, net_do_03;
    wire [0:`DATA_WIDTH - 1] net_do_10, net_do_11, net_do_12, net_do_13;
    wire [0:`DATA_WIDTH - 1] net_do_20, net_do_21, net_do_22, net_do_23;
    wire [0:`DATA_WIDTH - 1] net_do_30, net_do_31, net_do_32, net_do_33;

    // mesh -> NIC
    wire net_si_00, net_si_01, net_si_02, net_si_03;
    wire net_si_10, net_si_11, net_si_12, net_si_13;
    wire net_si_20, net_si_21, net_si_22, net_si_23;
    wire net_si_30, net_si_31, net_si_32, net_si_33;

    wire net_ri_00, net_ri_01, net_ri_02, net_ri_03;
    wire net_ri_10, net_ri_11, net_ri_12, net_ri_13;
    wire net_ri_20, net_ri_21, net_ri_22, net_ri_23;
    wire net_ri_30, net_ri_31, net_ri_32, net_ri_33;

    wire [0:`DATA_WIDTH - 1] net_di_00, net_di_01, net_di_02, net_di_03;
    wire [0:`DATA_WIDTH - 1] net_di_10, net_di_11, net_di_12, net_di_13;
    wire [0:`DATA_WIDTH - 1] net_di_20, net_di_21, net_di_22, net_di_23;
    wire [0:`DATA_WIDTH - 1] net_di_30, net_di_31, net_di_32, net_di_33;

    wire net_polarity_00, net_polarity_01, net_polarity_02, net_polarity_03;
    wire net_polarity_10, net_polarity_11, net_polarity_12, net_polarity_13;
    wire net_polarity_20, net_polarity_21, net_polarity_22, net_polarity_23;
    wire net_polarity_30, net_polarity_31, net_polarity_32, net_polarity_33;


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

    gold_nic nic_03(
        .clk(clk), .reset(reset),
        .addr(nic_addr_03),
        .d_in(nic_di_03),
        .d_out(nic_do_03),
        .nicEn(nic_En_03),
        .nicEnWr(nic_WrEn_03),
        .net_si(net_si_03),
        .net_ri(net_ri_03),
        .net_di(net_di_03),
        .net_so(net_so_03),
        .net_ro(net_ro_03),
        .net_do(net_do_03),
        .net_polarity(net_polarity_03)
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

    gold_nic nic_13(
        .clk(clk), .reset(reset),
        .addr(nic_addr_13),
        .d_in(nic_di_13),
        .d_out(nic_do_13),
        .nicEn(nic_En_13),
        .nicEnWr(nic_WrEn_13),
        .net_si(net_si_13),
        .net_ri(net_ri_13),
        .net_di(net_di_13),
        .net_so(net_so_13),
        .net_ro(net_ro_13),
        .net_do(net_do_13),
        .net_polarity(net_polarity_13)
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

    gold_nic nic_23(
        .clk(clk), .reset(reset),
        .addr(nic_addr_23),
        .d_in(nic_di_23),
        .d_out(nic_do_23),
        .nicEn(nic_En_23),
        .nicEnWr(nic_WrEn_23),
        .net_si(net_si_23),
        .net_ri(net_ri_23),
        .net_di(net_di_23),
        .net_so(net_so_23),
        .net_ro(net_ro_23),
        .net_do(net_do_23),
        .net_polarity(net_polarity_23)
    );

    gold_nic nic_30(
        .clk(clk), .reset(reset),
        .addr(nic_addr_30),
        .d_in(nic_di_30),
        .d_out(nic_do_30),
        .nicEn(nic_En_30),
        .nicEnWr(nic_WrEn_30),
        .net_si(net_si_30),
        .net_ri(net_ri_30),
        .net_di(net_di_30),
        .net_so(net_so_30),
        .net_ro(net_ro_30),
        .net_do(net_do_30),
        .net_polarity(net_polarity_30)
    );

    gold_nic nic_31(
        .clk(clk), .reset(reset),
        .addr(nic_addr_31),
        .d_in(nic_di_31),
        .d_out(nic_do_31),
        .nicEn(nic_En_31),
        .nicEnWr(nic_WrEn_31),
        .net_si(net_si_31),
        .net_ri(net_ri_31),
        .net_di(net_di_31),
        .net_so(net_so_31),
        .net_ro(net_ro_31),
        .net_do(net_do_31),
        .net_polarity(net_polarity_31)
    );

    gold_nic nic_32(
        .clk(clk), .reset(reset),
        .addr(nic_addr_32),
        .d_in(nic_di_32),
        .d_out(nic_do_32),
        .nicEn(nic_En_32),
        .nicEnWr(nic_WrEn_32),
        .net_si(net_si_32),
        .net_ri(net_ri_32),
        .net_di(net_di_32),
        .net_so(net_so_32),
        .net_ro(net_ro_32),
        .net_do(net_do_32),
        .net_polarity(net_polarity_32)
    );

    gold_nic nic_33(
        .clk(clk), .reset(reset),
        .addr(nic_addr_33),
        .d_in(nic_di_33),
        .d_out(nic_do_33),
        .nicEn(nic_En_33),
        .nicEnWr(nic_WrEn_33),
        .net_si(net_si_33),
        .net_ri(net_ri_33),
        .net_di(net_di_33),
        .net_so(net_so_33),
        .net_ro(net_ro_33),
        .net_do(net_do_33),
        .net_polarity(net_polarity_33)
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

    // CPU (0,3)
    cardinal_cpu processor_03(
        .clk(clk),
        .reset(reset),
        .instr_addr(node03_pc_out),
        .instr_in(node03_inst_in),
        .dmem_addr(node03_addr_out),
        .dmem_data_out(node03_d_out),
        .dmem_data_in(node03_d_in),
        .dmem_En(node03_memEn),
        .dmem_WrEn(node03_memWrEn),
        .nic_addr(nic_addr_03),
        .nic_data_out(nic_di_03),
        .nic_data_in(nic_do_03),
        .nic_En(nic_En_03),
        .nic_WrEn(nic_WrEn_03)
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

    // CPU (1,3)
    cardinal_cpu processor_13(
        .clk(clk),
        .reset(reset),
        .instr_addr(node13_pc_out),
        .instr_in(node13_inst_in),
        .dmem_addr(node13_addr_out),
        .dmem_data_out(node13_d_out),
        .dmem_data_in(node13_d_in),
        .dmem_En(node13_memEn),
        .dmem_WrEn(node13_memWrEn),
        .nic_addr(nic_addr_13),
        .nic_data_out(nic_di_13),
        .nic_data_in(nic_do_13),
        .nic_En(nic_En_13),
        .nic_WrEn(nic_WrEn_13)
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

    // CPU (2,3)
    cardinal_cpu processor_23(
        .clk(clk),
        .reset(reset),
        .instr_addr(node23_pc_out),
        .instr_in(node23_inst_in),
        .dmem_addr(node23_addr_out),
        .dmem_data_out(node23_d_out),
        .dmem_data_in(node23_d_in),
        .dmem_En(node23_memEn),
        .dmem_WrEn(node23_memWrEn),
        .nic_addr(nic_addr_23),
        .nic_data_out(nic_di_23),
        .nic_data_in(nic_do_23),
        .nic_En(nic_En_23),
        .nic_WrEn(nic_WrEn_23)
    );

    // CPU (3,0)
    cardinal_cpu processor_30(
        .clk(clk),
        .reset(reset),
        .instr_addr(node30_pc_out),
        .instr_in(node30_inst_in),
        .dmem_addr(node30_addr_out),
        .dmem_data_out(node30_d_out),
        .dmem_data_in(node30_d_in),
        .dmem_En(node30_memEn),
        .dmem_WrEn(node30_memWrEn),
        .nic_addr(nic_addr_30),
        .nic_data_out(nic_di_30),
        .nic_data_in(nic_do_30),
        .nic_En(nic_En_30),
        .nic_WrEn(nic_WrEn_30)
    );

    // CPU (3,1)
    cardinal_cpu processor_31(
        .clk(clk),
        .reset(reset),
        .instr_addr(node31_pc_out),
        .instr_in(node31_inst_in),
        .dmem_addr(node31_addr_out),
        .dmem_data_out(node31_d_out),
        .dmem_data_in(node31_d_in),
        .dmem_En(node31_memEn),
        .dmem_WrEn(node31_memWrEn),
        .nic_addr(nic_addr_31),
        .nic_data_out(nic_di_31),
        .nic_data_in(nic_do_31),
        .nic_En(nic_En_31),
        .nic_WrEn(nic_WrEn_31)
    );

    // CPU (3,2)
    cardinal_cpu processor_32(
        .clk(clk),
        .reset(reset),
        .instr_addr(node32_pc_out),
        .instr_in(node32_inst_in),
        .dmem_addr(node32_addr_out),
        .dmem_data_out(node32_d_out),
        .dmem_data_in(node32_d_in),
        .dmem_En(node32_memEn),
        .dmem_WrEn(node32_memWrEn),
        .nic_addr(nic_addr_32),
        .nic_data_out(nic_di_32),
        .nic_data_in(nic_do_32),
        .nic_En(nic_En_32),
        .nic_WrEn(nic_WrEn_32)
    );

    // CPU (3,3)
    cardinal_cpu processor_33(
        .clk(clk),
        .reset(reset),
        .instr_addr(node33_pc_out),
        .instr_in(node33_inst_in),
        .dmem_addr(node33_addr_out),
        .dmem_data_out(node33_d_out),
        .dmem_data_in(node33_d_in),
        .dmem_En(node33_memEn),
        .dmem_WrEn(node33_memWrEn),
        .nic_addr(nic_addr_33),
        .nic_data_out(nic_di_33),
        .nic_data_in(nic_do_33),
        .nic_En(nic_En_33),
        .nic_WrEn(nic_WrEn_33)
    );


// gold_mesh instantiation
    gold_mesh #(.PACKET_SIZE(`DATA_WIDTH)) mesh_0
    (
        .clk(clk),
        .reset(reset),

        //------------------------------------------------------
        // Row y=0: node00, node10, node20, node30
        //------------------------------------------------------
        .node00_pesi(net_so_00),
        .node00_pero(net_ri_00),
        .node00_pedi(net_do_00),
        .node00_peri(net_ro_00),
        .node00_peso(net_si_00),
        .node00_pedo(net_di_00),
        .node00_polarity(net_polarity_00),

        .node10_pesi(net_so_10),
        .node10_pero(net_ri_10),
        .node10_pedi(net_do_10),
        .node10_peri(net_ro_10),
        .node10_peso(net_si_10),
        .node10_pedo(net_di_10),
        .node10_polarity(net_polarity_10),

        .node20_pesi(net_so_20),
        .node20_pero(net_ri_20),
        .node20_pedi(net_do_20),
        .node20_peri(net_ro_20),
        .node20_peso(net_si_20),
        .node20_pedo(net_di_20),
        .node20_polarity(net_polarity_20),

        .node30_pesi(net_so_30),
        .node30_pero(net_ri_30),
        .node30_pedi(net_do_30),
        .node30_peri(net_ro_30),
        .node30_peso(net_si_30),
        .node30_pedo(net_di_30),
        .node30_polarity(net_polarity_30),

        //------------------------------------------------------
        // Row y=1: node01, node11, node21, node31
        //------------------------------------------------------
        .node01_pesi(net_so_01),
        .node01_pero(net_ri_01),
        .node01_pedi(net_do_01),
        .node01_peri(net_ro_01),
        .node01_peso(net_si_01),
        .node01_pedo(net_di_01),
        .node01_polarity(net_polarity_01),

        .node11_pesi(net_so_11),
        .node11_pero(net_ri_11),
        .node11_pedi(net_do_11),
        .node11_peri(net_ro_11),
        .node11_peso(net_si_11),
        .node11_pedo(net_di_11),
        .node11_polarity(net_polarity_11),

        .node21_pesi(net_so_21),
        .node21_pero(net_ri_21),
        .node21_pedi(net_do_21),
        .node21_peri(net_ro_21),
        .node21_peso(net_si_21),
        .node21_pedo(net_di_21),
        .node21_polarity(net_polarity_21),

        .node31_pesi(net_so_31),
        .node31_pero(net_ri_31),
        .node31_pedi(net_do_31),
        .node31_peri(net_ro_31),
        .node31_peso(net_si_31),
        .node31_pedo(net_di_31),
        .node31_polarity(net_polarity_31),

        //------------------------------------------------------
        // Row y=2: node02, node12, node22, node32
        //------------------------------------------------------
        .node02_pesi(net_so_02),
        .node02_pero(net_ri_02),
        .node02_pedi(net_do_02),
        .node02_peri(net_ro_02),
        .node02_peso(net_si_02),
        .node02_pedo(net_di_02),
        .node02_polarity(net_polarity_02),

        .node12_pesi(net_so_12),
        .node12_pero(net_ri_12),
        .node12_pedi(net_do_12),
        .node12_peri(net_ro_12),
        .node12_peso(net_si_12),
        .node12_pedo(net_di_12),
        .node12_polarity(net_polarity_12),

        .node22_pesi(net_so_22),
        .node22_pero(net_ri_22),
        .node22_pedi(net_do_22),
        .node22_peri(net_ro_22),
        .node22_peso(net_si_22),
        .node22_pedo(net_di_22),
        .node22_polarity(net_polarity_22),

        .node32_pesi(net_so_32),
        .node32_pero(net_ri_32),
        .node32_pedi(net_do_32),
        .node32_peri(net_ro_32),
        .node32_peso(net_si_32),
        .node32_pedo(net_di_32),
        .node32_polarity(net_polarity_32),

        //------------------------------------------------------
        // Row y=3: node03, node13, node23, node33
        //------------------------------------------------------
        .node03_pesi(net_so_03),
        .node03_pero(net_ri_03),
        .node03_pedi(net_do_03),
        .node03_peri(net_ro_03),
        .node03_peso(net_si_03),
        .node03_pedo(net_di_03),
        .node03_polarity(net_polarity_03),

        .node13_pesi(net_so_13),
        .node13_pero(net_ri_13),
        .node13_pedi(net_do_13),
        .node13_peri(net_ro_13),
        .node13_peso(net_si_13),
        .node13_pedo(net_di_13),
        .node13_polarity(net_polarity_13),

        .node23_pesi(net_so_23),
        .node23_pero(net_ri_23),
        .node23_pedi(net_do_23),
        .node23_peri(net_ro_23),
        .node23_peso(net_si_23),
        .node23_pedo(net_di_23),
        .node23_polarity(net_polarity_23),

        .node33_pesi(net_so_33),
        .node33_pero(net_ri_33),
        .node33_pedi(net_do_33),
        .node33_peri(net_ro_33),
        .node33_peso(net_si_33),
        .node33_pedo(net_di_33),
        .node33_polarity(net_polarity_33)
    );

endmodule

`undef DATA_WIDTH
`undef INST_WIDTH
`undef ADDR_WIDTH