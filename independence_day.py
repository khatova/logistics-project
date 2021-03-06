#!/usr/bin/python

import os, sys, getopt, argparse
from utils import aesthetic

def run(directory, output):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        command = "clingo --out-atomf='%s.' -V0 -c horizon=15 "
        path = os.path.join("plans/",directory)
        print("DEBUG: Path {}".format(path))
        files = os.listdir(path)
        stopwords = ['solution', 'conflicts', 'cluster', 'merger', '.DS_Store']
        for f in files:
            quit = False
            for sw in stopwords:
                if sw in f:
                    quit = True
            if quit == True:
                continue
            command += os.path.join(path,f) + " "
        command += "independence_detector.lp" + " > " + output
        print("Command: {}".format(command))

        stream = os.popen(command)
        output = stream.read()
        if output == "" or output == None:
            print("Command runned without output")
        else:
            print("Command runned with output... : {}".format(output))

def cluster(directory):
    dirs = [x.name for x in os.scandir("plans") if x.is_dir()]
    if directory not in dirs:
        print("Directory not found. Please select one of these options: ")
        print(dirs)
        sys.exit(0)
    else:
        path = os.path.join("plans/", directory)
        cluster_path = os.path.join("plans/", directory, "cluster")
        print("Cluster path {}".format(cluster_path))
        if not os.path.exists(cluster_path):
            os.mkdir(cluster_path)
        files = os.listdir(path)
        conflicted_robots_set = set([])
        for f in files:
            if "independencies_solution" in f:
                temp = os.path.join("plans/", directory,f)
                with open(temp,'r',encoding='utf-8') as file:
                    for line in file:
                        if "dependent" in line and "independent" not in line:
                            robots = line[10:-3].split(",")
                            for r in robots:
                                conflicted_robots_set.add(int(r))

        conflicted_robots = list(conflicted_robots_set)
        print("Conflicted robots {}".format(conflicted_robots))

        stopwords = ['solution', 'cluster', 'merger', '.DS_Store']
        for f in files:
            quit = False
            for sw in stopwords:
                if sw in f:
                    quit = True
            if quit == True:
                continue
            for cr in conflicted_robots:
                if str(cr) in f:
                    temp = os.path.join("plans/", directory, f)
                    cmd = "move {} {}".format(temp,cluster_path)
                    print(cmd)
                    stream = os.popen(cmd)
                    output = stream.read()
                    if output == "" or output == None:
                        print("Command runned without output")
                    else:
                        print("Command runned with output... : {}".format(output))
                    continue

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

    output = os.path.join("plans/", directory, directory + "_independencies_solution.lp")
    print("Directory: {}".format(directory))
    print("Output: {}".format(output))

    run(directory, output)
    aesthetic(output)
    cluster(directory)

if __name__ == "__main__":
    main(sys.argv[1:])