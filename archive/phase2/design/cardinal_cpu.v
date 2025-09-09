module cardinal_cpu (
    clk, reset, instr_in, dmem_data_in,
    instr_addr, dmem_addr, dmem_data_out, dmem_En, dmem_WrEn
);

   // I/O Declarations
   input  clk, reset;                 // sync active-high reset
   output [0:31] instr_addr;          // address for instruction fetch
   input  [0:31] instr_in;            // fetched instruction
   
   output [0:31] dmem_addr;           // address for data memory
   output [0:63] dmem_data_out;       // data value written to memory
   output        dmem_En, dmem_WrEn;  // enable signals for data memory
   input  [0:63] dmem_data_in;        // data loaded from memory

   // Internal Pipeline Signals
   wire stall_pipeline;         // overall stall signal 
   reg branch_taken;            // if branch is taken, flush pipeline
   reg [0:31] branch_target;    // branch destination address

   // Opcode Definitions
   localparam OP_R_ALU  = 6'b101010, // generic R-type ALU
              OP_R_BEZ  = 6'b100010, // branch if zero
              OP_R_BNEZ = 6'b100011, // branch if not zero
              OP_R_NOP  = 6'b111100, // no-op
              OP_M_LD   = 6'b100000, // load
              OP_M_SD   = 6'b100001; // store

   // Partial-write modes
   localparam MODE_A = 3'b000,
              MODE_U = 3'b001,
              MODE_D = 3'b010,
              MODE_E = 3'b011,
              MODE_O = 3'b100;

   // ALU function codes
   localparam ALU_AND   = 6'b000001,
              ALU_OR    = 6'b000010,
              ALU_XOR   = 6'b000011,
              ALU_NOT   = 6'b000100,
              ALU_MOV   = 6'b000101,
              ALU_ADD   = 6'b000110,
              ALU_SUB   = 6'b000111,
              ALU_MULEU = 6'b001000,
              ALU_MULOU = 6'b001001,
              ALU_SLL   = 6'b001010,
              ALU_SRL   = 6'b001011,
              ALU_SRA   = 6'b001100,
              ALU_RTT   = 6'b001101,
              ALU_DIV   = 6'b001110,
              ALU_MOD   = 6'b001111, 
              ALU_SQEU  = 6'b010000,
              ALU_SQOU  = 6'b010001,
              ALU_SQRT  = 6'b010010;


// IF Stage: Program Counter and IF/ID Pipeline Reg
   reg [0:31] prog_counter; 
   reg [0:31] if_id_reg; 

   // Priority: reset > stall > branch
   always @(posedge clk) begin
       if (reset)
           prog_counter <= 32'b0;
       else if (stall_pipeline)
           prog_counter <= prog_counter;
       else if (branch_taken)
           prog_counter <= branch_target;
       else 
           prog_counter <= prog_counter + 4; 
   end

   assign instr_addr = prog_counter;

   // IF/ID pipeline register
   always @(posedge clk) begin
       if (reset)
           if_id_reg <= 32'b0; 
       else if (stall_pipeline)
           if_id_reg <= if_id_reg;
       else if (branch_taken)
           if_id_reg[0:5] <= OP_R_NOP;  // flush: convert to NOP
       else 
           if_id_reg <= instr_in;
   end


// ID Stage: Instruction Decode and RegFile Access
   wire [0:5] opcode_id;
   wire [0:4] rd_id, ra_id, rb_id;
   wire [0:2] sel_mode_id;
   wire [0:1] subfield_id;
   wire [0:5] alu_func_id;
   wire [0:15] immediate_id;

   // Break down IF/ID pipeline register
   assign opcode_id    = if_id_reg[0:5];
   assign rd_id        = if_id_reg[6:10];
   assign ra_id        = if_id_reg[11:15];
   assign rb_id        = if_id_reg[16:20];
   // For loads, partial-write mode forced to 3'b000
   assign sel_mode_id  = (opcode_id == OP_M_LD) ? 3'b000 : if_id_reg[21:23];
   assign subfield_id  = if_id_reg[24:25];
   assign alu_func_id  = if_id_reg[26:31];
   assign immediate_id = if_id_reg[16:31];

   // Register File signals
   reg  [0:4] regfile_raddr0, regfile_raddr1;
   wire [0:63] regfile_data0, regfile_data1;

   // Writeback signals from WB
   wire       rf_write_en_wb; 
   wire [0:2] wb_sel_mode;
   wire [0:4] rf_waddr_wb;
   wire [0:63] rf_wdata_wb;

   // Instantiate register file
   register_file RegFile (
       .clk(clk),
       .reset(reset),
       .write_enb(rf_write_en_wb),
       .di(rf_wdata_wb),
       .sel(wb_sel_mode),  
       .addr_wr(rf_waddr_wb),
       .addr_rd_0(regfile_raddr0),
       .addr_rd_1(regfile_raddr1),
       .do_0(regfile_data0),
       .do_1(regfile_data1)
   );

   // ID-stage control signals: dmem_En_id, dmem_WrEn_id, rf_write_en_id
   reg dmem_En_id, dmem_WrEn_id, rf_write_en_id;
   always @(*) begin
       dmem_En_id   = 1'b0;
       dmem_WrEn_id = 1'b0;
       rf_write_en_id = 1'b0;
       case (opcode_id)
           OP_R_ALU:   rf_write_en_id = 1'b1;
           OP_M_LD: begin
               rf_write_en_id = 1'b1;
               dmem_En_id     = 1'b1;
           end
           OP_M_SD: begin
               dmem_En_id     = 1'b1;
               dmem_WrEn_id   = 1'b1;
           end
           default: /* no action */ ;
       endcase
   end

   // Memory stall intention: store or load (destination != 0) => next stage stall
   wire stall_intent_mem;
   assign stall_intent_mem = ((opcode_id == OP_M_SD) || 
                             ((opcode_id == OP_M_LD) && (rd_id != 0)));

   // ALU stall intentions based on function codes
   wire stall_intent_alu5;
   assign stall_intent_alu5 = ((opcode_id == OP_R_ALU) &&
                               ((alu_func_id == ALU_DIV) || (alu_func_id == ALU_SQRT)) &&
                               (rd_id != 0)) ? 1'b1 : 1'b0;

   wire stall_intent_alu4;
   assign stall_intent_alu4 = ((opcode_id == OP_R_ALU) &&
                               ((alu_func_id == ALU_MULEU) || (alu_func_id == ALU_MULOU) ||
                                (alu_func_id == ALU_MOD)   || (alu_func_id == ALU_SQEU)  ||
                                (alu_func_id == ALU_SQOU)) &&
                               (rd_id != 0)) ? 1'b1 : 1'b0;

   wire stall_intent_alu3;
   assign stall_intent_alu3 = ((opcode_id == OP_R_ALU) &&
                               ((alu_func_id == ALU_ADD) || (alu_func_id == ALU_SUB)  ||
                                (alu_func_id == ALU_SLL) || (alu_func_id == ALU_SRL)  ||
                                (alu_func_id == ALU_SRA)) &&
                               (rd_id != 0)) ? 1'b1 : 1'b0;

   // Generate read addresses for register file
   always @(*) begin
       regfile_raddr1 = rb_id;
       if ((opcode_id == OP_M_SD) || (opcode_id == OP_R_BEZ) || (opcode_id == OP_R_BNEZ))
           regfile_raddr0 = rd_id;
       else
           regfile_raddr0 = ra_id;
   end

   // Hazard detection: compare rD of older instruction with rA/rB of current in ID
   reg hazard_rA_id, hazard_rB_id;
   wire write_en_exm;
   wire [0:4] rD_exm;
   always @(*) begin
       hazard_rA_id = 1'b0;
       hazard_rB_id = 1'b0;
       if ((write_en_exm == 1'b1) && (rD_exm != 0)) begin
           if (rD_exm == regfile_raddr0)
               hazard_rA_id = 1'b1;
           if (rD_exm == regfile_raddr1)
               hazard_rB_id = 1'b1;
       end
   end

   // Forwarding MUX in ID stage, from EX_MEM stage
   reg [0:63] rf_mux_out0, rf_mux_out1;
   reg [0:63] exm_regfile_wdata;
   wire [0:2] exm_sel_mode;
   always @(*) begin
       rf_mux_out0 = regfile_data0;
       rf_mux_out1 = regfile_data1;

       if (hazard_rA_id == 1'b1) begin
           case (exm_sel_mode)
               MODE_A: rf_mux_out0 = exm_regfile_wdata;
               MODE_U: rf_mux_out0[0:31]  = exm_regfile_wdata[0:31];
               MODE_D: rf_mux_out0[32:63] = exm_regfile_wdata[32:63];
               MODE_E: begin
                   rf_mux_out0[0:7]   = exm_regfile_wdata[0:7];
                   rf_mux_out0[16:23] = exm_regfile_wdata[16:23];
                   rf_mux_out0[32:39] = exm_regfile_wdata[32:39];
                   rf_mux_out0[48:55] = exm_regfile_wdata[48:55];
               end
               MODE_O: begin
                   rf_mux_out0[8:15]  = exm_regfile_wdata[8:15];
                   rf_mux_out0[24:31] = exm_regfile_wdata[24:31];
                   rf_mux_out0[40:47] = exm_regfile_wdata[40:47];
                   rf_mux_out0[56:63] = exm_regfile_wdata[56:63];
               end
           endcase
       end

       if (hazard_rB_id == 1'b1) begin
           case (exm_sel_mode)
               MODE_A: rf_mux_out1 = exm_regfile_wdata;
               MODE_U: rf_mux_out1[0:31]  = exm_regfile_wdata[0:31];
               MODE_D: rf_mux_out1[32:63] = exm_regfile_wdata[32:63];
               MODE_E: begin
                   rf_mux_out1[0:7]   = exm_regfile_wdata[0:7];
                   rf_mux_out1[16:23] = exm_regfile_wdata[16:23];
                   rf_mux_out1[32:39] = exm_regfile_wdata[32:39];
                   rf_mux_out1[48:55] = exm_regfile_wdata[48:55];
               end
               MODE_O: begin
                   rf_mux_out1[8:15]  = exm_regfile_wdata[8:15];
                   rf_mux_out1[24:31] = exm_regfile_wdata[24:31];
                   rf_mux_out1[40:47] = exm_regfile_wdata[40:47];
                   rf_mux_out1[56:63] = exm_regfile_wdata[56:63];
               end
           endcase
       end
   end

   // Branch logic
   always @(*) begin
       branch_taken  = 1'b0;
       branch_target = {32'b0, immediate_id};

       if ((opcode_id == OP_R_BEZ) && (rf_mux_out0 == 64'b0))
           branch_taken = 1'b1;
       if ((opcode_id == OP_R_BNEZ) && (rf_mux_out0 != 64'b0))
           branch_taken = 1'b1;
   end

   // Shadow register for stalling memory signals
   reg [0:97] shadow_reg;
   always @(posedge clk) begin
       if (reset)
           shadow_reg <= {98{1'b0}};
       else if (stall_pipeline)
           shadow_reg <= shadow_reg;
       else begin
           shadow_reg[0]     <= dmem_WrEn_id;
           shadow_reg[1]     <= dmem_En_id;
           shadow_reg[2:33]  <= {16'b0, immediate_id};
           shadow_reg[34:97] <= rf_mux_out0;
       end
   end

   // dmem_En, dmem_WrEn, dmem_addr, dmem_data_out 
   // either from ID stage or from shadow_reg if stall
   assign dmem_En       = (stall_pipeline) ? shadow_reg[1]    : dmem_En_id;
   assign dmem_WrEn     = (stall_pipeline) ? shadow_reg[0]    : dmem_WrEn_id;
   assign dmem_addr     = (stall_pipeline) ? shadow_reg[2:33] : {16'b0, immediate_id};
   assign dmem_data_out = (stall_pipeline) ? shadow_reg[34:97]: rf_mux_out0;

   // ID/EX_MEM pipeline register: 151 bits
   reg [0:150] id_exm_reg;
   always @(posedge clk) begin
       if (reset)
           id_exm_reg <= {151{1'b0}};
       else if (stall_pipeline)
           id_exm_reg <= id_exm_reg;
       else begin
           id_exm_reg[0:63]    <= rf_mux_out0;
           id_exm_reg[64:127]  <= rf_mux_out1;
           id_exm_reg[128]     <= stall_intent_mem;
           id_exm_reg[129:133] <= rd_id;
           id_exm_reg[134:136] <= sel_mode_id;
           id_exm_reg[137:138] <= subfield_id;
           id_exm_reg[139:144] <= alu_func_id;
           id_exm_reg[145:147] <= {dmem_En_id, dmem_WrEn_id, rf_write_en_id};
           id_exm_reg[148]     <= stall_intent_alu5;
           id_exm_reg[149]     <= stall_intent_alu4;
           id_exm_reg[150]     <= stall_intent_alu3;
       end
   end


// EX_MEM Stage
   wire dmem_En_exm, dmem_WrEn_exm;
   wire stall_mem_exm, stall_alu5_exm, stall_alu4_exm, stall_alu3_exm;
   wire [0:63] exm_dataA, exm_dataB, alu_result_exm;
   wire [0:5] alu_func_exm;
   wire [0:1] subfield_exm;
   assign stall_mem_exm   = id_exm_reg[128];
   assign rD_exm          = id_exm_reg[129:133];
   assign exm_sel_mode    = id_exm_reg[134:136];
   assign subfield_exm    = id_exm_reg[137:138];
   assign alu_func_exm    = id_exm_reg[139:144];
   assign {dmem_En_exm, dmem_WrEn_exm, write_en_exm} = id_exm_reg[145:147];
   assign stall_alu5_exm  = id_exm_reg[148];
   assign stall_alu4_exm  = id_exm_reg[149];
   assign stall_alu3_exm  = id_exm_reg[150];

   assign {exm_dataA, exm_dataB} = id_exm_reg[0:127];

   // ALU instantiation
   alu alu_exm_inst (
       .di_A(exm_dataA),
       .di_B(exm_dataB),
       .opcode(alu_func_exm),
       .fieldSelect(subfield_exm),
       .do(alu_result_exm)
   );

   // Single-cycle memory stall logic
   reg mem_stall_flipflop;
   reg mem_stall_signal;
   always @(posedge clk) begin
       if (reset)
           mem_stall_flipflop <= 1'b0;
       else if (stall_mem_exm == 1'b1)
           mem_stall_flipflop <= ~mem_stall_flipflop;
   end
   always @(*) begin
       mem_stall_signal = 1'b0;
       if ((stall_mem_exm == 1'b1) && (mem_stall_flipflop == 1'b0))
           mem_stall_signal = 1'b1;
   end

   // 5-cycle stall logic (DIV, SQRT)
   reg [0:2] stall5_reg;
   reg stall5_flag;
   always @(posedge clk) begin
       if (reset)
           stall5_reg <= 3'b000;
       else if (stall_alu5_exm == 1'b1) begin
           if (stall5_reg == 3'b100)
               stall5_reg <= 3'b000;
           else 
               stall5_reg <= stall5_reg + 1'b1;
       end
   end
   always @(*) begin
       stall5_flag = 1'b0;
       if ((stall_alu5_exm == 1'b1) &&
           ((stall5_reg == 3'b000) || (stall5_reg == 3'b001) ||
            (stall5_reg == 3'b010) || (stall5_reg == 3'b011)))
           stall5_flag = 1'b1;
   end

   // 4-cycle stall logic (MUL, MOD, SQ)
   reg [0:1] stall4_reg;
   reg stall4_flag;
   always @(posedge clk) begin
       if (reset)
           stall4_reg <= 2'b00;
       else if (stall_alu4_exm == 1'b1)
           stall4_reg <= stall4_reg + 1'b1;
   end
   always @(*) begin
       stall4_flag = 1'b0;
       if ((stall_alu4_exm == 1'b1) &&
           ((stall4_reg == 2'b00) || (stall4_reg == 2'b01) || (stall4_reg == 2'b10)))
           stall4_flag = 1'b1;
   end

   // 3-cycle stall logic (ADD, SUB, SHIFT)
   reg [0:1] stall3_reg;
   reg stall3_flag;
   always @(posedge clk) begin
       if (reset)
           stall3_reg <= 2'b00;
       else if (stall_alu3_exm == 1'b1) begin
           if (stall3_reg == 2'b10)
               stall3_reg <= 2'b00;
           else 
               stall3_reg <= stall3_reg + 1'b1;
       end
   end
   always @(*) begin
       stall3_flag = 1'b0;
       if ((stall_alu3_exm == 1'b1) &&
           ((stall3_reg == 2'b00) || (stall3_reg == 2'b01)))
           stall3_flag = 1'b1;
   end

   // Combine all stalls
   assign stall_pipeline = (stall5_flag || stall4_flag || stall3_flag || mem_stall_signal);

   // EX stage: choose data for register write (ALU vs memory)
   always @(*) begin
       exm_regfile_wdata = alu_result_exm; // default
       if (dmem_En_exm == 1'b1)
           exm_regfile_wdata = dmem_data_in;
   end

   // EX_MEM/WB pipeline register
   reg [0:72] exm_wb_reg;
   always @(posedge clk) begin
       if (reset)
           exm_wb_reg <= {73{1'b0}};
       else if (stall_pipeline)
           exm_wb_reg[64] <= 1'b0; // bubble
       else begin
           exm_wb_reg[0:63]  <= exm_regfile_wdata[0:63];
           exm_wb_reg[64]    <= write_en_exm;
           exm_wb_reg[65:67] <= exm_sel_mode;
           exm_wb_reg[68:72] <= rD_exm;
       end
   end


// WB Stage: Writeback to Register File
   assign rf_write_en_wb  = exm_wb_reg[64];
   assign wb_sel_mode     = exm_wb_reg[65:67];
   assign rf_waddr_wb     = exm_wb_reg[68:72];
   assign rf_wdata_wb     = exm_wb_reg[0:63];

endmodule
