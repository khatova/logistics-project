#!/usr/bin/python

import os, sys, getopt, argparse
from utils import aesthetic, visualize,run_cmd

def run_independents(directory, output_plan):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
        path = os.path.join("plans",directory)
        stopwords = ['cluster', 'merger', 'merged', '.DS_Store']
        files = os.listdir(path)
        for f in files:
            quit = False
            for sw in stopwords:
                if sw in f:
                    quit = True
            if quit == True:
                continue
            command += os.path.join(path,f)
        command += " merger_hierarchical.lp output_plan.lp > " + output_plan

        print("Command: {}".format(command))
        run_cmd(command)

def run_from_cluster(directory, output_plan):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        stopwords = ['solution', 'cluster', 'merged', 'merger', '.DS_Store']
        path = os.path.join("plans/", directory,'cluster')
        files = os.listdir(path)
        for f in files:
            quit = False
            for sw in stopwords:
                if sw in f:
                    quit = True
            if quit == True:
                continue
            agent = os.path.join(path, f)
            command = "clingo --out-atomf='%s.' -V0 -c horizon=15 merger_hierarchical.lp "
            command += agent + " > " + output_plan
            print("Command: {}".format(command))
            run_cmd(command)
            aesthetic(output_plan)

def run_hierarchical_output(directory, temporal_plan, output_plan):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
    command += temporal_plan + " hierarchical_output.lp > " + output_plan
    print("Command: {}".format(command))
    run_cmd(command)
    aesthetic(output_plan)

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')

    directory = 'poland'

    help_line = 'hierarchical.py -d <directory> -m <merger> -c <conflicts_detector>'

    try:
        opts, args = getopt.getopt(argv,"hd:c:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg

    temporal_plan = os.path.join("plans/", directory, 'temp_plans.lp')
    output_plan = os.path.join("plans/", directory, 'merged_plans.lp')
    print("Directory: {}".format(directory))
    print("Output_plan: {}".format(output_plan))

    run_independents(directory, temporal_plan)
    aesthetic(output_plan)
    #run_from_cluster(directory, temporal_plan)
    run_hierarchical_output(directory, temporal_plan, output_plan)
    visualize(output_plan)

if __name__ == "__main__":
    main(sys.argv[1:])