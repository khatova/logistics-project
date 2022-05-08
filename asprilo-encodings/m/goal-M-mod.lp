processed(A,R) :- ordered(O,A), shelved(S,A), isRobot(R), position(S,C,0),
                  position(R,C,_).
processed(A)   :- processed(A,R).

:- ordered(O,A), not processed(A).