#!/usr/bin/python

import os, sys, getopt, argparse

def run(directory, output_plan,action,merger,conflicts_detector, independencies_solution,input_parser,output_format):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
        path = os.path.join("plans/",directory)
        files = os.listdir(path)
        print("DEBUG: 1 {}".format(merger))
        for f in files:
            if 'merger' in f and merger == '':
                merger = os.path.join(path,f)
            if 'independencies_solution' in f and independencies_solution == '':
                independencies_solution = os.path.join(path,f)
            if ('solution' in f) or ('conflicts' in f) or f == ".DS_Store":
                continue
            if 'cluster' in f:
                cluster_path = os.path.join(path, f)
                cluster_files = os.listdir(cluster_path)
                for cf in cluster_files:
                    command += os.path.join(cluster_path,cf) + " "
        print("DEBUG: 2 {}".format(merger))
        #print("Command: {}".format(command))
        # Files: Input, independence_solution, Merger, action, output , + independencies_solution + " "
        command += input_parser + " " + merger + " " + action + " " + conflicts_detector + " " +independencies_solution +" "+ output_format + " > " + output_plan
        #command += input_parser + " " + action +" " + output_format + "" +" > " + output_plan
        print("Command: {}".format(command))

        stream = os.popen(command)
        output = stream.read()
        if output == "" or output == None:
            print("Command runned without output")
        else:
            print("Command runned with output... : {}".format(output))

def aesthetic(location):
    with open(location, 'r+') as file:
        lines = file.readlines()
        #TODO: Remove each optimization line
        if 'SATISFIABLE' in lines:
            lines.remove('SATISFIABLE')
        elif 'SATISFIABLE\n' in lines:
            lines.remove('SATISFIABLE\n')
    with open(location, "w") as file:
        for line in lines:
            rules = line.split()
            for rule in rules:
                rule = rule.replace("'","")
                file.write(rule + "\n")


def visualize(plan):
    command = "".join(["viz  -p ",plan])
    print("Command: {}".format(command))

    stream = os.popen(command)
    output = stream.read()
    if output == "" or output == None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')

    directory = 'original'

    input_parser = 'A_output_to_input.lp'
    action = 'B_action.lp'
    conflicts_detector = 'C_conflicts_detector.lp'
    independencies_solution = ''
    output_format = 'D_output.lp'
    merger = ''

    help_line = 'run_clingo.py -d <directory> -m <merger> -a <action> -c <conflicts_detector> -p <input_parser> -f <output_format>'

    try:
        opts, args = getopt.getopt(argv,"hd:m:a:c:i:p:f:")
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
        elif opt == '-c':
            independencies_solution = arg
        elif opt == '-p':
            input_parser = arg
        elif opt == '-f':
            output_format = arg

    output_plan = os.path.join("plans/", directory, directory + "_solution.lp")
    print("Directory: {}".format(directory))
    print("Output_plan: {}".format(output_plan))

    run(directory, output_plan, action, merger, conflicts_detector, independencies_solution, input_parser,output_format)
    aesthetic(output_plan)
    visualize(output_plan)

if __name__ == "__main__":
    main(sys.argv[1:])