
module gold_mesh
#(
    parameter PACKET_SIZE = 64
)
(
    input clk,
    input reset,

    //------------------------------------------------------
    // Device ports for each router's local node (PE)
    // Bottom row is y=0, top row is y=3.
    // Left column is x=0, right column is x=3.
    //------------------------------------------------------

    // Row y=0
    input                     node00_pesi, node00_pero,
    output                    node00_peri, node00_peso,
    input  [PACKET_SIZE-1:0] node00_pedi,
    output [PACKET_SIZE-1:0] node00_pedo,

    input                     node10_pesi, node10_pero,
    output                    node10_peri, node10_peso,
    input  [PACKET_SIZE-1:0] node10_pedi,
    output [PACKET_SIZE-1:0] node10_pedo,

    input                     node20_pesi, node20_pero,
    output                    node20_peri, node20_peso,
    input  [PACKET_SIZE-1:0] node20_pedi,
    output [PACKET_SIZE-1:0] node20_pedo,

    input                     node30_pesi, node30_pero,
    output                    node30_peri, node30_peso,
    input  [PACKET_SIZE-1:0] node30_pedi,
    output [PACKET_SIZE-1:0] node30_pedo,

    // Row y=1
    input                     node01_pesi, node01_pero,
    output                    node01_peri, node01_peso,
    input  [PACKET_SIZE-1:0] node01_pedi,
    output [PACKET_SIZE-1:0] node01_pedo,

    input                     node11_pesi, node11_pero,
    output                    node11_peri, node11_peso,
    input  [PACKET_SIZE-1:0] node11_pedi,
    output [PACKET_SIZE-1:0] node11_pedo,

    input                     node21_pesi, node21_pero,
    output                    node21_peri, node21_peso,
    input  [PACKET_SIZE-1:0] node21_pedi,
    output [PACKET_SIZE-1:0] node21_pedo,

    input                     node31_pesi, node31_pero,
    output                    node31_peri, node31_peso,
    input  [PACKET_SIZE-1:0] node31_pedi,
    output [PACKET_SIZE-1:0] node31_pedo,

    // Row y=2
    input                     node02_pesi, node02_pero,
    output                    node02_peri, node02_peso,
    input  [PACKET_SIZE-1:0] node02_pedi,
    output [PACKET_SIZE-1:0] node02_pedo,

    input                     node12_pesi, node12_pero,
    output                    node12_peri, node12_peso,
    input  [PACKET_SIZE-1:0] node12_pedi,
    output [PACKET_SIZE-1:0] node12_pedo,

    input                     node22_pesi, node22_pero,
    output                    node22_peri, node22_peso,
    input  [PACKET_SIZE-1:0] node22_pedi,
    output [PACKET_SIZE-1:0] node22_pedo,

    input                     node32_pesi, node32_pero,
    output                    node32_peri, node32_peso,
    input  [PACKET_SIZE-1:0] node32_pedi,
    output [PACKET_SIZE-1:0] node32_pedo,

    // Row y=3
    input                     node03_pesi, node03_pero,
    output                    node03_peri, node03_peso,
    input  [PACKET_SIZE-1:0] node03_pedi,
    output [PACKET_SIZE-1:0] node03_pedo,

    input                     node13_pesi, node13_pero,
    output                    node13_peri, node13_peso,
    input  [PACKET_SIZE-1:0] node13_pedi,
    output [PACKET_SIZE-1:0] node13_pedo,

    input                     node23_pesi, node23_pero,
    output                    node23_peri, node23_peso,
    input  [PACKET_SIZE-1:0] node23_pedi,
    output [PACKET_SIZE-1:0] node23_pedo,

    input                     node33_pesi, node33_pero,
    output                    node33_peri, node33_peso,
    input  [PACKET_SIZE-1:0] node33_pedi,
    output [PACKET_SIZE-1:0] node33_pedo,

    //------------------------------------------------------
    // Expose polarity from each router
    //------------------------------------------------------
    output node00_polarity, output node10_polarity, output node20_polarity, output node30_polarity,
    output node01_polarity, output node11_polarity, output node21_polarity, output node31_polarity,
    output node02_polarity, output node12_polarity, output node22_polarity, output node32_polarity,
    output node03_polarity, output node13_polarity, output node23_polarity, output node33_polarity
);

    //------------------------------------------------------
    // 1) Polarity register (shared by all routers)
    //------------------------------------------------------
    reg polarity;
    always @(posedge clk) begin
        if (reset)
            polarity <= 1'b1; // or 1'b0, depending on your design choice
        else
            polarity <= ~polarity;
    end

    // Assign polarity outputs
    assign node00_polarity = polarity;
    assign node10_polarity = polarity;
    assign node20_polarity = polarity;
    assign node30_polarity = polarity;

    assign node01_polarity = polarity;
    assign node11_polarity = polarity;
    assign node21_polarity = polarity;
    assign node31_polarity = polarity;

    assign node02_polarity = polarity;
    assign node12_polarity = polarity;
    assign node22_polarity = polarity;
    assign node32_polarity = polarity;

    assign node03_polarity = polarity;
    assign node13_polarity = polarity;
    assign node23_polarity = polarity;
    assign node33_polarity = polarity;

    //------------------------------------------------------
    // 2) Wires between neighboring routers
    //    We have 3 horizontal links per row and 3 vertical
    //    links per column. Each link has two directions:
    //    cw / ccw and ns / sn.
    //------------------------------------------------------

    // ------------------
    // Row 0: (0,0)-(1,0)-(2,0)-(3,0)
    // ------------------
    wire        cwso_0_0_to_1_0; wire [PACKET_SIZE-1:0] cwdo_0_0_to_1_0; wire cwro_1_0_to_0_0;
    wire        ccwso_1_0_to_0_0; wire [PACKET_SIZE-1:0] ccwdo_1_0_to_0_0; wire ccwro_0_0_to_1_0;

    wire        cwso_1_0_to_2_0; wire [PACKET_SIZE-1:0] cwdo_1_0_to_2_0; wire cwro_2_0_to_1_0;
    wire        ccwso_2_0_to_1_0; wire [PACKET_SIZE-1:0] ccwdo_2_0_to_1_0; wire ccwro_1_0_to_2_0;

    wire        cwso_2_0_to_3_0; wire [PACKET_SIZE-1:0] cwdo_2_0_to_3_0; wire cwro_3_0_to_2_0;
    wire        ccwso_3_0_to_2_0; wire [PACKET_SIZE-1:0] ccwdo_3_0_to_2_0; wire ccwro_2_0_to_3_0;

    // ------------------
    // Row 1: (0,1)-(1,1)-(2,1)-(3,1)
    // ------------------
    wire        cwso_0_1_to_1_1; wire [PACKET_SIZE-1:0] cwdo_0_1_to_1_1; wire cwro_1_1_to_0_1;
    wire        ccwso_1_1_to_0_1; wire [PACKET_SIZE-1:0] ccwdo_1_1_to_0_1; wire ccwro_0_1_to_1_1;

    wire        cwso_1_1_to_2_1; wire [PACKET_SIZE-1:0] cwdo_1_1_to_2_1; wire cwro_2_1_to_1_1;
    wire        ccwso_2_1_to_1_1; wire [PACKET_SIZE-1:0] ccwdo_2_1_to_1_1; wire ccwro_1_1_to_2_1;

    wire        cwso_2_1_to_3_1; wire [PACKET_SIZE-1:0] cwdo_2_1_to_3_1; wire cwro_3_1_to_2_1;
    wire        ccwso_3_1_to_2_1; wire [PACKET_SIZE-1:0] ccwdo_3_1_to_2_1; wire ccwro_2_1_to_3_1;

    // ------------------
    // Row 2: (0,2)-(1,2)-(2,2)-(3,2)
    // ------------------
    wire        cwso_0_2_to_1_2; wire [PACKET_SIZE-1:0] cwdo_0_2_to_1_2; wire cwro_1_2_to_0_2;
    wire        ccwso_1_2_to_0_2; wire [PACKET_SIZE-1:0] ccwdo_1_2_to_0_2; wire ccwro_0_2_to_1_2;

    wire        cwso_1_2_to_2_2; wire [PACKET_SIZE-1:0] cwdo_1_2_to_2_2; wire cwro_2_2_to_1_2;
    wire        ccwso_2_2_to_1_2; wire [PACKET_SIZE-1:0] ccwdo_2_2_to_1_2; wire ccwro_1_2_to_2_2;

    wire        cwso_2_2_to_3_2; wire [PACKET_SIZE-1:0] cwdo_2_2_to_3_2; wire cwro_3_2_to_2_2;
    wire        ccwso_3_2_to_2_2; wire [PACKET_SIZE-1:0] ccwdo_3_2_to_2_2; wire ccwro_2_2_to_3_2;

    // ------------------
    // Row 3: (0,3)-(1,3)-(2,3)-(3,3)
    // ------------------
    wire        cwso_0_3_to_1_3; wire [PACKET_SIZE-1:0] cwdo_0_3_to_1_3; wire cwro_1_3_to_0_3;
    wire        ccwso_1_3_to_0_3; wire [PACKET_SIZE-1:0] ccwdo_1_3_to_0_3; wire ccwro_0_3_to_1_3;

    wire        cwso_1_3_to_2_3; wire [PACKET_SIZE-1:0] cwdo_1_3_to_2_3; wire cwro_2_3_to_1_3;
    wire        ccwso_2_3_to_1_3; wire [PACKET_SIZE-1:0] ccwdo_2_3_to_1_3; wire ccwro_1_3_to_2_3;

    wire        cwso_2_3_to_3_3; wire [PACKET_SIZE-1:0] cwdo_2_3_to_3_3; wire cwro_3_3_to_2_3;
    wire        ccwso_3_3_to_2_3; wire [PACKET_SIZE-1:0] ccwdo_3_3_to_2_3; wire ccwro_2_3_to_3_3;

    // ================================
    // Vertical links (4 columns => 3 vertical links each)
    // x=0 column => (0,0)->(0,1)->(0,2)->(0,3)
    // ================================
    wire nsso_0_1_to_0_0; wire [PACKET_SIZE-1:0] nsdo_0_1_to_0_0; wire nsro_0_0_to_0_1;
    wire snso_0_0_to_0_1; wire [PACKET_SIZE-1:0] sndo_0_0_to_0_1; wire snro_0_1_to_0_0;

    wire nsso_0_2_to_0_1; wire [PACKET_SIZE-1:0] nsdo_0_2_to_0_1; wire nsro_0_1_to_0_2;
    wire snso_0_1_to_0_2; wire [PACKET_SIZE-1:0] sndo_0_1_to_0_2; wire snro_0_2_to_0_1;

    wire nsso_0_3_to_0_2; wire [PACKET_SIZE-1:0] nsdo_0_3_to_0_2; wire nsro_0_2_to_0_3;
    wire snso_0_2_to_0_3; wire [PACKET_SIZE-1:0] sndo_0_2_to_0_3; wire snro_0_3_to_0_2;

    // x=1 column => (1,0)->(1,1)->(1,2)->(1,3)
    wire nsso_1_1_to_1_0; wire [PACKET_SIZE-1:0] nsdo_1_1_to_1_0; wire nsro_1_0_to_1_1;
    wire snso_1_0_to_1_1; wire [PACKET_SIZE-1:0] sndo_1_0_to_1_1; wire snro_1_1_to_1_0;

    wire nsso_1_2_to_1_1; wire [PACKET_SIZE-1:0] nsdo_1_2_to_1_1; wire nsro_1_1_to_1_2;
    wire snso_1_1_to_1_2; wire [PACKET_SIZE-1:0] sndo_1_1_to_1_2; wire snro_1_2_to_1_1;

    wire nsso_1_3_to_1_2; wire [PACKET_SIZE-1:0] nsdo_1_3_to_1_2; wire nsro_1_2_to_1_3;
    wire snso_1_2_to_1_3; wire [PACKET_SIZE-1:0] sndo_1_2_to_1_3; wire snro_1_3_to_1_2;

    // x=2 column => (2,0)->(2,1)->(2,2)->(2,3)
    wire nsso_2_1_to_2_0; wire [PACKET_SIZE-1:0] nsdo_2_1_to_2_0; wire nsro_2_0_to_2_1;
    wire snso_2_0_to_2_1; wire [PACKET_SIZE-1:0] sndo_2_0_to_2_1; wire snro_2_1_to_2_0;

    wire nsso_2_2_to_2_1; wire [PACKET_SIZE-1:0] nsdo_2_2_to_2_1; wire nsro_2_1_to_2_2;
    wire snso_2_1_to_2_2; wire [PACKET_SIZE-1:0] sndo_2_1_to_2_2; wire snro_2_2_to_2_1;

    wire nsso_2_3_to_2_2; wire [PACKET_SIZE-1:0] nsdo_2_3_to_2_2; wire nsro_2_2_to_2_3;
    wire snso_2_2_to_2_3; wire [PACKET_SIZE-1:0] sndo_2_2_to_2_3; wire snro_2_3_to_2_2;

    // x=3 column => (3,0)->(3,1)->(3,2)->(3,3)
    wire nsso_3_1_to_3_0; wire [PACKET_SIZE-1:0] nsdo_3_1_to_3_0; wire nsro_3_0_to_3_1;
    wire snso_3_0_to_3_1; wire [PACKET_SIZE-1:0] sndo_3_0_to_3_1; wire snro_3_1_to_3_0;

    wire nsso_3_2_to_3_1; wire [PACKET_SIZE-1:0] nsdo_3_2_to_3_1; wire nsro_3_1_to_3_2;
    wire snso_3_1_to_3_2; wire [PACKET_SIZE-1:0] sndo_3_1_to_3_2; wire snro_3_2_to_3_1;

    wire nsso_3_3_to_3_2; wire [PACKET_SIZE-1:0] nsdo_3_3_to_3_2; wire nsro_3_2_to_3_3;
    wire snso_3_2_to_3_3; wire [PACKET_SIZE-1:0] sndo_3_2_to_3_3; wire snro_3_3_to_3_2;

    //------------------------------------------------------
    // 3) Instantiate all 16 cross_routers
    //------------------------------------------------------

    //------------------
    // (x=0, y=0) - bottom-left
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_0 (
        .clk      (clk),
        .reset    (reset),
        .polarity (polarity),

        // cw (west->east): no west neighbor
        .cwsi (1'b0),
        .cwdi ({PACKET_SIZE{1'b0}}),
        .cwri (/*unused*/),
        // out to (1,0)
        .cwso (cwso_0_0_to_1_0),
        .cwdo (cwdo_0_0_to_1_0),
        .cwro (cwro_1_0_to_0_0),

        // ccw (east->west): from (1,0)
        .ccwsi (ccwso_1_0_to_0_0),
        .ccwdi (ccwdo_1_0_to_0_0),
        .ccwri (ccwro_0_0_to_1_0),
        // no router further west
        .ccwso (/*unused*/),
        .ccwdo (/*unused*/),
        .ccwro (/*unused*/),

        // ns (north->south): from (0,1) down
        .nssi (nsso_0_1_to_0_0),
        .nsdi (nsdo_0_1_to_0_0),
        .nsri (nsro_0_0_to_0_1),
        // no south neighbor
        .nsso (/*unused*/),
        .nsdo (/*unused*/),
        .nsro (/*unused*/),

        // sn (south->north): no router below
        .snsi (1'b0),
        .sndi ({PACKET_SIZE{1'b0}}),
        .snri (/*unused*/),
        // up to (0,1)
        .snso (snso_0_0_to_0_1),
        .sndo (sndo_0_0_to_0_1),
        .snro (snro_0_1_to_0_0),

        // device
        .pesi (node00_pesi),
        .peri (node00_peri),
        .pero (node00_pero),
        .peso (node00_peso),
        .pedi (node00_pedi),
        .pedo (node00_pedo)
    );

    //------------------
    // (x=1, y=0)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_0 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw (west->east): in from (0,0), out to (2,0)
        .cwsi (cwso_0_0_to_1_0),
        .cwdi (cwdo_0_0_to_1_0),
        .cwri (cwro_1_0_to_0_0),
        .cwso (cwso_1_0_to_2_0),
        .cwdo (cwdo_1_0_to_2_0),
        .cwro (cwro_2_0_to_1_0),

        // ccw (east->west): in from (2,0), out to (0,0)
        .ccwsi (ccwso_2_0_to_1_0),
        .ccwdi (ccwdo_2_0_to_1_0),
        .ccwri (ccwro_1_0_to_2_0),
        .ccwso (ccwso_1_0_to_0_0),
        .ccwdo (ccwdo_1_0_to_0_0),
        .ccwro (ccwro_0_0_to_1_0),

        // ns (north->south): from (1,1), no south neighbor
        .nssi (nsso_1_1_to_1_0),
        .nsdi (nsdo_1_1_to_1_0),
        .nsri (nsro_1_0_to_1_1),
        .nsso (/*unused*/),
        .nsdo (/*unused*/),
        .nsro (/*unused*/),

        // sn (south->north): none below, up to (1,1)
        .snsi (1'b0),
        .sndi ({PACKET_SIZE{1'b0}}),
        .snri (/*unused*/),
        .snso (snso_1_0_to_1_1),
        .sndo (sndo_1_0_to_1_1),
        .snro (snro_1_1_to_1_0),

        // device
        .pesi (node10_pesi),
        .peri (node10_peri),
        .pero (node10_pero),
        .peso (node10_peso),
        .pedi (node10_pedi),
        .pedo (node10_pedo)
    );

    //------------------
    // (x=2, y=0)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_0 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: in from (1,0), out to (3,0)
        .cwsi (cwso_1_0_to_2_0),
        .cwdi (cwdo_1_0_to_2_0),
        .cwri (cwro_2_0_to_1_0),
        .cwso (cwso_2_0_to_3_0),
        .cwdo (cwdo_2_0_to_3_0),
        .cwro (cwro_3_0_to_2_0),

        // ccw: in from (3,0), out to (1,0)
        .ccwsi (ccwso_3_0_to_2_0),
        .ccwdi (ccwdo_3_0_to_2_0),
        .ccwri (ccwro_2_0_to_3_0),
        .ccwso (ccwso_2_0_to_1_0),
        .ccwdo (ccwdo_2_0_to_1_0),
        .ccwro (ccwro_1_0_to_2_0),

        // ns: from (2,1), none below
        .nssi (nsso_2_1_to_2_0),
        .nsdi (nsdo_2_1_to_2_0),
        .nsri (nsro_2_0_to_2_1),
        .nsso (/*unused*/),
        .nsdo (/*unused*/),
        .nsro (/*unused*/),

        // sn: none below, up to (2,1)
        .snsi (1'b0),
        .sndi ({PACKET_SIZE{1'b0}}),
        .snri (/*unused*/),
        .snso (snso_2_0_to_2_1),
        .sndo (sndo_2_0_to_2_1),
        .snro (snro_2_1_to_2_0),

        // device
        .pesi (node20_pesi),
        .peri (node20_peri),
        .pero (node20_pero),
        .peso (node20_peso),
        .pedi (node20_pedi),
        .pedo (node20_pedo)
    );

    //------------------
    // (x=3, y=0) - bottom-right
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_3_0 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: in from (2,0), no east neighbor
        .cwsi (cwso_2_0_to_3_0),
        .cwdi (cwdo_2_0_to_3_0),
        .cwri (cwro_3_0_to_2_0),
        .cwso (/*unused*/),
        .cwdo (/*unused*/),
        .cwro (/*unused*/),

        // ccw: no real east neighbor => tie in low, out to (2,0)
        .ccwsi (1'b0),
        .ccwdi ({PACKET_SIZE{1'b0}}),
        .ccwri (/*unused*/),
        .ccwso (ccwso_3_0_to_2_0),
        .ccwdo (ccwdo_3_0_to_2_0),
        .ccwro (ccwro_2_0_to_3_0),

        // ns: from (3,1), no south
        .nssi (nsso_3_1_to_3_0),
        .nsdi (nsdo_3_1_to_3_0),
        .nsri (nsro_3_0_to_3_1),
        .nsso (/*unused*/),
        .nsdo (/*unused*/),
        .nsro (/*unused*/),

        // sn: no south neighbor, up to (3,1)
        .snsi (1'b0),
        .sndi ({PACKET_SIZE{1'b0}}),
        .snri (/*unused*/),
        .snso (snso_3_0_to_3_1),
        .sndo (sndo_3_0_to_3_1),
        .snro (snro_3_1_to_3_0),

        // device
        .pesi (node30_pesi),
        .peri (node30_peri),
        .pero (node30_pero),
        .peso (node30_peso),
        .pedi (node30_pedi),
        .pedo (node30_pedo)
    );

    //------------------
    // (x=0, y=1)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_1 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: no west neighbor
        .cwsi (1'b0),
        .cwdi ({PACKET_SIZE{1'b0}}),
        .cwri (/*unused*/),
        .cwso (cwso_0_1_to_1_1),
        .cwdo (cwdo_0_1_to_1_1),
        .cwro (cwro_1_1_to_0_1),

        // ccw: from (1,1)
        .ccwsi (ccwso_1_1_to_0_1),
        .ccwdi (ccwdo_1_1_to_0_1),
        .ccwri (ccwro_0_1_to_1_1),
        .ccwso (/*unused*/),
        .ccwdo (/*unused*/),
        .ccwro (/*unused*/),

        // ns: from (0,2), to (0,0)
        .nssi (nsso_0_2_to_0_1),
        .nsdi (nsdo_0_2_to_0_1),
        .nsri (nsro_0_1_to_0_2),
        .nsso (nsso_0_1_to_0_0),
        .nsdo (nsdo_0_1_to_0_0),
        .nsro (nsro_0_0_to_0_1),

        // sn: from (0,0), to (0,2)
        .snsi (snso_0_0_to_0_1),
        .sndi (sndo_0_0_to_0_1),
        .snri (snro_0_1_to_0_0),
        .snso (snso_0_1_to_0_2),
        .sndo (sndo_0_1_to_0_2),
        .snro (snro_0_2_to_0_1),

        // device
        .pesi (node01_pesi),
        .peri (node01_peri),
        .pero (node01_pero),
        .peso (node01_peso),
        .pedi (node01_pedi),
        .pedo (node01_pedo)
    );

    //------------------
    // (x=1, y=1)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_1 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (0,1) to (2,1)
        .cwsi (cwso_0_1_to_1_1),
        .cwdi (cwdo_0_1_to_1_1),
        .cwri (cwro_1_1_to_0_1),
        .cwso (cwso_1_1_to_2_1),
        .cwdo (cwdo_1_1_to_2_1),
        .cwro (cwro_2_1_to_1_1),

        // ccw: from (2,1) to (0,1)
        .ccwsi (ccwso_2_1_to_1_1),
        .ccwdi (ccwdo_2_1_to_1_1),
        .ccwri (ccwro_1_1_to_2_1),
        .ccwso (ccwso_1_1_to_0_1),
        .ccwdo (ccwdo_1_1_to_0_1),
        .ccwro (ccwro_0_1_to_1_1),

        // ns: from (1,2) to (1,0)
        .nssi (nsso_1_2_to_1_1),
        .nsdi (nsdo_1_2_to_1_1),
        .nsri (nsro_1_1_to_1_2),
        .nsso (nsso_1_1_to_1_0),
        .nsdo (nsdo_1_1_to_1_0),
        .nsro (nsro_1_0_to_1_1),

        // sn: from (1,0) to (1,2)
        .snsi (snso_1_0_to_1_1),
        .sndi (sndo_1_0_to_1_1),
        .snri (snro_1_1_to_1_0),
        .snso (snso_1_1_to_1_2),
        .sndo (sndo_1_1_to_1_2),
        .snro (snro_1_2_to_1_1),

        // device
        .pesi (node11_pesi),
        .peri (node11_peri),
        .pero (node11_pero),
        .peso (node11_peso),
        .pedi (node11_pedi),
        .pedo (node11_pedo)
    );

    //------------------
    // (x=2, y=1)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_1 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (1,1) to (3,1)
        .cwsi (cwso_1_1_to_2_1),
        .cwdi (cwdo_1_1_to_2_1),
        .cwri (cwro_2_1_to_1_1),
        .cwso (cwso_2_1_to_3_1),
        .cwdo (cwdo_2_1_to_3_1),
        .cwro (cwro_3_1_to_2_1),

        // ccw: from (3,1) to (1,1)
        .ccwsi (ccwso_3_1_to_2_1),
        .ccwdi (ccwdo_3_1_to_2_1),
        .ccwri (ccwro_2_1_to_3_1),
        .ccwso (ccwso_2_1_to_1_1),
        .ccwdo (ccwdo_2_1_to_1_1),
        .ccwro (ccwro_1_1_to_2_1),

        // ns: from (2,2) to (2,0)
        .nssi (nsso_2_2_to_2_1),
        .nsdi (nsdo_2_2_to_2_1),
        .nsri (nsro_2_1_to_2_2),
        .nsso (nsso_2_1_to_2_0),
        .nsdo (nsdo_2_1_to_2_0),
        .nsro (nsro_2_0_to_2_1),

        // sn: from (2,0) to (2,2)
        .snsi (snso_2_0_to_2_1),
        .sndi (sndo_2_0_to_2_1),
        .snri (snro_2_1_to_2_0),
        .snso (snso_2_1_to_2_2),
        .sndo (sndo_2_1_to_2_2),
        .snro (snro_2_2_to_2_1),

        // device
        .pesi (node21_pesi),
        .peri (node21_peri),
        .pero (node21_pero),
        .peso (node21_peso),
        .pedi (node21_pedi),
        .pedo (node21_pedo)
    );

    //------------------
    // (x=3, y=1)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_3_1 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (2,1), no east
        .cwsi (cwso_2_1_to_3_1),
        .cwdi (cwdo_2_1_to_3_1),
        .cwri (cwro_3_1_to_2_1),
        .cwso (/*unused*/),
        .cwdo (/*unused*/),
        .cwro (/*unused*/),

        // ccw: no router further east => tie in low, out to (2,1)
        .ccwsi (1'b0),
        .ccwdi ({PACKET_SIZE{1'b0}}),
        .ccwri (/*unused*/),
        .ccwso (ccwso_3_1_to_2_1),
        .ccwdo (ccwdo_3_1_to_2_1),
        .ccwro (ccwro_2_1_to_3_1),

        // ns: from (3,2), to (3,0)
        .nssi (nsso_3_2_to_3_1),
        .nsdi (nsdo_3_2_to_3_1),
        .nsri (nsro_3_1_to_3_2),
        .nsso (nsso_3_1_to_3_0),
        .nsdo (nsdo_3_1_to_3_0),
        .nsro (nsro_3_0_to_3_1),

        // sn: from (3,0) to (3,2)
        .snsi (snso_3_0_to_3_1),
        .sndi (sndo_3_0_to_3_1),
        .snri (snro_3_1_to_3_0),
        .snso (snso_3_1_to_3_2),
        .sndo (sndo_3_1_to_3_2),
        .snro (snro_3_2_to_3_1),

        // device
        .pesi (node31_pesi),
        .peri (node31_peri),
        .pero (node31_pero),
        .peso (node31_peso),
        .pedi (node31_pedi),
        .pedo (node31_pedo)
    );

    //------------------
    // (x=0, y=2)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_2 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: no west
        .cwsi (1'b0),
        .cwdi ({PACKET_SIZE{1'b0}}),
        .cwri (/*unused*/),
        .cwso (cwso_0_2_to_1_2),
        .cwdo (cwdo_0_2_to_1_2),
        .cwro (cwro_1_2_to_0_2),

        // ccw: from (1,2)
        .ccwsi (ccwso_1_2_to_0_2),
        .ccwdi (ccwdo_1_2_to_0_2),
        .ccwri (ccwro_0_2_to_1_2),
        .ccwso (/*unused*/),
        .ccwdo (/*unused*/),
        .ccwro (/*unused*/),

        // ns: from (0,3) => down to (0,1)
        .nssi (nsso_0_3_to_0_2),
        .nsdi (nsdo_0_3_to_0_2),
        .nsri (nsro_0_2_to_0_3),
        .nsso (nsso_0_2_to_0_1),
        .nsdo (nsdo_0_2_to_0_1),
        .nsro (nsro_0_1_to_0_2),

        // sn: from (0,1) up to (0,3)
        .snsi (snso_0_1_to_0_2),
        .sndi (sndo_0_1_to_0_2),
        .snri (snro_0_2_to_0_1),
        .snso (snso_0_2_to_0_3),
        .sndo (sndo_0_2_to_0_3),
        .snro (snro_0_3_to_0_2),

        // device
        .pesi (node02_pesi),
        .peri (node02_peri),
        .pero (node02_pero),
        .peso (node02_peso),
        .pedi (node02_pedi),
        .pedo (node02_pedo)
    );

    //------------------
    // (x=1, y=2)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_2 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (0,2) => (2,2)
        .cwsi (cwso_0_2_to_1_2),
        .cwdi (cwdo_0_2_to_1_2),
        .cwri (cwro_1_2_to_0_2),
        .cwso (cwso_1_2_to_2_2),
        .cwdo (cwdo_1_2_to_2_2),
        .cwro (cwro_2_2_to_1_2),

        // ccw: from (2,2) => (0,2)
        .ccwsi (ccwso_2_2_to_1_2),
        .ccwdi (ccwdo_2_2_to_1_2),
        .ccwri (ccwro_1_2_to_2_2),
        .ccwso (ccwso_1_2_to_0_2),
        .ccwdo (ccwdo_1_2_to_0_2),
        .ccwro (ccwro_0_2_to_1_2),

        // ns: from (1,3) => down to (1,1)
        .nssi (nsso_1_3_to_1_2),
        .nsdi (nsdo_1_3_to_1_2),
        .nsri (nsro_1_2_to_1_3),
        .nsso (nsso_1_2_to_1_1),
        .nsdo (nsdo_1_2_to_1_1),
        .nsro (nsro_1_1_to_1_2),

        // sn: from (1,1) => up to (1,3)
        .snsi (snso_1_1_to_1_2),
        .sndi (sndo_1_1_to_1_2),
        .snri (snro_1_2_to_1_1),
        .snso (snso_1_2_to_1_3),
        .sndo (sndo_1_2_to_1_3),
        .snro (snro_1_3_to_1_2),

        // device
        .pesi (node12_pesi),
        .peri (node12_peri),
        .pero (node12_pero),
        .peso (node12_peso),
        .pedi (node12_pedi),
        .pedo (node12_pedo)
    );

    //------------------
    // (x=2, y=2)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_2 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (1,2) => (3,2)
        .cwsi (cwso_1_2_to_2_2),
        .cwdi (cwdo_1_2_to_2_2),
        .cwri (cwro_2_2_to_1_2),
        .cwso (cwso_2_2_to_3_2),
        .cwdo (cwdo_2_2_to_3_2),
        .cwro (cwro_3_2_to_2_2),

        // ccw: from (3,2) => (1,2)
        .ccwsi (ccwso_3_2_to_2_2),
        .ccwdi (ccwdo_3_2_to_2_2),
        .ccwri (ccwro_2_2_to_3_2),
        .ccwso (ccwso_2_2_to_1_2),
        .ccwdo (ccwdo_2_2_to_1_2),
        .ccwro (ccwro_1_2_to_2_2),

        // ns: from (2,3) => down to (2,1)
        .nssi (nsso_2_3_to_2_2),
        .nsdi (nsdo_2_3_to_2_2),
        .nsri (nsro_2_2_to_2_3),
        .nsso (nsso_2_2_to_2_1),
        .nsdo (nsdo_2_2_to_2_1),
        .nsro (nsro_2_1_to_2_2),

        // sn: from (2,1) => up to (2,3)
        .snsi (snso_2_1_to_2_2),
        .sndi (sndo_2_1_to_2_2),
        .snri (snro_2_2_to_2_1),
        .snso (snso_2_2_to_2_3),
        .sndo (sndo_2_2_to_2_3),
        .snro (snro_2_3_to_2_2),

        // device
        .pesi (node22_pesi),
        .peri (node22_peri),
        .pero (node22_pero),
        .peso (node22_peso),
        .pedi (node22_pedi),
        .pedo (node22_pedo)
    );

    //------------------
    // (x=3, y=2)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_3_2 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (2,2), no east
        .cwsi (cwso_2_2_to_3_2),
        .cwdi (cwdo_2_2_to_3_2),
        .cwri (cwro_3_2_to_2_2),
        .cwso (/*unused*/),
        .cwdo (/*unused*/),
        .cwro (/*unused*/),

        // ccw: tie in low, out to (2,2)
        .ccwsi (1'b0),
        .ccwdi ({PACKET_SIZE{1'b0}}),
        .ccwri (/*unused*/),
        .ccwso (ccwso_3_2_to_2_2),
        .ccwdo (ccwdo_3_2_to_2_2),
        .ccwro (ccwro_2_2_to_3_2),

        // ns: from (3,3) => down to (3,1)
        .nssi (nsso_3_3_to_3_2),
        .nsdi (nsdo_3_3_to_3_2),
        .nsri (nsro_3_2_to_3_3),
        .nsso (nsso_3_2_to_3_1),
        .nsdo (nsdo_3_2_to_3_1),
        .nsro (nsro_3_1_to_3_2),

        // sn: from (3,1) => up to (3,3)
        .snsi (snso_3_1_to_3_2),
        .sndi (sndo_3_1_to_3_2),
        .snri (snro_3_2_to_3_1),
        .snso (snso_3_2_to_3_3),
        .sndo (sndo_3_2_to_3_3),
        .snro (snro_3_3_to_3_2),

        // device
        .pesi (node32_pesi),
        .peri (node32_peri),
        .pero (node32_pero),
        .peso (node32_peso),
        .pedi (node32_pedi),
        .pedo (node32_pedo)
    );

    //------------------
    // (x=0, y=3) - top-left
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_0_3 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: no west
        .cwsi (1'b0),
        .cwdi ({PACKET_SIZE{1'b0}}),
        .cwri (/*unused*/),
        .cwso (cwso_0_3_to_1_3),
        .cwdo (cwdo_0_3_to_1_3),
        .cwro (cwro_1_3_to_0_3),

        // ccw: from (1,3)
        .ccwsi (ccwso_1_3_to_0_3),
        .ccwdi (ccwdo_1_3_to_0_3),
        .ccwri (ccwro_0_3_to_1_3),
        .ccwso (/*unused*/),
        .ccwdo (/*unused*/),
        .ccwro (/*unused*/),

        // ns: no router above => tie in low
        .nssi (1'b0),
        .nsdi ({PACKET_SIZE{1'b0}}),
        .nsri (/*unused*/),
        // south => (0,2)
        .nsso (nsso_0_3_to_0_2),
        .nsdo (nsdo_0_3_to_0_2),
        .nsro (nsro_0_2_to_0_3),

        // sn: from (0,2), no further north
        .snsi (snso_0_2_to_0_3),
        .sndi (sndo_0_2_to_0_3),
        .snri (snro_0_3_to_0_2),
        .snso (/*unused*/),
        .sndo (/*unused*/),
        .snro (/*unused*/),

        // device
        .pesi (node03_pesi),
        .peri (node03_peri),
        .pero (node03_pero),
        .peso (node03_peso),
        .pedi (node03_pedi),
        .pedo (node03_pedo)
    );

    //------------------
    // (x=1, y=3)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_1_3 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (0,3) => (2,3)
        .cwsi (cwso_0_3_to_1_3),
        .cwdi (cwdo_0_3_to_1_3),
        .cwri (cwro_1_3_to_0_3),
        .cwso (cwso_1_3_to_2_3),
        .cwdo (cwdo_1_3_to_2_3),
        .cwro (cwro_2_3_to_1_3),

        // ccw: from (2,3) => (0,3)
        .ccwsi (ccwso_2_3_to_1_3),
        .ccwdi (ccwdo_2_3_to_1_3),
        .ccwri (ccwro_1_3_to_2_3),
        .ccwso (ccwso_1_3_to_0_3),
        .ccwdo (ccwdo_1_3_to_0_3),
        .ccwro (ccwro_0_3_to_1_3),

        // ns: no router above => tie in low, south => (1,2)
        .nssi (1'b0),
        .nsdi ({PACKET_SIZE{1'b0}}),
        .nsri (/*unused*/),
        .nsso (nsso_1_3_to_1_2),
        .nsdo (nsdo_1_3_to_1_2),
        .nsro (nsro_1_2_to_1_3),

        // sn: from (1,2), no further north
        .snsi (snso_1_2_to_1_3),
        .sndi (sndo_1_2_to_1_3),
        .snri (snro_1_3_to_1_2),
        .snso (/*unused*/),
        .sndo (/*unused*/),
        .snro (/*unused*/),

        // device
        .pesi (node13_pesi),
        .peri (node13_peri),
        .pero (node13_pero),
        .peso (node13_peso),
        .pedi (node13_pedi),
        .pedo (node13_pedo)
    );

    //------------------
    // (x=2, y=3)
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_2_3 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (1,3) => (3,3)
        .cwsi (cwso_1_3_to_2_3),
        .cwdi (cwdo_1_3_to_2_3),
        .cwri (cwro_2_3_to_1_3),
        .cwso (cwso_2_3_to_3_3),
        .cwdo (cwdo_2_3_to_3_3),
        .cwro (cwro_3_3_to_2_3),

        // ccw: from (3,3) => (1,3)
        .ccwsi (ccwso_3_3_to_2_3),
        .ccwdi (ccwdo_3_3_to_2_3),
        .ccwri (ccwro_2_3_to_3_3),
        .ccwso (ccwso_2_3_to_1_3),
        .ccwdo (ccwdo_2_3_to_1_3),
        .ccwro (ccwro_1_3_to_2_3),

        // ns: no router above => tie in low, south => (2,2)
        .nssi (1'b0),
        .nsdi ({PACKET_SIZE{1'b0}}),
        .nsri (/*unused*/),
        .nsso (nsso_2_3_to_2_2),
        .nsdo (nsdo_2_3_to_2_2),
        .nsro (nsro_2_2_to_2_3),

        // sn: from (2,2), no further north
        .snsi (snso_2_2_to_2_3),
        .sndi (sndo_2_2_to_2_3),
        .snri (snro_2_3_to_2_2),
        .snso (/*unused*/),
        .sndo (/*unused*/),
        .snro (/*unused*/),

        // device
        .pesi (node23_pesi),
        .peri (node23_peri),
        .pero (node23_pero),
        .peso (node23_peso),
        .pedi (node23_pedi),
        .pedo (node23_pedo)
    );

    //------------------
    // (x=3, y=3) - top-right
    //------------------
    gold_router #(.PACKET_SIZE(PACKET_SIZE)) router_3_3 (
        .clk(clk), .reset(reset), .polarity(polarity),

        // cw: from (2,3), no east neighbor
        .cwsi (cwso_2_3_to_3_3),
        .cwdi (cwdo_2_3_to_3_3),
        .cwri (cwro_3_3_to_2_3),
        .cwso (/*unused*/),
        .cwdo (/*unused*/),
        .cwro (/*unused*/),

        // ccw: tie in low, out to (2,3)
        .ccwsi (1'b0),
        .ccwdi ({PACKET_SIZE{1'b0}}),
        .ccwri (/*unused*/),
        .ccwso (ccwso_3_3_to_2_3),
        .ccwdo (ccwdo_3_3_to_2_3),
        .ccwro (ccwro_2_3_to_3_3),

        // ns: no router above => tie in low, south => (3,2)
        .nssi (1'b0),
        .nsdi ({PACKET_SIZE{1'b0}}),
        .nsri (/*unused*/),
        .nsso (nsso_3_3_to_3_2),
        .nsdo (nsdo_3_3_to_3_2),
        .nsro (nsro_3_2_to_3_3),

        // sn: from (3,2), no further north
        .snsi (snso_3_2_to_3_3),
        .sndi (sndo_3_2_to_3_3),
        .snri (snro_3_3_to_3_2),
        .snso (/*unused*/),
        .sndo (/*unused*/),
        .snro (/*unused*/),

        // device
        .pesi (node33_pesi),
        .peri (node33_peri),
        .pero (node33_pero),
        .peso (node33_peso),
        .pedi (node33_pedi),
        .pedo (node33_pedo)
    );

endmodule
