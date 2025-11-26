// `timescale 1ns/1ps

// module canny_top #(
//     parameter int W = 3124,
//     parameter int H = 3030,
//     parameter int T_LOW  = 50,
//     parameter int T_HIGH = 100
// )(
//     input  logic clk, rst_n,
//     input  logic [7:0] pixel_in,
//     input  logic       in_valid,
//     output logic [7:0] edge_out,
//     output logic       out_valid
// );

//     // ------------------ Stage1 : LB → Gaussian ------------------
//     logic g_valid;
//     logic [7:0] g00,g01,g02,g10,g11,g12,g20,g21,g22;
//     linebuffer_3x3 #(.DATA_W(8),.IMG_W(W)) LB_GAUSS(
//         .clk(clk),.rst_n(rst_n),.pixel_in(pixel_in),.valid_in(in_valid),
//         .w00(g00),.w01(g01),.w02(g02),
//         .w10(g10),.w11(g11),.w12(g12),
//         .w20(g20),.w21(g21),.w22(g22),
//         .valid_out(g_valid)
//     );

//     logic [7:0] gpix;
//     logic       g_out;
//     gaussian3x3 GA(.clk(clk),.rst_n(rst_n),.in_valid(g_valid),
//             .p00(g00),.p01(g01),.p02(g02),
//             .p10(g10),.p11(g11),.p12(g12),
//             .p20(g20),.p21(g21),.p22(g22),
//             .pix_out(gpix),.out_valid(g_out));

//     // ------------------ Stage2 : LB → Sobel ---------------------
//     logic s_valid;
//     logic [7:0] s00,s01,s02,s10,s11,s12,s20,s21,s22;
//     linebuffer_3x3 #(.DATA_W(8),.IMG_W(W)) LB_SOBEL(
//         .clk(clk),.rst_n(rst_n),.pixel_in(gpix),.valid_in(g_out),
//         .w00(s00),.w01(s01),.w02(s02),
//         .w10(s10),.w11(s11),.w12(s12),
//         .w20(s20),.w21(s21),.w22(s22),
//         .valid_out(s_valid)
//     );

//     logic signed [15:0] gx,gy;
//     logic [15:0] mag;
//     logic sobel_out;
//     sobel3x3 SOB(.clk(clk),.rst_n(rst_n),.in_valid(s_valid),
//         .p00(s00),.p01(s01),.p02(s02),
//         .p10(s10),.p11(s11),.p12(s12),
//         .p20(s20),.p21(s21),.p22(s22),
//         .gx(gx),.gy(gy),.mag(mag),.out_valid(sobel_out));

//     // ------------------ Stage3 : LB → NMS -----------------------
//     logic nm_valid;
//     logic [15:0] n00,n01,n02,n10,n11,n12,n20,n21,n22;
//     linebuffer_3x3 #(.DATA_W(16),.IMG_W(W)) LB_MAG(
//         .clk(clk),.rst_n(rst_n),.pixel_in(mag),.valid_in(sobel_out),
//         .w00(n00),.w01(n01),.w02(n02),
//         .w10(n10),.w11(n11),.w12(n12),
//         .w20(n20),.w21(n21),.w22(n22),
//         .valid_out(nm_valid)
//     );

//     logic [15:0] mag_nms;
//     logic        nms_o;
//     canny_nms NMS(.clk(clk),.rst_n(rst_n),.in_valid(nm_valid),
//         .gx(gx),.gy(gy),
//         .m00(n00),.m01(n01),.m02(n02),
//         .m10(n10),.m11(n11),.m12(n12),
//         .m20(n20),.m21(n21),.m22(n22),
//         .mag_nms(mag_nms),.out_valid(nms_o));

//     // ------------------ Stage4 : LB → Hysteresis ----------------
//     logic hy_valid;
//     logic [15:0] h00,h01,h02,h10,h11,h12,h20,h21,h22;
//     linebuffer_3x3 #(.DATA_W(16),.IMG_W(W)) LB_NMS(
//         .clk(clk),.rst_n(rst_n),.pixel_in(mag_nms),.valid_in(nms_o),
//         .w00(h00),.w01(h01),.w02(h02),
//         .w10(h10),.w11(h11),.w12(h12),
//         .w20(h20),.w21(h21),.w22(h22),
//         .valid_out(hy_valid)
//     );

//     canny_threshold_hyst #(.T_LOW(T_LOW),.T_HIGH(T_HIGH)) HYS(
//         .clk(clk),.rst_n(rst_n),.in_valid(hy_valid),
//         .c(h11),.n00(h00),.n01(h01),.n02(h02),
//                 .n10(h10),          .n12(h12),
//                 .n20(h20),.n21(h21),.n22(h22),
//         .edge_out(edge_out),.out_valid(out_valid));

// endmodule
`timescale 1ns/1ps

module canny_top #(
    parameter int W = 3124,
    parameter int H = 3030,
    parameter int T_LOW  = 50,
    parameter int T_HIGH = 100
)(
    input  logic clk, rst_n,
    input  logic [7:0] pixel_in,
    input  logic       in_valid,
    output logic [7:0] edge_out,
    output logic       out_valid
);

    // ============================================================
    //   NEW STAGE 0 : NOISE REDUCTION (Median 3x3)
    // ============================================================
    logic n_valid;
    logic [7:0] n00,n01,n02,n10,n11,n12,n20,n21,n22;

    linebuffer_3x3 #(.DATA_W(8),.IMG_W(W)) LB_NOISE(
        .clk(clk),.rst_n(rst_n),.pixel_in(pixel_in),.valid_in(in_valid),
        .w00(n00),.w01(n01),.w02(n02),
        .w10(n10),.w11(n11),.w12(n12),
        .w20(n20),.w21(n21),.w22(n22),
        .valid_out(n_valid)
    );

    logic [7:0] noise_clean;
    logic      noise_ok;
    median3x3 MED(.clk(clk),.rst_n(rst_n),.in_valid(n_valid),
                  .p00(n00),.p01(n01),.p02(n02),
                  .p10(n10),.p11(n11),.p12(n12),
                  .p20(n20),.p21(n21),.p22(n22),
                  .median(noise_clean),.out_valid(noise_ok));

    // ============================================================
    //   Stage 1 : Gaussian Blur
    // ============================================================
    logic g_valid;
    logic [7:0] g00,g01,g02,g10,g11,g12,g20,g21,g22;

    linebuffer_3x3 #(.DATA_W(8),.IMG_W(W)) LB_GAUSS(
        .clk(clk),.rst_n(rst_n),.pixel_in(noise_clean),.valid_in(noise_ok),
        .w00(g00),.w01(g01),.w02(g02),
        .w10(g10),.w11(g11),.w12(g12),
        .w20(g20),.w21(g21),.w22(g22),
        .valid_out(g_valid)
    );

    logic [7:0] gpix;
    logic      g_out;
    gaussian3x3 GA(.clk(clk),.rst_n(rst_n),.in_valid(g_valid),
            .p00(g00),.p01(g01),.p02(g02),
            .p10(g10),.p11(g11),.p12(g12),
            .p20(g20),.p21(g21),.p22(g22),
            .pix_out(gpix),.out_valid(g_out));

    // ============================================================
    //   Stage 2 : Sobel
    // ============================================================
    logic s_valid;
    logic [7:0] s00,s01,s02,s10,s11,s12,s20,s21,s22;
    linebuffer_3x3 #(.DATA_W(8),.IMG_W(W)) LB_SOBEL(
        .clk(clk),.rst_n(rst_n),.pixel_in(gpix),.valid_in(g_out),
        .w00(s00),.w01(s01),.w02(s02),
        .w10(s10),.w11(s11),.w12(s12),
        .w20(s20),.w21(s21),.w22(s22),
        .valid_out(s_valid)
    );

    logic signed [15:0] gx,gy;
    logic [15:0] mag;
    logic sobel_out;
    sobel3x3 SOB(.clk(clk),.rst_n(rst_n),.in_valid(s_valid),
        .p00(s00),.p01(s01),.p02(s02),
        .p10(s10),.p11(s11),.p12(s12),
        .p20(s20),.p21(s21),.p22(s22),
        .gx(gx),.gy(gy),.mag(mag),.out_valid(sobel_out));

    // ============================================================
    //   Stage 3 : NMS
    // ============================================================
    logic nm_valid;
    logic [15:0] n00_m,n01_m,n02_m,n10_m,n11_m,n12_m,n20_m,n21_m,n22_m;
    linebuffer_3x3 #(.DATA_W(16),.IMG_W(W)) LB_MAG(
        .clk(clk),.rst_n(rst_n),.pixel_in(mag),.valid_in(sobel_out),
        .w00(n00_m),.w01(n01_m),.w02(n02_m),
        .w10(n10_m),.w11(n11_m),.w12(n12_m),
        .w20(n20_m),.w21(n21_m),.w22(n22_m),
        .valid_out(nm_valid)
    );

    logic [15:0] mag_nms;
    logic       nms_o;
    canny_nms NMS(.clk(clk),.rst_n(rst_n),.in_valid(nm_valid),
        .gx(gx),.gy(gy),
        .m00(n00_m),.m01(n01_m),.m02(n02_m),
        .m10(n10_m),.m11(n11_m),.m12(n12_m),
        .m20(n20_m),.m21(n21_m),.m22(n22_m),
        .mag_nms(mag_nms),.out_valid(nms_o));

    // ============================================================
    //   Stage 4 : Hysteresis
    // ============================================================
    logic hy_valid;
    logic [15:0] h00,h01,h02,h10,h11,h12,h20,h21,h22;
    linebuffer_3x3 #(.DATA_W(16),.IMG_W(W)) LB_HYST(
        .clk(clk),.rst_n(rst_n),.pixel_in(mag_nms),.valid_in(nms_o),
        .w00(h00),.w01(h01),.w02(h02),
        .w10(h10),.w11(h11),.w12(h12),
        .w20(h20),.w21(h21),.w22(h22),
        .valid_out(hy_valid)
    );

    canny_threshold_hyst #(.T_LOW(T_LOW),.T_HIGH(T_HIGH)) HYS(
        .clk(clk),.rst_n(rst_n),.in_valid(hy_valid),
        .c(h11),.n00(h00),.n01(h01),.n02(h02),
                .n10(h10),          .n12(h12),
                .n20(h20),.n21(h21),.n22(h22),
        .edge_out(edge_out),.out_valid(out_valid)
    );

endmodule
