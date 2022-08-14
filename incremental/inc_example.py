from clingo import Number
import clingo

ctl = clingo.Control()
ctl.load('inc_example.lp')

def main(prg):
	#prg.ground([("acid",[Number(42)])])
	#prg.solve()
	for i in range(5):
		prg.ground([("acid",[Number(i)])])
		prg.solve()
	#prg.solve()


main(ctl)