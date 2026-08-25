// ======================================================================
// agent：被动 agent，仅例化 monitor（is_active = UVM_PASSIVE）
// ======================================================================
class lpddr5_mon_agent extends uvm_agent;

  `uvm_component_utils(lpddr5_mon_agent)

  lpddr5_mon_monitor monitor;
  lpddr5_mon_config  cfg;

  function new(string name = "lpddr5_mon_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    is_active = UVM_PASSIVE;
    cfg = lpddr5_mon_config::get_config(this);
    if (uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::get(this, "", "vif", cfg.vif))
      `uvm_info(get_name(), "已从 config_db 获取 vif", UVM_MEDIUM);
    uvm_config_db#(lpddr5_mon_config)::set(this, "monitor", "cfg", cfg);
    monitor = lpddr5_mon_monitor::type_id::create("monitor", this);
  endfunction

endclass : lpddr5_mon_agent
