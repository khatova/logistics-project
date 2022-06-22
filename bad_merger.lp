%cost(R,|SX-X|+|SY-Y|,T) :- position(robot(R), (X,Y), T), init(object(shelf,S),value(at,(SX,SY))).

{ move_(R,D,T) : direction(D) } 1 :- robot(R), dependent(R,_), time(T).

moved_(R,(0,0),0) :- robot(R).
moved_(R,(X+D1,Y+D2),T) :- moved_(R,(X,Y),T-1), move_(R,(D1,D2),T), robot(R), time(T).
position_(robot(R),(X0+X,Y0+Y),T) :-  moved_(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).
:- not position(robot(R),_,T), move_(R,_,T), robot(R), time(T).

:- position_(robot(R), (X,Y), T), illegal((X,Y), T).

% edge collision at the next step -> conflict at the current step
vertical_edge_conflict_(R1,(X,Y),R2,(X,Y'),T) :- position_(robot(R1),(X,Y),T), position_(robot(R2),(X,Y'),T), position_(robot(R1),(X,Y'),T+1), position_(robot(R2),(X,Y),T+1), time_(T).
horizontal_edge_conflict_(R1,(X,Y),R2,(X',Y),T) :- position_(robot(R1),(X,Y),T), position_(robot(R2),(X',Y),T), position_(robot(R1),(X',Y),T+1), position_(robot(R2),(X,Y),T+1), time_(T).
edge_conflict_(R,T) :- vertical_edge_conflict_(R,_,_,_,T).
edge_conflict_(R,T) :- horizontal_edge_conflict_(R,_,_,_,T).

% two robots move to the same cell at the next step -> conflict at the current step
node_conflict_(R1,R2,C,T) :- position_(robot(R1),C,T+1), position_(robot(R2),C,T+1).
node_conflict_(R,T) :- node_conflict_(R,_,_,T).
% maybe differentiate between different incoming directions of robots?

conflict_(R,T) :- edge_conflict_(R,T).
conflict_(R,T) :- node_conflict_(R,T).

:- conflict_(R,T), robot(R), time(T).