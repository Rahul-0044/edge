module line_buffer_5x5_8px #(parameter W=3124)(
    input  logic clk,
    input  pix_bus_t in_pix,
    input  logic in_valid,
    output pixel_t win[5][12],
    output logic out_valid
);

    pixel_t L0[W],L1[W],L2[W],L3[W],L4[W];
    integer col=0,row=0;

    always_ff @(posedge clk) begin
        if(in_valid) begin
            for(int i=0;i<8;i++) begin
                L4[col] <= L3[col];
                L3[col] <= L2[col];
                L2[col] <= L1[col];
                L1[col] <= L0[col];
                L0[col] <= in_pix[i];

                col++;
                if(col==W) begin col=0; row++; end
            end
        end
    end

    always_comb begin
        for(int r=0;r<5;r++)
        for(int c=0;c<12;c++) begin
            int idx = col-12+c; if(idx<0) idx+=W;
            case(r)
                0: win[r][c]=L0[idx];
                1: win[r][c]=L1[idx];
                2: win[r][c]=L2[idx];
                3: win[r][c]=L3[idx];
                4: win[r][c]=L4[idx];
            endcase
        end
    end

    assign out_valid = (row>=4 && col>12);
endmodule
module line_buffer_3x3_8px #(parameter W=3124)(
    input logic clk,
    input pix_bus_t in_pix,
    input logic in_valid,
    output pixel_t win[3][10],
    output logic out_valid
);
    pixel_t A[W],B[W],C[W];
    integer col=0,row=0;

    always_ff @(posedge clk) begin
        if(in_valid)
            for(int i=0;i<8;i++) begin
                C[col] <= B[col];
                B[col] <= A[col];
                A[col] <= in_pix[i];
                col++; if(col==W) begin col=0; row++; end
            end
    end

    always_comb begin
        for(int c=0;c<10;c++) begin
            int idx=col-10+c; if(idx<0) idx+=W;
            win[0][c]=C[idx];
            win[1][c]=B[idx];
            win[2][c]=A[idx];
        end
    end

    assign out_valid = (row>=2 && col>10);
endmodule
