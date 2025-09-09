// Router module

module gold_router 
#(
    parameter PACKET_SIZE = 64 // assume flit = packet size
)
(
    input clk, reset, polarity, // sync high active reset

    // clockwise stream (west->east)
    input cwsi,               // "send" from west neighbor
    output reg cwri,          // "ready" back to west neighbor
    input  [PACKET_SIZE-1:0] cwdi,

    output cwso,             // "send" from router to east neighbor
    input  cwro,             // "ready" from east neighbor
    output [PACKET_SIZE-1:0] cwdo,

    // counter-clockwise stream (east->west)
    input ccwsi,
    output reg ccwri,
    input  [PACKET_SIZE-1:0] ccwdi,

    output ccwso,
    input  ccwro,
    output [PACKET_SIZE-1:0] ccwdo,

    // north->south
    input nssi,
    output reg nsri,
    input  [PACKET_SIZE-1:0] nsdi,

    output nsso,
    input  nsro,
    output [PACKET_SIZE-1:0] nsdo,

    // south->north
    input snsi,
    output reg snri,
    input  [PACKET_SIZE-1:0] sndi,

    output snso,
    input  snro,
    output [PACKET_SIZE-1:0] sndo,

    // local process element
    input pesi,
    output reg peri,
    input  [PACKET_SIZE-1:0] pedi,

    output peso,
    input  pero,
    output [PACKET_SIZE-1:0] pedo
);


// INPUT BUFFERS
    // cw
    wire full_cwi_v0,   full_cwi_v1;
    wire empty_cwi_v0,  empty_cwi_v1;
    reg  rdReq_cwi_v0,  rdReq_cwi_v1;
    reg  wrReq_cwi_v0,  wrReq_cwi_v1;
    wire [PACKET_SIZE-1:0] do_cwi_v0, do_cwi_v1;

    buffer buf_cwi_v0 (
    .clk(clk), .reset(reset),
    .full(full_cwi_v0),
    .empty(empty_cwi_v0),
    .read_req(rdReq_cwi_v0),
    .write_req(wrReq_cwi_v0),
    .data_in(cwdi),
    .data_out(do_cwi_v0)
    );

    buffer buf_cwi_v1 (
    .clk(clk), .reset(reset),
    .full(full_cwi_v1),
    .empty(empty_cwi_v1),
    .read_req(rdReq_cwi_v1),
    .write_req(wrReq_cwi_v1),
    .data_in(cwdi),
    .data_out(do_cwi_v1)
    );

    // ccw
    wire full_ccwi_v0,   full_ccwi_v1;
    wire empty_ccwi_v0,  empty_ccwi_v1;
    reg  rdReq_ccwi_v0,  rdReq_ccwi_v1;
    reg  wrReq_ccwi_v0,  wrReq_ccwi_v1;
    wire [PACKET_SIZE-1:0] do_ccwi_v0, do_ccwi_v1;

    buffer buf_ccwi_v0 (
    .clk(clk), .reset(reset),
    .full(full_ccwi_v0),
    .empty(empty_ccwi_v0),
    .read_req(rdReq_ccwi_v0),
    .write_req(wrReq_ccwi_v0),
    .data_in(ccwdi),
    .data_out(do_ccwi_v0)
    );

    buffer buf_ccwi_v1 (
    .clk(clk), .reset(reset),
    .full(full_ccwi_v1),
    .empty(empty_ccwi_v1),
    .read_req(rdReq_ccwi_v1),
    .write_req(wrReq_ccwi_v1),
    .data_in(ccwdi),
    .data_out(do_ccwi_v1)
    );

    // nssi
    wire full_nsi_v0,   full_nsi_v1;
    wire empty_nsi_v0,  empty_nsi_v1;
    reg  rdReq_nsi_v0,  rdReq_nsi_v1;
    reg  wrReq_nsi_v0,  wrReq_nsi_v1;
    wire [PACKET_SIZE-1:0] do_nsi_v0, do_nsi_v1;

    buffer buf_nsi_v0 (
    .clk(clk), .reset(reset),
    .full(full_nsi_v0),
    .empty(empty_nsi_v0),
    .read_req(rdReq_nsi_v0),
    .write_req(wrReq_nsi_v0),
    .data_in(nsdi),
    .data_out(do_nsi_v0)
    );

    buffer buf_nsi_v1 (
    .clk(clk), .reset(reset),
    .full(full_nsi_v1),
    .empty(empty_nsi_v1),
    .read_req(rdReq_nsi_v1),
    .write_req(wrReq_nsi_v1),
    .data_in(nsdi),
    .data_out(do_nsi_v1)
    );

    // snsi
    wire full_sni_v0,   full_sni_v1;
    wire empty_sni_v0,  empty_sni_v1;
    reg  rdReq_sni_v0,  rdReq_sni_v1;
    reg  wrReq_sni_v0,  wrReq_sni_v1;
    wire [PACKET_SIZE-1:0] do_sni_v0, do_sni_v1;

    buffer buf_sni_v0 (
    .clk(clk), .reset(reset),
    .full(full_sni_v0),
    .empty(empty_sni_v0),
    .read_req(rdReq_sni_v0),
    .write_req(wrReq_sni_v0),
    .data_in(sndi),
    .data_out(do_sni_v0)
    );

    buffer buf_sni_v1 (
    .clk(clk), .reset(reset),
    .full(full_sni_v1),
    .empty(empty_sni_v1),
    .read_req(rdReq_sni_v1),
    .write_req(wrReq_sni_v1),
    .data_in(sndi),
    .data_out(do_sni_v1)
    );

    // PE input
    wire full_pei_v0,   full_pei_v1;
    wire empty_pei_v0,  empty_pei_v1;
    reg  rdReq_pei_v0,  rdReq_pei_v1;
    reg  wrReq_pei_v0,  wrReq_pei_v1;
    wire [PACKET_SIZE-1:0] do_pei_v0, do_pei_v1;

    buffer buf_pei_v0 (
    .clk(clk), .reset(reset),
    .full(full_pei_v0),
    .empty(empty_pei_v0),
    .read_req(rdReq_pei_v0),
    .write_req(wrReq_pei_v0),
    .data_in(pedi),
    .data_out(do_pei_v0)
    );

    buffer buf_pei_v1 (
    .clk(clk), .reset(reset),
    .full(full_pei_v1),
    .empty(empty_pei_v1),
    .read_req(rdReq_pei_v1),
    .write_req(wrReq_pei_v1),
    .data_in(pedi),
    .data_out(do_pei_v1)
    );


// DECODE HEADERS
    wire vc_cwi   = cwdi[63];
    wire vc_ccwi  = ccwdi[63];
    wire vc_nsi   = nsdi[63];
    wire vc_sni   = sndi[63];
    wire vc_pei   = pedi[63];


// SELECT WHICH VC buffer (v0 or v1) GETS WRITTEN
    always @(*) begin
        // defaults
        wrReq_cwi_v0  = 1'b0; 
        wrReq_cwi_v1  = 1'b0;
        wrReq_ccwi_v0 = 1'b0; 
        wrReq_ccwi_v1 = 1'b0;
        wrReq_nsi_v0  = 1'b0; 
        wrReq_nsi_v1  = 1'b0;
        wrReq_sni_v0  = 1'b0; 
        wrReq_sni_v1  = 1'b0;
        wrReq_pei_v0  = 1'b0; 
        wrReq_pei_v1  = 1'b0;

        // For each input side:
        // a) We require "si && ri" => handshake
        // b) We check vc_* => 0 => v0, 1 => v1
        // c) Then wrReq_*_v0 or v1 = 1

        // cw
        if (cwsi && cwri) begin
            if (vc_cwi==1'b0) wrReq_cwi_v0 = 1;
            else              wrReq_cwi_v1 = 1;
        end

        // ccw
        if (ccwsi && ccwri) begin
            if (vc_ccwi==1'b0) wrReq_ccwi_v0 = 1;
            else               wrReq_ccwi_v1 = 1;
        end

        // ns
        if (nssi && nsri) begin
            if (vc_nsi==1'b0) wrReq_nsi_v0 = 1;
            else              wrReq_nsi_v1 = 1;
        end

        // sn
        if (snsi && snri) begin
            if (vc_sni==1'b0) wrReq_sni_v0 = 1;
            else              wrReq_sni_v1 = 1;
        end

        // pe
        if (pesi && peri) begin
            if (vc_pei==1'b0) wrReq_pei_v0 = 1;
            else              wrReq_pei_v1 = 1;
        end
    end


// READY SIGNALS: "ri" => not full of the
    always @(*) begin
    // cwri depends on whether vc_cwi=0 or 1
    if (vc_cwi==1'b0)
        cwri = ~full_cwi_v0; // if v0 is not full => we can accept
    else
        cwri = ~full_cwi_v1;

    // ccwri
    if (vc_ccwi==1'b0)
        ccwri = ~full_ccwi_v0;
    else
        ccwri = ~full_ccwi_v1;

    // nsri
    if (vc_nsi==1'b0)
        nsri = ~full_nsi_v0;
    else
        nsri = ~full_nsi_v1;

    // snri
    if (vc_sni==1'b0)
        snri = ~full_sni_v0;
    else
        snri = ~full_sni_v1;

    // peri
    if (vc_pei==1'b0)
        peri = ~full_pei_v0;
    else
        peri = ~full_pei_v1;
    end


// Output buffers wires & regs
    wire full_cwo_v0, full_cwo_v1, full_ccwo_v0, full_ccwo_v1, full_nso_v0, full_nso_v1, full_sno_v0, full_sno_v1, full_peo_v0, full_peo_v1;
    wire empty_cwo_v0, empty_cwo_v1, empty_ccwo_v0, empty_ccwo_v1, empty_nso_v0, empty_nso_v1, empty_sno_v0, empty_sno_v1, empty_peo_v0, empty_peo_v1;
    wire rdReq_cwo_v0, rdReq_cwo_v1, rdReq_ccwo_v0, rdReq_ccwo_v1, rdReq_nso_v0, rdReq_nso_v1, rdReq_sno_v0, rdReq_sno_v1, rdReq_peo_v0, rdReq_peo_v1;
    reg wrReq_cwo_v0, wrReq_cwo_v1, wrReq_ccwo_v0, wrReq_ccwo_v1, wrReq_nso_v0, wrReq_nso_v1, wrReq_sno_v0, wrReq_sno_v1, wrReq_peo_v0, wrReq_peo_v1;
    reg [PACKET_SIZE - 1:0] di_cwo_v0, di_cwo_v1, di_ccwo_v0, di_ccwo_v1, di_nso_v0, di_nso_v1, di_sno_v0, di_sno_v1, di_peo_v0, di_peo_v1;
    wire [PACKET_SIZE - 1:0] do_cwo_v0, do_cwo_v1, do_ccwo_v0, do_ccwo_v1, do_nso_v0, do_nso_v1, do_sno_v0, do_sno_v1, do_peo_v0, do_peo_v1;

// Output buffers
    // clockwise input virtual channels
    buffer buf_cwo_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_cwo_v0),
        .empty(empty_cwo_v0),
        .read_req(rdReq_cwo_v0),
        .write_req(wrReq_cwo_v0),
        .data_in(di_cwo_v0),
        .data_out(do_cwo_v0)
    );

    buffer buf_cwo_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_cwo_v1),
        .empty(empty_cwo_v1),
        .read_req(rdReq_cwo_v1),
        .write_req(wrReq_cwo_v1),
        .data_in(di_cwo_v1),
        .data_out(do_cwo_v1)
    );

    // counter-clockwise input virtual channels
    buffer buf_ccwo_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_ccwo_v0),
        .empty(empty_ccwo_v0),
        .read_req(rdReq_ccwo_v0),
        .write_req(wrReq_ccwo_v0),
        .data_in(di_ccwo_v0),
        .data_out(do_ccwo_v0)
    );

    buffer buf_ccwo_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_ccwo_v1),
        .empty(empty_ccwo_v1),
        .read_req(rdReq_ccwo_v1),
        .write_req(wrReq_ccwo_v1),
        .data_in(di_ccwo_v1),
        .data_out(do_ccwo_v1)
    );

    // north-to-south input virtual channels
    buffer buf_nso_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_nso_v0),
        .empty(empty_nso_v0),
        .read_req(rdReq_nso_v0),
        .write_req(wrReq_nso_v0),
        .data_in(di_nso_v0),
        .data_out(do_nso_v0)
    );

    buffer buf_nso_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_nso_v1),
        .empty(empty_nso_v1),
        .read_req(rdReq_nso_v1),
        .write_req(wrReq_nso_v1),
        .data_in(di_nso_v1),
        .data_out(do_nso_v1)
    );

    // south-to-north input virtual channels
    buffer buf_sno_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_sno_v0),
        .empty(empty_sno_v0),
        .read_req(rdReq_sno_v0),
        .write_req(wrReq_sno_v0),
        .data_in(di_sno_v0),
        .data_out(do_sno_v0)
    );

    buffer buf_sno_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_sno_v1),
        .empty(empty_sno_v1),
        .read_req(rdReq_sno_v1),
        .write_req(wrReq_sno_v1),
        .data_in(di_sno_v1),
        .data_out(do_sno_v1)
    );

    // process element input virtual channels
    buffer buf_peo_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_peo_v0),
        .empty(empty_peo_v0),
        .read_req(rdReq_peo_v0),
        .write_req(wrReq_peo_v0),
        .data_in(di_peo_v0),
        .data_out(do_peo_v0)
    );   

    buffer buf_peo_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_peo_v1),
        .empty(empty_peo_v1),
        .read_req(rdReq_peo_v1),
        .write_req(wrReq_peo_v1),
        .data_in(di_peo_v1),
        .data_out(do_peo_v1)
    );  


// Internal Request Signals.
    // If the input buffer is full and target output buffer is empty, the input buffer will send request to that output buffer
    // dir bits: do[62] == 0 to right
    //           do[62] == 1 to left
    //           do[61] == 0 to south
    //           do[61] == 1 to north

    reg req_cwi_cwo, req_cwi_nso, req_cwi_sno, req_cwi_peo;
    reg req_ccwi_ccwo, req_ccwi_nso, req_ccwi_sno, req_ccwi_peo;
    reg req_nsi_nso, req_nsi_peo;
    reg req_sni_sno, req_sni_peo;
    reg req_pei_cwo, req_pei_ccwo, req_pei_nso, req_pei_sno;

// Virtual channel multiplexing: routing request from input buffer to output buffer.
    always @(*) 
    begin

        req_cwi_cwo  = 0; req_cwi_nso  = 0; req_cwi_sno  = 0; req_cwi_peo  = 0;
        req_ccwi_ccwo= 0; req_ccwi_nso = 0; req_ccwi_sno = 0; req_ccwi_peo = 0;
        req_nsi_nso  = 0; req_nsi_peo  = 0;
        req_sni_sno  = 0; req_sni_peo  = 0;
        req_pei_cwo  = 0; req_pei_ccwo = 0; req_pei_nso = 0; req_pei_sno  = 0;

        if (polarity == 0) 
        begin
            //-------------------------------------------------
            // cwi_v0 => cwo / nso / sno / peo
            //-------------------------------------------------
            if (full_cwi_v0) begin
                if (do_cwi_v0[52] != 0) begin
                    // horizontal hop
                    if (do_cwi_v0[62] == 1'b0) begin
                        // cwi->cwo
                        if (empty_cwo_v0) req_cwi_cwo = 1;
                    end
                end
                else if (do_cwi_v0[48] != 0) begin
                    // vertical hop
                    if (do_cwi_v0[61] == 1'b0) begin
                        // cwi->nso
                        if (empty_nso_v0) req_cwi_nso = 1;
                    end
                    else begin
                        // cwi->sno
                        if (empty_sno_v0) req_cwi_sno = 1;
                    end
                end
                else begin
                    // local => cwi->peo
                    if (empty_peo_v0) req_cwi_peo = 1;
                end
            end

            //-------------------------------------------------
            // ccwi_v0 => ccwo / nso / sno / peo
            //-------------------------------------------------
            if (full_ccwi_v0) begin
                if (do_ccwi_v0[52] != 0) begin
                    // horizontal hop
                    if (do_ccwi_v0[62] == 1'b1) begin
                        // ccwi->ccwo
                        if (empty_ccwo_v0) req_ccwi_ccwo = 1;
                    end
                end
                else if (do_ccwi_v0[48] != 0) begin
                    // vertical
                    if (do_ccwi_v0[61] == 1'b0) begin
                        // ccwi->nso
                        if (empty_nso_v0) req_ccwi_nso = 1;
                    end
                    else begin
                        // ccwi->sno
                        if (empty_sno_v0) req_ccwi_sno = 1;
                    end
                end
                else begin
                    // local => ccwi->peo
                    if (empty_peo_v0) req_ccwi_peo = 1;
                end
            end

            //-------------------------------------------------
            // nsi_v0 => nso / peo
            //-------------------------------------------------
            if (full_nsi_v0) begin
                if (do_nsi_v0[48] != 0) begin
                    // vertical
                    if (do_nsi_v0[61] == 1'b0) begin
                        // nsi->nso
                        if (empty_nso_v0) req_nsi_nso = 1;
                    end
                end
                else begin
                    // local => nsi->peo
                    if (empty_peo_v0) req_nsi_peo = 1;
                end
            end

            //-------------------------------------------------
            // sni_v0 => sno / peo
            //-------------------------------------------------
            if (full_sni_v0) begin
                if (do_sni_v0[48] != 0) begin
                    // vertical
                    if (do_sni_v0[61] == 1'b1) begin
                        // sni->sno
                        if (empty_sno_v0) req_sni_sno = 1;
                    end
                end
                else begin
                    // local => sni->peo
                    if (empty_peo_v0) req_sni_peo = 1;
                end
            end

            //-------------------------------------------------
            // pei_v0 => cwo / ccwo / nso / sno
            //-------------------------------------------------
            if (full_pei_v0) begin
                if (do_pei_v0[52] != 0) begin
                    // horizontal
                    if (do_pei_v0[62] == 1'b0) begin
                        // pei->cwo
                        if (empty_cwo_v0) req_pei_cwo = 1;
                    end
                    else begin
                        // pei->ccwo
                        if (empty_ccwo_v0) req_pei_ccwo = 1;
                    end
                end
                else if (do_pei_v0[48] != 0) begin
                    // vertical
                    if (do_pei_v0[61] == 1'b0) begin
                        // pei->nso
                        if (empty_nso_v0) req_pei_nso = 1;
                    end
                    else begin
                        // pei->sno
                        if (empty_sno_v0) req_pei_sno = 1;
                    end
                end
            end

        end
        else // if (polarity==0)
        begin

            //---------------- cwi_v1 => cwo/nso/sno/peo
            if (full_cwi_v1) begin
                if (do_cwi_v1[52] != 0) begin
                    if (do_cwi_v1[62] == 1'b0) begin
                        if (empty_cwo_v1) req_cwi_cwo = 1;
                    end
                end
                else if (do_cwi_v1[48] != 0) begin
                    if (do_cwi_v1[61] == 1'b0) begin
                        if (empty_nso_v1) req_cwi_nso = 1;
                    end
                    else begin
                        if (empty_sno_v1) req_cwi_sno = 1;
                    end
                end
                else begin
                    if (empty_peo_v1) req_cwi_peo = 1;
                end
            end

            //---------------- ccwi_v1 => ccwo/nso/sno/peo
            if (full_ccwi_v1) begin
                if (do_ccwi_v1[52] != 0) begin
                    if (do_ccwi_v1[62] == 1'b1) begin
                        if (empty_ccwo_v1) req_ccwi_ccwo = 1;
                    end
                end
                else if (do_ccwi_v1[48] != 0) begin
                    if (do_ccwi_v1[61] == 1'b0) begin
                        if (empty_nso_v1) req_ccwi_nso = 1;
                    end
                    else begin
                        if (empty_sno_v1) req_ccwi_sno = 1;
                    end
                end
                else begin
                    if (empty_peo_v1) req_ccwi_peo = 1;
                end
            end

            //---------------- nsi_v1 => nso/peo
            if (full_nsi_v1) begin
                if (do_nsi_v1[48] != 0) begin
                    if (do_nsi_v1[61] == 1'b0) begin
                        if (empty_nso_v1) req_nsi_nso = 1;
                    end
                end
                else begin
                    if (empty_peo_v1) req_nsi_peo = 1;
                end
            end

            //---------------- sni_v1 => sno/peo
            if (full_sni_v1) begin
                if (do_sni_v1[48] != 0) begin
                    if (do_sni_v1[61] == 1'b1) begin
                        if (empty_sno_v1) req_sni_sno = 1;
                    end
                    else begin
                        // skip
                    end
                end
                else begin
                    if (empty_peo_v1) req_sni_peo = 1;
                end
            end

            //---------------- pei_v1 => cwo/ccwo/nso/sno
            if (full_pei_v1) begin
                if (do_pei_v1[52] != 0) begin
                    if (do_pei_v1[62] == 1'b0) begin
                        if (empty_cwo_v1) req_pei_cwo = 1;
                    end
                    else begin
                        if (empty_ccwo_v1) req_pei_ccwo = 1;
                    end
                end
                else if (do_pei_v1[48] != 0) begin
                    if (do_pei_v1[61] == 1'b0) begin
                        if (empty_nso_v1) req_pei_nso = 1;
                    end
                    else begin
                        if (empty_sno_v1) req_pei_sno = 1;
                    end
                end
            end

        end // else (polarity==1)
    end // always @(*)



// Internal grant signals.
    wire gnt_cwi_cwo, gnt_cwi_nso, gnt_cwi_sno, gnt_cwi_peo; 
    wire gnt_ccwi_ccwo, gnt_ccwi_nso, gnt_ccwi_sno, gnt_ccwi_peo;
    wire gnt_nsi_nso, gnt_nsi_peo;
    wire gnt_sni_sno, gnt_sni_peo;
    wire gnt_pei_cwo, gnt_pei_ccwo, gnt_pei_nso, gnt_pei_sno;

// Arbiters
    // Arbiter for requests sent to cwo
    arbiter #(.NUM_REQ(2), .INIT_PRIO(0)) arb_cwo (
        .clk      (clk),
        .reset    (reset),
        .polarity (polarity),
        .req_0    (req_cwi_cwo),
        .req_1    (req_pei_cwo),
        .req_2    (1'b0),
        .req_3    (1'b0),
        .gnt_0    (gnt_cwi_cwo),
        .gnt_1    (gnt_pei_cwo),
        .gnt_2    (),
        .gnt_3    (),
        .debug_last_gnt_v0(),
        .debug_last_gnt_v1()
    );

    // Arbiter for requests sent to ccwo
    arbiter #(.NUM_REQ(2), .INIT_PRIO(0)) arb_ccwo (
        .clk      (clk),
        .reset    (reset),
        .polarity (polarity),
        .req_0    (req_ccwi_ccwo),
        .req_1    (req_pei_ccwo),
        .req_2    (1'b0),
        .req_3    (1'b0),
        .gnt_0    (gnt_ccwi_ccwo),
        .gnt_1    (gnt_pei_ccwo),
        .gnt_2    (),
        .gnt_3    (),
        .debug_last_gnt_v0(),
        .debug_last_gnt_v1()
    );

    // Arbiter for requests sent to nso
    arbiter #(.NUM_REQ(4), .INIT_PRIO(0)) arb_nso (
        .clk      (clk),
        .reset    (reset),
        .polarity (polarity),
        .req_0    (req_cwi_nso),
        .req_1    (req_ccwi_nso),
        .req_2    (req_pei_nso),
        .req_3    (req_nsi_nso),
        .gnt_0    (gnt_cwi_nso),
        .gnt_1    (gnt_ccwi_nso),
        .gnt_2    (gnt_pei_nso),
        .gnt_3    (gnt_nsi_nso),
        .debug_last_gnt_v0(),
        .debug_last_gnt_v1()
    );

    // Arbiter for requests sent to sno
    arbiter #(.NUM_REQ(4), .INIT_PRIO(0)) arb_sno (
        .clk      (clk),
        .reset    (reset),
        .polarity (polarity),
        .req_0    (req_cwi_sno),
        .req_1    (req_ccwi_sno),
        .req_2    (req_pei_sno),
        .req_3    (req_sni_sno),
        .gnt_0    (gnt_cwi_sno),
        .gnt_1    (gnt_ccwi_sno),
        .gnt_2    (gnt_pei_sno),
        .gnt_3    (gnt_sni_sno),
        .debug_last_gnt_v0(),
        .debug_last_gnt_v1()
    );

    // Arbiter for requests sent to peo
    arbiter #(.NUM_REQ(4), .INIT_PRIO(0)) arb_peo (
        .clk      (clk),
        .reset    (reset),
        .polarity (polarity),
        .req_0    (req_cwi_peo),
        .req_1    (req_ccwi_peo),
        .req_2    (req_nsi_peo),
        .req_3    (req_sni_peo),
        .gnt_0    (gnt_cwi_peo),
        .gnt_1    (gnt_ccwi_peo),
        .gnt_2    (gnt_nsi_peo),
        .gnt_3    (gnt_sni_peo),
        .debug_last_gnt_v0(),
        .debug_last_gnt_v1()
    );

    
// Load data into output buffer based on arbitration on grant signals
    always @(*)
    begin
        // reset
        rdReq_cwi_v0 = 0;
        rdReq_cwi_v1 = 0;
        rdReq_nsi_v0 = 0; 
        rdReq_nsi_v1 = 0; 
        rdReq_sni_v0 = 0; 
        rdReq_sni_v1 = 0;
        rdReq_ccwi_v0 = 0;
        rdReq_ccwi_v1 = 0;
        rdReq_pei_v0 = 0;
        rdReq_pei_v1 = 0;
        
        wrReq_cwo_v0 = 0;
        wrReq_cwo_v1 = 0;
        wrReq_ccwo_v0 = 0;
        wrReq_ccwo_v1 = 0;
        wrReq_nso_v0 = 0; 
        wrReq_nso_v1 = 0; 
        wrReq_sno_v0 = 0; 
        wrReq_sno_v1 = 0;
        wrReq_peo_v0 = 0;
        wrReq_peo_v1 = 0;

        di_cwo_v0 = 64'bx;
        di_cwo_v1 = 64'bx;
        di_ccwo_v0 = 64'bx;
        di_ccwo_v1 = 64'bx;
        di_nso_v0 = 64'bx; 
        di_nso_v1 = 64'bx; 
        di_sno_v0 = 64'bx; 
        di_sno_v1 = 64'bx;
        di_peo_v0 = 64'bx;
        di_peo_v1 = 64'bx;

        if (polarity == 0) 
        begin
            // cwi -> cwo
            if (gnt_cwi_cwo) begin
                rdReq_cwi_v0 = 1;
                wrReq_cwo_v0 = 1;
                di_cwo_v0    = do_cwi_v0;
                di_cwo_v0[55 -: 4] = do_cwi_v0[55 -: 4] >> 1;
            end

            // cwi -> nso
            if (gnt_cwi_nso) begin
                rdReq_cwi_v0 = 1;
                wrReq_nso_v0 = 1;
                di_nso_v0    = do_cwi_v0;   // (source cwi)
                di_nso_v0[51 -: 4] = do_cwi_v0[51 -: 4] >> 1;
            end

            // cwi -> sno
            if (gnt_cwi_sno) begin
                rdReq_cwi_v0 = 1;
                wrReq_sno_v0 = 1;
                di_sno_v0    = do_cwi_v0;
                di_sno_v0[51 -: 4] = do_cwi_v0[51 -: 4] >> 1;
            end

            // cwi -> peo
            if (gnt_cwi_peo) begin
                rdReq_cwi_v0 = 1;
                wrReq_peo_v0 = 1;
                di_peo_v0    = do_cwi_v0;
            end

            // ccwi -> ccwo
            if (gnt_ccwi_ccwo) begin
                rdReq_ccwi_v0 = 1;
                wrReq_ccwo_v0 = 1;
                di_ccwo_v0    = do_ccwi_v0;
                di_ccwo_v0[55 -: 4] = do_ccwi_v0[55 -: 4] >> 1;
            end

            // ccwi -> nso
            if (gnt_ccwi_nso) begin
                rdReq_ccwi_v0 = 1;
                wrReq_nso_v0 = 1;
                di_nso_v0    = do_ccwi_v0;
                di_nso_v0[51 -: 4] = do_ccwi_v0[51 -: 4] >> 1; // if that's your vertical shift
            end

            // ccwi -> sno
            if (gnt_ccwi_sno) begin
                rdReq_ccwi_v0 = 1;
                wrReq_sno_v0 = 1;
                di_sno_v0    = do_ccwi_v0;
                di_sno_v0[51 -: 4] = do_ccwi_v0[51 -: 4] >> 1;
            end

            // ccwi -> peo
            if (gnt_ccwi_peo) begin
                rdReq_ccwi_v0 = 1;
                wrReq_peo_v0  = 1;
                di_peo_v0     = do_ccwi_v0;
            end

            // nsi -> nso
            if (gnt_nsi_nso) begin
                rdReq_nsi_v0 = 1;
                wrReq_nso_v0 = 1;
                di_nso_v0    = do_nsi_v0;
                di_nso_v0[51 -: 4] = do_nsi_v0[51 -: 4] >> 1;
            end

            // nsi -> peo
            if (gnt_nsi_peo) begin
                rdReq_nsi_v0 = 1;
                wrReq_peo_v0 = 1;            // local => peo
                di_peo_v0    = do_nsi_v0;
            end

            // sni -> sno
            if (gnt_sni_sno) begin
                rdReq_sni_v0 = 1;
                wrReq_sno_v0 = 1;
                di_sno_v0    = do_sni_v0;
                di_sno_v0[51 -: 4] = do_sni_v0[51 -: 4] >> 1;
            end

            // sni -> peo
            if (gnt_sni_peo) begin
                rdReq_sni_v0 = 1;
                wrReq_peo_v0 = 1;
                di_peo_v0    = do_sni_v0;
            end

            // pei -> cwo, ccwo, nso, sno
            if (gnt_pei_cwo) begin
                rdReq_pei_v0 = 1;
                wrReq_cwo_v0 = 1;
                di_cwo_v0    = do_pei_v0;
                di_cwo_v0[55 -: 4] = do_pei_v0[55 -: 4] >> 1;
            end

            if (gnt_pei_ccwo) begin
                rdReq_pei_v0 = 1;
                wrReq_ccwo_v0= 1;
                di_ccwo_v0   = do_pei_v0;
                di_ccwo_v0[55 -: 4] = do_pei_v0[55 -: 4] >> 1;
            end

            if (gnt_pei_nso) begin
                rdReq_pei_v0 = 1;
                wrReq_nso_v0 = 1;
                di_nso_v0    = do_pei_v0;
                di_nso_v0[51 -: 4] = do_pei_v0[51 -: 4] >> 1;
            end

            if (gnt_pei_sno) begin
                rdReq_pei_v0 = 1;
                wrReq_sno_v0 = 1;
                di_sno_v0    = do_pei_v0;
                di_sno_v0[51 -: 4] = do_pei_v0[51 -: 4] >> 1;
            end

        end
        else // if (polarity==0)
        begin
            // cwi -> cwo
            if (gnt_cwi_cwo) begin
                rdReq_cwi_v1 = 1;
                wrReq_cwo_v1 = 1;
                di_cwo_v1    = do_cwi_v1;
                di_cwo_v1[55 -: 4] = do_cwi_v1[55 -: 4] >> 1;
            end

            // cwi->nso
            if (gnt_cwi_nso) begin
                rdReq_cwi_v1 = 1;
                wrReq_nso_v1 = 1;
                di_nso_v1    = do_cwi_v1;
                di_nso_v1[51 -: 4] = do_cwi_v1[51 -: 4] >> 1;
            end

            // cwi->sno
            if (gnt_cwi_sno) begin
                rdReq_cwi_v1 = 1;
                wrReq_sno_v1 = 1;
                di_sno_v1    = do_cwi_v1;
                di_sno_v1[51 -: 4] = do_cwi_v1[51 -: 4] >> 1;
            end

            // cwi->peo
            if (gnt_cwi_peo) begin
                rdReq_cwi_v1 = 1;
                wrReq_peo_v1 = 1;
                di_peo_v1    = do_cwi_v1;
            end

            // ccwi->ccwo
            if (gnt_ccwi_ccwo) begin
                rdReq_ccwi_v1 = 1;
                wrReq_ccwo_v1 = 1;
                di_ccwo_v1    = do_ccwi_v1;
                di_ccwo_v1[55 -: 4] = do_ccwi_v1[55 -: 4] >> 1;
            end

            // ccwi->nso
            if (gnt_ccwi_nso) begin
                rdReq_ccwi_v1 = 1;
                wrReq_nso_v1  = 1;
                di_nso_v1     = do_ccwi_v1;
                di_nso_v1[51 -: 4] = do_ccwi_v1[51 -: 4] >> 1;
            end

            // ccwi->sno
            if (gnt_ccwi_sno) begin
                rdReq_ccwi_v1 = 1;
                wrReq_sno_v1  = 1;
                di_sno_v1     = do_ccwi_v1;
                di_sno_v1[51 -: 4] = do_ccwi_v1[51 -: 4] >> 1;
            end

            // ccwi->peo
            if (gnt_ccwi_peo) begin
                rdReq_ccwi_v1 = 1;
                wrReq_peo_v1  = 1;
                di_peo_v1     = do_ccwi_v1;
            end

            // nsi->nso
            if (gnt_nsi_nso) begin
                rdReq_nsi_v1 = 1;
                wrReq_nso_v1 = 1;
                di_nso_v1    = do_nsi_v1;
                di_nso_v1[51 -: 4] = do_nsi_v1[51 -: 4] >> 1;
            end

            // nsi->peo
            if (gnt_nsi_peo) begin
                rdReq_nsi_v1 = 1;
                wrReq_peo_v1 = 1;
                di_peo_v1    = do_nsi_v1;
            end

            // sni->sno
            if (gnt_sni_sno) begin
                rdReq_sni_v1 = 1;
                wrReq_sno_v1 = 1;
                di_sno_v1    = do_sni_v1;
                di_sno_v1[51 -: 4] = do_sni_v1[51 -: 4] >> 1;
            end

            // sni->peo
            if (gnt_sni_peo) begin
                rdReq_sni_v1 = 1;
                wrReq_peo_v1 = 1;
                di_peo_v1    = do_sni_v1;
            end

            // pei->cwo
            if (gnt_pei_cwo) begin
                rdReq_pei_v1 = 1;
                wrReq_cwo_v1 = 1;
                di_cwo_v1    = do_pei_v1;
                di_cwo_v1[55 -: 4] = do_pei_v1[55 -: 4] >> 1;
            end

            // pei->ccwo
            if (gnt_pei_ccwo) begin
                rdReq_pei_v1 = 1;
                wrReq_ccwo_v1= 1;
                di_ccwo_v1   = do_pei_v1;
                di_ccwo_v1[55 -: 4] = do_pei_v1[55 -: 4] >> 1;
            end

            // pei->nso
            if (gnt_pei_nso) begin
                rdReq_pei_v1 = 1;
                wrReq_nso_v1 = 1;
                di_nso_v1    = do_pei_v1;
                di_nso_v1[51 -: 4] = do_pei_v1[51 -: 4] >> 1;
            end

            // pei->sno
            if (gnt_pei_sno) begin
                rdReq_pei_v1 = 1;
                wrReq_sno_v1 = 1;
                di_sno_v1    = do_pei_v1;
                di_sno_v1[51 -: 4] = do_pei_v1[51 -: 4] >> 1;
            end
        end
    end

// Output signal assignments
    assign cwdo = (polarity == 0) ? do_cwo_v1 : do_cwo_v0;
    assign ccwdo = (polarity == 0) ? do_ccwo_v1 : do_ccwo_v0;
    assign nsdo = (polarity == 0) ? do_nso_v1 : do_nso_v0;
    assign sndo = (polarity == 0) ? do_sno_v1 : do_sno_v0;
    assign pedo = (polarity == 0) ? do_peo_v1 : do_peo_v0;  


    assign cwso = (polarity == 0) ? (full_cwo_v1 & cwro) : (full_cwo_v0 & cwro);
    assign ccwso = (polarity == 0) ? (full_ccwo_v1 & ccwro) : (full_ccwo_v0 & ccwro); 
    assign nsso = (polarity == 0) ? (full_nso_v1 & nsro) : (full_nso_v0 & nsro);
    assign snso = (polarity == 0) ? (full_sno_v1 & snro) : (full_sno_v0 & snro); 
    assign peso = (polarity == 0) ? (full_peo_v1 & pero) : (full_peo_v0 & pero); 


    assign rdReq_cwo_v0 = (polarity == 1) ? (cwso & cwro) : 0;
    assign rdReq_cwo_v1 = (polarity == 0) ? (cwso & cwro) : 0;

    assign rdReq_ccwo_v0 = (polarity == 1) ? (ccwso & ccwro) : 0;  
    assign rdReq_ccwo_v1 = (polarity == 0) ? (ccwso & ccwro) : 0;

    assign rdReq_nso_v0 = (polarity == 1) ? (nsso & nsro) : 0;
    assign rdReq_nso_v1 = (polarity == 0) ? (nsso & nsro) : 0;

    assign rdReq_sno_v0 = (polarity == 1) ? (snso & snro) : 0;
    assign rdReq_sno_v1 = (polarity == 0) ? (snso & snro) : 0;

    assign rdReq_peo_v0 = (polarity == 1) ? (peso & pero) : 0;
    assign rdReq_peo_v1 = (polarity == 0) ? (peso & pero) : 0;

endmodule 