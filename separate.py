import argparse
import getopt
import os
import re
import sys

from utils import read_file, empty_folder, delete_instances, aesthetic
from make_plans import run

help_line = "separate.py -i <instance.lp> -o <out_folder>"


def parse_args(argv):
    parser = argparse.ArgumentParser(description='Separate an instance into n files for n robots')

    instance = ""
    out_folder = ""

    try:
        opts, args = getopt.getopt(argv, "hi:o:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-i':
            instance = arg
        elif opt == '-o':
            out_folder = arg

    return instance, out_folder


def main(argv):
    instance, out_folder = parse_args(argv)
    if len(instance) == 0:
        print(help_line)
    else:
        #empty_folder(out_folder)
        aesthetic(instance)
        common_lines = []
        lines = read_file(instance)
        instance_files = []
        horizon = 0
        for line in lines:
            # init(object(node, 21), value(at, (1, 3))).
            m = re.search(r'init\(object\(node', line)
            if m:
                horizon += 1
                common_lines.append(line)
            # init(object(shelf,2), value(at,(1,2))).
            elif re.search(r'init\(object\(shelf', line):
                common_lines.append(line)
            else:
                # init(object(robot,1), value(at,(5,10))).
                m = re.search(r'init\(object\(robot,(\d*)\)', line)
                if not m:
                    # occurs(object(robot,3),action(move,(0,-1)),1).
                    m = re.search(r'occurs\(object\(robot,(\d*)\)', line)
                if m:
                    filename = os.path.join(out_folder, "plan_{}.lp".format(m.group(1)))
                    if not filename in instance_files:
                        instance_files.append(filename)
                    with open(filename, 'a') as file:
                        file.write(line)

        for filename in instance_files:
            with open(filename, 'a') as file:
                file.writelines(common_lines)

        print("done.")


if __name__ == "__main__":
    main(sys.argv[1:])
