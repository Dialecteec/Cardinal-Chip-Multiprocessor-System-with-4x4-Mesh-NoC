module gold_mesh
#(
    parameter PACKET_SIZE = 64
)
(
    input  clk,
    input  reset,

    //------------------------------------------------------
    // Device ports for each router's local node (PE)
    // 3×3 mesh: x = 0..2, y = 0..2.  y=0 bottom, y=2 top.
    //------------------------------------------------------

    // Row y=0
    input                     node00_pesi, node00_pero,
    output                    node00_peri, node00_peso,
    input  [PACKET_SIZE-1:0]  node00_pedi,
    output [PACKET_SIZE-1:0]  node00_pedo,

    input                     node10_pesi, node10_pero,
    output                    node10_peri, node10_peso,
    input  [PACKET_SIZE-1:0]  node10_pedi,
    output [PACKET_SIZE-1:0]  node10_pedo,

    input                     node20_pesi, node20_pero,
    output                    node20_peri, node20_peso,
    input  [PACKET_SIZE-1:0]  node20_pedi,
    output [PACKET_SIZE-1:0]  node20_pedo,

    // Row y=1
    input                     node01_pesi, node01_pero,
    output                    node01_peri, node01_peso,
    input  [PACKET_SIZE-1:0]  node01_pedi,
    output [PACKET_SIZE-1:0]  node01_pedo,

    input                     node11_pesi, node11_pero,
    output                    node11_peri, node11_peso,
    input  [PACKET_SIZE-1:0]  node11_pedi,
    output [PACKET_SIZE-1:0]  node11_pedo,

    input                     node21_pesi, node21_pero,
    output                    node21_peri, node21_peso,
    input  [PACKET_SIZE-1:0]  node21_pedi,
    output [PACKET_SIZE-1:0]  node21_pedo,

    // Row y=2
    input                     node02_pesi, node02_pero,
    output                    node02_peri, node02_peso,
    input  [PACKET_SIZE-1:0]  node02_pedi,
    output [PACKET_SIZE-1:0]  node02_pedo,

    input                     node12_pesi, node12_pero,
    output                    node12_peri, node12_peso,
    input  [PACKET_SIZE-1:0]  node12_pedi,
    output [PACKET_SIZE-1:0]  node12_pedo,

    input                     node22_pesi, node22_pero,
    output                    node22_peri, node22_peso,
    input  [PACKET_SIZE-1:0]  node22_pedi,
    output [PACKET_SIZE-1:0]  node22_pedo,

    //------------------------------------------------------
    // Polarity outputs for each of the 9 routers
    //------------------------------------------------------
    output node00_polarity, node10_polarity, node20_polarity,
    output node01_polarity, node11_polarity, node21_polarity,
    output node02_polarity, node12_polarity, node22_polarity
);

    //------------------------------------------------------
    // 1) Shared polarity register
    //------------------------------------------------------
    reg polarity;
    always @(posedge clk) begin
        if (reset)
            polarity <= 1'b1;
        else
            polarity <= ~polarity;
    end

    // Assign polarity outputs
    assign node00_polarity = polarity;
    assign node10_polarity = polarity;
    assign node20_polarity = polarity;
    assign node01_polarity = polarity;
    assign node11_polarity = polarity;
    assign node21_polarity = polarity;
    assign node02_polarity = polarity;
    assign node12_polarity = polarity;
    assign node22_polarity = polarity;

    //------------------------------------------------------
    // 2) Wires between neighboring routers
    //    2 horizontal links per row, 2 vertical per column
    //------------------------------------------------------

    // ── Row y=0 ── (0,0)-(1,0)-(2,0)
    wire        cwso_0_0_to_1_0;  wire [PACKET_SIZE-1:0] cwdo_0_0_to_1_0;  wire cwro_1_0_to_0_0;
    wire        ccwso_1_0_to_0_0; wire [PACKET_SIZE-1:0] ccwdo_1_0_to_0_0; wire ccwro_0_0_to_1_0;
    wire        cwso_1_0_to_2_0;  wire [PACKET_SIZE-1:0] cwdo_1_0_to_2_0;  wire cwro_2_0_to_1_0;
    wire        ccwso_2_0_to_1_0; wire [PACKET_SIZE-1:0] ccwdo_2_0_to_1_0; wire ccwro_1_0_to_2_0;

    // ── Row y=1 ── (0,1)-(1,1)-(2,1)
    wire        cwso_0_1_to_1_1;  wire [PACKET_SIZE-1:0] cwdo_0_1_to_1_1;  wire cwro_1_1_to_0_1;
    wire        ccwso_1_1_to_0_1; wire [PACKET_SIZE-1:0] ccwdo_1_1_to_0_1; wire ccwro_0_1_to_1_1;
    wire        cwso_1_1_to_2_1;  wire [PACKET_SIZE-1:0] cwdo_1_1_to_2_1;  wire cwro_2_1_to_1_1;
    wire        ccwso_2_1_to_1_1; wire [PACKET_SIZE-1:0] ccwdo_2_1_to_1_1; wire ccwro_1_1_to_2_1;

    // ── Row y=2 ── (0,2)-(1,2)-(2,2)
    wire        cwso_0_2_to_1_2;  wire [PACKET_SIZE-1:0] cwdo_0_2_to_1_2;  wire cwro_1_2_to_0_2;
    wire        ccwso_1_2_to_0_2; wire [PACKET_SIZE-1:0] ccwdo_1_2_to_0_2; wire ccwro_0_2_to_1_2;
    wire        cwso_1_2_to_2_2;  wire [PACKET_SIZE-1:0] cwdo_1_2_to_2_2;  wire cwro_2_2_to_1_2;
    wire        ccwso_2_2_to_1_2; wire [PACKET_SIZE-1:0] ccwdo_2_2_to_1_2; wire ccwro_1_2_to_2_2;

    // ── Column x=0 ── (0,0)-(0,1)-(0,2)
    wire nsso_0_1_to_0_0;  wire [PACKET_SIZE-1:0] nsdo_0_1_to_0_0;  wire nsro_0_0_to_0_1;
    wire snso_0_0_to_0_1;  wire [PACKET_SIZE-1:0] sndo_0_0_to_0_1;  wire snro_0_1_to_0_0;
    wire nsso_0_2_to_0_1;  wire [PACKET_SIZE-1:0] nsdo_0_2_to_0_1;  wire nsro_0_1_to_0_2;
    wire snso_0_1_to_0_2;  wire [PACKET_SIZE-1:0] sndo_0_1_to_0_2;  wire snro_0_2_to_0_1;

    // ── Column x=1 ── (1,0)-(1,1)-(1,2)
    wire nsso_1_1_to_1_0;  wire [PACKET_SIZE-1:0] nsdo_1_1_to_1_0;  wire nsro_1_0_to_1_1;
    wire snso_1_0_to_1_1;  wire [PACKET_SIZE-1:0] sndo_1_0_to_1_1;  wire snro_1_1_to_1_0;
    wire nsso_1_2_to_1_1;  wire [PACKET_SIZE-1:0] nsdo_1_2_to_1_1;  wire nsro_1_1_to_1_2;
    wire snso_1_1_to_1_2;  wire [PACKET_SIZE-1:0] sndo_1_1_to_1_2;  wire snro_1_2_to_1_1;

    // ── Column x=2 ── (2,0)-(2,1)-(2,2)
    wire nsso_2_1_to_2_0;  wire [PACKET_SIZE-1:0] nsdo_2_1_to_2_0;  wire nsro_2_0_to_2_1;
    wire snso_2_0_to_2_1;  wire [PACKET_SIZE-1:0] sndo_2_0_to_2_1;  wire snro_2_1_to_2_0;
    wire nsso_2_2_to_2_1;  wire [PACKET_SIZE-1:0] nsdo_2_2_to_2_1;  wire nsro_2_1_to_2_2;
    wire snso_2_1_to_2_2;  wire [PACKET_SIZE-1:0] sndo_2_1_to_2_2;  wire snro_2_2_to_2_1;

    //------------------------------------------------------
    // 3) Instantiate all 9 gold_router blocks
    //------------------------------------------------------

    // (x=0, y=0)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_0 (
        .clk      (clk),      .reset (reset),  .polarity (polarity),
        // cw (W→E)
        .cwsi     (1'b0),                    .cwdi ({PACKET_SIZE{1'b0}}),  .cwri (),
        .cwso     (cwso_0_0_to_1_0),         .cwdo (cwdo_0_0_to_1_0),      .cwro (cwro_1_0_to_0_0),
        // ccw (E→W)
        .ccwsi    (ccwso_1_0_to_0_0),        .ccwdi(ccwdo_1_0_to_0_0),     .ccwri(ccwro_0_0_to_1_0),
        .ccwso    (),                        .ccwdo(),                     .ccwro(),
        // ns (N→S)
        .nssi     (nsso_0_1_to_0_0),         .nsdi(nsdo_0_1_to_0_0),       .nsri(nsro_0_0_to_0_1),
        .nsso     (),                        .nsdo(),                     .nsro(),
        // sn (S→N)
        .snsi     (1'b0),                    .sndi({PACKET_SIZE{1'b0}}),   .snri(),
        .snso     (snso_0_0_to_0_1),         .sndo(sndo_0_0_to_0_1),      .snro(snro_0_1_to_0_0),
        // local PE
        .pesi     (node00_pesi), .peri(node00_peri), .pero(node00_pero), .peso(node00_peso),
        .pedi     (node00_pedi), .pedo(node00_pedo)
    );

    // (x=1, y=0)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_0 (
        .clk      (clk),      .reset(reset),   .polarity(polarity),
        // cw
        .cwsi     (cwso_0_0_to_1_0), .cwdi(cwdo_0_0_to_1_0), .cwri(cwro_1_0_to_0_0),
        .cwso     (cwso_1_0_to_2_0), .cwdo(cwdo_1_0_to_2_0), .cwro(cwro_2_0_to_1_0),
        // ccw
        .ccwsi    (ccwso_2_0_to_1_0), .ccwdi(ccwdo_2_0_to_1_0), .ccwri(ccwro_1_0_to_2_0),
        .ccwso    (ccwso_1_0_to_0_0), .ccwdo(ccwdo_1_0_to_0_0), .ccwro(ccwro_0_0_to_1_0),
        // ns
        .nssi     (nsso_1_1_to_1_0), .nsdi(nsdo_1_1_to_1_0), .nsri(nsro_1_0_to_1_1),
        .nsso     (),                .nsdo(),               .nsro(),
        // sn
        .snsi     (1'b0), .sndi({PACKET_SIZE{1'b0}}), .snri(),
        .snso     (snso_1_0_to_1_1), .sndo(sndo_1_0_to_1_1), .snro(snro_1_1_to_1_0),
        // local PE
        .pesi     (node10_pesi), .peri(node10_peri), .pero(node10_pero), .peso(node10_peso),
        .pedi     (node10_pedi), .pedo(node10_pedo)
    );

    // (x=2, y=0)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_0 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (cwso_1_0_to_2_0), .cwdi(cwdo_1_0_to_2_0), .cwri(cwro_2_0_to_1_0),
        .cwso     (),                .cwdo(),               .cwro(),
        // ccw
        .ccwsi    (1'b0), .ccwdi({PACKET_SIZE{1'b0}}), .ccwri(),
        .ccwso    (ccwso_2_0_to_1_0), .ccwdo(ccwdo_2_0_to_1_0), .ccwro(ccwro_1_0_to_2_0),
        // ns
        .nssi     (nsso_2_1_to_2_0), .nsdi(nsdo_2_1_to_2_0), .nsri(nsro_2_0_to_2_1),
        .nsso     (),                .nsdo(),               .nsro(),
        // sn
        .snsi     (1'b0), .sndi({PACKET_SIZE{1'b0}}), .snri(),
        .snso     (snso_2_0_to_2_1), .sndo(sndo_2_0_to_2_1), .snro(snro_2_1_to_2_0),
        // local PE
        .pesi     (node20_pesi), .peri(node20_peri), .pero(node20_pero), .peso(node20_peso),
        .pedi     (node20_pedi), .pedo(node20_pedo)
    );

    // (x=0, y=1)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_1 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (1'b0),                   .cwdi({PACKET_SIZE{1'b0}}), .cwri(),
        .cwso     (cwso_0_1_to_1_1),        .cwdo(cwdo_0_1_to_1_1),      .cwro(cwro_1_1_to_0_1),
        // ccw
        .ccwsi    (ccwso_1_1_to_0_1),       .ccwdi(ccwdo_1_1_to_0_1),     .ccwri(ccwro_0_1_to_1_1),
        .ccwso    (),                       .ccwdo(),                     .ccwro(),
        // ns
        .nssi     (nsso_0_2_to_0_1),        .nsdi(nsdo_0_2_to_0_1),       .nsri(nsro_0_1_to_0_2),
        .nsso     (nsso_0_1_to_0_0),        .nsdo(nsdo_0_1_to_0_0),       .nsro(nsro_0_0_to_0_1),
        // sn
        .snsi     (snso_0_0_to_0_1),        .sndi(sndo_0_0_to_0_1),       .snri(snro_0_1_to_0_0),
        .snso     (snso_0_1_to_0_2),        .sndo(sndo_0_1_to_0_2),       .snro(snro_0_2_to_0_1),
        // local PE
        .pesi     (node01_pesi), .peri(node01_peri), .pero(node01_pero), .peso(node01_peso),
        .pedi     (node01_pedi), .pedo(node01_pedo)
    );

    // (x=1, y=1)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_1 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (cwso_0_1_to_1_1), .cwdi(cwdo_0_1_to_1_1), .cwri(cwro_1_1_to_0_1),
        .cwso     (cwso_1_1_to_2_1), .cwdo(cwdo_1_1_to_2_1), .cwro(cwro_2_1_to_1_1),
        // ccw
        .ccwsi    (ccwso_2_1_to_1_1), .ccwdi(ccwdo_2_1_to_1_1), .ccwri(ccwro_1_1_to_2_1),
        .ccwso    (ccwso_1_1_to_0_1), .ccwdo(ccwdo_1_1_to_0_1), .ccwro(ccwro_0_1_to_1_1),
        // ns
        .nssi     (nsso_1_2_to_1_1), .nsdi(nsdo_1_2_to_1_1), .nsri(nsro_1_1_to_1_2),
        .nsso     (nsso_1_1_to_1_0), .nsdo(nsdo_1_1_to_1_0), .nsro(nsro_1_0_to_1_1),
        // sn
        .snsi     (snso_1_0_to_1_1), .sndi(sndo_1_0_to_1_1), .snri(snro_1_1_to_1_0),
        .snso     (snso_1_1_to_1_2), .sndo(sndo_1_1_to_1_2), .snro(snro_1_2_to_1_1),
        // local PE
        .pesi     (node11_pesi), .peri(node11_peri), .pero(node11_pero), .peso(node11_peso),
        .pedi     (node11_pedi), .pedo(node11_pedo)
    );

    // (x=2, y=1)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_1 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (cwso_1_1_to_2_1), .cwdi(cwdo_1_1_to_2_1), .cwri(cwro_2_1_to_1_1),
        .cwso     (),                .cwdo(),               .cwro(),
        // ccw
        .ccwsi    (1'b0), .ccwdi({PACKET_SIZE{1'b0}}), .ccwri(),
        .ccwso    (ccwso_2_1_to_1_1), .ccwdo(ccwdo_2_1_to_1_1), .ccwro(ccwro_1_1_to_2_1),
        // ns
        .nssi     (nsso_2_2_to_2_1), .nsdi(nsdo_2_2_to_2_1), .nsri(nsro_2_1_to_2_2),
        .nsso     (nsso_2_1_to_2_0), .nsdo(nsdo_2_1_to_2_0), .nsro(nsro_2_0_to_2_1),
        // sn
        .snsi     (snso_2_0_to_2_1), .sndi(sndo_2_0_to_2_1), .snri(snro_2_1_to_2_0),
        .snso     (snso_2_1_to_2_2), .sndo(sndo_2_1_to_2_2), .snro(snro_2_2_to_2_1),
        // local PE
        .pesi     (node21_pesi), .peri(node21_peri), .pero(node21_pero), .peso(node21_peso),
        .pedi     (node21_pedi), .pedo(node21_pedo)
    );

    // (x=0, y=2)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_2 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (1'b0),                   .cwdi({PACKET_SIZE{1'b0}}), .cwri(),
        .cwso     (cwso_0_2_to_1_2),        .cwdo(cwdo_0_2_to_1_2),      .cwro(cwro_1_2_to_0_2),
        // ccw
        .ccwsi    (ccwso_1_2_to_0_2),       .ccwdi(ccwdo_1_2_to_0_2),     .ccwri(ccwro_0_2_to_1_2),
        .ccwso    (),                       .ccwdo(),                     .ccwro(),
        // ns
        .nssi     (1'b0), .nsdi({PACKET_SIZE{1'b0}}), .nsri(),
        .nsso     (nsso_0_2_to_0_1),       .nsdo(nsdo_0_2_to_0_1),       .nsro(nsro_0_1_to_0_2),
        // sn
        .snsi     (snso_0_1_to_0_2),       .sndi(sndo_0_1_to_0_2),       .snri(snro_0_2_to_0_1),
        .snso     (),                      .sndo(),                     .snro(),
        // local PE
        .pesi     (node02_pesi), .peri(node02_peri), .pero(node02_pero), .peso(node02_peso),
        .pedi     (node02_pedi), .pedo(node02_pedo)
    );

    // (x=1, y=2)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_2 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (cwso_0_2_to_1_2), .cwdi(cwdo_0_2_to_1_2), .cwri(cwro_1_2_to_0_2),
        .cwso     (cwso_1_2_to_2_2), .cwdo(cwdo_1_2_to_2_2), .cwro(cwro_2_2_to_1_2),
        // ccw
        .ccwsi    (ccwso_2_2_to_1_2), .ccwdi(ccwdo_2_2_to_1_2), .ccwri(ccwro_1_2_to_2_2),
        .ccwso    (ccwso_1_2_to_0_2), .ccwdo(ccwdo_1_2_to_0_2), .ccwro(ccwro_0_2_to_1_2),
        // ns
        .nssi     (1'b0), .nsdi({PACKET_SIZE{1'b0}}), .nsri(),
        .nsso     (nsso_1_2_to_1_1), .nsdo(nsdo_1_2_to_1_1), .nsro(nsro_1_1_to_1_2),
        // sn
        .snsi     (snso_1_1_to_1_2), .sndi(sndo_1_1_to_1_2), .snri(snro_1_2_to_1_1),
        .snso     (),                .sndo(),               .snro(),
        // local PE
        .pesi     (node12_pesi), .peri(node12_peri), .pero(node12_pero), .peso(node12_peso),
        .pedi     (node12_pedi), .pedo(node12_pedo)
    );

    // (x=2, y=2)
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_2 (
        .clk      (clk),      .reset(reset), .polarity(polarity),
        // cw
        .cwsi     (cwso_1_2_to_2_2), .cwdi(cwdo_1_2_to_2_2), .cwri(cwro_2_2_to_1_2),
        .cwso     (),                .cwdo(),               .cwro(),
        // ccw
        .ccwsi    (1'b0), .ccwdi({PACKET_SIZE{1'b0}}), .ccwri(),
        .ccwso    (ccwso_2_2_to_1_2), .ccwdo(ccwdo_2_2_to_1_2), .ccwro(ccwro_1_2_to_2_2),
        // ns
        .nssi     (1'b0), .nsdi({PACKET_SIZE{1'b0}}), .nsri(),
        .nsso     (nsso_2_2_to_2_1), .nsdo(nsdo_2_2_to_2_1), .nsro(nsro_2_1_to_2_2),
        // sn
        .snsi     (snso_2_1_to_2_2), .sndi(sndo_2_1_to_2_2), .snri(snro_2_2_to_2_1),
        .snso     (),                .sndo(),               .snro(),
        // local PE
        .pesi     (node22_pesi), .peri(node22_peri), .pero(node22_pero), .peso(node22_peso),
        .pedi     (node22_pedi), .pedo(node22_pedo)
    );

endmodule
