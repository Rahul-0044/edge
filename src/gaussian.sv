// // ===============================================
// // 3x3 Gaussian Blur with kernel:
// //  1 2 1
// //  2 4 2   / 16
// //  1 2 1
// // ===============================================
// module gaussian3x3(
//     input  logic        clk,
//     input  logic        rst_n,
//     input  logic        in_valid,

//     input  logic [7:0]  p00, p01, p02,
//     input  logic [7:0]  p10, p11, p12,
//     input  logic [7:0]  p20, p21, p22,

//     output logic [7:0]  pix_out,
//     output logic        out_valid
// );

//     logic [11:0] sum;
//     logic        v_d;

//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             sum      <= '0;
//             v_d      <= 1'b0;
//             pix_out  <= 8'd0;
//             out_valid<= 1'b0;
//         end else begin
//             v_d      <= in_valid;
//             out_valid<= v_d;
//             if (in_valid) begin
//                 sum <= p00 + (p01<<1) + p02 +
//                        (p10<<1) + (p11<<2) + (p12<<1) +
//                        p20 + (p21<<1) + p22;
//             end
//             if (v_d) begin
//                 // divide by 16, with rounding
//                 pix_out <= (sum + 12'd8) >> 4;
//             end
//         end
//     end

// endmodule
module gaussian3x3(input logic clk,rst_n,in_valid,
    input logic[7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,
    output logic[7:0] pix_out, output logic out_valid);

    logic[11:0] sum; logic d;
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin pix_out<=0;out_valid<=0;d<=0; end
        else begin
            d<=in_valid; out_valid<=d;
            if(in_valid)
                sum <= p00+(p01<<1)+p02 +((p10<<1)+(p11<<2)+(p12<<1)) + p20+(p21<<1)+p22;
            if(d) pix_out <= (sum+8)>>4;
        end
    end
endmodule
