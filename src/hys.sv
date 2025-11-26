//// ===============================================
//// Canny Double Threshold + Simple Hysteresis
//// Uses 3x3 window of NMS magnitudes:
//// - Center is c
//// - Neighbors are n00..n22 (excluding center)
//// Weak edges survive only if any neighbor is strong
//// ===============================================
//module canny_threshold_hyst #(
//    parameter int T_LOW  = 50,
//    parameter int T_HIGH = 100
//)(
//    input  logic        clk,
//    input  logic        rst_n,
//    input  logic        in_valid,

//    input  logic [15:0] c,
//    input  logic [15:0] n00, n01, n02,
//                        n10,       n12,
//                        n20, n21, n22,

//    output logic [7:0]  edge_out,
//    output logic        out_valid
//);

//    typedef enum logic [1:0] {EDGE_NONE, EDGE_WEAK, EDGE_STRONG} edge_t;

//    logic        v_d;
//    edge_t       center_class;
//    logic        nb_strong;

//    always_ff @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            v_d      <= 1'b0;
//            out_valid<= 1'b0;
//            edge_out <= 8'd0;
//        end else begin
//            v_d       <= in_valid;
//            out_valid <= v_d;

//            if (in_valid) begin
//                // classify center
//                if (c >= T_HIGH)
//                    center_class <= EDGE_STRONG;
//                else if (c >= T_LOW)
//                    center_class <= EDGE_WEAK;
//                else
//                    center_class <= EDGE_NONE;

//                // any strong neighbor?
//                nb_strong <= (n00 >= T_HIGH) || (n01 >= T_HIGH) || (n02 >= T_HIGH) ||
//                             (n10 >= T_HIGH) || (n12 >= T_HIGH) ||
//                             (n20 >= T_HIGH) || (n21 >= T_HIGH) || (n22 >= T_HIGH);
//            end

//            if (v_d) begin
//                edge_t final_class;
//                if (center_class == EDGE_STRONG)
//                    final_class = EDGE_STRONG;
//                else if (center_class == EDGE_WEAK && nb_strong)
//                    final_class = EDGE_STRONG;
//                else
//                    final_class = EDGE_NONE;

//                edge_out <= (final_class == EDGE_STRONG) ? 8'hFF : 8'h00;
//            end
//        end
//    end

//endmodule
// ============================================================
// Vivado-Compatible Canny Threshold + Hysteresis
// ============================================================

// Typedef declared BEFORE module → safest for Vivado
typedef enum logic [1:0] {
    EDGE_NONE,
    EDGE_WEAK,
    EDGE_STRONG
} edge_t;

module canny_threshold_hyst #(
    parameter T_LOW  = 50,
    parameter T_HIGH = 100
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,

    input  logic [15:0] c,
    input  logic [15:0] n00, n01, n02,
                        n10,       n12,
                        n20, n21, n22,

    output logic [7:0]  edge_out,
    output logic        out_valid
);

    // Vivado-safe declarations
    edge_t type_reg;        // Holds edge classification
    logic  v_reg;
    logic  strong_nb_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            v_reg         <= 1'b0;
            out_valid     <= 1'b0;
            type_reg      <= EDGE_NONE;
            strong_nb_reg <= 1'b0;
            edge_out      <= 8'd0;
        end
        else begin
            v_reg     <= in_valid;
            out_valid <= v_reg;

            // Evaluate thresholds only when valid input received
            if(in_valid) begin
                strong_nb_reg <= (n00>=T_HIGH)||(n01>=T_HIGH)||(n02>=T_HIGH)||
                                 (n10>=T_HIGH)||(n12>=T_HIGH)||
                                 (n20>=T_HIGH)||(n21>=T_HIGH)||(n22>=T_HIGH);

                if      (c >= T_HIGH) type_reg <= EDGE_STRONG;
                else if (c >= T_LOW ) type_reg <= EDGE_WEAK;
                else                  type_reg <= EDGE_NONE;
            end

            // Final pixel output during pipeline stage
            if(v_reg) begin
                edge_out <= (type_reg == EDGE_STRONG ||
                            (type_reg == EDGE_WEAK && strong_nb_reg))
                            ? 8'hFF : 8'h00;
            end
        end
    end

endmodule
