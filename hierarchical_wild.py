#!/usr/bin/python

import os, sys, re, json, getopt, argparse
from os.path import exists
from datetime import date, datetime
from utils import aesthetic, visualize, run_cmd, delete_file
from independence_day import pipeline
from rule import Rule


def run_independents(directory,horizon=15):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon={} ".format(horizon)
        path = os.path.join("plans", directory)
        stopwords = ['solution', 'cluster', 'merger', 'merged', 'table', '.DS_Store', 'bucket','.png','debug']
        files = os.listdir(path)
        for f in files:
            if any(sw in f for sw in stopwords):
                continue
            command += os.path.join(path, f + ' ')

        new_moves_table = os.path.join(path, "new_moves_table.lp")
        command = command + " h_newmoves_out.lp > " + new_moves_table
        #print("Command: {}".format(command))
        run_cmd(command)
        aesthetic(new_moves_table)


def add_new_predicates(input, output, keyword):
    temp_lines = []
    with open(input, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if keyword in line:
                if keyword == "illegal":
                    line = line.replace('new_', '')
                temp_lines.append(line)
    with open(output, 'a') as file:
        for line in temp_lines:
            line = line.replace('.','. ')
            file.write(line)

def get_last_position(path):
    result = 'arrived'
    with open(path, 'r') as tfile:
        tlines = tfile.readlines()
        for tline in tlines:
            if 'last_position' in tline:
                result = tline
                break
    return result

def prioritize(cluster_path, stopwords):
    # Order By Priority
    files = os.listdir(cluster_path)
    cluster_files = []
    priority_dicc = {}
    for f in files:
        if any(sw in f for sw in stopwords):
            continue
        cluster_files.append(f)
    costs = []
    for cf in cluster_files:
        with open(os.path.join(cluster_path, cf), 'r') as agent_file:
            lines = agent_file.readlines()
            cost = len(lines)
            costs.append(cost)
            priority_dicc[cf] = cost
    print("Priority Dicc {}".format(priority_dicc))
    costs.sort()
    sorted_files = []
    for c in costs:
        for cf in cluster_files:
            if priority_dicc[cf] == c and cf not in sorted_files:
                sorted_files.append(cf)
                break

    return sorted_files



def run_from_cluster(directory,bucket, horizon=15):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        stopwords = ['solution', 'cluster', 'merged', 'merger', '.DS_Store','bucket','.png','debug']
        path = os.path.join("plans//", directory)
        cluster_path = os.path.join(path, 'cluster')

        new_moves_table = os.path.join(path, "new_moves_table.lp")
        new_encodings = 'hierarchical_encoding.lp'
        count = 0

        sorted_files = prioritize(cluster_path, stopwords)

        for f in sorted_files:
            if any(sw in f for sw in stopwords):
                continue
            robot = re.findall(r'\d+', f)[0]
            #print("Robot : {}".format(robot))
            original_plan = os.path.join(cluster_path, f)
            temp_file = os.path.join(bucket, robot + '_temp_file.lp')
            count += 1
            illegal_table = os.path.join("plans", directory, "illegal_table.lp")
            agent = os.path.join(path, 'cluster', f)
            command = "clingo --out-atomf='%s.' -V0 -c horizon={} hierarchical_merger.lp ".format(horizon)
            command += illegal_table + " " + agent + " > " + temp_file
            #print("Command: {}".format(command))
            run_cmd(command)
            aesthetic(temp_file)

            last_position = get_last_position(temp_file)
            #print(last_position)
            init_horizon = int(int(horizon) * 0.75)
            end_horizon = int(int(horizon) * 1.5)
            #delete_file(temp_file)
            #print("TEMP {}".format(temp_file))
            if 'arrived' not in last_position:
                split_position = last_position.split(",")
                tuple_last_position = split_position[1]+","+split_position[2]
                last_time = split_position[3].replace(").\n","")
                #print(f"DEBUG. Last position: {tuple_last_position}, Last time: |{last_time}|")
                updated_instance = os.path.join(bucket, 'updated_' + f)
                update_init(path,original_plan, robot, tuple_last_position, updated_instance)
                new_plan = os.path.join(bucket, 'new_plan_' + robot + '.lp')
                #run_hierarchical_clingo(updated_instance, illegal_table, new_encodings, last_time, new_plan, horizon)
                #print("Robot: {} and new_plan {}".format(robot,new_plan))
                for i in range(init_horizon,end_horizon):
                    run_hierarchical_clingo(updated_instance, illegal_table, new_encodings, last_time, new_plan, str(i))
                    with open(new_plan,'r') as plan:
                        lines = plan.readlines()
                        if "UNSATISFIABLE" in lines[0]:
                            #print("Robot {} with horizon {} is unsatisfiable".format(robot,i))
                            continue
                        else:
                            break
                plan_to_temp(new_plan,temp_file)

            add_final_illegal(temp_file,end_horizon)
            add_new_predicates(temp_file, illegal_table, 'illegal')
            add_new_predicates(temp_file, new_moves_table, 'move')

        occurs_table = os.path.join(path, 'occurs_table.lp')
        command = "clingo --out-atomf='%s.' -V0 h_occurs_out.lp " + new_moves_table + " > " + occurs_table
        #print("Command: {}".format(command))
        run_cmd(command)
        aesthetic(occurs_table)

def add_final_illegal(temp_file,final_horizon):
    with open(temp_file, 'r') as tf:
        lines = tf.readlines()
        final_time = 0
        illegal_dicc = {}
        for line in lines:
            if "new_illegal" in line and "_from" not in line:
                split_line = line.replace("(", " ").replace(")", " ").replace(",", " ").split()
                #print("SPLIT LINE: {}".format(split_line))
                time = int(split_line[4])
                #print("Time " +str(time))
                illegal_dicc[str(time)] = line.replace("\n","")
                if time > final_time:
                    final_time = time
                    #print("Final Time " + str(final_time))
        #print("Illegal_dicc {}".format(illegal_dicc))
        #print("FINAL TIME {}".format(final_time))
        winner_line = illegal_dicc[str(final_time)]
        split_winner_line = winner_line.replace("(", " ").replace(")", " ").replace(",", " ").split()
        robot = split_winner_line[1]
        final_x = split_winner_line[2]
        final_y = split_winner_line[3]
    with open(temp_file, 'a') as ta:
        for time in range(final_time,final_horizon+1):
            new_illegal = "new_illegal({0},({1},{2}),{3}).".format(robot,final_x,final_y,str(time))
            ta.write(new_illegal+"\n")

def plan_to_temp(plan,temp):
    new_moves = []
    new_illegals = []
    with open(plan,'r') as file:
        lines = file.readlines()
        for line in lines:
            if 'occurs' in line:
                # occurs(object(robot, 4), action(move, (-1, 0)), 1). to new_move(4,(1,0),2)
                re_oc = line.replace('(',' ').replace(')',' ').replace(',',' ').replace('.',' ')
                sp_oc = re_oc.split()
                robot = sp_oc[3]
                position = "("+sp_oc[6]+","+sp_oc[7]+")"
                time = sp_oc[8]
                new_move = 'new_move({0},{1},{2}).'.format(robot,position,time)
                new_moves.append(new_move)

            elif 'position' in line:
                # and position(robot(4),(3,5),2). to new_illegal(4,(3,5),2).
                re_po = line.replace('(', ' ').replace(')', ' ').replace(',', ' ').replace('.', ' ')
                sp_po = re_po.split()
                robot = sp_po[2]
                position = "(" + sp_po[3] + "," + sp_po[4] + ")"
                time = sp_po[5]
                new_illegal = 'new_illegal({0},{1},{2}).'.format(robot,position,time)
                new_illegals.append(new_illegal)

            elif 'new_illegal_from' in line:
                # new_illegal_from(4,(4,5),(4,4),6).
                line.replace('\n','')
                if line != '':
                    new_illegals.append(line)

    with open(temp, 'a') as file:
        for nm in new_moves:
            file.write(nm+'\n')
        for ni in new_illegals:
            file.write(ni+'\n')



def run_hierarchical_clingo(up_plan, illegal, encoding, last_time, new_plan,horizon):
    command = "clingo --out-atomf='%s.' -V0 -c horizon={} -c lasttime=".format(horizon)
    command += last_time + " " + up_plan + " " + illegal + " " + encoding + " > " + new_plan
    #print("Run Hierarchical " + command)
    run_cmd(command)
    aesthetic(new_plan)

def update_init(path,original_file, robot, position, updated_instance):
    rule = Rule('robot', robot, 'at', position).to_string()
    with open(original_file, 'r') as file:
        lines = file.readlines()
        to_remove = []
        for line in lines:
            if ('robot' in line and 'at' in line) or ('occurs' in line):
                to_remove.append(line)
        for line in to_remove:
            lines.remove(line)
        lines.append(rule)
    lines = list(set(lines))
    with open(updated_instance, 'w') as file:
        file.writelines(lines)


def write_final_file(directory, output):
    path = os.path.join('plans/', directory)
    cluster_path = os.path.join('plans/', directory, 'cluster')
    stopwords = ['solution', 'cluster', 'merger', 'merged', 'table', '.DS_Store','bucket','reserve','.png','debug']
    init_lines = []
    files = os.listdir(path)
    for f in files:
        if any(sw in f for sw in stopwords):
            continue
        file_path = os.path.join(path, f)
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines:
                if "init" in line:
                    init_lines.append(line)
    files = os.listdir(cluster_path)
    for f in files:
        if any(sw in f for sw in stopwords):
            continue
        file_path = os.path.join(cluster_path, f)
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines:
                if "init" in line:
                    init_lines.append(line)

    init_lines = list(set(init_lines))

    occurs_table = os.path.join(path, 'occurs_table.lp')
    with open(occurs_table, 'r') as file:
        lines = file.readlines()
        occurs_lines = lines

    with open(output, 'w') as file:
        file.writelines(init_lines)
        file.writelines(occurs_lines)


def clean(directory):
    path = os.path.join("plans", directory)
    print(f'Path to clean: {path}')
    files = os.listdir(path)
    delete_words = ['illegal', 'merged_plans', 'new_moves', 'occurs', 'temp', 'independencies']
    for file in files:
        if any(sw in file for sw in delete_words):
            delete_file(os.path.join(path, file))

def clean_bucket(directory):
    path = os.path.join("plans", directory, "bucket")
    print(f'Path to clean: {path}')
    files = os.listdir(path)
    for file in files:
        delete_file(os.path.join(path, file))

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

    return steps/len(steps_dicc)

def to_log(directory,start_time,duration, avg_steps, total_steps, log_file = 'log_file.json', method = 'hierarchical'):
    log_dicc = {"directory": directory, "timestamp": start_time.strftime("%Y.%m.%d %H:%M:%S"), "enabled_time": duration,
                "avg_steps" : avg_steps, "total_steps": total_steps, "method":method}
    log_json = json.dumps(log_dicc)
    print("Results: {}".format(log_dicc))
    if not exists(log_file):
        with open('log_file.json', 'w') as file:
            dicc = {"records": []}
            json.dump(dicc, file)
    with open(log_file, 'r') as json_file:
        json_data = json.load(json_file)
        json_data["records"].append(log_json)
    with open(log_file, 'w') as json_file:
        json.dump(json_data, json_file, indent=4)

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')
    print("Starting the program")
    directory = 'hierarchical'
    horizon = 15

    help_line = 'hierarchical.py -d <directory>'

    try:
        opts, args = getopt.getopt(argv, "hd:c:z:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
        elif opt == '-z':
            horizon = arg

    start_time = datetime.now()
    path = os.path.join("plans/", directory)
    temporal_plan = os.path.join(path, 'temp_plans_solution.lp')
    output_plan = os.path.join(path, 'merged_plans.lp')
    new_moves_table = os.path.join(path, 'new_moves_table.lp')
    bucket = os.path.join(path, 'bucket')
    print("Directory: {}".format(directory))
    print("Output_plan: {}".format(output_plan))
    clean(directory)
    if not os.path.exists(bucket):
        os.makedirs(bucket)
    else:
        clean_bucket(directory)
    pipeline(directory)
    delete_file(temporal_plan)
    delete_file(output_plan)
    delete_file(new_moves_table)
    run_independents(directory,horizon)
    run_from_cluster(directory,bucket,horizon)
    write_final_file(directory, output_plan)
    aesthetic(output_plan)
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    total_steps = total_number_of_moves(output_plan)
    avg_steps = avg_moves_agents(output_plan)
    to_log(directory,start_time,duration, avg_steps, total_steps,log_file = 'log_file.json')
    visualize(output_plan)

if __name__ == "__main__":
    main(sys.argv[1:])
