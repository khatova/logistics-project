# logistics-project

This is a repository for the project in knowledge representation and reasoning.
We are trying to solve MAPF (multi agent path finding) problem using plan merging approach. You can learn more about MAPF here: https://ktiml.mff.cuni.cz/~bartak/AAAI2019/.

Our solution is build upon asprilo: https://potassco.org/asprilo/.
To make youreslf familiar with asprilo, you can use these exercises: https://github.com/potassco/asprilo-seminar.

We use individual robot plans created by asprilo and merge them in order to resolve conflicts. At this moment, we are working in non-autonomous domain of MAPF. For the simplicity, for now, we are working in M-domain only (movement only, see detailed description here: https://asprilo.github.io/specification/).

To use our merger, you have to:
1. Install asprilo (follow instructions in https://github.com/potassco/asprilo-seminar).
2. Install visualizer (follow instructions in https://github.com/potassco/asprilo-seminar).
3. Generate an instance
```
gen -x 20 -y 20 -X 5 -Y 2 -s 40 -p 1 -r 40 -H -P 40 -u 40 -o 40 --prs 1 --pus 1 -t 4 -V -I
```

or alternatively, 
```
python generate_file.py -d <directory> -x <x> -y <y> -n <number of agents>
```
Options:
```
-d : directory inside folder 'plans' to save the new instace
-x : horizontal length of the grid
-y : vertical length of the grid
-n : number of agents, shelfs, orders and products
```
Output:
```
'<directory>_nonanonymous_instance.lp'
```

4. Create separate plans for all robots:
```
python make_original_plans.py -i instances/med_dense_x20_y20_n400_r40_s40_ps1_pr40_u40_o40_l40_N001.lp -o plans/medium_dense -n med_dense_x20_y20_n400_r40_s40_ps1_pr40_u40_o40_l40_N001  --horizon=30
```
Options:
```
-i : input instance
-o : output folder
-n : output name prefix
--horizon : horizon
```

5. Launch merger and visualize the result:
```
python run_clingo.py -d "plans/medium_dense" -m "merger_traffic.lp"
```
Options:

```
-d : directory containing input plans
-m : merger (omit to use the default merger)
```
For more info and additional options, run 
```
python run_clingo.py -h
```

### Extras
For some mergers, would be convenient to work only with the conflicted robots.
For this purpose there is an Independence Detector.
```
python independence_day.py -d <directory>
```
Options:
```
-d : subfolder inside 'plans' containing the paths of the agents
```

Output: 
A file called '<directory>_independencies_solution.lp' that identify the independent and the dependent robots.

With this file, then we can separate the robots using:

```
python clustering.py -d <directory>
```
Options:
```
-d : subfolder inside 'plans' containing the paths of the agents
```

Output:
A folder in <directory> called `cluster` which contains all the independent plans. 
In other words, all the paths of the robots that do not conflict other robots' paths.
