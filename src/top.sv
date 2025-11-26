import img_top_pkg::*;

module img_top_8(
    input  logic clk, rst_n,
    input  logic in_valid,
    input  pix_bus_t pix_in,
    output logic out_valid,
    output pix_bus_t pix_out
);

    integer x=0,y=0;
    logic valid_pix;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin x<=0; y<=0; valid_pix<=0; end
        else if(in_valid) begin
            valid_pix<=1;

            x <= x+8;
            if(x+8 >= WIDTH) begin
                x<=0; y<=y+1;
            end
        end
    end

    // STOP when complete
    wire frame_done = (y >= HEIGHT);

    // PIPELINE CONNECTION
    pix_bus_t bg = '{default:0};
    pix_bus_t sub; logic v1;
    background_subtract u1(clk,pix_in,bg,valid_pix,sub,v1);

    pixel_t W5[5][12]; logic v2;
    line_buffer_5x5_8px LB5(clk,sub,v1,W5,v2);

    pix_bus_t blur; logic v3;
    gaussian5x5_core GA(clk,v2,W5,blur,v3);

    pixel_t W3[3][10]; logic v4;
    line_buffer_3x3_8px LB3(clk,blur,v3,W3,v4);

    sobel3x3_core SOB(clk,v4,W3,pix_out,out_valid);

endmodule
