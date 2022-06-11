time(1..horizon).

robot(R) :- init(object(robot,R),value(at,(X0,Y0))).
move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).
moved(R,(0,0),0) :- robot(R).
moved(R,(X+D1,Y+D2),T) :- moved(R,(X,Y),T-1), move(R,(D1,D2),T), robot(R), time(T).
position(robot(R),(X0+X,Y0+Y),T) :-  moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).

conflict(R,S,T) :- position(robot(R),(X,Y),T), position(robot(S),(X,Y),T), R < S.
conflict(R,T) :- conflict(R,S,T).
conflict(S,T) :- conflict(R,S,T).

dependent(R,S) :- conflict(R,S,T), R < S, robot(R), robot(S).
independent(R) :- not dependent(R,_), not dependent(_,R), robot(R).

cluster(1,R) :- dependent(R,.
cluster(1,B).
illegal((X,Y),T) :- position(robot(R),(X,Y),T), independent(R), robot(R), time(T).
move_(R,D,T) :- move(R,D,T), time(T), robot(R), independent(R).

#show.
#show independent/1.
#show dependent/2.
#show illegal/2.
#show occurs(object(robot,R), action(move,D),T) : move_(R,D,T).