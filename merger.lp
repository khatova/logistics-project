#include "asprilo-encodings/input.lp".

time(1..horizon).

time_(T) :- occurs(_,_,T).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).

% translates occurs into position and move
move_X(X,R,T) :- X = #sum{D1 : occurs(object(robot,R),action(move,(D1,D2)),T') }, T'<= T, robot(R), time_(T), time_(T').
move_Y(Y,R,T) :- Y = #sum{D2 : occurs(object(robot,R),action(move,(D1,D2)),T') }, T'<= T, robot(R), time_(T), time_(T').
position(robot(R),(X0+X,Y0+Y),T) :-  move_X(X,R,T), move_Y(Y,R,T), init(object(robot,R),value(at,(X0,Y0))).
move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T). 

% two robots move to the same cell at the next step -> conflict at the current step
% conflict(R1,C,R2,C,T) :- position(robot(R1),C,T+1), position(robot(R2),C,T+1), R1 < R2.
% maybe differentiate between different incoming directions of robots?

% edge collision at the next step -> conflict at the current step
vertical_conflict(R1,(X,Y),R2,(X,Y'),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X,Y'),T), position(robot(R1),(X,Y'),T+1), position(robot(R2),(X,Y),T+1), R1 < R2, time_(T).
horizontal_conflict(R1,(X,Y),R2,(X',Y),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X',Y),T), position(robot(R1),(X',Y),T+1), position(robot(R2),(X,Y),T+1), R1 < R2, time_(T).
conflict(R,T) :- vertical_conflict(R,_,_,_,T).
conflict(R,T) :- horizontal_conflict(R,_,_,_,T).

% need to think about other possible conflict types


% number of conflicts for robot R at time step T
num_conflicts(R,T,CN) :- CN = #count{T' : conflict(R,T'), T' < T}, robot(R), time_(T), time_(T').
% if no conflict at the previous step, then copy the current step (with adjusted time step T_)
move_(R,D,T_) :- move(R,D,T), T_ = T + CN * 2, num_conflicts(R,T,CN), not conflict(R,T-1), time(T), time_(T'), robot(R).

% idea: make a random move in the direction perpendicular to the direction of the conflict
% doesn't work yet
%{move_(A,(M,0),T+1)}  :- vertical_conflict(A,(X,Y),B,(X,Y'),T), M=-1..1.
%{move_(A,(0,M),T+1)}   :- horizontal_conflict(A,(X,Y),B,(X,Y'),T), M=-1..1.

%:- move_(A,(0,0),T+1), move_(B,(0,0),T+1), vertical_conflict(A,_,B,_,T).
%:- move_(A,(0,0),T+1), move_(B,(0,0),T+1), horizontal_conflict(A,_,B,_,T).
%:- move_(A,(D1,_), T), move_(B,(D2,_),T), vertical_conflict(A,_,B,_,T-1), |D1+D2|>1.
%:- move_(A,(_,D1), T), move_(B,(_,D2),T), horizontal_conflict(A,_,B,_,T-1), |D1+D2|>1.

% idea: move -1 in the direction perpendicular to the direction of the conflict
move_(R,(0,-1),T+1) :- horizontal_conflict(R,_,_,_,T).
move_(R,(-1,0),T+1) :- vertical_conflict(R,_,_,_,T).

% return back to the plan
move_(R,D,T+2) :- move(R,D,T+1), conflict(R,T).
move_(R,(-D1,-D2),T+3) :- move_(R,(D1,D2),T+1), conflict(R,T).



