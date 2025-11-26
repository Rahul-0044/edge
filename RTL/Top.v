`timescale 1ns / 1ps

module imageProcessTop(
input   axi_clk,
input   axi_reset_n,
//slave interface
input   i_data_valid,
input [7:0] i_data,
output  o_data_ready,
//master interface
output  o_data_valid,
output [7:0] o_data,
input   i_data_ready,
//interrupt
output  o_intr

    );

wire [71:0] pixel_data;
wire pixel_data_valid;
wire axis_prog_full;
wire [7:0] convolved_data;
wire convolved_data_valid;

assign o_data_ready = !axis_prog_full;
    
imageControl IC(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(i_data),
    .i_pixel_data_valid(i_data_valid),
    .o_pixel_data(pixel_data),
    .o_pixel_data_valid(pixel_data_valid),
    .o_intr(o_intr)
  );    
  
 conv conv(
     .i_clk(axi_clk),
     .i_pixel_data(pixel_data),
     .i_pixel_data_valid(pixel_data_valid),
     .o_convolved_data(convolved_data),
     .o_convolved_data_valid(convolved_data_valid)
 ); 

    // IP INSTANTIATION
 outputBuffer OB (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_reset_n),            // input wire s_aresetn
  .s_axis_tvalid(convolved_data_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(convolved_data),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(i_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);
 
endmodule
module outputBuffer #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 1024       // change if needed
)(
    input  wire                     s_aclk,
    input  wire                     s_aresetn,

    // AXI Stream Slave (Input)
    input  wire                     s_axis_tvalid,
    output wire                     s_axis_tready,
    input  wire [DATA_WIDTH-1:0]    s_axis_tdata,

    // AXI Stream Master (Output)
    output reg                      m_axis_tvalid,
    input  wire                     m_axis_tready,
    output reg [DATA_WIDTH-1:0]     m_axis_tdata,

    // Status signals
    output wire                     wr_rst_busy,
    output wire                     rd_rst_busy,
    output wire                     axis_prog_full
);

    // -----------------------------------------
    // Internal FIFO buffer
    // -----------------------------------------
    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH):0] wr_ptr=0, rd_ptr=0, count=0;

    assign s_axis_tready = (count < FIFO_DEPTH-1);   // input backpressure enable
    assign axis_prog_full = (count >= FIFO_DEPTH-2); // FIFO almost full flag

    assign wr_rst_busy = ~s_aresetn; // simple model
    assign rd_rst_busy = ~s_aresetn;

    // -----------------------------------------
    // WRITE to FIFO
    // -----------------------------------------
    always @(posedge s_aclk) begin
        if(!s_aresetn) begin
            wr_ptr <= 0;
            count  <= 0;
        end else if(s_axis_tvalid && s_axis_tready) begin
            fifo[wr_ptr] <= s_axis_tdata;
            wr_ptr <= wr_ptr + 1;
            count <= count + 1;
        end
    end

    // -----------------------------------------
    // READ from FIFO
    // -----------------------------------------
    always @(posedge s_aclk) begin
        if(!s_aresetn) begin
            rd_ptr <= 0;
            m_axis_tvalid <= 0;
        end 
        else if(m_axis_tready && (count > 0)) begin
            m_axis_tdata  <= fifo[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            count <= count - 1;
            m_axis_tvalid <= 1;
        end 
        else if(count == 0) begin
            m_axis_tvalid <= 0;
        end
    end

endmodule
