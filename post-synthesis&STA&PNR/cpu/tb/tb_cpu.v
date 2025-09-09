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
`define CYCLE_TIME 100

// Include Files
// Memory Files
`include "./include/dmem.v"
`include "./include/imem.v"
`include "./include/gscl45nm.v"

// Register File
//`include "./design/REGFILE32x64.v"

//Design File
//`include "./design/cpu.v"
//`include "./design/cardinal_nic.v"
//`include "./design/cardinal_ring.v"
//`include "./design/cardinal_router.v"

// This testbench instantiates the following modules:
// a. 64-bit Variable width Cardinal Processor as CPU, 
// b. 256 X 32 bit word Instruction memory
// c. 256 X 64 bit word Data memory

module tb_cpu;
reg CLK, RESET;

wire [0:31] node0_pc_out;
wire [0:31] node0_inst_in;
wire [0:31] node0_addr_out;
wire [0:63] node0_d_out, node0_d_in;
wire node0_memEn, node0_memWrEn;



integer dmem0_dump_file;		// Channel Descriptor for DMEM0 final dump

integer i;

//// ******************** Module Instantiations ******************** \\\\

// Instruction Memory Instance
imem IM_node0 (
	.memAddr		(node0_pc_out[22:29]),	// Only 8-bits are used in this project
	.dataOut		(node0_inst_in)		// 32-bit  Instruction
	);

// Data Memory Instance
dmem DM_node0 (
	.clk 		(CLK),				// System Clock
	.memEn		(node0_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node0_memWrEn),		// data-memory Write Enable
	.memAddr	(node0_addr_out[24:31]),	// 8-bit Memory address
	.dataIn		(node0_d_out),			// 64-bit data to data-memory
	.dataOut	(node0_d_in)			// 64-bit data from data-memory
	);	
	
cardinal_cpu CPU(
	.clk(CLK),
	.reset(RESET),
	
	.instr_in	(node0_inst_in	),
	.dmem_data_in	(node0_d_in	),
	.instr_addr  	(node0_pc_out  	),
	.dmem_data_out   	(node0_d_out   	),
	.dmem_addr	(node0_addr_out	),
	.dmem_WrEn	(node0_memWrEn	),
	.dmem_En    (node0_memEn    )


	);
	
always #(`CYCLE_TIME / 2) CLK <= ~CLK;	

initial begin
	#50000000
    $finish;
end
	
initial
begin
	$readmemh("imem_1.fill", IM_node0.MEM); 	// loading instruction memory into node0

	$readmemh("dmem.fill", DM_node0.MEM); 	// loading data memory into node0
	
	CLK <= 0;				// initialize Clock
	RESET <= 1'b1;				// reset the CPU 
	repeat(5) @(negedge CLK);		// wait for 5 clock cycles
	RESET <= 1'b0;				// de-activate reset signal after 5ns

	// Convention for the last instruction
	// We would have a last instruction NOP  => 32'h00000000
	// wait (node0_inst_in == 32'h00000000 && node1_inst_in == 32'h00000000 && node2_inst_in == 32'h00000000 && node3_inst_in == 32'h00000000);
	// Let us see how much did you stall
	// Let us now flush the pipe line
	#40000000;
	repeat(5) @(negedge CLK); 
	// Open file for output
	dmem0_dump_file = $fopen("cmp_test.dmem0.dump"); // assigning the channel descriptor for output file

	// Let us now dump all the locations of the data memory now
	for (i=0; i<128; i=i+1) 
	begin
		$fdisplay(dmem0_dump_file, "Memory location #%d : %h ", i, DM_node0.MEM[i]);
	end
	$fclose(dmem0_dump_file);
	$finish;
	
end
	
endmodule
