import argparse
import getopt
import os
import sys

from clingo.control import Control
from clingo.symbol import Number


def get(val, default):
    return val if val != None else default


def read_file_to_str(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
    except Exception as err:
        print(f"Unexpected error opening {file_path} is",repr(err))
        sys.exit(1)
    else:
        file_str = ""
        for line in lines:
            file_str += line

    return file_str


def parse_args(argv):
    parser = argparse.ArgumentParser(description='Command runs MAPP merger using clingo')

    help_line = "mapp_merger_inc.py -i <input_folder> -a <encoding.lp>"

    asp_file = "MAPP/mapp_merger_inc.lp"
    show_file = "MAPP/MAPP_output.lp"
    alt_file = "alt_paths.lp"
    try:
        opts, args = getopt.getopt(argv, "hi:a:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-i':
            directory = arg
        elif opt == '-a':
            asp_file = arg

    work_dir = os.path.join("plans/", directory)

    alt_file = os.path.join(work_dir, alt_file)
    input = read_file_to_str(alt_file)

    init_dir = os.path.join(work_dir, "initial_plans/")
    for filename in os.listdir(init_dir):
        if not filename.startswith('.'):
            f = os.path.join(init_dir, filename)
            if os.path.isfile(f):
                input += read_file_to_str(f)

    asp = read_file_to_str(asp_file)
    asp += read_file_to_str(show_file)

    return input, asp


def on_model(m):
    print(m)


def main(argv):
    input, asp = parse_args(argv)
    task = input+asp

    ctl = Control()
    ctl.add("base", [], task)

    parts = [("base", [])]
    ctl.ground(parts)
    ps = 0

    istop = get(ctl.get_const("istop"), "SAT")
    while ps < 6:
        parts.append(("progression_step", [Number(ps)]))
        ctl.ground(parts)
        ret = ctl.solve(on_model=on_model)
        if ((istop == "SAT" and not ret.satisfiable) or
                (istop == "UNSAT" and not ret.unsatisfiable) or
                (istop == "UNKNOWN" and not ret.unknown)):
            break
        ps += 1


if __name__ == "__main__":
    main(sys.argv[1:])
