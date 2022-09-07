import os
import sys
import argparse
import getopt
from utils import aesthetic, delete_file

def merge_plans(path, init_name = "merged_plans.lp", output_name='out_occurs.lp', temp_file="delete_after_evaluate.lp"):
    rules = []
    with open(os.path.join(path,init_name), 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "init" in line and line not in rules:
                rules.append(line)
    with open(os.path.join(path,output_name), 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "occurs" in line and line not in rules:
                rules.append(line)
    with open(os.path.join(path,temp_file),'w') as f:
        for r in rules:
            f.write(r)



def total_number_of_moves(path):
    steps = 0
    with open(path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if 'occurs' in line:
                steps += 1
    return steps

def avg_moves_agents(path):
    steps = 0
    with open(path, 'r') as file:
        lines = file.readlines()
        steps_dicc = {}
        saved_agents = []
        for line in lines:
            if 'occurs' in line:
                agent = line.replace('(',' ').replace(')',' ').replace(',',' ').split()[3]
                if agent not in saved_agents:
                    steps_dicc[agent] = 1
                    saved_agents.append(agent)
                else:
                    steps_dicc[agent] += 1
    for key, value in steps_dicc.items():
        steps += value
    n = len(steps_dicc)
    if n == 0:
        return 0
    else:
        return steps / n

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')
    help_line = 'merge_plans.py -d <directory>'
    input_file = 'merged_plans.lp'
    occurs_file = 'out_occurs.lp'
    evaluation_file = "evaluation_file.lp"
    directory = ''

    try:
        opts, args = getopt.getopt(argv,"hd:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
    path = os.path.join("plans/", directory)

    merge_plans(path,input_file,occurs_file,evaluation_file)
    tnom = total_number_of_moves(os.path.join(path,evaluation_file))
    ama = avg_moves_agents(os.path.join(path,evaluation_file))
    print(f'Total moves: {tnom} and Average Moves: {ama}')
    #delete_file(os.path.join(path, evaluation_file))

if __name__ == "__main__":
    main(sys.argv[1:])