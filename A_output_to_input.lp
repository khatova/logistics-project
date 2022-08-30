#include "asprilo-encodings/input.lp".

time(1..15). % output time
time_(T) :- occurs(_,_,T). % input time

% translates occurs into position and move
move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).
moved(R,(0,0),0) :- robot(R).
moved(R,(X+D1,Y+D2),T) :- moved(R,(X,Y),T-1), move(R,(D1,D2),T), robot(R), time(T).
position(robot(R),(X0+X,Y0+Y),T) :-  moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).

% probably redundant
:- not position(robot(R),_,T), move(R,_,T), robot(R), time(T).