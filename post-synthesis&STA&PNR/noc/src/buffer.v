// Buffer Module

`define WIDTH 64
module buffer
(
    input clk, reset,
    input read_req, write_req, //read request and write request
    input [`WIDTH - 1:0] data_in,
    output [`WIDTH - 1:0] data_out,
    output full, empty
);
    reg [`WIDTH - 1:0] mem; // memory location

    // is_full 0 means empty, 1 means full
    reg is_full;
    assign full = is_full;
    assign empty = ~is_full;

    wire read_enb, write_enb;
    assign read_enb = (read_req & is_full);
    assign write_enb = (write_req & !is_full);

    // sequential logic
    always @(posedge clk)
    begin
        if(reset)
        begin
            is_full <= 0; // initial state is empty
            mem <= 0;
        end
        else
        begin
            // read_enb and write_enb are exclusive at same clk
            if(read_enb) is_full <= 0;

            else if(write_enb)
                begin
                    mem <= data_in;
                    is_full <= 1;
                end
        end
    end

    assign data_out = mem;
    
endmodule
`undef WIDTH