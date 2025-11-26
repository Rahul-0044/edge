import img_top_pkg::*;

module background_subtract(
    input  logic clk,
    input  pix_bus_t img_in,
    input  pix_bus_t bg_in,
    input  logic in_valid,
    output pix_bus_t pix_out,
    output logic out_valid
);
    always_ff @(posedge clk)
        if(in_valid) begin
            for(int i=0;i<PCLK;i++)
                pix_out[i] <= (img_in[i] > bg_in[i]) ? img_in[i]-bg_in[i] : 0;
            out_valid <= 1;
        end else begin
            out_valid <= 0;
        end
endmodule
