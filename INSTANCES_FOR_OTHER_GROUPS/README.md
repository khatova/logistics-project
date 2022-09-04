Hello

In this folder there are 2 different instances. Each instance has a plan for every robot. There are conflicts in each instance.

To run our merger for a instance with plans, like those examples, you need to follow this steps:

1. Create a folder named 'plans' and inside a folder with name 'example'
2. run 'python separate.py -i <merged_instances> -o example'
3. run hierarchical_wild.py -d example

That should create a file called 'merged_plans.lp' in which you can find the paths for each robots without conflicts.
Also, automatically the visualizer will show the solution in that file.