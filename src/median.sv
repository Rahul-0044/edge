module median3x3 #(
    parameter DATA_W = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic in_valid,
    input  logic [DATA_W-1:0] p00,p01,p02,
    input  logic [DATA_W-1:0] p10,p11,p12,
    input  logic [DATA_W-1:0] p20,p21,p22,

    output logic out_valid,
    output logic [DATA_W-1:0] median
);

    logic [DATA_W-1:0] pix[0:8];

    assign pix[0]=p00; assign pix[1]=p01; assign pix[2]=p02;
    assign pix[3]=p10; assign pix[4]=p11; assign pix[5]=p12;
    assign pix[6]=p20; assign pix[7]=p21; assign pix[8]=p22;

    // Sorting network (low logic depth, pipelinable)
    function automatic [DATA_W-1:0] sort3(input [DATA_W-1:0] a,b,c);
        reg [DATA_W-1:0] x,y,z;
        begin
            {x,y,z}={a,b,c};
            if(x>y) swap(x,y);
            if(y>z) swap(y,z);
            if(x>y) swap(x,y);
            return y;        // median of 3
        end
    endfunction

    logic [DATA_W-1:0] m0,m1,m2;
    always_comb begin
        m0 = sort3(pix[0],pix[1],pix[2]);
        m1 = sort3(pix[3],pix[4],pix[5]);
        m2 = sort3(pix[6],pix[7],pix[8]);
        median = sort3(m0,m1,m2);
    end

    always_ff @(posedge clk)
        out_valid <= in_valid;

endmodule
