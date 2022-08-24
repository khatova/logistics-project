import os, sys, getopt, argparse

def total_number_of_moves(path):
    steps = 0
    with open(path,'r') as file:
        lines = file.readlines()
        for line in lines:
            if 'occurs' in line:
                steps += 1
    return steps

def get_time(log_file,plan_path):
    with open(log_file,'r') as file:
        lines = file.readlines()
        for line in lines:
            name, time = line.split()
            if name == plan_path:
                return time
    return 0
def main(argv):
    parser = argparse.ArgumentParser(description='Command runs custom plan merger using clingo')
    print("Starting the program")
    directory = 'hierarchical'
    plans_file = 'merged_plans.lp'

    help_line = 'benchmarking.py -d <directory> -p <plans>'
    plan_path = os.path.join ("plans/",directory,plans_file)

    try:
        opts, args = getopt.getopt(argv, "hp:")
    except getopt.GetoptError:
        print(help_line)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(help_line)
            sys.exit()
        elif opt == '-d':
            directory = arg
        elif opt == '-p':
            plans_file = arg

    log_file = 'log_file.txt'
    steps = total_number_of_moves(plan_path)
    time = get_time(log_file,plan_path)
    print(f'Steps : {steps}')
    print(f'Time : {time}')

if __name__ == "__main__":
    main(sys.argv[1:])