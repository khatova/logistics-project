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

new_move(R,(X,Y),T) :- move(R,(X,Y),T), conflicted(R,0,T).
new_moved(R,(0,0),0) :- robot(R).
new_moved(R,(X+D1,Y+D2),T) :- new_moved(R,(X,Y),T-1), new_move(R,(D1,D2),T), robot(R), time(T).
new_position(robot(R),(X0+X,Y0+Y),T) :-  new_moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).
new_illegal((X,Y),T) :- new_position(robot(R),(X,Y),T).

shelf(R,D) :- init(object(shelf,R),value(at,D)).
arrived(R,T) :- new_position(robot(R),C,T), shelf(R,C).
last_position(R,C,T) :- new_position(robot(R),C,T), not new_position(robot(R),_,T+1), not arrived(R,T).

#show.
#show new_move/3.
#show new_illegal/2.
#show last_position/3.