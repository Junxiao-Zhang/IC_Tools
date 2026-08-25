// ======================================================================
// 自研 LPDDR5 monitor VIP 独立自测台（非 UVM）
// 激励方式：negedge 设第一半 → posedge 后 2ps 设第二半，避免与接口
// 边沿采样竞争（接口在边沿 0 delay 采样，与 golden 边沿采样对齐，校准确定）。
// 期望行为对齐 golden（Task 7 校准，见 lpddr5_mon_jedec_chip_if.svi
// 头部注释）：
//   - posedge 只更新 cmd 字符串；DESELECT posedge 清地址为 z
//   - negedge 更新地址字段（ACTIVE_1 只 bank、ACTIVE_2 只 row、
//     RD/WR/MWR 系 bank+col、PRECHARGE 只 bank、其余不更新）
//   - 首个 cs=1 命令前不报告；col = Micron_col << (8B?5:4)；
//     bg 仅 BG 模式（MR3 data[4:3]=00）报告；WR→WR_A、REF per→all 修正
// 注意：send_cmd 末尾的空闲周期（cs_p=0）在下个 posedge 被解码为
// DESELECT 并清地址为 z——因此每个 check 的"未更新"字段期望都是 z
//（与 golden 逐命令对比行为一致）。
// ======================================================================
`include "lpddr5_mon_jedec_chip_if.svi"

module lpddr5_mon_tb_top;

  // ck_c 仅由 assign 连续赋值驱动（声明处初始化会与 assign 冲突，VCS ICPSD_INIT）
  logic ck_t = 0, ck_c, cs_p = 0, reset_n = 0;
  logic [6:0] ca = 7'b0;
  int error_cnt = 0;
  int check_cnt = 0;

  lpddr5_mon_jedec_chip_if dut_if (.ck_t(ck_t), .ck_c(ck_c), .cs_p(cs_p),
                                   .ca(ca), .reset_n(reset_n));
  assign ck_c = ~ck_t;

  // 2ns 周期时钟
  initial begin
    forever begin
      #1000ps ck_t = ~ck_t;
    end
  end

  // 把 casez 模式（位序 {CS,CA0..CA6}）转为物理 ca[6:0]（{CA6..CA0}）：
  // ca = {p[0],p[1],p[2],p[3],p[4],p[5],p[6]}
  function automatic logic [6:0] enc_first(input logic [7:0] p);
    return {p[0], p[1], p[2], p[3], p[4], p[5], p[6]};
  endfunction

  // 发送一个单周期命令：f=第一半 ca（物理位序），s=第二半 ca
  // 时序约定：信号在边沿后 2ps 建立（接口在边沿 0 delay 采样，与 golden
  // 边沿采样对齐，校准确定）；命令末尾
  // 拉低 cs_p 插入空闲周期。check_cmd 在返回后立即执行，读到刚解码的值。
  task send_cmd(input logic [6:0] f, input logic [6:0] s);
    @(negedge ck_t); #2ps; cs_p = 1'b1; ca = f;    // 第一半
    @(posedge ck_t); #2ps; ca = s;                 // 第二半
    @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0; // 空闲（cs 拉低）
  endtask

  // 发送 MRW-1/MRW-2 相邻对（真实场景 MRW 两段命令之间无空闲）
  task send_mrw(input logic [6:0] mr_addr, input logic [6:0] data);
    // MRW-1（第二半 = MR 地址）
    @(negedge ck_t); #2ps; cs_p = 1'b1; ca = enc_first('b1_000_1101);
    @(posedge ck_t); #2ps; ca = mr_addr;
    // MRW-2（第二半 = data；cs 保持 1，两段命令相邻）
    @(negedge ck_t); #2ps; ca = enc_first('b1_000_1000);
    @(posedge ck_t); #2ps; ca = data;
    @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0;
  endtask

  // 检查：命令字符串 + 地址字段 + bank/bg（=== 比较，z 视为确定值）
  task check_cmd(input string exp_cmd,
                 input logic [31:0] exp_row, exp_col,
                 input logic [3:0] exp_ba, input logic [1:0] exp_bg);
    #1ps;
    check_cnt++;
    if (dut_if.cmd_string() != exp_cmd) begin
      $display("[FAIL] %0t: 命令期望 %s 实际 %s", $time, exp_cmd, dut_if.cmd_string());
      error_cnt++;
    end
    if (dut_if.row_addr !== exp_row) begin
      $display("[FAIL] %0t: row 期望 0x%0h 实际 0x%0h", $time, exp_row, dut_if.row_addr);
      error_cnt++;
    end
    if (dut_if.col_addr !== exp_col) begin
      $display("[FAIL] %0t: col 期望 0x%0h 实际 0x%0h", $time, exp_col, dut_if.col_addr);
      error_cnt++;
    end
    if (dut_if.bank_addr !== exp_ba) begin
      $display("[FAIL] %0t: bank 期望 0x%0h 实际 0x%0h", $time, exp_ba, dut_if.bank_addr);
      error_cnt++;
    end
    if (dut_if.bank_group_id !== exp_bg) begin
      $display("[FAIL] %0t: bg 期望 0x%0h 实际 0x%0h", $time, exp_bg, dut_if.bank_group_id);
      error_cnt++;
    end
  endtask

  // 检查当前 cmd_string 为空串（首个 cs=1 命令前不报告）
  task check_not_reported();
    #1ps;
    check_cnt++;
    if (dut_if.cmd_string() != "") begin
      $display("[FAIL] %0t: 首命令前不应报告，实际 cmd_string=%s", $time, dut_if.cmd_string());
      error_cnt++;
    end
  endtask

  // 发送 PDE/PDX（Task 8 实测：均由第一半判定，见接口注释）
  // PDE：第一半 {1, 1000000} → posedge 报 POWER_DOWN_ENTRY 并进入 power-down；
  // PDX：第一半 {1, 0000000}（与 NOP 同编码）在 power-down 状态中报
  //      POWER_DOWN_EXIT——用例先发一次 PDE 置状态，再发 PDX 第一半。
  // 返回时 cs 已拉低，之后的下一个 posedge 被解码为 DESELECT。
  task send_pde_pdx(input bit is_pdx);
    if (!is_pdx) begin
      @(negedge ck_t); #2ps; cs_p = 1'b1; ca = 7'b1000000;  // PDE 第一半
      @(posedge ck_t); #2ps;                                // posedge 报 POWER_DOWN_ENTRY
      @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0;        // 第二半拉低空闲
    end else begin
      @(negedge ck_t); #2ps; cs_p = 1'b1; ca = 7'b1000000;  // PDE 第一半（进入 power-down）
      @(posedge ck_t); #2ps; ca = 7'b0000000;
      @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0;        // 第二半拉低
      @(posedge ck_t); #2ps;                                // DESELECT（cs=0，保持 in_pd）
      @(negedge ck_t); #2ps; cs_p = 1'b1; ca = 7'b0000000;  // PDX 第一半 {1, 0000000}
      @(posedge ck_t); #2ps;                                // posedge 报 POWER_DOWN_EXIT
      @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0;        // 拉低空闲
    end
  endtask

  initial begin
    // ---- 复位与初始化 ----
    reset_n = 1'b0;
    #3ns;
    // 地址已在首个 posedge（复位期间）被 initial 块写 z；cmd 仍为 x
    #1ps;
    check_cnt++;
    if (dut_if.row_addr !== 'z) begin
      $display("[FAIL] %0t: 初始化后 row 应为 z 实际 0x%0h", $time, dut_if.row_addr);
      error_cnt++;
    end
    if (dut_if.bank_addr !== 'z || dut_if.col_addr !== 'z ||
        dut_if.bank_group_id !== 'z) begin
      $display("[FAIL] %0t: 初始化后 bank/bg/col 应为 z", $time);
      error_cnt++;
    end
    if (dut_if.cmd !== 256'hx) begin
      $display("[FAIL] %0t: 首个命令前 cmd 应保持 x", $time);
      error_cnt++;
    end
    reset_n = 1'b1;
    #2ns;

    // ---- 首命令前 DESELECT 不报告（seen_cs1 语义）----
    @(negedge ck_t); #2ps;
    check_not_reported();
    @(negedge ck_t); #2ps;
    check_not_reported();

    // ---- NOP（首个 cs=1 命令）----
    send_cmd(7'b0000000, 7'b0000000);   // 1_000_0000 → NOP
    check_cmd("NOP", 'z, 'z, 'z, 'z);    // NOP 不更新地址（仍 z）

    // ---- DESELECT（cs=0 完整周期）：cmd 更新 + 地址清 z ----
    @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0101010;
    @(posedge ck_t); #2ps; ca = 7'b1010101;
    @(negedge ck_t); #2ps;
    check_cmd("DESELECT", 'z, 'z, 'z, 'z);

    // ---- ACTIVE_1：只更新 bank（8B 模式 bg 不报告）----
    // 模式 1_111_0000 → ca=0000111；s=1011100：row_high={f[6:3],s[6:4]}={0000,101}=5，
    // bank=s[3:0]=1100=0xC
    send_cmd(enc_first('b1_111_0000), 7'b1011100);
    check_cmd("ACTIVE_1", 'z, 'z, 4'hC, 2'bz);

    // ---- ACTIVE_2：只更新 row（bank 保持 z，8B）----
    // 模式 1_110_0010 → ca=0100011；s=0001011：row={5,{0100,0001011}}=0x2A0B
    send_cmd(enc_first('b1_110_0010), 7'b0001011);
    check_cmd("ACTIVE_2", 32'h2A0B, 'z, 'z, 2'bz);

    // ---- MRW 序列（MR3 = 8B，data=0x2E → data[4:3]=01）：地址不更新 ----
    send_mrw(7'b0000011, 7'b0101110);
    check_cmd("MRW_2", 'z, 'z, 'z, 2'bz);
    // MRW-1 → MRW-2（地址非 MR3，不切换 bk_org）
    send_mrw(7'b0001010, 7'b1010101);
    check_cmd("MRW_2", 'z, 'z, 'z, 2'bz);

    // ---- WR（8B）：bank+col，col=Micron_col<<5=0x17<<5=0x2E0 ----
    // 模式 1_011_1010 → ca=0101110；s=0110110：Micron_col={010,11,1}=0x17；bank=0110=6
    send_cmd(enc_first('b1_011_1010), 7'b0110110);
    check_cmd("WR", 'z, 32'h2E0, 4'h6, 2'bz);
    // WR_A：s[6]=1 → negedge 修正为 WR_A（地址同 WR）
    send_cmd(enc_first('b1_011_1010), 7'b1110110);
    check_cmd("WR_A", 'z, 32'h2E0, 4'h6, 2'bz);

    // ---- MASKED_WRITING / _A（8B）----
    // 模式 1_010_1010 → ca=0101110；Micron_col=0x17 → 0x2E0
    send_cmd(enc_first('b1_010_1010), 7'b0110110);
    check_cmd("MASKED_WRITING", 'z, 32'h2E0, 4'h6, 2'bz);
    send_cmd(enc_first('b1_010_1010), 7'b1110110);
    check_cmd("MASKED_WRITING_A", 'z, 32'h2E0, 4'h6, 2'bz);

    // ---- WR32 / WR32_A（8B；Micron_col={f[6:4],s[5:4],1'b0}）----
    // 模式 1_001_0110 → ca=0110100；s=0101001：Micron_col={011,10,0}=0x1C
    // → 8B：0x1C<<5=0x380；bank=s[3:0]=1001=9
    send_cmd(enc_first('b1_001_0110), 7'b0101001);
    check_cmd("WR32", 'z, 32'h380, 4'h9, 2'bz);
    send_cmd(enc_first('b1_001_0110), 7'b1101001);
    check_cmd("WR32_A", 'z, 32'h380, 4'h9, 2'bz);

    // ---- RD（8B）：Micron_col={101,01,1}=0x2B → 0x2B<<5=0x560 ----
    // 模式 1_100_1101 → ca=1011001；s=0011010；s[3]=1（s[3:0]=1010）。
    // 修复轮 1（2ch diff_bl 校准）：8B 模式 READ 的 s[3] 是 B4（burst 位）
    // 非 bank 位，bank={1'b0, s[2:0]}={1'b0,010}=2（修复前误报 0xA；
    // Micron 模型 BGBK_8 时 burst_start[4]=s[3]）
    send_cmd(enc_first('b1_100_1101), 7'b0011010);
    check_cmd("RD", 'z, 32'h560, 4'h2, 2'bz);
    // RD（8B）s[3]=0：s=0000010；Micron_col={101,00,1}=0x29 → 0x29<<5=0x520；
    // bank={1'b0,010}=2（s[3]=0 时两语义一致，覆盖 s[3]=0 路径）
    send_cmd(enc_first('b1_100_1101), 7'b0000010);
    check_cmd("RD", 'z, 32'h520, 4'h2, 2'bz);

    // ---- CAS 变体：不更新地址（2ch 实测 golden 行为）----
    // CAS_WS: 模式 1_001_1101 → ca=1011100；s=0000010
    send_cmd(enc_first('b1_001_1101), 7'b0000010);
    check_cmd("CAS_WS", 'z, 'z, 'z, 2'bz);
    // CAS_WR: 1_001_1100 → ca=0011100（2ch 实测：CAS 后跟 WR）
    send_cmd(enc_first('b1_001_1100), 7'b0000000);
    check_cmd("CAS_WR", 'z, 'z, 'z, 2'bz);
    // CAS_RD: 1_001_1010 → ca=0101100（2ch 实测：CAS 后跟 RD）
    send_cmd(enc_first('b1_001_1010), 7'b0000000);
    check_cmd("CAS_RD", 'z, 'z, 'z, 2'bz);
    // CAS_FS: 1_001_1001 → ca=1001100
    send_cmd(enc_first('b1_001_1001), 7'b0000000);
    check_cmd("CAS_FS", 'z, 'z, 'z, 2'bz);

    // ---- PRECHARGE：只更新 bank（col 不更新）----
    // 模式 1_000_1111 → ca=1111000；s=0000111：bank=0111=7
    send_cmd(enc_first('b1_000_1111), 7'b0000111);
    check_cmd("PRECHARGE", 'z, 'z, 4'h7, 2'bz);
    // PRECHARGE_ALL：s[6]=1（AP 位）→ negedge 修正为 PRECHARGE_ALL；
    // （2ch 实测 golden 对 PRECHARGE_ALL 不更新 bank，保持 z）
    send_cmd(enc_first('b1_000_1111), 7'b1000111);
    check_cmd("PRECHARGE_ALL", 'z, 'z, 'z, 2'bz);

    // ---- REF：posedge "REFRESH_PER_BANK"，s[6]=1 → negedge 修正
    //      "REFRESH_ALL_BANK"；ALL 不更新地址，PER_BANK 更新 bank ----
    // 模式 1_000_1110 → ca=0111000；s=1000101（s[6]=1 → REFab）
    send_cmd(enc_first('b1_000_1110), 7'b1000101);
    check_cmd("REFRESH_ALL_BANK", 'z, 'z, 'z, 2'bz);
    // s[6]=0 → 保持 REFRESH_PER_BANK；bank=s[3:0]=0101=5（2ch 实测）
    send_cmd(enc_first('b1_000_1110), 7'b0000101);
    check_cmd("REFRESH_PER_BANK", 'z, 'z, 4'h5, 2'bz);

    // ---- MR3 = BG（data=0x26 → data[4:3]=00）：bg 报告 + col<<4 + 命令名 WR16 ----
    send_mrw(7'b0000011, 7'b0100110);
    check_cmd("MRW_2", 'z, 'z, 'z, 2'bz);
    // WR（BG 模式 → 命令名 WR16，col=0x17<<4=0x170，bg=s[3:2]=01）
    send_cmd(enc_first('b1_011_1010), 7'b0110110);
    check_cmd("WR16", 'z, 32'h170, 4'h6, 2'b01);
    // WR_A（BG 模式 → WR16_A）
    send_cmd(enc_first('b1_011_1010), 7'b1110110);
    check_cmd("WR16_A", 'z, 32'h170, 4'h6, 2'b01);
    // ACTIVE_1（BG 模式 → bg 报告 s[3:2]=11；bank=s[3:0]=0xC）
    send_cmd(enc_first('b1_111_0000), 7'b1011100);
    check_cmd("ACTIVE_1", 'z, 'z, 4'hC, 2'b11);

    // ---- MR3 = 16B（data=0x36 → data[4:3]=10）：col<<4、bg 不报告、命令名 WR16 ----
    send_mrw(7'b0000011, 7'b0110110);
    check_cmd("MRW_2", 'z, 'z, 'z, 2'bz);
    send_cmd(enc_first('b1_011_1010), 7'b0110110);
    check_cmd("WR16", 'z, 32'h170, 4'h6, 2'bz);
    // RD16（16B）：col=0x2B<<4=0x2B0
    send_cmd(enc_first('b1_100_1101), 7'b0011010);
    check_cmd("RD16", 'z, 32'h2B0, 4'hA, 2'bz);
    // RD32：模式无关命名；col=0x2B<<4=0x2B0
    send_cmd(enc_first('b1_101_1101), 7'b0011010);
    check_cmd("RD32", 'z, 32'h2B0, 4'hA, 2'bz);

    // ---- 回到 8B：ACT-1/ACT-2 完整 row ----
    send_mrw(7'b0000011, 7'b0101110);   // MR3=8B
    check_cmd("MRW_2", 'z, 'z, 'z, 2'bz);
    send_cmd(enc_first('b1_111_0000), 7'b1011100);   // ACTIVE_1：row_high=5
    check_cmd("ACTIVE_1", 'z, 'z, 4'hC, 2'bz);
    send_cmd(enc_first('b1_110_0010), 7'b0001011);   // ACTIVE_2：row={5,0x20B}=0x2A0B
    check_cmd("ACTIVE_2", 32'h2A0B, 'z, 'z, 2'bz);

    // ---- WRITE_FIFO / READ_FIFO：不更新地址 ----
    // WFF: 模式 1_000_0011 → ca=1100000；s 全 0
    send_cmd(enc_first('b1_000_0011), 7'b0000000);
    check_cmd("WRITE_FIFO", 'z, 'z, 'z, 2'bz);
    // RFF: 模式 1_000_0010 → ca=0100000；s 全 0
    send_cmd(enc_first('b1_000_0010), 7'b0000000);
    check_cmd("READ_FIFO", 'z, 'z, 'z, 2'bz);
    // RDC 第二半非 0 → 非法编码（Micron valid_cmd=0）：
    // posedge 已报 "RDC"，negedge 校验失败 → cmd 恢复报告前值
    // （报告前值是末尾空闲周期的 DESELECT，与下方"非法编码"用例的
    // 保持语义一致），字段保持 z
    send_cmd(enc_first('b1_000_0101), 7'b0000001);
    check_cmd("DESELECT", 'z, 'z, 'z, 2'bz);

    // ---- MRR（推测字符串，不更新地址）----
    // 模式 1_000_1100 → ca=0011000；s=0000111
    send_cmd(enc_first('b1_000_1100), 7'b0000111);
    check_cmd("MRR", 'z, 'z, 'z, 2'bz);

    // ---- MPC：posedge 报 MPC_TRAINING，negedge 按 opcode 报变体名（2ch 实测）----
    // 模式 1_000_0111 → ca=1110000；opcode s=0000001 → START_WCK2DQI_INT_OSC
    send_cmd(enc_first('b1_000_0111), 7'b0000001);
    check_cmd("MPC_START_WCK2DQI_INT_OSC", 'z, 'z, 'z, 2'bz);
    // opcode s=0000010 → STOP_WCK2DQI_INT_OSC
    send_cmd(enc_first('b1_000_0111), 7'b0000010);
    check_cmd("MPC_STOP_WCK2DQI_INT_OSC", 'z, 'z, 'z, 2'bz);

    // ---- PDE/PDX（2ch 实测：POWER_DOWN_ENTRY/EXIT，第一半判定）----
    send_pde_pdx(1'b0);
    check_cmd("POWER_DOWN_ENTRY", 'z, 'z, 'z, 2'bz);
    send_pde_pdx(1'b1);
    check_cmd("POWER_DOWN_EXIT", 'z, 'z, 'z, 2'bz);

    // ---- 非法编码 / x 输入：不更新（cmd 保持上一命令）----
    // 非法编码 模式 1_000_0100 → ca=0010000（UNKNOWN，不写 cmd_str；
    // 当前 cmd_str 为 PDX 之后空闲周期的 DESELECT）
    send_cmd(enc_first('b1_000_0100), 7'b0010110);
    check_cmd("DESELECT", 'z, 'z, 'z, 2'bz);
    // x 输入：ca 为 x 时不解码，保持
    @(negedge ck_t); #2ps; cs_p = 1'b1; ca = 7'bxxxxxxx;
    @(posedge ck_t); #2ps; ca = 7'b0000000;
    @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0;
    check_cmd("DESELECT", 'z, 'z, 'z, 2'bz);

    $display("==== 自测结束：%0d 项检查，%0d 项失败 ====", check_cnt, error_cnt);
    if (error_cnt == 0) $display("PASS");
    else                $display("FAIL");
    $finish;
  end

  // FSDB 波形转储（run 脚本编译时 +define+WAVES_FSDB 并链接 Verdi PLI 时启用）
  `ifdef WAVES_FSDB
  initial begin
    $fsdbDumpfile("lpddr5_mon_tb_top.fsdb");
    $fsdbDumpvars(0, lpddr5_mon_tb_top);
  end
  `endif

endmodule
