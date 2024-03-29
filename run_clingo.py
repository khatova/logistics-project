#!/usr/bin/python

import os, sys, getopt, argparse
from utils import aesthetic, visualize, run_cmd

def run(directory, output_plan,action,merger,conflicts_detector,input_parser,output_format):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
        path = os.path.join("plans/",directory)
        files = os.listdir(path)
        for f in files:
            if ('solution' in f) or ('conflicts' in f) or ('cluster' in f) or f == ".DS_Store":
                continue
            command += os.path.join(path,f) + " "
        command += input_parser + " " + merger + " " + action + " " + conflicts_detector + " " + output_format + " > " + output_plan
        print("Command: {}".format(command))
        run_cmd(command)

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')

    directory = 'original'

    input_parser = 'A_output_to_input.lp'
    action = 'B_action.lp'
    conflicts_detector = 'C_conflicts_detector.lp'
    output_format = 'D_output.lp'
    merger = ''

    help_line = 'run_clingo.py -d <directory> -m <merger> -a <action> -c <conflicts_detector> -p <input_parser> -f <output_format>'

    try:
        opts, args = getopt.getopt(argv,"hd:m:a:c:p:f:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
        elif opt == '-m':
            merger = arg    
        elif opt == '-a':
            action = arg
        elif opt == '-c':
            conflicts_detector = arg
        elif opt == '-p':
            input_parser = arg
        elif opt == '-f':
            output_format = arg

    output_plan = os.path.join("plans/", directory, directory + "_solution.lp")
    print("Directory: {}".format(directory))
    print("Output_plan: {}".format(output_plan))

    run(directory, output_plan, action, merger, conflicts_detector,input_parser,output_format)
    aesthetic(output_plan)
    visualize(output_plan)

if __name__ == "__main__":
    main(sys.argv[1:])