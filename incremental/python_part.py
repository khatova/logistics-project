import clingo
#from clingo import Function
#from clingo import Number

# class Context:
#     def peg(self, x):
#         return x
#     def disk(self, x):
#         return x
#     def init_on(self, x, y):
#         return [x, y]
#     def goal_on(self, x, y):
#         return [x, y]
#
# def on_model(m):
#     print (m)

ctl = clingo.Control()
ctl.load('clingo_part.lp')
# # 1 peg(a;b;c). 2 disk(1..4). 3 init_on(1..4,a). 4 goal_on(1..4,c).))
# ctl.ground([("acid", Number(42))])
# ctl.solve()
# for sym in ctl.symbolic_atoms:
#     print(sym.symbol)


# def get(val, default):
#     return val if val != None else default
# def main(prg):
#     imin = get(prg.get_const("imin"), 1)
#     imax = prg.get_const("imax")
#     istop = get(prg.get_const("istop"), "SAT")
#     step, ret = 0, None
#     while ((imax is None or step < imax) and
#         (step == 0 or step < imin or (
#         (istop == "SAT" and not ret.satisfiable) or
#         (istop == "UNSAT" and not ret.unsatisfiable) or
#         (istop == "UNKNOWN" and not ret.unknown)))):
#             parts = []
#             parts.append(("check", [step]))
#             if step > 0:
#                 prg.release_external(Function("query", [step-1]))
#                 parts.append(("step", [step]))
#                 prg.cleanup()
#             else:
#                 parts.append(("base", []))
#                 prg.ground(parts)
#                 prg.assign_external(Function("query", [step]), True)
#                 ret, step = prg.solve(), step+1