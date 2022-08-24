import os
from rule import Rule
import sys
import argparse, getopt
import random
from utils import empty_folder, aesthetic, visualize, delete_instances, remove_node
from merge_plans import merge_plans
from make_plans import run


def get_random_tuple(x,y,robot=False):
    if robot:
        i = random.randint(1, x)
        j = y #random.choice([1,y])
    else:
        i = random.randint(2, x - 1)
        j = random.randint(2, y - 2)
    return (i,j)

def rules_generator(x=8,y=8,id_of_agent=1,shelf_cells={}, robot_cells={}):
    rules = []
    count = 0
    for j in range(y):
        for i in range(x):
            count += 1
            rule = Rule('node',count,'at',(i+1,j+1))
            rules.append(rule.to_string())

    count = 0
    count += 1
    rule1 = Rule('robot',id_of_agent,'max_energy',0)
    rule2 = Rule('robot',id_of_agent,'energy',0)
    rule3 = Rule('product',id_of_agent,'on',(id_of_agent,1))
    shelf_tuple = get_random_tuple(x,y)
    while shelf_tuple in shelf_cells.values():
        shelf_tuple = get_random_tuple(x,y)
    shelf_cells[id_of_agent] = shelf_tuple
    rule4 = Rule('shelf',id_of_agent,'at',shelf_tuple)
    robot_tuple = get_random_tuple(x, y,robot=True)
    while robot_tuple in robot_cells.values():
        robot_tuple = get_random_tuple(x, y, robot= True)
    robot_cells[id_of_agent] = robot_tuple
    rule5 = Rule('robot', id_of_agent, 'at', robot_tuple)
    rule6 = Rule('order',count,'line',(id_of_agent,1))
    for ru in [rule1, rule2, rule3,rule4,rule5,rule6]:
        rules.append(ru.to_string())

    #rule = Rule('pickingStation',1,'at',(int((x+1)/2),1))
    #rules.append(rule.to_string())

    return rules, shelf_cells, robot_cells

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')

    directory = 'nonanonymous'
    x=5
    y=5
    n_agents=2
    vis = False
    horizon = 15
    help_line = 'generator_one_by_one.py -d <directory> -x <x> -y <y> -n <n>'

    try:
        opts, args = getopt.getopt(argv,"hd:x:y:n:v:z:")
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
            x = int(arg)
        elif opt == '-y':
            y = int(arg)
        elif opt == '-n':
            n_agents = int(arg)
        elif opt == '-v':
            vis = True
        elif opt == '-z':
            horizon = arg

    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    output = os.path.join("plans/", directory)
    print("Directory: {}".format(directory))
    print("Output: {}".format(output))

    path = os.path.join("plans/", directory)
    empty_folder(path)
    shelf_cells = {}
    robot_cells = {}
    for id in range(n_agents):
        rules, shelf_cells, robot_cells = rules_generator(x,y,id+1,shelf_cells,robot_cells)
        temp_out = os.path.join(path,'instance_nona_'+str(id+1)+'.lp')
        with open(temp_out,'w') as file:
            file.writelines(rules)
    print('shelf_cells: ', shelf_cells)
    print('robot_cells: ', robot_cells)
    deleted_nodes = []
    for id in range(n_agents):
        temp_out = os.path.join(path, 'instance_nona_' + str(id + 1) + '.lp')
        for id_sh,(i,j) in shelf_cells.items():
            if (i,j) != shelf_cells[id+1]:
                #shelf_rule = Rule('node',id_sh,'at',(i,j)).to_string()
                #print(f'Rule to delete: {shelf_rule} from instance {id+1}')
                remove_node(temp_out,(i,j))
        for id_r,(i,j) in robot_cells.items():
            if id_r != id+1:
                robot_rule = Rule('node',id_r,'at',(i,j)).to_string()
                #print(f'Rule to delete: {robot_rule} from instance {id+1}')
                removed_nodes = remove_node(temp_out,(i,j))
                for rn in removed_nodes:
                    deleted_nodes.append(rn)
        run(temp_out, path, 'plan_only_'+str(id+1), horizon)
        aesthetic(os.path.join(path,'plan_only_'+str(id+1)+'.lp'))
    nodes_to_delete = list(set(deleted_nodes))
    with open(os.path.join(path,'reserve_nodes.lp'),'w') as file:
        file.writelines(nodes_to_delete)
        aesthetic(os.path.join(path,'reserve_nodes.lp'))
    delete_instances(path=path)
    merge_plans(directory=path,output_name='merged_plans.lp')

    visualize(os.path.join(path,'merged_plans.lp'))



if __name__ == "__main__":
    main(sys.argv[1:])
