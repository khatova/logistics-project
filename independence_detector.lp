time(1..horizon).
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.

robot(R) :- init(object(robot,R),value(at,(X0,Y0))).
move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).
moved(R,(0,0),0) :- robot(R).
moved(R,(X+D1,Y+D2),T) :- moved(R,(X,Y),T-1), move(R,(D1,D2),T), robot(R), time(T).
position(robot(R),(X0+X,Y0+Y),T) :-  moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).

% edge collision at the next step -> conflict at the current step
vertical_edge_conflict(R1,(X,Y),R2,(X,Y'),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X,Y'),T), position(robot(R1),(X,Y'),T+1), position(robot(R2),(X,Y),T+1).
horizontal_edge_conflict(R1,(X,Y),R2,(X',Y),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X',Y),T), position(robot(R1),(X',Y),T+1), position(robot(R2),(X,Y),T+1).
edge_conflict(R,T) :- vertical_edge_conflict(R,_,_,_,T).
edge_conflict(R,T) :- horizontal_edge_conflict(R,_,_,_,T).
node_conflict(R1,R2,C,T) :- position(robot(R1),C,T+1), position(robot(R2),C,T+1).
node_conflict(R,T) :- node_conflict(R,_,_,T).

conflict(R,S,T) :- position(robot(R),(X,Y),T), position(robot(S),(X,Y),T), R < S.
conflict(R,T) :- edge_conflict(R,T).
conflict(R,T) :- conflict(R,S,T).
conflict(S,T) :- conflict(R,S,T).

dependent(R,S) :- conflict(R,S,T), R < S, robot(R), robot(S).
independent(R) :- not dependent(R,_), not dependent(_,R), robot(R).
dependent(R) :- dependent(R,_).
dependent(R) :- dependent(_,R).

illegal((X,Y),T) :- position(robot(R),(X,Y),T), independent(R), robot(R), time(T).

#show.
#show independent/1.
%#show dependent/2.
#show dependent/1.
#show illegal/2.