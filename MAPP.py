import argparse
import getopt
import os
import re
import sys

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
    directory = "MAPP20x20"
    asp_file = "MAPP/mapp_merger_1s.lp"
    show_file = "MAPP/MAPP_output.lp"
    alt_file = "alt_paths.lp"
    instance_file = "instance.lp"
    asprilo_input_file = "asprilo-encodings/input.lp"
    prev_step_file = "prev_step.lp"
    step_input = "step_input.lp"
    out_file = "out_occurs.lp"
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
    instance_file = os.path.join(work_dir, instance_file)
    prev_step_file = os.path.join(work_dir, prev_step_file)
    step_input = os.path.join(work_dir, step_input)
    out_file = os.path.join(work_dir, out_file)
    #input = read_file_to_str(alt_file)

    init_dir = os.path.join(work_dir, "initial_plans/")
    init_plans = []
    for filename in os.listdir(init_dir):
        if not filename.startswith('.'):
            f = os.path.join(init_dir, filename)
            if os.path.isfile(f):
                init_plans.append(f)
                #input += read_file_to_str(f)

    instance = read_file(instance_file)
    #asp = read_file_to_str(asp_file)
    #show = read_file_to_str(show_file)
    #asprilo_input = read_file_to_str(asprilo_input_file)

    lp_files = [asprilo_input_file, asp_file, instance_file, alt_file]
    lp_files.extend(init_plans)
    return lp_files, show_file, instance, prev_step_file, init_plans, step_input, out_file


def run_step(progr_step, new_input, lp_files, prev_step_file):
    command = "clingo --out-atomf='%s.' -V0 -c horizon=15 -c progression_step="
    command = command + str(progr_step)+" "+new_input
    command = command + " A_output_to_input.lp"
    for lp_file in lp_files:
        command = command + " " + lp_file
    command = command + " > " + prev_step_file
    run_cmd(command)
    aesthetic(prev_step_file)


#def pos_to_occurs()

def main(argv):
    lp_files, show_file, instance, prev_step_file, init_plans, step_input, out_file = parse_args(argv)
    num_robots = len(init_plans)
    active_robots = []
    new_input = []
    out_occurs = []

    for line in instance:
        # init(object(robot,4),value(at,(3,5))).
        m = re.search(r'init\(object\(robot,(\d*)', line)
        if m:
            active_robots.append(m.group(1))

    for progr_step in range(num_robots):
        if len(active_robots) == 0:
            print("No active robots at progression step {ps}. Preparing output...".format(ps = progr_step))
            break

        if progr_step > 0:
            prev_step = read_file(prev_step_file)
            new_input = []
            for line in prev_step:
                if line.startswith("total_num_steps("):
                    new_input.append(line)

                # pos(5,(4,4),ps(1),ss(0)).
                m = re.search(r'pos\((.+?),\((.+?)\),ps\({ps}\),ss\(0\)'.format(ps=progr_step), line)
                if m:
                    r = m.group(1)
                    if r in active_robots:
                        new_input.append(line)
                    continue

                # initial_step(8,7,ps(1),ss(0)).
                m = re.search(r'initial_step\((.+?),(.+?),ps\({ps}\),ss\(0\)'.format(ps=progr_step), line)
                if m:
                    r = m.group(1)
                    if r in active_robots:
                        new_input.append(line)
                    continue

        with open(step_input, "w") as file:
            for line in new_input:
                file.write(line)

        run_step(progr_step, step_input, lp_files, prev_step_file)
        active_robots = []
        step_out = read_file(prev_step_file)
        for line in step_out:
            if line.startswith("occurs("):
                out_occurs.append(line)

            # active_robot(R,ps(PS))
            m = re.search(r'active_robot\((\d*),ps\({ps}\)'.format(ps = progr_step + 1), line)
            if m:
                active_robots.append(m.group(1))

    with open(out_file, "w") as file:
        for line in out_occurs:
            file.write(line)

    print('WOW IT WORKED!')


if __name__ == "__main__":
    main(sys.argv[1:])