import argparse
import getopt
import os
import re
import sys

from utils import read_file, empty_folder, delete_instances, aesthetic, delete_file
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
        list_files = os.listdir(out_folder)
        for lf in list_files:
            if 'plan_' in lf:
                delete_file(os.path.join(out_folder,lf))
        #empty_folder(out_folder)
        with open(instance,'r') as file:
            lines = file.readlines()
        with open(instance,'w') as file:
            for line in lines:
                if 'init' in line:
                    line = line.replace(', ',',')
                file.write(line)
        aesthetic(instance)
        common_lines = []
        lines = read_file(instance)
        instance_files = []
        horizon = 0
        count = 0
        for line in lines:
            # init(object(node, 21), value(at, (1, 3))).
            if 'init(object(nod' in line or 'init(object(produc' in line or 'init(object(order' in line:
                horizon += 1
                common_lines.append(line)
                continue
            # init(object(shelf,2), value(at,(1,2))).
            if '(object(shelf' in line or 'object(robot' in line:
                if '\n' not in line:
                    line = line.replace('.','.\n')
                robot = line.replace('(',' ').replace(',',' ').replace(')',' ').split()[3]
                filename = os.path.join(out_folder, "plan_{}.lp".format(robot))
                if not os.path.exists(filename):
                    count += 1
                    print("Triggered {} times".format(count))
                    instance_files.append(filename)
                    with open(filename, 'w') as file:
                        file.write(line)
                else:
                    with open(filename, 'a') as file:
                        file.write(line)
                continue

        for filename in instance_files:
            with open(filename, 'a') as file:
                file.writelines(common_lines)

        print("done.")


if __name__ == "__main__":
    main(sys.argv[1:])
