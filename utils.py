import os, shutil, sys


def empty_folder(path):
    for filename in os.listdir(path):
        file_path = os.path.join(path, filename)
        try:
            if 'merger' in file_path:
                continue
            elif os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))

def delete_file(file_path):
    if os.path.isfile(file_path) or os.path.islink(file_path):
        os.unlink(file_path)

def aesthetic(location):
    with open(location, 'r') as file:
        lines = file.readlines()
        if 'SATISFIABLE' in lines:
            lines.remove('SATISFIABLE')
        elif 'SATISFIABLE\n' in lines:
            lines.remove('SATISFIABLE\n')
    with open(location, "w") as file:
        for line in lines:
            rules = line.split()
            for rule in rules:
                rule = rule.replace("'", "")
                file.write(rule + "\n")


def visualize(plan):
    command = "".join(["viz  -p ", plan])
    print("Command: {}".format(command))

    stream = os.popen(command)
    output = stream.read()
    if output == "" or output == None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))


def delete_instances(path):
    files = os.listdir(path)
    for file in files:
        if 'instance' in file:
            os.remove(os.path.join(path, file))


def remove_node(path, coor):
    with open(path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if str(coor) in line and 'node' in line:
                lines.remove(line)
    with open(path, 'w') as file:
        for line in lines:
            line = line.replace("'", "")
            file.write(line)


def run_cmd(command):
    stream = os.popen(command)
    output = stream.read()
    if output == "" or output == None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))

def add_lines(input,output):
    with open(input, 'r') as file:
        lines = file.readlines()
    with open(output, 'a') as file:
        for line in lines:
            file.write(line)
    remove_repeated(output)

def remove_repeated(path):
    with open(path, 'r') as file:
        lines = file.readlines()
        lines = list(set(lines))
    with open(path, 'w') as file:
        for line in lines:
            file.write(line)

def read_file(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
    except Exception as err:
        print(f"Unexpected error opening {file_path} is", repr(err))
        sys.exit(1)

    return lines


def read_file_to_str(file_path):
    lines = read_file(file_path)
    file_str = ""
    for line in lines:
        file_str += line

    return file_str
