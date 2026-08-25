// ======================================================================
// monitor：等待接口 cmd_sampled_event，把接口已解码的 debug port 值
//          打包成事务经 analysis port 输出（纯被动观察）。
// ======================================================================
class lpddr5_mon_monitor extends uvm_monitor;

  `uvm_component_utils(lpddr5_mon_monitor)

  virtual lpddr5_mon_jedec_chip_if vif;
  uvm_analysis_port #(lpddr5_mon_transaction) ap;

  function new(string name = "lpddr5_mon_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // 局部声明须置于方法体语句之前（VCS 解析限制：语句后声明无法解析）
    lpddr5_mon_config cfg = lpddr5_mon_config::get_config(this);
    super.build_phase(phase);
    ap = new("ap", this);
    vif = cfg.vif;
    if (vif == null)
      `uvm_fatal(get_name(), "未提供 virtual interface（config_db 键 lpddr5_mon_vif_0/1）");
  endfunction

  task run_phase(uvm_phase phase);
    lpddr5_mon_transaction item;
    forever begin
      @(vif.cmd_sampled_event);
      // NOP/DESELECT 不产生事务，保持日志简洁（debug port 仍会更新）；
      // UNKNOWN（未解码/无效输入）同样过滤
      if (vif.cmd_string() == "NOP" || vif.cmd_string() == "DESELECT" ||
          vif.cmd_string() == "UNKNOWN")
        continue;
      item = lpddr5_mon_transaction::type_id::create("item");
      item.cmd         = vif.cmd_string();
      item.row         = vif.row_addr;
      item.col         = vif.col_addr;
      item.bank        = vif.bank_addr;
      item.bank_group  = vif.bank_group_id;
      item.sample_time = $time;
      ap.write(item);
      `uvm_info(get_name(),
        $psprintf("%0t: %s", $time, item.convert2string()), UVM_MEDIUM);
    end
  endtask

endclass : lpddr5_mon_monitor
