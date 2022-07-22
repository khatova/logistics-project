import argparse
import getopt
import os
import re
import sys
import time

from utils import aesthetic, run_cmd


def read_file(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
    except Exception as err:
        print(f"Unexpected error opening {file_path} is",repr(err))
        sys.exit(1)

    return lines


def parse_args(argv):
    parser = argparse.ArgumentParser(description='Command runs MAPP merger using clingo')

    help_line = "MAPP.py -i <input_folder> -a <encoding.lp>"
    directory = "MAPP10x10"
    asp_file = "MAPP/mapp_merger_1ss.lp"
    show_file = "MAPP/MAPP_output.lp"
    asprilo_encodings_dir = "asprilo-encodings"

    try:
        opts, args = getopt.getopt(argv, "hi:a:e:")
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
        elif opt == '-e':
            asprilo_encodings_dir = arg

    work_dir = os.path.join("plans/", directory)

    return work_dir, asprilo_encodings_dir, asp_file, show_file


def run_substep(progr_step, substep, new_input, ss_input, lp_files, prev_step_file):
    command = "clingo --out-atomf='%s.' -V0 -c horizon=15 -c progression_step="
    command = command + str(progr_step)+" -c sub_step="
    command = command + str(substep)+" "+new_input
    command = command + " A_output_to_input.lp"
    for lp_file in lp_files:
        command = command + " " + lp_file
    command = command + " > " + prev_step_file
    print("Command: {}".format(command))
    run_cmd(command)
    aesthetic(prev_step_file)


#def pos_to_occurs()


def run_command(command):
    stream = os.popen(command)
    output = stream.read()
    if output == "" or output is None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))


def main(argv):
    work_dir, asprilo_encodings_dir, asp_file, show_file = parse_args(argv)

    start = time.time()
    alt_file = os.path.join(work_dir, "alt_paths.lp")
    #prev_ps_file = os.path.join(work_dir, "prev_ps.lp")
    prev_ss_file = os.path.join(work_dir, "prev_ss.lp")
    ps_input = os.path.join(work_dir, "step_input.lp")
    ss_input = os.path.join(work_dir, "substep_input.lp")
    out_file = os.path.join(work_dir, "out_occurs.lp")
    #asprilo_input_file = os.path.join(asprilo_encodings_dir, "input.lp")

    input_plans = os.path.join(work_dir, "merged_plans.lp")

    lp_files = [asp_file, alt_file, input_plans]

    active_robots = []
    inputs = read_file(input_plans)
    for line in inputs:
        # init(object(robot,4),value(at,(3,5))).
        m = re.search(r'init\(object\(robot,(\d*)\),value\(at', line)
        if m:
            active_robots.append(m.group(1))
    num_robots = len(active_robots)

    new_ps_input = []
    out_occurs = []
    for progr_step in range(num_robots):
        if len(active_robots) == 0:
            print("No active robots at progression step {ps}. Preparing output...".format(ps = progr_step))
            break

        if progr_step > 0:
            prev_progr_step = read_file(prev_ss_file)
            new_ps_input = []
            for line in prev_progr_step:
                if line.startswith("total_num_steps("):
                    new_ps_input.append(line)

                # pos(5,(4,4),ps(1),ss(0)).
                m = re.search(r'pos\((.+?),\((.+?)\),ps\({ps}\),ss\(0\)'.format(ps=progr_step), line)
                if m:
                    r = m.group(1)
                    if r in active_robots:
                        new_ps_input.append(line)
                    continue

                # initial_step(8,7,ps(1),ss(0)).
                m = re.search(r'initial_step\((.+?),(.+?),ps\({ps}\),ss\(0\)'.format(ps=progr_step), line)
                if m:
                    r = m.group(1)
                    if r in active_robots:
                        new_ps_input.append(line)
                    continue

        with open(ps_input, "w") as file:
            for line in new_ps_input:
                file.write(line)

        ps_solved = False
        substep = 0
        while(not ps_solved):
            if substep == 0:
                if os.path.exists(prev_ss_file):
                    os.remove(prev_ss_file)

            run_substep(progr_step, substep, ps_input, prev_ss_file, lp_files, prev_ss_file)
            substep += 1

            ss_out = read_file(prev_ss_file)
            for line in ss_out:
                # progr_done(ps(1),ss(7))
                if line.startswith("repositioning_done(ps({ps}".format(ps=progr_step)):
                    ps_solved = True
                    break

        active_robots = []
        # output of last substep = output of the whole progression step
        ps_out = read_file(prev_ss_file)
        for line in ps_out:
            if line.startswith("occurs("):
                out_occurs.append(line)

            # active_robot(R,ps(PS))
            m = re.search(r'active_robot\((\d*),ps\({ps}\)'.format(ps = progr_step + 1), line)
            if m:
                active_robots.append(m.group(1))

    with open(out_file, "w") as file:
        for line in out_occurs:
            file.write(line)

    if os.path.exists(prev_ss_file):
        os.remove(prev_ss_file)
    if os.path.exists(ps_input):
        os.remove(ps_input)

    end = time.time()

    print('WOW IT WORKED!')
    print(end - start)

if __name__ == "__main__":
    main(sys.argv[1:])