`timescale 1ns/1ps
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

    // =========================
    // SWAP INLINE FUNCTION 🔥
    // =========================
    function automatic void swap(
        inout logic [DATA_W-1:0] a,
        inout logic [DATA_W-1:0] b
    );
        logic [DATA_W-1:0] t;
        t = a; 
        a = b;
        b = t;
    endfunction

    // =========================
    // SORT3 (median of three)
    // =========================
    function automatic [DATA_W-1:0] sort3(
        input logic [DATA_W-1:0] a,b,c
    );
        logic [DATA_W-1:0] x,y,z;
        begin
            x=a; y=b; z=c;
            if(x > y) swap(x,y);
            if(y > z) swap(y,z);
            if(x > y) swap(x,y);
            return y;      // middle value = median
        end
    endfunction

    // =========================
    // Median 3x3 using 3-3-3 reduce
    // =========================
    logic [DATA_W-1:0] m0,m1,m2;

    always_comb begin
        m0 = sort3(p00,p01,p02);
        m1 = sort3(p10,p11,p12);
        m2 = sort3(p20,p21,p22);
        median = sort3(m0,m1,m2);   // final 3-way median
    end

    // pipeline 1-cycle latency
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) out_valid <= 0;
        else       out_valid <= in_valid;
    end

endmodule
