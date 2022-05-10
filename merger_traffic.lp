#include "asprilo-encodings/input.lp".

time(1..horizon).

time_(T) :- occurs(_,_,T).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).

% borders of the grid
border((X,Y),(P,Q)) :- init(object(node, _), value(at, (X,Y))), not init(object(node, _), value(at, (P,Q))), position((P,Q)), nextto((X,Y),(_,_),(P,Q)).


% translates occurs into position and move
move_X(X,R,T) :- X = #sum{D1 : occurs(object(robot,R),action(move,(D1,D2)),T') }, T'<= T, robot(R), time_(T), time_(T').
move_Y(Y,R,T) :- Y = #sum{D2 : occurs(object(robot,R),action(move,(D1,D2)),T') }, T'<= T, robot(R), time_(T), time_(T').
position(robot(R),(X0+X,Y0+Y),T) :-  move_X(X,R,T), move_Y(Y,R,T), init(object(robot,R),value(at,(X0,Y0))).
move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).

% edge collision at the next step -> conflict at the current step
vertical_conflict(R1,(X,Y),R2,(X,Y'),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X,Y'),T), position(robot(R1),(X,Y'),T+1), position(robot(R2),(X,Y),T+1), R1 < R2, time_(T).
horizontal_conflict(R1,(X,Y),R2,(X',Y),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X',Y),T), position(robot(R1),(X',Y),T+1), position(robot(R2),(X,Y),T+1), R1 < R2, time_(T).
conflict(R,T) :- vertical_conflict(R,_,_,_,T).
conflict(R,T) :- horizontal_conflict(R,_,_,_,T).

% number of conflicts for robot R at time step T
num_conflicts(R,T,CN) :- CN = #count{T' : conflict(R,T'), T' < T}, robot(R), time_(T), time_(T').
% if no conflict at the previous step, then copy the current step (with adjusted time step T_)
move_(R,D,T_) :- move(R,D,T), T_ = T + CN * 2, num_conflicts(R,T,CN), not conflict(R,T-1), time(T), time_(T'), robot(R).

% idea: move to the right in the direction perpendicular to the direction of the conflict
% Robot wants to move to the right
move_(R,(0,1),T) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(1,0),T), not border((X,Y),(X,Y+1)).
move_(R,(0,0),T) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(1,0),T), border((X,Y),(X,Y+1)).
% Robot wants to move to the left
move_(R,(0,-1),T) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(-1,0),T), not border((X,Y),(X,Y-1)).
move_(R,(0,0),T) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(-1,0),T), border((X,Y),(X,Y-1)).
% Robot wants to move down
move_(R,(-1,1),T) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,1),T), not border((X,Y),(X-1,Y)).
move_(R,(0,0),T) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,1),T), border((X,Y),(X-1,Y)).
% Robot wants to move up
move_(R,(0,-1),T) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,-1),T), not border((X,Y),(X+1,Y)).
move_(R,(0,0),T) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,-1),T), border((X,Y),(X+1,Y)).


% return back to the plan
move_(R,D,T+1) :- move(R,D,T), conflict(R,T).
move_(R,(-D1,-D2),T+2) :- move_(R,(D1,D2),T), conflict(R,T).

% Show output
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),     T) :    move_(R,D,T).

