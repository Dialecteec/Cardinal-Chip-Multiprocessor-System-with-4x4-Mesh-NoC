module cardinal_cmp(
    input clk, reset,
    input [0:31] node0_inst_in, node1_inst_in, node2_inst_in, node3_inst_in,
    input [0:63] node0_d_in, node1_d_in, node2_d_in, node3_d_in,
    output [0:31] node0_pc_out, node1_pc_out, node2_pc_out, node3_pc_out,
    output [0:63] node0_d_out, node1_d_out, node2_d_out, node3_d_out,
    output [0:31] node0_addr_out, node1_addr_out, node2_addr_out, node3_addr_out,
    output node0_memWrEn, node1_memWrEn, node2_memWrEn, node3_memWrEn,
    output node0_memEn, node1_memEn, node2_memEn, node3_memEn
 );

    cardinal_cpu P0
    (
        .clk(clk),
        .reset(reset),
        .instr_in(node0_inst_in),
        .dmem_data_in(node0_d_in),
        .instr_addr(node0_pc_out),
        .dmem_data_out(node0_d_out),
        .dmem_addr(node0_addr_out),
        .dmem_WrEn(node0_memWrEn),
        .dmem_En(node0_memEn)
    );

    cardinal_cpu P1
    (
        .clk(clk),
        .reset(reset),
        .instr_in(node1_inst_in),
        .dmem_data_in(node1_d_in),
        .instr_addr(node1_pc_out),
        .dmem_data_out(node1_d_out),
        .dmem_addr(node1_addr_out),
        .dmem_WrEn(node1_memWrEn),
        .dmem_En(node1_memEn)
    );

    cardinal_cpu P2
    (
        .clk(clk),
        .reset(reset),
        .instr_in(node2_inst_in),
        .dmem_data_in(node2_d_in),
        .instr_addr(node2_pc_out),
        .dmem_data_out(node2_d_out),
        .dmem_addr(node2_addr_out),
        .dmem_WrEn(node2_memWrEn),
        .dmem_En(node2_memEn)
    );

    cardinal_cpu P3
    (
        .clk(clk),
        .reset(reset),
        .instr_in(node3_inst_in),
        .dmem_data_in(node3_d_in),
        .instr_addr(node3_pc_out),
        .dmem_data_out(node3_d_out),
        .dmem_addr(node3_addr_out),
        .dmem_WrEn(node3_memWrEn),
        .dmem_En(node3_memEn)
    );

    
endmodule
