module gold_nic
#(
    parameter PACKET_SIZE = 64
)
(
    input                           clk,
    input                           reset,       
    input      [0:1]                addr,        
    input      [0:PACKET_SIZE-1]    d_in,        
    output reg [0:PACKET_SIZE-1]    d_out,       
    input                           nicEn,       
    input                           nicEnWr,     

    input                           net_si,      
    output reg                    net_ri,      
    input      [0:PACKET_SIZE-1]    net_di,      

    output reg                    net_so,      
    input                           net_ro,      
    output reg [0:PACKET_SIZE-1]    net_do,      
    input                           net_polarity 
);

    // Internal signals for buffers
    reg  [0:PACKET_SIZE-1] input_buf_data_in;
    wire [0:PACKET_SIZE-1] input_buf_data_out;
    wire                   input_buf_full;
    reg                    input_buf_rd_en;
    reg                    input_buf_wr_en;
    
    reg  [0:PACKET_SIZE-1] output_buf_data_in;
    wire [0:PACKET_SIZE-1] output_buf_data_out;
    wire                   output_buf_full;
    reg                    output_buf_rd_en;
    reg                    output_buf_wr_en;

    // Input buffer instance
    buffer input_buffer_inst (
        .clk(clk),
        .reset(reset),
        .data_in(input_buf_data_in),
        .data_out(input_buf_data_out),
        .read_req(input_buf_rd_en),
        .write_req(input_buf_wr_en),
        .full(input_buf_full),
        .empty()
    );

    // Output buffer instance
    buffer output_buffer_inst (
        .clk(clk),
        .reset(reset),
        .data_in(output_buf_data_in),
        .data_out(output_buf_data_out),
        .read_req(output_buf_rd_en),
        .write_req(output_buf_wr_en),
        .full(output_buf_full),
        .empty()
    );

    // Processor read/write logic
    always @(*) begin
        output_buf_wr_en   = 1'b0;
        input_buf_rd_en    = 1'b0;
        d_out              = {PACKET_SIZE{1'b0}};
        output_buf_data_in = d_in;

        if (nicEn) begin
            if (nicEnWr) begin
                if (addr == 2'b10)
                    output_buf_wr_en = 1'b1;
            end else begin
                case (addr)
                    2'b00: begin
                        input_buf_rd_en = 1'b1;
                        d_out = input_buf_data_out;
                    end
                    2'b01: d_out[63] = input_buf_full;
                    2'b11: d_out[63] = output_buf_full;
                    default: d_out = {PACKET_SIZE{1'b0}};
                endcase
            end
        end
    end

    // Reception logic
    always @(*) begin
        input_buf_data_in = net_di;
        net_ri = (input_buf_full == 1'b0);
        input_buf_wr_en = ((input_buf_full == 1'b0) && net_si) ? 1'b1 : 1'b0;
    end

    // Transmission logic
    always @(*) begin
        net_do = output_buf_data_out;
        net_so = 1'b0;
        if (output_buf_full && net_ro) begin
            if (net_polarity && (output_buf_data_out[0] == 1'b0))
                net_so = 1'b1;
            else if (!net_polarity && (output_buf_data_out[0] == 1'b1))
                net_so = 1'b1;
        end
        output_buf_rd_en = (net_so && net_ro) ? 1'b1 : 1'b0;
    end

endmodule
