#!/usr/bin/python

import os, sys, re, getopt, argparse
from utils import aesthetic, run_cmd

def run(directory, output):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
        path = os.path.join("plans/",directory)
        files = os.listdir(path)
        stopwords = ['solution', 'conflicts', 'cluster', 'merger', '.DS_Store','bucket']
        for f in files:
            if any(sw in f for sw in stopwords):
                continue
            command += os.path.join(path,f) + " "
        command += "independence_detector.lp" + " > " + output
        #print("Command: {}".format(command))
        run_cmd(command)

def cluster(path):
    cluster_path = os.path.join(path, "cluster")
    print("Cluster path {}".format(cluster_path))
    if not os.path.exists(cluster_path):
        os.mkdir(cluster_path)
    files = os.listdir(path)
    conflicted_robots = []
    for f in files:
        if "independencies_solution" in f:
            temp = os.path.join(path,f)
            with open(temp,'r',encoding='utf-8') as file:
                for line in file:
                    if "dependent" in line and "independent" not in line:
                        robot = re.findall(r'\d+', line)[0]
                        conflicted_robots.append(robot)

    print("Conflicted robots {}".format(conflicted_robots))

    stopwords = ['solution', 'cluster', 'illegal', 'reserve', 'merger', '.DS_Store','bucket']
    for f in files:
        if any(sw in f for sw in stopwords):
            continue
        agent = re.findall(r'\d+', f)[0]
        for cr in conflicted_robots:
            if cr == agent:
                temp = os.path.join(path, f)
                cmd = "move {} {}".format(temp,cluster_path)
                run_cmd(cmd)

def illegal_table(file_path, path):
    illegal_cells = []
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if "illegal" in line:
                illegal_cells.append(line)
    output_path = os.path.join(path,'illegal_table.lp')
    with open(output_path, 'w') as file:
        file.writelines(illegal_cells)

def empty_cluster(path):
    cluster_path = os.path.join(path, "cluster")
    files = os.listdir(cluster_path)
    for f in files:
        temp = os.path.join(cluster_path, f)
        cmd = "move {} {}".format(temp, path)
        run_cmd(cmd)

def pipeline(directory):
    path = os.path.join("plans", directory)
    output = os.path.join(path, directory + "_independencies_solution.lp")
    if os.path.isdir(os.path.join(path,'cluster')):
        empty_cluster(path)
    run(directory, output)
    aesthetic(output)
    illegal_table(output, path)
    cluster(path)

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')

    directory = 'original'

    help_line = 'independence_day.py -d <directory>'

    try:
        opts, args = getopt.getopt(argv,"h:d:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
    path = os.path.join("plans", directory)
    output = os.path.join(path, directory + "_independencies_solution.lp")
    print("Directory: {}".format(directory))
    print("Output: {}".format(output))

    pipeline(directory)

if __name__ == "__main__":
    main(sys.argv[1:])