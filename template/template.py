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

import argparse
from string import Template
import re

def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--input_file", type=str, help="input the vcs compile log")
    parser.add_argument("-o", "--output_name", type=str, help="output file name")
    args = parser.parse_args()
    return args


def main():
    args = get_parser()

if __name__ == "__main__":
    main()


