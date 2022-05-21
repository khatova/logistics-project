import tkinter as tk
import os

class Example(tk.Frame):
    def __init__(self, parent):
        tk.Frame.__init__(self, parent)

        # create a prompt, an input box, an output label,
        # and a button to do the computation
# gen -x 5 -y 9 -n 36 -s 4 -p 2 -r 2 -P 4 -u 4 -o 4 --oap -H -R --gs 3
        self.variables = ['Dimension x', 'Dimension y', 'Number of Nodes', 'Number of shelves',
                          'Number of picking stations', 'Number of robots', 'Types of products',
                          'u', 'Order of products', 'oap', 'Highway', 'R', 'Size of blocked nodes']
        self.prompts = []
        self.entries = []
        for var in self.variables:
            self.prompts.append(tk.Label(self, text=var + ":", anchor="w"))
            if var not in self.variables[-4:]:
                self.v = tk.StringVar(root, value='5')
                self.entries.append(tk.Entry(self, textvariable=self.v))
            else:
                self.entries.append(tk.Entry(self))
        self.submit = tk.Button(self, text="Generate", command = self.run_command)
        self.output = tk.Label(self, text="")

        # lay the widgets out on the screen.
        for p, e in zip(self.prompts, self.entries):
            p.pack(side="top", fill="x")
            e.pack(side="top", fill="x", padx=20)
        self.output.pack(side="top", fill="x", expand=True)
        self.submit.pack(side="right")

    def write_command(self):
        # get the value from the input widget, convert
        # it to an int, and do a calculation
        try:
            x = self.entries[0].get()
            y = self.entries[1].get()
            n = self.entries[2].get()
            s = self.entries[3].get()
            ps = self.entries[4].get()
            r = self.entries[5].get()
            pr = self.entries[6].get()
            u = self.entries[7].get()
            o = self.entries[8].get()
            oap = self.entries[9].get()
            h = self.entries[10].get()
            reach = self.entries[11].get()
            gs = self.entries[12].get()
            parameters = [x,y,n,s,ps,r,pr,u,o]
            for p in parameters:
                if p == "":
                    p = "4"
            command = "gen -d instances/labor/ "
            command = command + "-x {} -y {} -n {} -s {} -p {} -r {} -P {} -u {} -o {} ".format(x, y, n, s, ps, r, pr, u, o)

            # set the output widget to have our result
            self.output.configure(text=command)
            print("Simple command {}".format(command))
            if oap != "":
                command = command + "--oap "
            if h != "":
                command = command + "-H "
            if reach != "":
                command = command + "-R "
            if gs != "":
                command = command + "--gs {} ".format(gs)
        except ValueError:
            command = ""
            print("Error by creating line command")

        return command

    def run_command(self):
        command = self.write_command()
        print("Command: {}".format(command))

        stream = os.popen(command)
        output = stream.read()
        if output == "" or output == None:
            print("Command runned without output")
        else:
            print("Command runned with output... : {}".format(output))
    # if this is run as a program (versus being imported),
    # create a root window and an instance of our example,
    # then start the event loop

if __name__ == "__main__":
    root = tk.Tk()
    Example(root).pack(fill="both", expand=True)
    root.mainloop()