// // ===============================================
// // Sobel 3x3 on blurred pixels
// // Outputs signed gx, gy and |gx|+|gy| magnitude
// // ===============================================
// module sobel3x3(
//     input  logic              clk,
//     input  logic              rst_n,
//     input  logic              in_valid,

//     input  logic  [7:0]       p00, p01, p02,
//     input  logic  [7:0]       p10, p11, p12,
//     input  logic  [7:0]       p20, p21, p22,

//     output logic signed [15:0] gx,
//     output logic signed [15:0] gy,
//     output logic        [15:0] mag,
//     output logic              out_valid
// );

//     logic              v_d;
//     logic signed [15:0] gx_i, gy_i;
//     logic        [15:0] ax, ay;

//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             gx       <= '0;
//             gy       <= '0;
//             mag      <= '0;
//             v_d      <= 1'b0;
//             out_valid<= 1'b0;
//         end else begin
//             v_d       <= in_valid;
//             out_valid <= v_d;

//             if (in_valid) begin
//                 // Sobel kernels
//                 gx_i <= -$signed({8'd0,p00}) + $signed({8'd0,p02})
//                          - ($signed({8'd0,p10}) <<< 1) + ($signed({8'd0,p12}) <<< 1)
//                          - $signed({8'd0,p20}) + $signed({8'd0,p22});

//                 gy_i <=  $signed({8'd0,p00}) + ($signed({8'd0,p01}) <<< 1) + $signed({8'd0,p02})
//                          - $signed({8'd0,p20}) - ($signed({8'd0,p21}) <<< 1) - $signed({8'd0,p22});
//             end

//             if (v_d) begin
//                 gx <= gx_i;
//                 gy <= gy_i;

//                 ax  <= gx_i[15] ? (~gx_i + 1) : gx_i;
//                 ay  <= gy_i[15] ? (~gy_i + 1) : gy_i;
//                 mag <= ax + ay;   // |gx| + |gy|
//             end
//         end
//     end

// endmodule
module sobel3x3(input logic clk,rst_n,in_valid,
    input logic[7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,
    output logic signed[15:0] gx,gy, output logic[15:0] mag, output logic out_valid);

    logic v; logic signed[15:0] ax,ay,tmpx,tmpy;
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin out_valid<=0;v<=0; end
        else begin
            v<=in_valid; out_valid<=v;
            if(in_valid) begin
                tmpx<=-(p00)+(p02)-((p10)<<1)+((p12)<<1)-(p20)+(p22);
                tmpy<= (p00)+((p01)<<1)+(p02)-(p20)-((p21)<<1)-(p22);
            end
            if(v) begin
                gx<=tmpx; gy<=tmpy;
                ax<=tmpx[15]?-tmpx:tmpx;
                ay<=tmpy[15]?-tmpy:tmpy;
                mag<=ax+ay;
            end
        end
    end
endmodule
