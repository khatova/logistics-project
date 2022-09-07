#!/usr/bin/python

import os, sys, getopt, argparse
from utils import aesthetic, visualize, run_cmd

def run(instance,output_path,horizon):
    action_path = "asprilo-encodings/m/action-M-no-constraints.lp"
    goal_path = "asprilo-encodings/m/goal-M.lp"
    out_path = "asprilo-encodings/m/output-M.lp"
    # TODO: mkdir

    command = "clingo --out-atomf='%s.' -V0 -c horizon="
    command = command + str(horizon)+" "+action_path+" "+goal_path+" "+out_path +" "+instance+" > "+output_path
    #print("Command: {}".format(command))
    run_cmd(command)


def main(argv):
    parser = argparse.ArgumentParser(description='Command creates separate robot plans for a given instance.')

    help_line = "make_plans.py -i <input_instance> -o <output_folder> -n <output_name> --horizon <horizon>"

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

    output_name = instance.replace(".lp", "_solution.lp")
    #output_path = os.path.join(output_folder, output_name)
    run(instance,output_name,horizon)
    aesthetic(output_name)
    visualize(output_name)


if __name__ == "__main__":
    main(sys.argv[1:])