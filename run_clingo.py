#!/usr/bin/python

import os, sys, getopt, argparse

def run(input_plans,merger,output_plan,action,conflicts_detector,input_parser,output_format):
    command = "".join(["clingo --out-atomf='%s.' -V0 -c horizon=15  ",input_plans," ",conflicts_detector," ",merger," ",action," ",input_parser," ",output_format," > ",output_plan])
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

    input_plans = 'plans/original/{plan_1_original.lp,plan_2_original.lp}'
    merger = "merger.lp"
    output_plan = 'plans/merged/out_plan.lp'

    action = 'action.lp'
    conflicts_detector = 'conflicts_detector.lp'
    input_parser = 'asprilo_output_to_input.lp'
    output_format = 'merger_output.lp'

    help_line = 'run_clingo.py -i <input_plans> -o <output_plans> -m <merger> -a <action> -c <conflicts_detector> -p <input_parser> -f <output_format>'

    try:
        opts, args = getopt.getopt(argv,"hi:o:m:c:p:f:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-i':
            input_plans = arg
        elif opt == "-o":
            output_plan = arg
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

    run(input_plans,merger,output_plan,action,conflicts_detector,input_parser,output_format)
    aesthetic(output_plan)
    visualize(output_plan)

if __name__ == "__main__":
    main(sys.argv[1:])

    

    