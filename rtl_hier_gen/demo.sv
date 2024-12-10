
    `ifdef TOP_PATH
    `undef TOP_PATH
    `define TOP_PATH top
    `endif

    `ifdef U_DUT_PATH
    `undef U_DUT_PATH
    `define U_DUT_PATH top.u_dut
    `endif 

    `ifdef U_MODULE0_PATH
    `undef U_MODULE0_PATH
    `define U_MODULE0_PATH top.u_dut.u_module0
    `endif 

    `ifdef U_CLK_PATH
    `undef U_CLK_PATH
    `define U_CLK_PATH top.u_dut.u_module0.u_clk
    `endif 

    `ifdef U_MODULE1_PATH
    `undef U_MODULE1_PATH
    `define U_MODULE1_PATH top.u_dut.u_module1
    `endif 

    `ifdef U_CLK_0_PATH
    `undef U_CLK_0_PATH
    `define U_CLK_0_PATH top.u_dut.u_module1.u_clk
    `endif 
