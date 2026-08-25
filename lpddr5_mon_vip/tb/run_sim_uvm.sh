#!/bin/bash
# UVM 冒烟自测：编译（UVM-1.2）+ 运行（-kdb，FSDB 波形转储）
set -e
cd "$(dirname "$0")"

# Verdi FSDB 波形转储（需 VERDI_HOME，环境已配置）
VERDI_HOME="${VERDI_HOME:-/opt/Synopsys/verdi/V-2023.12-SP2}"
FSDB_PLI="-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a"

vcs -full64 -sverilog -timescale=1ps/1fs -ntb_opts uvm-1.2 -debug_access+all -R -kdb \
  ${FSDB_PLI} +define+WAVES_FSDB \
  +incdir+../if +incdir+../agent +incdir+. \
  -l vcs_uvm.log \
  lpddr5_mon_uvm_tb_top.sv
