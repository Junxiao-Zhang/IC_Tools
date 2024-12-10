    `ifdef I2C_TB_PATH
    `undef I2C_TB_PATH
    `define I2C_TB_PATH i2c_tb
    `endif 

    `ifdef DUT_PATH
    `undef DUT_PATH
    `define DUT_PATH i2c_tb.dut
    `endif 

    `ifdef U_APB_I2C_BIU_PATH
    `undef U_APB_I2C_BIU_PATH
    `define U_APB_I2C_BIU_PATH i2c_tb.dut.U_apb_i2c_biu
    `endif 

    `ifdef IPWDATA_PROC_PATH
    `undef IPWDATA_PROC_PATH
    `define IPWDATA_PROC_PATH i2c_tb.dut.U_apb_i2c_biu.IPWDATA_PROC
    `endif 

    `ifdef PRDATA_PROC_PATH
    `undef PRDATA_PROC_PATH
    `define PRDATA_PROC_PATH i2c_tb.dut.U_apb_i2c_biu.PRDATA_PROC
    `endif 

    `ifdef U_APB_I2C_CLK_GEN_PATH
    `undef U_APB_I2C_CLK_GEN_PATH
    `define U_APB_I2C_CLK_GEN_PATH i2c_tb.dut.U_apb_i2c_clk_gen
    `endif 

    `ifdef BUS_IDLE_CNTR_PROC_PATH
    `undef BUS_IDLE_CNTR_PROC_PATH
    `define BUS_IDLE_CNTR_PROC_PATH i2c_tb.dut.U_apb_i2c_clk_gen.BUS_IDLE_CNTR_PROC
    `endif 

    `ifdef BUS_IDLE_PROC_PATH
    `undef BUS_IDLE_PROC_PATH
    `define BUS_IDLE_PROC_PATH i2c_tb.dut.U_apb_i2c_clk_gen.BUS_IDLE_PROC
    `endif 

    `ifdef U_APB_I2C_FIFO_PATH
    `undef U_APB_I2C_FIFO_PATH
    `define U_APB_I2C_FIFO_PATH i2c_tb.dut.U_apb_i2c_fifo
    `endif 

    `ifdef U_APB_I2C_BCM21_IC2PL_RX_PUSH_FLG_PSYZR_PATH
    `undef U_APB_I2C_BCM21_IC2PL_RX_PUSH_FLG_PSYZR_PATH
    `define U_APB_I2C_BCM21_IC2PL_RX_PUSH_FLG_PSYZR_PATH i2c_tb.dut.U_apb_i2c_fifo.U_apb_i2c_bcm21_ic2pl_rx_push_flg_psyzr
    `endif 

    `ifdef GEN_FST2_PATH
    `undef GEN_FST2_PATH
    `define GEN_FST2_PATH i2c_tb.dut.U_apb_i2c_fifo.U_apb_i2c_bcm21_ic2pl_rx_push_flg_psyzr.GEN_FST2
    `endif 

    `ifdef POSEDGE_REGISTERS_PROC_PATH
    `undef POSEDGE_REGISTERS_PROC_PATH
    `define POSEDGE_REGISTERS_PROC_PATH i2c_tb.dut.U_apb_i2c_fifo.U_apb_i2c_bcm21_ic2pl_rx_push_flg_psyzr.GEN_FST2.posedge_registers_PROC
    `endif 

    `ifdef U_APB_I2C_BCM21_IC2PL_TX_POP_FLG_PSYZR_PATH
    `undef U_APB_I2C_BCM21_IC2PL_TX_POP_FLG_PSYZR_PATH
    `define U_APB_I2C_BCM21_IC2PL_TX_POP_FLG_PSYZR_PATH i2c_tb.dut.U_apb_i2c_fifo.U_apb_i2c_bcm21_ic2pl_tx_pop_flg_psyzr
    `endif 

    `ifdef GEN_FST2_0_PATH
    `undef GEN_FST2_0_PATH
    `define GEN_FST2_0_PATH i2c_tb.dut.U_apb_i2c_fifo.U_apb_i2c_bcm21_ic2pl_tx_pop_flg_psyzr.GEN_FST2
    `endif 

    `ifdef POSEDGE_REGISTERS_PROC_0_PATH
    `undef POSEDGE_REGISTERS_PROC_0_PATH
    `define POSEDGE_REGISTERS_PROC_0_PATH i2c_tb.dut.U_apb_i2c_fifo.U_apb_i2c_bcm21_ic2pl_tx_pop_flg_psyzr.GEN_FST2.posedge_registers_PROC
    `endif 

    `ifdef U_RX_FIFO_PATH
    `undef U_RX_FIFO_PATH
    `define U_RX_FIFO_PATH i2c_tb.dut.U_apb_i2c_fifo.U_rx_fifo
    `endif 

    `ifdef GEN_EM_EQ2_PATH
    `undef GEN_EM_EQ2_PATH
    `define GEN_EM_EQ2_PATH i2c_tb.dut.U_apb_i2c_fifo.U_rx_fifo.GEN_EM_EQ2
    `endif 

    `ifdef GEN_PWR2_PATH
    `undef GEN_PWR2_PATH
    `define GEN_PWR2_PATH i2c_tb.dut.U_apb_i2c_fifo.U_rx_fifo.GEN_PWR2
    `endif 

    `ifdef INFER_INCDEC_PROC_PATH
    `undef INFER_INCDEC_PROC_PATH
    `define INFER_INCDEC_PROC_PATH i2c_tb.dut.U_apb_i2c_fifo.U_rx_fifo.infer_incdec_PROC
    `endif 

    `ifdef REGISTERS_PROC_PATH
    `undef REGISTERS_PROC_PATH
    `define REGISTERS_PROC_PATH i2c_tb.dut.U_apb_i2c_fifo.U_rx_fifo.registers_PROC
    `endif 

    `ifdef U_TX_FIFO_PATH
    `undef U_TX_FIFO_PATH
    `define U_TX_FIFO_PATH i2c_tb.dut.U_apb_i2c_fifo.U_tx_fifo
    `endif 

    `ifdef GEN_EM_EQ2_0_PATH
    `undef GEN_EM_EQ2_0_PATH
    `define GEN_EM_EQ2_0_PATH i2c_tb.dut.U_apb_i2c_fifo.U_tx_fifo.GEN_EM_EQ2
    `endif 

    `ifdef GEN_PWR2_0_PATH
    `undef GEN_PWR2_0_PATH
    `define GEN_PWR2_0_PATH i2c_tb.dut.U_apb_i2c_fifo.U_tx_fifo.GEN_PWR2
    `endif 

    `ifdef INFER_INCDEC_PROC_0_PATH
    `undef INFER_INCDEC_PROC_0_PATH
    `define INFER_INCDEC_PROC_0_PATH i2c_tb.dut.U_apb_i2c_fifo.U_tx_fifo.infer_incdec_PROC
    `endif 

    `ifdef REGISTERS_PROC_0_PATH
    `undef REGISTERS_PROC_0_PATH
    `define REGISTERS_PROC_0_PATH i2c_tb.dut.U_apb_i2c_fifo.U_tx_fifo.registers_PROC
    `endif 