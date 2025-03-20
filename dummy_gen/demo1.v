module example_module (
  input         clk,
  input         rst_n,
  input  [255:0]      test,
  output [WIDTH-1:0] data_out,
  output [WIDTH/2:0] data_out_1,
  output [WIDTH+2:0] data_out_2,
  output [256-1:0] data_out_3,
  inout         bi_dir
);
  
  reg [WIDTH-1:0] counter;
  
  always @(posedge clk) begin
    if (!rst_n) counter <= 0;
    else counter <= counter + 1;
  end
  
  assign data_out = counter;
  assign bi_dir = 1'bz;

  ddr_top ddr_dut(
    .clk (clk),
    .rst_n (rst_n)
  );

endmodule
