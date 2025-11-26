import img_top_pkg::*;

module gaussian5x5_core(
    input  logic clk,
    input  logic in_valid,
    input  pixel_t win[5][12],   // <- MUST MATCH linebuffer
    output pix_bus_t pix_out,    // 8 pixels out per clock
    output logic out_valid
);

    always_ff @(posedge clk) begin
        out_valid <= in_valid;

        if(in_valid) begin
            for(int p=0; p<8; p++) begin
                int unsigned sum =
                      win[0][p]*1  + win[0][p+1]*4  + win[0][p+2]*6  + win[0][p+3]*4  + win[0][p+4]*1  +
                      win[1][p]*4  + win[1][p+1]*16 + win[1][p+2]*24 + win[1][p+3]*16 + win[1][p+4]*4  +
                      win[2][p]*6  + win[2][p+1]*24 + win[2][p+2]*36 + win[2][p+3]*24 + win[2][p+4]*6  +
                      win[3][p]*4  + win[3][p+1]*16 + win[3][p+2]*24 + win[3][p+3]*16 + win[3][p+4]*4  +
                      win[4][p]*1  + win[4][p+1]*4  + win[4][p+2]*6  + win[4][p+3]*4  + win[4][p+4]*1;

                pix_out[p] <= sum >> 8;
            end
        end
    end
endmodule
