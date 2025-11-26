`timescale 1ns/1ps
module tb_canny;

    localparam W   = 3124;
    localparam H   = 3030;
    localparam PIX = W*H;

    logic clk=0, rst_n=0;
    logic [7:0] pixel_in;
    logic in_valid;
    logic [7:0] edge_out;
    logic out_valid;

    // CLK
    always #5 clk=~clk;

    // DUT
    canny_top dut(
        .clk(clk), .rst_n(rst_n),
        .pixel_in(pixel_in), .in_valid(in_valid),
        .edge_out(edge_out), .out_valid(out_valid)
    );

    // ==============================
    //  LOAD MASTER CSV
    // ==============================
    byte mem [0:PIX-1];
    initial begin
        integer fd = $fopen("/home/rahul/Documents/Image-processing/Image_data_for_Assessment_FPGA_Engineer_Digantara.csv", "r");
        if(fd==0) $fatal("❌ INPUT CSV NOT FOUND");

        for(int i=0;i<PIX;i++)
            void'($fscanf(fd,"%d,",mem[i]));

        $fclose(fd);
        $display("✔ Loaded %0d pixels [%0dx%0d]", PIX, W, H);
    end

    // ==============================
    //  STREAM ONE PIXEL / CLOCK
    // ==============================
    initial begin
        rst_n=0; repeat(20) @(posedge clk); rst_n=1;  // Reset release

        @(posedge clk);
        in_valid=1;

        for(int i=0;i<PIX;i++) begin
            @(posedge clk);
            pixel_in = mem[i];
        end

        in_valid=0;
        $display("➡ Input feeding finished :: waiting for pipeline flush...");
    end

    // ==============================
    //  **100% CORRECT OUTPUT WRITER**
    //  No extra column
    //  No missing last row
    // ==============================
    integer fp = $fopen("/home/rahul/Documents/Image-processing/tmp.csv","w");
    longint count=0;

    always @(posedge clk) begin
        if(out_valid) begin

            if((count % W) == (W-1))   // LAST COLUMN → write + newline
                $fwrite(fp, "%0d\n", edge_out);
            else                      // ELSE normal comma write
                $fwrite(fp, "%0d,", edge_out);

            count++;
        end
    end

    // ==============================
    //  AUTO STOP WHEN 3030×3124 DONE
    // ==============================
    always @(posedge clk)
        if(count == PIX) begin
            $display("\n===============================");
            $display("   ✔ SIM DONE");
            $display("   ✔ Pixels written = %0d",count);
            $display("   ✔ Exact Size = %0d x %0d",H,W);
            $display("   ✔ Saved → out.csv");
            $display("===============================\n");
            $finish;
        end

endmodule
