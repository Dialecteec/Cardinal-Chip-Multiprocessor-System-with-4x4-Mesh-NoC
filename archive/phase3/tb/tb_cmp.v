/////////////////////////////////////////////////////////
// Filename       	: cpu_tb.v 				  
// Description    	: Cardinal Processor Simulation Testbenc
// Author         	: Praveen Sharma							  
// Fixed dataIn, dataOut port for DMEM.
// Fixed $readmemh statement for DM.fill
// Fixed minor bugs, related to signal names
/////////////////////////////////////////////////////////
// Test Bench for the Cardinal Processor RTL Verification

`timescale 1ns/10ps

//Define the clock cycle
`define CYCLE_TIME 4

// Include Files
// Memory Files
`include "./include/dmem.v"
`include "./include/imem.v"
`include "./include/gscl45nm.v"

// Register File
`include "./design/register_file.v"

//Design File
`include "./design/alu.v"
`include "./design/arbiter.v"
`include "./design/buffer.v"
`include "./design/cardinal_cpu.v"
`include "./design/cardinal_cmp.v"
`include "./design/gold_mesh.v"
`include "./design/gold_router.v"
`include "./design/gold_nic.v"


// This testbench instantiates the following modules:
// a. 64-bit Variable width Cardinal Processor as CPU, 
// b. 256 X 32 bit word Instruction memory
// c. 256 X 64 bit word Data memory

module tb_cmp;
    reg CLK, RESET;

    integer i;
    integer cycle_number;
    integer imem_test, imem_test2, j;
    //===========================================================
    // Declare wires for 16 nodes
    //===========================================================
    // Node 00
    wire [0:31] node00_pc_out;
    wire [0:31] node00_inst_in;
    wire [0:31] node00_addr_out;
    wire [0:63] node00_d_out, node00_d_in;
    wire        node00_memEn, node00_memWrEn;

    // Node 01
    wire [0:31] node01_pc_out;
    wire [0:31] node01_inst_in;
    wire [0:31] node01_addr_out;
    wire [0:63] node01_d_out, node01_d_in;
    wire        node01_memEn, node01_memWrEn;

    // Node 02
    wire [0:31] node02_pc_out;
    wire [0:31] node02_inst_in;
    wire [0:31] node02_addr_out;
    wire [0:63] node02_d_out, node02_d_in;
    wire        node02_memEn, node02_memWrEn;

    // Node 03
    wire [0:31] node03_pc_out;
    wire [0:31] node03_inst_in;
    wire [0:31] node03_addr_out;
    wire [0:63] node03_d_out, node03_d_in;
    wire        node03_memEn, node03_memWrEn;

    // Node 10
    wire [0:31] node10_pc_out;
    wire [0:31] node10_inst_in;
    wire [0:31] node10_addr_out;
    wire [0:63] node10_d_out, node10_d_in;
    wire        node10_memEn, node10_memWrEn;

    // Node 11
    wire [0:31] node11_pc_out;
    wire [0:31] node11_inst_in;
    wire [0:31] node11_addr_out;
    wire [0:63] node11_d_out, node11_d_in;
    wire        node11_memEn, node11_memWrEn;

    // Node 12
    wire [0:31] node12_pc_out;
    wire [0:31] node12_inst_in;
    wire [0:31] node12_addr_out;
    wire [0:63] node12_d_out, node12_d_in;
    wire        node12_memEn, node12_memWrEn;

    // Node 13
    wire [0:31] node13_pc_out;
    wire [0:31] node13_inst_in;
    wire [0:31] node13_addr_out;
    wire [0:63] node13_d_out, node13_d_in;
    wire        node13_memEn, node13_memWrEn;

    // Node 20
    wire [0:31] node20_pc_out;
    wire [0:31] node20_inst_in;
    wire [0:31] node20_addr_out;
    wire [0:63] node20_d_out, node20_d_in;
    wire        node20_memEn, node20_memWrEn;

    // Node 21
    wire [0:31] node21_pc_out;
    wire [0:31] node21_inst_in;
    wire [0:31] node21_addr_out;
    wire [0:63] node21_d_out, node21_d_in;
    wire        node21_memEn, node21_memWrEn;

    // Node 22
    wire [0:31] node22_pc_out;
    wire [0:31] node22_inst_in;
    wire [0:31] node22_addr_out;
    wire [0:63] node22_d_out, node22_d_in;
    wire        node22_memEn, node22_memWrEn;

    // Node 23
    wire [0:31] node23_pc_out;
    wire [0:31] node23_inst_in;
    wire [0:31] node23_addr_out;
    wire [0:63] node23_d_out, node23_d_in;
    wire        node23_memEn, node23_memWrEn;

    // Node 30
    wire [0:31] node30_pc_out;
    wire [0:31] node30_inst_in;
    wire [0:31] node30_addr_out;
    wire [0:63] node30_d_out, node30_d_in;
    wire        node30_memEn, node30_memWrEn;

    // Node 31
    wire [0:31] node31_pc_out;
    wire [0:31] node31_inst_in;
    wire [0:31] node31_addr_out;
    wire [0:63] node31_d_out, node31_d_in;
    wire        node31_memEn, node31_memWrEn;

    // Node 32
    wire [0:31] node32_pc_out;
    wire [0:31] node32_inst_in;
    wire [0:31] node32_addr_out;
    wire [0:63] node32_d_out, node32_d_in;
    wire        node32_memEn, node32_memWrEn;

    // Node 33
    wire [0:31] node33_pc_out;
    wire [0:31] node33_inst_in;
    wire [0:31] node33_addr_out;
    wire [0:63] node33_d_out, node33_d_in;
    wire        node33_memEn, node33_memWrEn;

    //===========================================================
    // Data memory dump file descriptors (optional)
    //===========================================================
    integer dmem00_dump_file, dmem01_dump_file, dmem02_dump_file, dmem03_dump_file;
    integer dmem10_dump_file, dmem11_dump_file, dmem12_dump_file, dmem13_dump_file;
    integer dmem20_dump_file, dmem21_dump_file, dmem22_dump_file, dmem23_dump_file;
    integer dmem30_dump_file, dmem31_dump_file, dmem32_dump_file, dmem33_dump_file;

    //===========================================================
    // Instruction Memory (imem) for each node
    //===========================================================
    imem IM_node00 (
        .memAddr (node00_pc_out[22:29]),
        .dataOut (node00_inst_in)
    );
    imem IM_node01 (
        .memAddr (node01_pc_out[22:29]),
        .dataOut (node01_inst_in)
    );
    imem IM_node02 (
        .memAddr (node02_pc_out[22:29]),
        .dataOut (node02_inst_in)
    );
    imem IM_node03 (
        .memAddr (node03_pc_out[22:29]),
        .dataOut (node03_inst_in)
    );

    imem IM_node10 (
        .memAddr (node10_pc_out[22:29]),
        .dataOut (node10_inst_in)
    );
    imem IM_node11 (
        .memAddr (node11_pc_out[22:29]),
        .dataOut (node11_inst_in)
    );
    imem IM_node12 (
        .memAddr (node12_pc_out[22:29]),
        .dataOut (node12_inst_in)
    );
    imem IM_node13 (
        .memAddr (node13_pc_out[22:29]),
        .dataOut (node13_inst_in)
    );

    imem IM_node20 (
        .memAddr (node20_pc_out[22:29]),
        .dataOut (node20_inst_in)
    );
    imem IM_node21 (
        .memAddr (node21_pc_out[22:29]),
        .dataOut (node21_inst_in)
    );
    imem IM_node22 (
        .memAddr (node22_pc_out[22:29]),
        .dataOut (node22_inst_in)
    );
    imem IM_node23 (
        .memAddr (node23_pc_out[22:29]),
        .dataOut (node23_inst_in)
    );

    imem IM_node30 (
        .memAddr (node30_pc_out[22:29]),
        .dataOut (node30_inst_in)
    );
    imem IM_node31 (
        .memAddr (node31_pc_out[22:29]),
        .dataOut (node31_inst_in)
    );
    imem IM_node32 (
        .memAddr (node32_pc_out[22:29]),
        .dataOut (node32_inst_in)
    );
    imem IM_node33 (
        .memAddr (node33_pc_out[22:29]),
        .dataOut (node33_inst_in)
    );

    //===========================================================
    // Data Memory (dmem) for each node
    //===========================================================
    dmem DM_node00 (
        .clk    (CLK),
        .memEn  (node00_memEn),
        .memWrEn(node00_memWrEn),
        .memAddr(node00_addr_out[24:31]),
        .dataIn (node00_d_out),
        .dataOut(node00_d_in)
    );
    dmem DM_node01 (
        .clk    (CLK),
        .memEn  (node01_memEn),
        .memWrEn(node01_memWrEn),
        .memAddr(node01_addr_out[24:31]),
        .dataIn (node01_d_out),
        .dataOut(node01_d_in)
    );
    dmem DM_node02 (
        .clk    (CLK),
        .memEn  (node02_memEn),
        .memWrEn(node02_memWrEn),
        .memAddr(node02_addr_out[24:31]),
        .dataIn (node02_d_out),
        .dataOut(node02_d_in)
    );
    dmem DM_node03 (
        .clk    (CLK),
        .memEn  (node03_memEn),
        .memWrEn(node03_memWrEn),
        .memAddr(node03_addr_out[24:31]),
        .dataIn (node03_d_out),
        .dataOut(node03_d_in)
    );

    dmem DM_node10 (
        .clk    (CLK),
        .memEn  (node10_memEn),
        .memWrEn(node10_memWrEn),
        .memAddr(node10_addr_out[24:31]),
        .dataIn (node10_d_out),
        .dataOut(node10_d_in)
    );
    dmem DM_node11 (
        .clk    (CLK),
        .memEn  (node11_memEn),
        .memWrEn(node11_memWrEn),
        .memAddr(node11_addr_out[24:31]),
        .dataIn (node11_d_out),
        .dataOut(node11_d_in)
    );
    dmem DM_node12 (
        .clk    (CLK),
        .memEn  (node12_memEn),
        .memWrEn(node12_memWrEn),
        .memAddr(node12_addr_out[24:31]),
        .dataIn (node12_d_out),
        .dataOut(node12_d_in)
    );
    dmem DM_node13 (
        .clk    (CLK),
        .memEn  (node13_memEn),
        .memWrEn(node13_memWrEn),
        .memAddr(node13_addr_out[24:31]),
        .dataIn (node13_d_out),
        .dataOut(node13_d_in)
    );

    dmem DM_node20 (
        .clk    (CLK),
        .memEn  (node20_memEn),
        .memWrEn(node20_memWrEn),
        .memAddr(node20_addr_out[24:31]),
        .dataIn (node20_d_out),
        .dataOut(node20_d_in)
    );
    dmem DM_node21 (
        .clk    (CLK),
        .memEn  (node21_memEn),
        .memWrEn(node21_memWrEn),
        .memAddr(node21_addr_out[24:31]),
        .dataIn (node21_d_out),
        .dataOut(node21_d_in)
    );
    dmem DM_node22 (
        .clk    (CLK),
        .memEn  (node22_memEn),
        .memWrEn(node22_memWrEn),
        .memAddr(node22_addr_out[24:31]),
        .dataIn (node22_d_out),
        .dataOut(node22_d_in)
    );
    dmem DM_node23 (
        .clk    (CLK),
        .memEn  (node23_memEn),
        .memWrEn(node23_memWrEn),
        .memAddr(node23_addr_out[24:31]),
        .dataIn (node23_d_out),
        .dataOut(node23_d_in)
    );

    dmem DM_node30 (
        .clk    (CLK),
        .memEn  (node30_memEn),
        .memWrEn(node30_memWrEn),
        .memAddr(node30_addr_out[24:31]),
        .dataIn (node30_d_out),
        .dataOut(node30_d_in)
    );
    dmem DM_node31 (
        .clk    (CLK),
        .memEn  (node31_memEn),
        .memWrEn(node31_memWrEn),
        .memAddr(node31_addr_out[24:31]),
        .dataIn (node31_d_out),
        .dataOut(node31_d_in)
    );
    dmem DM_node32 (
        .clk    (CLK),
        .memEn  (node32_memEn),
        .memWrEn(node32_memWrEn),
        .memAddr(node32_addr_out[24:31]),
        .dataIn (node32_d_out),
        .dataOut(node32_d_in)
    );
    dmem DM_node33 (
        .clk    (CLK),
        .memEn  (node33_memEn),
        .memWrEn(node33_memWrEn),
        .memAddr(node33_addr_out[24:31]),
        .dataIn (node33_d_out),
        .dataOut(node33_d_in)
    );

    //===========================================================
    // The 16-node cardinal_cmp instance
    // (the same expanded code you provided for 16 nodes)
    //===========================================================
    cardinal_cmp CMP(
        .clk(CLK),
        .reset(RESET),

        // Node 00
        .node00_inst_in (node00_inst_in),
        .node00_d_in    (node00_d_in),
        .node00_pc_out  (node00_pc_out),
        .node00_d_out   (node00_d_out),
        .node00_addr_out(node00_addr_out),
        .node00_memWrEn (node00_memWrEn),
        .node00_memEn   (node00_memEn),

        // Node 01
        .node01_inst_in (node01_inst_in),
        .node01_d_in    (node01_d_in),
        .node01_pc_out  (node01_pc_out),
        .node01_d_out   (node01_d_out),
        .node01_addr_out(node01_addr_out),
        .node01_memWrEn (node01_memWrEn),
        .node01_memEn   (node01_memEn),

        // Node 02
        .node02_inst_in (node02_inst_in),
        .node02_d_in    (node02_d_in),
        .node02_pc_out  (node02_pc_out),
        .node02_d_out   (node02_d_out),
        .node02_addr_out(node02_addr_out),
        .node02_memWrEn (node02_memWrEn),
        .node02_memEn   (node02_memEn),

        // Node 03
        .node03_inst_in (node03_inst_in),
        .node03_d_in    (node03_d_in),
        .node03_pc_out  (node03_pc_out),
        .node03_d_out   (node03_d_out),
        .node03_addr_out(node03_addr_out),
        .node03_memWrEn (node03_memWrEn),
        .node03_memEn   (node03_memEn),

        // Node 10
        .node10_inst_in (node10_inst_in),
        .node10_d_in    (node10_d_in),
        .node10_pc_out  (node10_pc_out),
        .node10_d_out   (node10_d_out),
        .node10_addr_out(node10_addr_out),
        .node10_memWrEn (node10_memWrEn),
        .node10_memEn   (node10_memEn),

        // Node 11
        .node11_inst_in (node11_inst_in),
        .node11_d_in    (node11_d_in),
        .node11_pc_out  (node11_pc_out),
        .node11_d_out   (node11_d_out),
        .node11_addr_out(node11_addr_out),
        .node11_memWrEn (node11_memWrEn),
        .node11_memEn   (node11_memEn),

        // Node 12
        .node12_inst_in (node12_inst_in),
        .node12_d_in    (node12_d_in),
        .node12_pc_out  (node12_pc_out),
        .node12_d_out   (node12_d_out),
        .node12_addr_out(node12_addr_out),
        .node12_memWrEn (node12_memWrEn),
        .node12_memEn   (node12_memEn),

        // Node 13
        .node13_inst_in (node13_inst_in),
        .node13_d_in    (node13_d_in),
        .node13_pc_out  (node13_pc_out),
        .node13_d_out   (node13_d_out),
        .node13_addr_out(node13_addr_out),
        .node13_memWrEn (node13_memWrEn),
        .node13_memEn   (node13_memEn),

        // Node 20
        .node20_inst_in (node20_inst_in),
        .node20_d_in    (node20_d_in),
        .node20_pc_out  (node20_pc_out),
        .node20_d_out   (node20_d_out),
        .node20_addr_out(node20_addr_out),
        .node20_memWrEn (node20_memWrEn),
        .node20_memEn   (node20_memEn),

        // Node 21
        .node21_inst_in (node21_inst_in),
        .node21_d_in    (node21_d_in),
        .node21_pc_out  (node21_pc_out),
        .node21_d_out   (node21_d_out),
        .node21_addr_out(node21_addr_out),
        .node21_memWrEn (node21_memWrEn),
        .node21_memEn   (node21_memEn),

        // Node 22
        .node22_inst_in (node22_inst_in),
        .node22_d_in    (node22_d_in),
        .node22_pc_out  (node22_pc_out),
        .node22_d_out   (node22_d_out),
        .node22_addr_out(node22_addr_out),
        .node22_memWrEn (node22_memWrEn),
        .node22_memEn   (node22_memEn),

        // Node 23
        .node23_inst_in (node23_inst_in),
        .node23_d_in    (node23_d_in),
        .node23_pc_out  (node23_pc_out),
        .node23_d_out   (node23_d_out),
        .node23_addr_out(node23_addr_out),
        .node23_memWrEn (node23_memWrEn),
        .node23_memEn   (node23_memEn),

        // Node 30
        .node30_inst_in (node30_inst_in),
        .node30_d_in    (node30_d_in),
        .node30_pc_out  (node30_pc_out),
        .node30_d_out   (node30_d_out),
        .node30_addr_out(node30_addr_out),
        .node30_memWrEn (node30_memWrEn),
        .node30_memEn   (node30_memEn),

        // Node 31
        .node31_inst_in (node31_inst_in),
        .node31_d_in    (node31_d_in),
        .node31_pc_out  (node31_pc_out),
        .node31_d_out   (node31_d_out),
        .node31_addr_out(node31_addr_out),
        .node31_memWrEn (node31_memWrEn),
        .node31_memEn   (node31_memEn),

        // Node 32
        .node32_inst_in (node32_inst_in),
        .node32_d_in    (node32_d_in),
        .node32_pc_out  (node32_pc_out),
        .node32_d_out   (node32_d_out),
        .node32_addr_out(node32_addr_out),
        .node32_memWrEn (node32_memWrEn),
        .node32_memEn   (node32_memEn),

        // Node 33
        .node33_inst_in (node33_inst_in),
        .node33_d_in    (node33_d_in),
        .node33_pc_out  (node33_pc_out),
        .node33_d_out   (node33_d_out),
        .node33_addr_out(node33_addr_out),
        .node33_memWrEn (node33_memWrEn),
        .node33_memEn   (node33_memEn)
    );
	
    always #(`CYCLE_TIME / 2) CLK <= ~CLK;	

    initial
    begin
        CLK <= 0;				// initialize Clock
        RESET <= 1'b1;				// reset the CPU 
        repeat(5) @(negedge CLK);		// wait for 5 clock cycles
        RESET <= 1'b0;				// de-activate reset signal after 5ns

        dmem00_dump_file = $fopen("cmp_test.dmem00.dump");
        dmem01_dump_file = $fopen("cmp_test.dmem01.dump");
        dmem02_dump_file = $fopen("cmp_test.dmem02.dump");
        dmem03_dump_file = $fopen("cmp_test.dmem03.dump");
        dmem10_dump_file = $fopen("cmp_test.dmem10.dump");
        dmem11_dump_file = $fopen("cmp_test.dmem11.dump");
        dmem12_dump_file = $fopen("cmp_test.dmem12.dump");
        dmem13_dump_file = $fopen("cmp_test.dmem13.dump");
        dmem20_dump_file = $fopen("cmp_test.dmem20.dump");
        dmem21_dump_file = $fopen("cmp_test.dmem21.dump");
        dmem22_dump_file = $fopen("cmp_test.dmem22.dump");
        dmem23_dump_file = $fopen("cmp_test.dmem23.dump");
        dmem30_dump_file = $fopen("cmp_test.dmem30.dump");
        dmem31_dump_file = $fopen("cmp_test.dmem31.dump");
        dmem32_dump_file = $fopen("cmp_test.dmem32.dump");
        dmem33_dump_file = $fopen("cmp_test.dmem33.dump");

        $readmemh("cmp_test.dmem.00.fill", DM_node00.MEM);
        $readmemh("cmp_test.dmem.01.fill", DM_node01.MEM);
        $readmemh("cmp_test.dmem.02.fill", DM_node02.MEM);
        $readmemh("cmp_test.dmem.03.fill", DM_node03.MEM);
        $readmemh("cmp_test.dmem.10.fill", DM_node10.MEM);
        $readmemh("cmp_test.dmem.11.fill", DM_node11.MEM);
        $readmemh("cmp_test.dmem.12.fill", DM_node12.MEM);
        $readmemh("cmp_test.dmem.13.fill", DM_node13.MEM);
        $readmemh("cmp_test.dmem.20.fill", DM_node20.MEM);
        $readmemh("cmp_test.dmem.21.fill", DM_node21.MEM);
        $readmemh("cmp_test.dmem.22.fill", DM_node22.MEM);
        $readmemh("cmp_test.dmem.23.fill", DM_node23.MEM);
        $readmemh("cmp_test.dmem.30.fill", DM_node30.MEM);
        $readmemh("cmp_test.dmem.31.fill", DM_node31.MEM);
        $readmemh("cmp_test.dmem.32.fill", DM_node32.MEM);
        $readmemh("cmp_test.dmem.33.fill", DM_node33.MEM);


        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node00 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node00.MEM);
        $readmemh("receive.fill", IM_node01.MEM);
        $readmemh("receive.fill", IM_node02.MEM);
        $readmemh("receive.fill", IM_node03.MEM);
        $readmemh("receive.fill", IM_node10.MEM);
        $readmemh("receive.fill", IM_node11.MEM);
        $readmemh("receive.fill", IM_node12.MEM);
        $readmemh("receive.fill", IM_node13.MEM);
        $readmemh("receive.fill", IM_node20.MEM);
        $readmemh("receive.fill", IM_node21.MEM);
        $readmemh("receive.fill", IM_node22.MEM);
        $readmemh("receive.fill", IM_node23.MEM);
        $readmemh("receive.fill", IM_node30.MEM);
        $readmemh("receive.fill", IM_node31.MEM);
        $readmemh("receive.fill", IM_node32.MEM);
        $readmemh("receive.fill", IM_node33.MEM);
        #600;
        $fdisplay(dmem01_dump_file, "Packet from node00 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from node00 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from node00 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from node00 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from node00 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from node00 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node00 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node00 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node00 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node00 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node00 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node00 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node00 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node00 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node00 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node01 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node01.MEM);
        $readmemh("receive.fill", IM_node00.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from node01 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from node01 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from node01 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from node01 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from node01 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from node01 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node01 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node01 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node01 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node01 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node01 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node01 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node01 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node01 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node01 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node02 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node02.MEM);
        $readmemh("receive.fill", IM_node01.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from node02 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from node02 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from node02 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from node02 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from node02 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from node02 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node02 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node02 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node02 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node02 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node02 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node02 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node02 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node02 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node02 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node03 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node03.MEM);
        $readmemh("receive.fill", IM_node02.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from node03 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from node03 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from node03 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from node03 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from node03 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from node03 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node03 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node03 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node03 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node03 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node03 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node03 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node03 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node03 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node03 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node10 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node10.MEM);
        $readmemh("receive.fill", IM_node03.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from node10 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from node10 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from node10 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from node10 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from node10 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from node10 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node10 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node10 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node10 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node10 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node10 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node10 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node10 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node10 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node10 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node11 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node11.MEM);
        $readmemh("receive.fill", IM_node10.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from node11 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from node11 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from node11 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from node11 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from node11 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from node11 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node11 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node11 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node11 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node11 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node11 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node11 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node11 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node11 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node11 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node13 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node13.MEM);
        $readmemh("receive.fill", IM_node11.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node13 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node13 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node13 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node13 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node13 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node13 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node13 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node13 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node13 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node13 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node13 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node13 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node13 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node13 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node13 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node20 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node20.MEM);
        $readmemh("receive.fill", IM_node13.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node20 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node20 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node20 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node20 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node20 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node20 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node20 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node20 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node20 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node20 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node20 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node20 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node20 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node20 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node20 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node21 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node21.MEM);
        $readmemh("receive.fill", IM_node20.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node21 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node21 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node21 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node21 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node21 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node21 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node21 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node21 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node21 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node21 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node21 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node21 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node21 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node21 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node21 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node22 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node22.MEM);
        $readmemh("receive.fill", IM_node21.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node22 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node22 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node22 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node22 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node22 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node22 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node22 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node22 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node22 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node22 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node22 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node22 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node22 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node22 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node22 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node23 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node23.MEM);
        $readmemh("receive.fill", IM_node22.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node23 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node23 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node23 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node23 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node23 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node23 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node23 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node23 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node23 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node23 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node23 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node23 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node23 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node23 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node23 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node30 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node30.MEM);
        $readmemh("receive.fill", IM_node23.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node30 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node30 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node30 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node30 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node30 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node30 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node30 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node30 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node30 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node30 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node30 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node30 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node30 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node30 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node30 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node31 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node31.MEM);
        $readmemh("receive.fill", IM_node30.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node31 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node31 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node31 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node31 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node31 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node31 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node31 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node31 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node31 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node31 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node31 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node31 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node31 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node31 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node31 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node32 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node32.MEM);
        $readmemh("receive.fill", IM_node31.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node32 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node32 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node32 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node32 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node32 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node32 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node32 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node32 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node32 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node32 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node32 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node32 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node32 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node32 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from Node32 : %h ", DM_node33.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node33 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node33.MEM);
        $readmemh("receive.fill", IM_node32.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from Node33 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from Node33 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from Node33 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from Node33 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from Node33 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from Node33 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem12_dump_file, "Packet from Node33 : %h ", DM_node12.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from Node33 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from Node33 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from Node33 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from Node33 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from Node33 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from Node33 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from Node33 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from Node33 : %h ", DM_node32.MEM[0]);

        #100;
        RESET <= 1'b1;
        repeat(5) @(negedge CLK);
        RESET <= 1'b0;

        /////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////                        Node12 broadcast                       ///////////////
        /////////////////////////////////////////////////////////////////////////////////////////////
        $readmemh("broadcast.fill", IM_node12.MEM);
        $readmemh("receive.fill", IM_node11.MEM);
        #600;
        $fdisplay(dmem00_dump_file, "Packet from node12 : %h ", DM_node00.MEM[0]);
        $fdisplay(dmem01_dump_file, "Packet from node12 : %h ", DM_node01.MEM[0]);
        $fdisplay(dmem02_dump_file, "Packet from node12 : %h ", DM_node02.MEM[0]);
        $fdisplay(dmem03_dump_file, "Packet from node12 : %h ", DM_node03.MEM[0]);
        $fdisplay(dmem10_dump_file, "Packet from node12 : %h ", DM_node10.MEM[0]);
        $fdisplay(dmem11_dump_file, "Packet from node12 : %h ", DM_node11.MEM[0]);
        $fdisplay(dmem13_dump_file, "Packet from node12 : %h ", DM_node13.MEM[0]);
        $fdisplay(dmem20_dump_file, "Packet from node12 : %h ", DM_node20.MEM[0]);
        $fdisplay(dmem21_dump_file, "Packet from node12 : %h ", DM_node21.MEM[0]);
        $fdisplay(dmem22_dump_file, "Packet from node12 : %h ", DM_node22.MEM[0]);
        $fdisplay(dmem23_dump_file, "Packet from node12 : %h ", DM_node23.MEM[0]);
        $fdisplay(dmem30_dump_file, "Packet from node12 : %h ", DM_node30.MEM[0]);
        $fdisplay(dmem31_dump_file, "Packet from node12 : %h ", DM_node31.MEM[0]);
        $fdisplay(dmem32_dump_file, "Packet from node12 : %h ", DM_node32.MEM[0]);
        $fdisplay(dmem33_dump_file, "Packet from node12 : %h ", DM_node33.MEM[0]);

        $fclose(dmem00_dump_file);
        $fclose(dmem01_dump_file);
        $fclose(dmem02_dump_file);
        $fclose(dmem03_dump_file);
        $fclose(dmem10_dump_file);
        $fclose(dmem11_dump_file);
        $fclose(dmem12_dump_file);
        $fclose(dmem13_dump_file);
        $fclose(dmem20_dump_file);
        $fclose(dmem21_dump_file);
        $fclose(dmem22_dump_file);
        $fclose(dmem23_dump_file);
        $fclose(dmem30_dump_file);
        $fclose(dmem31_dump_file);
        $fclose(dmem32_dump_file);
        $fclose(dmem33_dump_file);

        $finish;

    end

endmodule



