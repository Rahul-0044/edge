module linebuffer_3x3 #(parameter DATA_W=8,IMG_W=640)(
    input logic clk,rst_n, valid_in,
    input logic [DATA_W-1:0] pixel_in,
    output logic [DATA_W-1:0] w00,w01,w02,w10,w11,w12,w20,w21,w22,
    output logic valid_out
);
    logic [DATA_W-1:0] l0 [0:IMG_W-1];
    logic [DATA_W-1:0] l1 [0:IMG_W-1];
    integer col=0,row=0;

    logic [DATA_W-1:0] r00,r01,r02,r10,r11,r12,r20,r21,r22;

    assign {w00,w01,w02,w10,w11,w12,w20,w21,w22} =
           {r00,r01,r02,r10,r11,r12,r20,r21,r22};

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin col<=0;row<=0;valid_out<=0; end
        else if(valid_in) begin
            if(row==0)         l0[col]=pixel_in;
            else if(row==1)    l1[col]=pixel_in;
            else begin         l0[col]=l1[col]; l1[col]=pixel_in; end

            r00<=r01; r01<=r02; r02<= (row<2)?0:l0[col];
            r10<=r11; r11<=r12; r12<= (row<1)?0:l1[col];
            r20<=r21; r21<=r22; r22<= pixel_in;

            col++; if(col==IMG_W) begin col=0; row++; end
            valid_out <= (row>=2 && col>=2);
        end
    end
endmodule
