########################################################################################
#  Copyright 2024 Junxiao.Zhang(junxiaozhang95@gmail.com)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
########################################################################################
#    Rev    |  Date       |  Author  |  Change Description
#   -------------------------------------------------------------------------------------
#    0.1    |  2024-12-10 |  Junxiao |  Initial version
from __future__ import absolute_import
from __future__ import print_function
import sys
import os
from optparse import OptionParser

# the next line can be removed after installation
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import pyverilog
from pyverilog.vparser.parser import parse

def generate_expression(input_str):
    # 去掉括号并分割成单词
    parts = input_str.strip('()').split()
    
    if len(parts) != 3:
        return "Invalid input format"
    
    operation, variable, value = parts
    
    # 根据操作生成对应的表达式
    if operation == "Minus":
        return f"{variable}-{value}"
    elif operation == "Divide":
        return f"{variable}/{value}"
    elif operation == "Plus":
        return f"{variable}+{value}"
    else:
        return "Unsupported operation"

def main():
    INFO = "Verilog code parser"
    VERSION = pyverilog.__version__
    USAGE = "Usage: python example_parser.py file ..."

    #the useful info for scripts

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()

    optparser = OptionParser()
    optparser.add_option("-v", "--version", action="store_true", dest="showversion",
                         default=False, help="Show the version")
    optparser.add_option("-I", "--include", dest="include", action="append",
                         default=[], help="Include path")
    optparser.add_option("-D", dest="define", action="append",
                         default=[], help="Macro Definition")
    (options, args) = optparser.parse_args()

    filelist = args
    if options.showversion:
        showVersion()

    for f in filelist:
        if not os.path.exists(f):
            raise IOError("file not found: " + f)

    if len(filelist) == 0:
        showVersion()

    ast, directives = parse(filelist,
                            preprocess_include=options.include,
                            preprocess_define=options.define)

    #ast.show(attrnames=True)

    for c in ast.children():
        
        #c.children()[0].show()
        #print(c.children()[0].name)
        module_name =  c.children()[0].name 

        for i in c.children()[0].portlist.ports:
            print("----------------")
            #print(i.show())
            print(i.first.name)
            port_name = i.first.name
            if i.first.width is not None:
                print(i.first.width.msb)
                print(i.first.width.lsb)
                if "Minus" in str(i.first.width.msb) or "Divide" in str(i.first.width.msb) or "Plus" in str(i.first.width.msb):
                    msb_string = generate_expression(str(i.first.width.msb))
                    print(msb_string)
                else:
                    msb_string = i.first.width.msb 
                    print(msb_string)
 
            else:
                width = ""


if __name__ == '__main__':
    main()