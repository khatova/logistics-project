import os
import sys
import argparse
import getopt
from utils import aesthetic

def merge_plans(directory, output_name='merged_plans.lp'):
        rules = []
        files = os.listdir(directory)
        stopwords = ['non','solution', 'cluster', 'merger', '.DS_Store','bucket','debug','nodes']
        for file in files:
            if any(sw in file for sw in stopwords):
                continue
            aesthetic(os.path.join(directory, file))
            #print(f'Merge Plans. Processing file {file} in folder {directory}')
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

    merge_plans(path)

if __name__ == "__main__":
    main(sys.argv[1:])