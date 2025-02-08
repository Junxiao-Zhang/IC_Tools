module example_module #(
  parameter WIDTH = 8
)(
  input         clk,
  input         rst_n,
  output [WIDTH-1:0] data_out,
  inout         bi_dir
);
  
  reg [WIDTH-1:0] counter;
  
  always @(posedge clk) begin
    if (!rst_n) counter <= 0;
    else counter <= counter + 1;
  end
  
  assign data_out = counter;
  assign bi_dir = 1'bz;

endmodule
