move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).
robot(R) :- occurs(object(robot,R),action(move,(DX,DY)),T).
cost(R,0,0) :- robot(R).
cost(R,C+1,T) :- cost(R,C,T-1), move(R,D,T).

time(1..horizon).
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.

moved(R,(0,0),0) :- robot(R).
moved(R,(X+D1,Y+D2),T) :- moved(R,(X,Y),T-1), move(R,(D1,D2),T), robot(R), time(T).
position(robot(R),(X0+X,Y0+Y),T) :-  moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).

conflict(R,T) :- position(robot(R),(X,Y),T), illegal((X,Y),T).
conflicted(R,0,0) :- robot(R).
conflicted(R,C+1,T) :- conflicted(R,C,T-1), conflict(R,T), move(R,_,T), robot(R), time(T).
conflicted(R,C,T) :- conflicted(R,C,T-1), not conflict(R,T), move(R,_,T), robot(R), time(T).

move_(R,(X,Y),T) :- move(R,(X,Y),T), conflicted(R,0,T).
illegal((X,Y),T) :- move_(R,(X,Y),T).

#show.
#show illegal/2.
#show init/2.
#show move_/3.