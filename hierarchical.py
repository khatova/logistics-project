#!/usr/bin/python

import os, sys, getopt, argparse
from utils import aesthetic, visualize,run_cmd, delete_file
from independence_day import pipeline

def run_independents(directory):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
        path = os.path.join("plans",directory)
        stopwords = ['solution', 'cluster', 'merger', 'merged', 'table', '.DS_Store']
        files = os.listdir(path)
        for f in files:
            if any(sw in f for sw in stopwords):
                continue
            command += os.path.join(path,f + ' ')

        new_moves_table = os.path.join(path, "new_moves_table.lp")
        command = command + " h_newmoves_out.lp > " + new_moves_table
        print("Command: {}".format(command))
        run_cmd(command)
        aesthetic(new_moves_table)

def add_new_predicates(input,output,keyword):
    temp_lines = []
    with open(input, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if keyword in line:
                if keyword == "illegal":
                    line = line.replace('new_','')
                temp_lines.append(line)
    with open(output, 'a') as file:
        for line in temp_lines:
            file.write(line)

def run_from_cluster(directory):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        stopwords = ['solution', 'cluster', 'merged', 'merger', '.DS_Store']
        path = os.path.join("plans/", directory)
        files = os.listdir(os.path.join(path,'cluster'))
        new_moves_table = os.path.join(path, "new_moves_table.lp")
        count = 0
        for f in files:
            if any(sw in f for sw in stopwords):
                continue
            temp_file = os.path.join(path,'temp_file.lp')
            count += 1
            illegal_table = os.path.join("plans", directory, "illegal_table.lp")
            agent = os.path.join(path,'cluster', f)
            command = "clingo --out-atomf='%s.' -V0 -c horizon=15 hierarchical_merger.lp "
            command += illegal_table + " " + agent + " > " + temp_file
            print("Command: {}".format(command))
            run_cmd(command)
            aesthetic(temp_file)
            add_new_predicates(temp_file,illegal_table,'illegal')
            add_new_predicates(temp_file,new_moves_table,'move')

        occurs_table = os.path.join(path, 'occurs_table.lp')
        command = "clingo --out-atomf='%s.' -V0 h_occurs_out.lp " + new_moves_table + " > " + occurs_table
        print("Command: {}".format(command))
        run_cmd(command)

def write_final_file(directory,output):
    path = os.path.join('plans/',directory)
    cluster_path = os.path.join('plans/',directory,'cluster')
    stopwords = ['solution', 'cluster', 'merger', 'merged', 'table', '.DS_Store']
    init_lines = []
    files = os.listdir(path)
    for f in files:
        if any(sw in f for sw in stopwords):
            continue
        file_path = os.path.join(path,f)
        with open(file_path,'r') as file:
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

    occurs_table = os.path.join(path,'occurs_table.lp')
    with open(occurs_table, 'r') as file:
        lines = file.readlines()
        occurs_lines = lines

    with open(output,'w') as file:
        file.writelines(init_lines)
        file.writelines(occurs_lines)

def clean(directory):
    path = os.path.join("plans",directory)
    files = os.listdir(path)
    delete_words = ['illegal','merged_plans','new_moves','occurs','temp','independencies']
    for file in files:
        if any(sw in file for sw in delete_words):
            delete_file(os.path.join(path,file))

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')

    directory = 'poland'

    help_line = 'hierarchical.py -d <directory>'

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

    temporal_plan = os.path.join("plans/", directory, 'temp_plans_solution.lp')
    output_plan = os.path.join("plans/", directory, 'merged_plans.lp')
    new_moves_table = os.path.join("plans/", directory, 'new_moves_table.lp')
    print("Directory: {}".format(directory))
    print("Output_plan: {}".format(output_plan))

    clean(directory)
    pipeline(directory)
    delete_file(temporal_plan)
    delete_file(output_plan)
    delete_file(new_moves_table)
    run_independents(directory)
    run_from_cluster(directory)
    write_final_file(directory,output_plan)
    aesthetic(output_plan)
    visualize(output_plan)

if __name__ == "__main__":
    main(sys.argv[1:])