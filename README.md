# IC_tools

在工作中开发的一些有用的IC小工具

1. RTL Hierarchy PATH Generator Scripts

   基于verdi文件产生设计不同层次的宏定义path，用于取代绝对层次路径，提升后续项目中的可复用性

   目录结构：
   - rtl_hier_gen
     - rtl_hier_gen.py
     - content.txt
     - README.md
     - demo.sv

   How to use :
   
   (1) Export Hierarchy via Verdi GUI
   
   ![image-20241211005723000](C:\Users\20926\Documents\GitHub\IC_tools\.assets\Figure_001)
   
   导出后文件为：
   
   ![image-20241211010326953](C:\Users\20926\Documents\GitHub\IC_tools\.assets\Figure_002)
   
   (2) python3 rtl_hier_gen.py -f content.txt -o demo.sv

