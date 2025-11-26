import img_top_pkg::*;

module sobel3x3_core(
    input  logic clk,
    input  logic in_valid,
    input  pixel_t win[3][10],   // 3×3 sliding over 8 streams = require 10 taps
    output pix_bus_t edge_out,
    output logic out_valid
);

    always_ff @(posedge clk) begin
        out_valid <= in_valid;
        if(in_valid) begin
            for(int p=0;p<8;p++) begin
                int gx = -win[0][p] +win[0][p+2] -2*win[1][p] +2*win[1][p+2] -win[2][p]+win[2][p+2];
                int gy =  win[0][p]+2*win[0][p+1]+win[0][p+2] -win[2][p]-2*win[2][p+1]-win[2][p+2];
                int mag = (gx<0?-gx:gx)+(gy<0?-gy:gy);
                edge_out[p] <= (mag>40)?8'hFF:0;
            end
        end
    end
endmodule
