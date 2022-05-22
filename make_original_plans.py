#!/usr/bin/python

import os, sys, getopt, argparse, re

def split(plan_all, output_folder, output_name):
    all_plans = ""
    robots = {}
    with open(plan_all, 'r+') as file:
        lines = file.readlines()
        if 'SATISFIABLE\n' in lines:
            lines.remove('SATISFIABLE\n')
        for line in lines:
            m = re.search(r'occurs\(object\(robot,(\d*)', line)
            if m:
                r = m.group(1)
                robot = robots.pop(r,"")
                robot = robot + line
                robots[r] = robot
            else:
                all_plans = all_plans + line

    for r in robots.keys():
        r_file = os.path.join(output_folder, output_name + '_' + r + '.lp')
        with open(r_file, "w") as file:
            file.write(all_plans)
            file.write(robots[r])


def run(instance,output_folder,output_name,horizon):
    asprilo_path = "asprilo-encodings/m/{action-M-no-constraints.lp,goal-M.lp,output-M.lp}"
    output_temp = os.path.join(output_folder, output_name + '_conflicts.lp')
    # TODO: mkdir

    command = "clingo --out-atomf='%s.' -V0 -c horizon="
    command = command + horizon+" "+asprilo_path+" "+instance+" > "+output_temp
    print("Command: {}".format(command))

    stream = os.popen(command)
    output = stream.read()
    if output == "" or output == None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))

    with open(output_temp, 'r+') as file:
        lines = file.readlines()
    with open(output_temp, "w") as file:
        for line in lines:
            rules = line.split()
            for rule in rules:
                rule = rule.replace("'","")
                file.write(rule + "\n")

    split(output_temp, output_folder, output_name)


def main(argv):
    parser = argparse.ArgumentParser(description='Command creates separate robot plans for a given instance.')

    help_line = "make_original_plans.py -i <input_instance> -o <output_folder> -n <output_name> --horizon <horizon>"

    instance = ""
    output_folder = ""
    output_name = ""
    horizon = 15

    try:
        opts, args = getopt.getopt(argv,"hi:o:n:",["horizon="])
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-i':
            instance = arg
        elif opt == "-o":
            output_folder = arg
        elif opt == "-n":
            output_name = arg
        elif opt == "--horizon":
            horizon = arg

    run(instance,output_folder,output_name,horizon)


if __name__ == "__main__":
    main(sys.argv[1:])