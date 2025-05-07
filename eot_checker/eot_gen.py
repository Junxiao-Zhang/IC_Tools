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
#   ------------------------------------------------------------------------------------
#    0.1    |  2024-12-12 |  Junxiao |  Initial version
#                                       1. use testplusargs to control the eot checker
#                                       2. use argparse to control the verosity level
#  ------------------------------------------------------------------------------------- 

import argparse
from string import Template
import re
import csv 

eot_sva_template = Template(
    "   if (eot_check_en) ${sva_name} : assert (${signal} == ${exp_value}) else ${error_msg}\n"
)

eot_module_template = Template(
"""
`ifndef EOT_CHECKER
`define EOT_CHECKER
module eot_checker ();

logic eot_check_en = 1'b1; // default enable eot checker

initial begin
    // use testplusargs to control the eot checker
    if ($$test$$plusargs("DISABLE_EOT_CHECKER")) begin
        eot_check_en = 1'b0;
    end
end 

final begin

${eot_sva_string}
end


endmodule : eot_checker

`endif // EOT_CHECKER
"""
)

def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--input_file", type=str, help="input csv file to generate eot file", default="eot_check_list.csv")
    parser.add_argument("-o", "--output_name", type=str, help="output file name", default="eot_checker")
    parser.add_argument("-v", "--verosity", type=int, help="verosity level: 0:Error, 1:Warning, 2:Info", default=0)
    args = parser.parse_args()
    return args


def gen_eot_sva(args):
    eot_sva_string = ""

    with open(args.input_file, 'r') as csvfile:
        reader = csv.reader(csvfile)
        header = next(reader)
        data = [row for row in reader]
    
    for row in data:

        sva_name = row[0]
        signal = row[1] + "." + row[2]
        excepted_value = row[3]

        if row[4] == "":
            row[4] = "EOT_CHECKER FAILED: " + sva_name

        if args.verosity == 0:
            sva_msg = f"$error(\"" + row[4] + f"\");"
        elif args.verosity == 1:
            sva_msg = f"$warning(\"" + row[4] + f"\");"
        elif args.verosity == 2:
            sva_msg = f"$info(\"" + row[4] + f"\");"
        else:
            raise ValueError("Invalid verosity level. Must be 0, 1, or 2.")
    
        eot_sva = eot_sva_template.substitute(sva_name=sva_name, signal=signal, exp_value=excepted_value, error_msg=sva_msg)
        eot_sva_string = eot_sva_string + eot_sva

    eot_module = eot_module_template.substitute(eot_sva_string=eot_sva_string)
    print(eot_module)
    
    with open(args.output_name + ".sv", 'w') as f:
        f.write(eot_module)

def main():
    args = get_parser()
    gen_eot_sva(args)

if __name__ == "__main__":
    main()