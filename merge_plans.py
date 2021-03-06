import os
import sys
import argparse
import getopt
from utils import aesthetic

def merge_plans(directory, output_name='merged_plans.lp'):
        rules = []
        files = os.listdir(directory)
        stopwords = ['non','solution', 'cluster', 'merger', '.DS_Store']
        for file in files:
            quit = False
            for sw in stopwords:
                if sw in file:
                    quit = True
            if quit == True:
                continue
            print(f'Processing file {file} in folder {directory}')
            with open(os.path.join(directory,file), 'r') as f:
                lines = f.readlines()
                for line in lines:
                    if line not in rules:
                        rules.append(line)
        with open(os.path.join(directory,output_name),'w') as f:
            for r in rules:
                f.write(r)

def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')
    help_line = 'merge_plans.py -d <directory>'

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
    files = os.listdir(path)
    stopwords = ['solution', 'conflicts', 'cluster', 'merger', '.DS_Store']
    for f in files:
        quit = False
        for sw in stopwords:
            if sw in f:
                quit = True
        if quit == True:
            continue
        aesthetic(os.path.join(path,f))

    merge_plans(path)

if __name__ == "__main__":
    main(sys.argv[1:])