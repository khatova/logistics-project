import argparse
import getopt
import os
import re
import sys
import time

from utils import aesthetic, run_cmd, read_file, read_file_to_str
from clingo.control import Control
from clingo.symbol import Number, Function


def parse_args(argv):
    parser = argparse.ArgumentParser(description='Alternate paths generator for MAPP merger')

    help_line = "MAPP.py -d <working_dir> -a <encoding.lp>"
    directory = "12x12_dense"#"../instances/alt_test"
    asp_file = "MAPP/alternative_paths_shelves_inc.lp"

    try:
        opts, args = getopt.getopt(argv, "hi:a:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
        elif opt == '-a':
            asp_file = arg

    work_dir = os.path.join("plans/", directory)

    return work_dir, asp_file


def getInstanceSize(merged_file):
    xmax = 1
    ymax = 1
    for line in merged_file:
        # init(object(node,16),value(at,(4,2))).
        m = re.search(r'init\(object\(node,\s*\d*\),\s*value\(at,\s*\((\d*),\s*(\d*)', line)
        if m:
            xmax = max(xmax, int(m.group(1)))
            ymax = max(ymax, int(m.group(2)))

    return xmax, ymax


def getSubProblem(merged_file, xmax, ymax, xdone, ydone):
    task = ""
    for line in merged_file:
        if line.startswith("init(object(shelf"):
            task += str(line)
        elif line.startswith("init(object(node"):
            # init(object(node,16),value(at,(4,2))).
            m = re.search(r'init\(object\(node,\s*\d*\),\s*value\(at,\s*\((\d*),\s*(\d*)\)', line)
            if m:
                x = int(m.group(1))
                y = int(m.group(2))
                if x <= xmax and y <= ymax:
                    task += str(line)
                    if (x == xmax and not xdone) or (y == ymax and not ydone):
                        task += "new(({},{})).\n".format(x,y)

    return task


def save_solution(m, solution_lines):
    lines = []
    for symbol in m.symbols(shown=True):
        lines.append(symbol)
    solution_lines[:] = lines


def main(argv):
    work_dir, asp_file = parse_args(argv)
    merged_file = read_file(os.path.join(work_dir, "empty.lp"))
    xmax, ymax = getInstanceSize(merged_file)
    x = 1
    y = 1
    solution_lines = []
    task = ""
    solution = ""
    xdone = False
    ydone = False
    while not (xdone and ydone):
        print("Searching for {}x{}".format(x,y))
        task = getSubProblem(merged_file, x, y, xdone, ydone)
        ctl = Control(arguments=["--opt-mode=opt"])
        ctl.load(asp_file)
        ctl.add("base", [], solution)
        ctl.add("base", [], task)
        parts = [("base", [])]
        ctl.ground(parts)
        #solution_lines = []

        with ctl.solve(yield_=True) as handle:
            models = list(iter(handle))
            if len(models) > 0:
                solution_lines = []
                m = models[-1] # get the optimal model
                for symbol in m.symbols(shown=True):
                    if symbol.name == "at":
                        triplet = Function("alt", arguments=symbol.arguments)
                        solution_lines.append(triplet)
                    elif symbol.name == "alt":
                        solution_lines.append(symbol)
                print(m)

        #ctl.solve(on_model=lambda model: save_solution(model, solution_lines))

        solution = ""
        for line in solution_lines:
            solution += str(line) + "."
        print(solution)
        xdone = x == xmax
        ydone = y == ymax
        if x < xmax:
            x += 1
        if y < ymax:
            y += 1

    out_file = os.path.join(work_dir, "empty_alt_paths.lp")
    with open(out_file, "w") as file:
        for line in solution_lines:
            file.write(str(line) + ".\n")


if __name__ == "__main__":
    main(sys.argv[1:])
