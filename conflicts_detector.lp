% edge collision at the next step -> conflict at the current step
vertical_edge_conflict(R1,(X,Y),R2,(X,Y'),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X,Y'),T), position(robot(R1),(X,Y'),T+1), position(robot(R2),(X,Y),T+1), R1<R2, time_(T).
horizontal_edge_conflict(R1,(X,Y),R2,(X',Y),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X',Y),T), position(robot(R1),(X',Y),T+1), position(robot(R2),(X,Y),T+1), R1<R2, time_(T).
edge_conflict(R,T) :- vertical_edge_conflict(R,_,_,_,T).
edge_conflict(R,T) :- horizontal_edge_conflict(R,_,_,_,T).

% two robots move to the same cell at the next step -> conflict at the current step
node_conflict(R1,R2,C,T) :- position(robot(R1),C,T+1), position(robot(R2),C,T+1).
node_conflict(R,T) :- node_conflict(R,_,_,T).
% maybe differentiate between different incoming directions of robots?

conflict(R,T) :- edge_conflict(R,T).
conflict(R,T) :- node_conflict(R,T).