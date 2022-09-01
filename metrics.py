import argparse
import getopt
import os
import re
import sys

from utils import read_file
from hierarchical import total_number_of_moves, avg_moves_agents

help_line = "metrics.py -i <solution.lp> -o <metrics.lp>"


def get_makespan(path):
    makespan = 0
    lines = read_file(path)
    robots_dict = {}
    for line in lines:
        # occurs(object(robot,3),action(move,(0,1)),1).
        m = re.search(r'occurs\(object\(robot,.+,(\d*)\)\.', line)
        if m:
            makespan = max(makespan, int(m.group(1)))

    return makespan


def parse_args(argv):
    parser = argparse.ArgumentParser(description='Separate an instance into n files for n robots')

    solution_file = ""
    metrics_file = ""

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
            solution = arg
        elif opt == '-o':
            metrics_file = arg

    return solution, metrics_file


def main(argv):
    solution, metrics_file = parse_args(argv)
    if len(solution) == 0 or len(metrics_file) == 0:
        print(help_line)
    else:
        total_steps = total_number_of_moves(solution)
        avg_steps = avg_moves_agents(solution)
        makespan = get_makespan(solution)

        sum_of_costs_line = "Sum of costs: {}".format(total_steps)
        avg_steps_line = "Average number of steps per robot: {}".format(avg_steps)
        makespan_line = "Makespan: {}".format(makespan)

        with open(metrics_file, 'w') as file:
            file.write(sum_of_costs_line)
            file.write(avg_steps_line)
            file.write(makespan_line)

        print(sum_of_costs_line)
        print(avg_steps_line)
        print(makespan_line)

        print("done.")


if __name__ == "__main__":
    main(sys.argv[1:])

