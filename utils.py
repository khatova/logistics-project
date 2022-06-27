import os, shutil

def empty_folder(path):
    for filename in os.listdir(path):
        file_path = os.path.join(path, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))

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
                rule = rule.replace("'","")
                file.write(rule + "\n")

def visualize(plan):
    command = "".join(["viz  -p ",plan])
    print("Command: {}".format(command))

    stream = os.popen(command)
    output = stream.read()
    if output == "" or output == None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))