import clingo

ctl = clingo.Control()
ctl.load('alternative_paths.lp')
ctl.ground([("base")])
ctl.solve()
for sym in ctl.symbolic_atoms:
    print(sym.symbol)

