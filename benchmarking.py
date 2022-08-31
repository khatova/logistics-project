import os, sys, json
import matplotlib.pyplot as plt

def get_average_from_list(lista):
    if len(lista) == 0:
        print("ListStepsError. Empty List of Steps")
        return -1
    return sum(lista)/len(lista)

def read_json(log_file = 'log_file.json', directory=''):
    with open(log_file,'r') as json_file:
        json_data = json.load(json_file)
        records = json_data["records"]
        avg_steps = []
        total_steps = []
        duration = []
        for r in records:
            dicc = json.loads(r)
            plan = dicc["directory"]
            if directory != '' and plan != directory:
                continue
            avg_steps.append(dicc["avg_steps"])
            total_steps.append(dicc["total_steps"])
            duration.append(dicc["enabled_time"])

    return avg_steps, total_steps, duration

def get_metrics(avg_steps, total_steps, duration):
    avg_steps_per_agent = get_average_from_list(avg_steps)
    avg_total_steps = get_average_from_list(total_steps)
    avg_duration = get_average_from_list(duration)
    return avg_steps_per_agent, avg_total_steps, avg_duration

def plot_results(avg_steps, total_steps, duration):
    fig, ax = plt.subplots(1,3,figsize=(20, 10))
    ax[0].plot(avg_steps)
    ax[0].title.set_text('Avg Steps')
    ax[1].plot(total_steps)
    ax[1].title.set_text('Total Steps')
    ax[2].plot(duration)
    ax[2].title.set_text('Duration')
    plt.show()

if __name__ == "__main__":
    directory = 'large'
    a, b, c = read_json(directory=directory)
    plot_results(a,b,c)