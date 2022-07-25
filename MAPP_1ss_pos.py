import argparse
import getopt
import os
import re
import sys
import time

from utils import aesthetic, run_cmd, read_file, read_file_to_str
from clingo.control import Control
from clingo.symbol import Number

ps_solved = False
active_robots = []
prev_ps_model = []


def parse_args(argv):
    parser = argparse.ArgumentParser(description='Command runs MAPP merger using clingo')

    help_line = "MAPP.py -i <input_folder> -a <encoding.lp>"
    directory = "12x12_dense"
    asp_file = "MAPP/mapp_merger_1ss_pos.lp"
    show_file = "MAPP/MAPP_output.lp"

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

    return work_dir, asp_file, show_file


def run_command(command):
    stream = os.popen(command)
    output = stream.read()
    if output == "" or output is None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))


def save_ps(m, progr_step):
    global prev_ps_model
    for symbol in m.symbols(shown=True):
        if symbol.name in ["total_num_steps", "initial_step", "pos"]:
            prev_ps_model.append(symbol)


def main(argv):
    global active_robots
    global prev_ps_model
    work_dir, asp_file, show_file = parse_args(argv)

    start = time.time()
    alt_file = os.path.join(work_dir, "alt_paths.lp")
    prev_ss_file = os.path.join(work_dir, "prev_ss.lp")
    ps_input = os.path.join(work_dir, "step_input.lp")
    out_pos_file = os.path.join(work_dir, "out_pos.lp")
    out_occurs_file = os.path.join(work_dir, "out_occurs.lp")

    input_plans = os.path.join(work_dir, "merged_plans.lp")

    lp_files = [asp_file, alt_file, input_plans]

    active_robots = []
    inputs = read_file(input_plans)
    inputs_str = ""
    for line in inputs:
        inputs_str += line

        # init(object(robot,4),value(at,(3,5))).
        m = re.search(r'init\(object\(robot,(\d*)\),value\(at', line)
        if m:
            active_robots.append(m.group(1))
    num_robots = len(active_robots)
    inputs_str += read_file_to_str(alt_file)
    inputs_str += read_file_to_str("A_output_to_input.lp")

    # ctl.solve(on_model=on_model)

    new_ps_input = []
    out_pos = []
    for progr_step in range(num_robots):
        ctl = Control()
        ctl.load(asp_file)
        ctl.add("base", [], inputs_str)

        prev_ps_model_str = ""
        for item in prev_ps_model:
            prev_ps_model_str += str(item) + ". "

        ctl.add("base", [], prev_ps_model_str)
        parts = [("base", [])]
        ctl.ground(parts)

        if len(active_robots) == 0:
            print("No active robots at progression step {ps}. Preparing output...".format(ps=progr_step))
            break

        progression_step(progr_step, ctl, parts)

        ctl.solve(on_model=lambda model: save_ps(model, progr_step))

    with open(out_pos_file, "w") as file:
        for line in prev_ps_model:
            file.write(str(line) + ".\n")

    move_lp = "MAPP/mapp_merger_1ss_pos_move.lp"  # os.path.join(work_dir,"mapp_merger_1ss_pos_move.lp")
    command = "clingo --out-atomf='%s.' -V0 " + str(out_pos_file) + " " + str(move_lp)
    command = command + " > " + str(out_occurs_file)
    print("Command: {}".format(command))
    run_cmd(command)
    aesthetic(out_occurs_file)

    if os.path.exists(prev_ss_file):
        os.remove(prev_ss_file)
    if os.path.exists(ps_input):
        os.remove(ps_input)

    end = time.time()

    print('WOW IT WORKED!')
    print(end - start)


def on_model(m, progr_step):
    global ps_solved
    global active_robots
    active_robots = []
    for symbol in m.symbols(shown=True):
        if symbol.name == "repositioning_done":
            ps_symbol = symbol.arguments[0]
            if ps_symbol.arguments[0] == Number(progr_step):
                ps_solved = True

        if symbol.name == "active_robot":
            r_symbol = symbol.arguments[0]
            ps_symbol = symbol.arguments[1]
            if ps_symbol.arguments[0] == Number(progr_step + 1):
                active_robots.append(r_symbol.number)
    print(m)


def progression_step(progr_step, ctl, parts):
    parts.append(("pstep", [Number(progr_step)]))
    parts.append(("sstep", [Number(progr_step), Number(0)]))
    ctl.ground(parts)

    global ps_solved
    ps_solved = False
    substep = 1
    while not ps_solved:
        parts.append(("sstep", [Number(progr_step), Number(substep)]))
        ctl.ground(parts)
        #print(substep)
        ctl.solve(on_model=lambda model: on_model(model, progr_step))

        # if a.satisfiable:
        #    ps_solved = True
        #    break

        substep += 1

    return True


if __name__ == "__main__":
    main(sys.argv[1:])
