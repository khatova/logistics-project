# logistics-project

This is repository for the project in knowledge representation and reasoning.
We are trying to solve MAPF (multi agent path finding) problem using plan merging approach. You can learn more about MAPF here: https://ktiml.mff.cuni.cz/~bartak/AAAI2019/.

Our solution is build upon asprilo: https://potassco.org/asprilo/.
To make youreslf familiar with asprilo, you can use these exercises: https://github.com/potassco/asprilo-seminar.

We use individual robot plans created by asprilo and merge them in order to resolve conflicts. At this moment, we are working in non-autonomous domain of MAPF. For the simplicity, for now, we are working in M-domain only (movement only, see detailed description here: https://asprilo.github.io/specification/).

To use our merger, you have to:
1. Install asprilo (follow instructions in https://github.com/potassco/asprilo-seminar).
2. Install visualizer (follow instructions in https://github.com/potassco/asprilo-seminar).
3. Generate an instance and create separate plans for all robots using asprilo.
4. Launch merger:
```
python run_clingo.py -i "plans/line/{line_plan_x5y2r2s2p2_1.lp,line_plan_x5y2r2s2p2_2.lp}" -m "merger_line.lp" -o "plans/line/x5y2r2s2p2_merged.lp"
```
-i : input plans\
-m : merger (omit to use the default merger)\
-o : output merged plan\
For more info, run 
```
python run_clingo.py -h
```

This command will try to merge plans and show the result in the visualizer.
