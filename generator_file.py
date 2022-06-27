import os
from rule import Rule
import sys
import argparse, getopt
import random

def get_random_tuple(x,y):
    i = random.randint(2, x - 2)
    j = random.randint(2, y - 2)
    return (i,j)

def rules_generator(x=5,y=5,n_agents=2):
    used_cells = []
    rules = []
    count = 0
    for j in range(y):
        for i in range(x):
            count += 1
            rule = Rule('node',count,'at',(i+1,j+1))
            rules.append(rule.to_string())

    count = 0
    for a in range(n_agents):
        count += 1
        rule1 = Rule('robot',a+1,'max_energy',0)
        rule2 = Rule('robot',a+1,'energy',0)
        rule3 = Rule('product',a+1,'on',(a+1,1))
        shelf_tuple = get_random_tuple(x,y)
        while shelf_tuple in used_cells:
            shelf_tuple = get_random_tuple(x,y)
        used_cells.append(shelf_tuple)
        rule4 = Rule('shelf',a+1,'at',shelf_tuple)
        rule5 = Rule('robot', a + 1, 'at', (a + 2, y))
        rule6 = Rule('order',count,'line',((a+1),1))
        for x in [rule1, rule2, rule3,rule4,rule5,rule6]:
            rules.append(x.to_string())

    rule = Rule('pickingStation',1,'at',(int(x/2),1))
    rules.append(rule.to_string())

    return rules

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

    directory = 'nonanonymous'
    x=5
    y=5
    n_agents=2
    vis = False
    help_line = 'run_clingo.py -d <directory> -x <x> -y <y> -n <n>'

    try:
        opts, args = getopt.getopt(argv,"hd:x:y:n:v:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
        elif opt == '-x':
            x = arg
        elif opt == '-y':
            y = arg
        elif opt == '-n':
            n_agents = arg
        elif opt == '-v':
            vis = True

    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    output = os.path.join("plans/", directory, directory + "_nonanonymous_instance.lp")
    print("Directory: {}".format(directory))
    print("Output: {}".format(output))

    rules = rules_generator(x,y,n_agents)
    with open(output,'w') as file:
        file.writelines(rules)
    if vis == True:
        visualize(output)

if __name__ == "__main__":
    main(sys.argv[1:])
