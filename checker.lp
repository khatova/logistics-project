move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).
moved(R,(0,0),0) :- robot(R).
moved(R,(X+D1,Y+D2),T) :- moved(R,(X,Y),T-1), move(R,(D1,D2),T), robot(R), time(T).
position(robot(R),(X0+X,Y0+Y),T) :-  moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).
:- not position(robot(R),_,T), move(R,_,T), robot(R), time(T).

vertical_edge_conflict(R1,(X,Y),R2,(X,Y'),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X,Y'),T), position(robot(R1),(X,Y'),T+1), position(robot(R2),(X,Y),T+1), Y != Y'.
horizontal_edge_conflict(R1,(X,Y),R2,(X',Y),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X',Y),T), position(robot(R1),(X',Y),T+1), position(robot(R2),(X,Y),T+1), X != X'.
edge_conflict(R,T) :- vertical_edge_conflict(R,_,_,_,T).
edge_conflict(R,T) :- horizontal_edge_conflict(R,_,_,_,T).
node_conflict(R1,R2,C,T) :- position(robot(R1),C,T+1), position(robot(R2),C,T+1), R1 != R2.
node_conflict(R,T) :- node_conflict(R,_,_,T).

conflict(R,T) :- edge_conflict(R,T).
conflict(R,T) :- node_conflict(R,T).
