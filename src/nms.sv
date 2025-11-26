// // ===============================================
// // Canny NMS (Non-Maximum Suppression)
// // Uses gx, gy to quantize direction and a 3x3
// // magnitude window to keep only local maxima
// // ===============================================
// module canny_nms(
//     input  logic              clk,
//     input  logic              rst_n,
//     input  logic              in_valid,

//     input  logic signed [15:0] gx,
//     input  logic signed [15:0] gy,

//     input  logic [15:0]       m00, m01, m02,
//                               m10, m11, m12,
//                               m20, m21, m22,   // center is m11

//     output logic [15:0]       mag_nms,
//     output logic              out_valid
// );

//     logic              v_d;
//     logic [1:0]        dir;   // 0: 0°, 1:45°, 2:90°, 3:135°
//     logic [15:0]       ax, ay;
//     logic [15:0]       n1, n2;
//     logic [15:0]       center;

//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             v_d      <= 1'b0;
//             out_valid<= 1'b0;
//             mag_nms  <= '0;
//         end else begin
//             v_d       <= in_valid;
//             out_valid <= v_d;

//             if (in_valid) begin
//                 center <= m11;

//                 ax <= gx[15] ? (~gx + 1) : gx;
//                 ay <= gy[15] ? (~gy + 1) : gy;

//                 // rough quantization into 4 direction bins
//                 if (ay <= (ax >>> 1))       dir <= 2'd0; // ~0°
//                 else if (ax <= (ay >>> 1))  dir <= 2'd2; // ~90°
//                 else if ((gx ^ gy) >= 0)    dir <= 2'd1; // ~45°
//                 else                        dir <= 2'd3; // ~135°

//                 unique case (dir)
//                     2'd0: begin // left-right: (m10,m12)
//                         n1 <= m10;
//                         n2 <= m12;
//                     end
//                     2'd1: begin // 45°: (m02,m20)
//                         n1 <= m02;
//                         n2 <= m20;
//                     end
//                     2'd2: begin // up-down: (m01,m21)
//                         n1 <= m01;
//                         n2 <= m21;
//                     end
//                     default: begin // 135°: (m00,m22)
//                         n1 <= m00;
//                         n2 <= m22;
//                     end
//                 endcase
//             end

//             if (v_d) begin
//                 if (center >= n1 && center >= n2)
//                     mag_nms <= center;
//                 else
//                     mag_nms <= 16'd0;
//             end
//         end
//     end

// endmodule
module canny_nms(input logic clk,rst_n,in_valid,
    input logic signed[15:0] gx,gy,
    input logic[15:0] m00,m01,m02,m10,m11,m12,m20,m21,m22,
    output logic[15:0] mag_nms, output logic out_valid);

    logic v; logic[1:0] dir; logic[15:0] ax,ay,n1,n2;
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin out_valid<=0;v<=0; end
        else begin
            v<=in_valid; out_valid<=v;
            if(in_valid) begin
                ax<=gx[15]?-gx:gx; ay<=gy[15]?-gy:gy;
                if(ay<=(ax>>1)) dir<=0;
                else if(ax<=(ay>>1)) dir<=2;
                else if((gx^gy)>=0) dir<=1;
                else dir<=3;

                case(dir)
                    0: begin n1=m10;n2=m12; end
                    1: begin n1=m02;n2=m20; end
                    2: begin n1=m01;n2=m21; end
                    3: begin n1=m00;n2=m22; end
                endcase
            end
            if(v) mag_nms <= (m11>=n1 && m11>=n2)?m11:0;
        end
    end
endmodule
