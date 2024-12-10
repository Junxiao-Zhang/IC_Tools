# IC_tools

在工作中开发的一些有用的IC小工具

1. RTL Hierarchy PATH Generator Scripts 

基于verdi文件产生设计不同层次的宏定义path，用于取代绝对层次路径，提升后续项目中的可复用性
目录结构：
- rtl_hier_gen            
  - rtl_hier_gen.py   //脚本
  - content.txt       //verdi产生的层次树文件
  - README.md         //使用说明 
  - demo.sv           //基于content.txt产生的示例输出
