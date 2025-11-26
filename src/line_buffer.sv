// ===============================================
// Generic 3x3 linebuffer for streaming images
// One pixel per clock, row-major scan
// ===============================================
module linebuffer_3x3 #(
    parameter int DATA_W = 8,
    parameter int IMG_W  = 640
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_W-1:0]     pixel_in,
    input  logic                  valid_in,

    output logic [DATA_W-1:0]     w00, w01, w02,
    output logic [DATA_W-1:0]     w10, w11, w12,
    output logic [DATA_W-1:0]     w20, w21, w22,
    output logic                  valid_out
);

    // Two previous lines
    logic [DATA_W-1:0] line0 [0:IMG_W-1];
    logic [DATA_W-1:0] line1 [0:IMG_W-1];

    int col;
    int row;

    // Horizontal shift registers for each of the 3 rows
    logic [DATA_W-1:0] r0_0, r0_1, r0_2;
    logic [DATA_W-1:0] r1_0, r1_1, r1_2;
    logic [DATA_W-1:0] r2_0, r2_1, r2_2;

    logic valid_d;

    assign w00 = r0_0; assign w01 = r0_1; assign w02 = r0_2;
    assign w10 = r1_0; assign w11 = r1_1; assign w12 = r1_2;
    assign w20 = r2_0; assign w21 = r2_1; assign w22 = r2_2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col       <= 0;
            row       <= 0;
            valid_d   <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;
            if (valid_in) begin
                // write current pixel into line memories
                if (row == 0) begin
                    line0[col] <= pixel_in;
                end else if (row == 1) begin
                    line1[col] <= pixel_in;
                end else begin
                    // shift rows up
                    line0[col] <= line1[col];
                    line1[col] <= pixel_in;
                end

                // update horizontal shift regs
                r0_0 <= r0_1;
                r0_1 <= r0_2;
                r0_2 <= (row < 2) ? '0 : line0[col];

                r1_0 <= r1_1;
                r1_1 <= r1_2;
                r1_2 <= (row < 1) ? '0 : line1[col];

                r2_0 <= r2_1;
                r2_1 <= r2_2;
                r2_2 <= pixel_in;

                // update column / row counters
                if (col == IMG_W-1) begin
                    col <= 0;
                    row <= row + 1;
                end else begin
                    col <= col + 1;
                end

                // window valid when we have at least 2 previous rows and 2 previous cols
                if (row >= 2 && col >= 2) begin
                    valid_out <= 1'b1;
                end
            end
        end
    end

endmodule
