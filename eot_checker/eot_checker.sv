
`ifndef EOT_CHECKER
`define EOT_CHECKER
module eot_checker ();

logic eot_check_en = 1'b1; // default enable eot checker

initial begin
    // use testplusargs to control the eot checker
    if ($test$plusargs("DISABLE_EOT_CHECKER")) begin
        eot_check_en = 1'b0;
    end
end 

final begin

   if (eot_check_en) fifo_empty_checker : assert (tb_top.u_dut.u_apb_i2c_fifo.fifo_empty == 1'b0) else $error("i2c fifo should be empty in the end of test");
   if (eot_check_en) bus_idle_checker : assert (tb_top.u_dut.bus_idle == 1'b1) else $error("bus idle should be high active in the end of test");
   if (eot_check_en) bus1_idle_checker : assert (tb_top.u_dut.bus_idle == 1'b1) else $error("EOT_CHECKER FAILED: bus1_idle_checker");

end


endmodule : eot_checker

`endif // EOT_CHECKER
