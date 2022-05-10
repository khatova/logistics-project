import os

def run(instance1, instance2, merger, final_plan):
    command = "".join(["clingo --out-atomf='%s.' -V0 -c horizon=15  ",instance1," ",instance2," ",merger," > ",final_plan])
    print("Command: {}".format(command))

    stream = os.popen(command)
    output = stream.read()
    if output == "" or output == None:
        print("Command runned without output")
    else:
        print("Command runned with output... : {}".format(output))

def aesthetic(location):
    with open(location, 'r+') as file:
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

if __name__ == "__main__":
    instance1 = 'plans/original/plan_x3y2r1s2p2_1_original.lp'
    instance2 = 'plans/original/plan_x3y2r1s2p2_2_original.lp'
    merger = "merger_traffic.lp"
    final_plan = 'plans/merged/x2y3r2s2p2_traffic_plan.lp'

    run(instance1,instance2,merger,final_plan)
    aesthetic(final_plan)