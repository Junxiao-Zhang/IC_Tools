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
    parts = input_str.strip('()').split()
    
    if len(parts) != 3:
        return "Invalid input format"
    
    operation, variable, value = parts
    
    if operation == "Minus":
        return f"{variable}-{value}"
    elif operation == "Divide":
        return f"{variable}/{value}"
    elif operation == "Plus":
        return f"{variable}+{value}"
    else:
        return "Unsupported operation"

def main():

    optparser = OptionParser()
    optparser.add_option("-I", "--include", dest="include", action="append",
                         default=[], help="Include path")
    optparser.add_option("-D", dest="define", action="append",
                         default=[], help="Macro Definition")
    (options, args) = optparser.parse_args()

    filelist = args

    ast, directives = parse(filelist,
                            preprocess_include=options.include,
                            preprocess_define=options.define)
    
    declared_list = []
    parameter_list = []
    assign_list = []

    for c in ast.children():
        
        #c.children()[0].show()
        module_name =  c.children()[0].name


        for i in c.children()[0].paramlist.params:
            param_name = i.children()[0].name
            param_value = i.children()[0].value.var
            parameter_string = f"parameter {param_name} = {param_value}"
            parameter_list.append(parameter_string)

        for i in c.children()[0].portlist.ports:
            port_name = i.first.name
            if i.first.width is not None:
                if "Minus" in str(i.first.width.msb) or "Divide" in str(i.first.width.msb) or "Plus" in str(i.first.width.msb):
                    msb_string = generate_expression(str(i.first.width.msb))
                else:
                    msb_string = i.first.width.msb 
                lsb_string = i.first.width.lsb
                width_string = f"[{msb_string}:{lsb_string}]"
            else:
                width_string = ""

            type_string = type(i.first).__name__ 

            if type_string == "Output":
                assign_string = "assign" + " " + port_name + " = " + "0" + ";" 
                assign_list.append(assign_string)
                

            decl_string = f"{type_string.lower()} {width_string} {port_name}"
            declared_list.append(decl_string)

    print(module_name)
    print(declared_list)
    print(parameter_list)
    print(assign_list)

if __name__ == '__main__':
    main()