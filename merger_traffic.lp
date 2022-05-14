#include "asprilo-encodings/input.lp".

time(1..horizon).

time_(T) :- move(_,_,T).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).

% borders of the grid
border((X,Y),(P,Q)) :- init(object(node, _), value(at, (X,Y))), not init(object(node, _), value(at, (P,Q))), position((P,Q)), nextto((X,Y),(_,_),(P,Q)).

% translates occurs into position and move
move(R,(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).
moved(R,(0,0),0) :- robot(R).
moved(R,(X+D1,Y+D2),T) :- moved(R,(X,Y),T-1), move(R,(D1,D2),T), robot(R), time(T).
position(robot(R),(X0+X,Y0+Y),T) :-  moved(R,(X,Y),T), init(object(robot,R),value(at,(X0,Y0))).
:- not position(robot(R),_,T), move(R,_,T), robot(R), time(T).

% edge collision at the next step -> conflict at the current step
vertical_conflict(R1,(X,Y),R2,(X,Y'),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X,Y'),T), position(robot(R1),(X,Y'),T+1), position(robot(R2),(X,Y),T+1), time(T).
horizontal_conflict(R1,(X,Y),R2,(X',Y),T) :- position(robot(R1),(X,Y),T), position(robot(R2),(X',Y),T), position(robot(R1),(X',Y),T+1), position(robot(R2),(X,Y),T+1), time(T).
conflict(R,T) :- vertical_conflict(R,_,_,_,T).
conflict(R,T) :- horizontal_conflict(R,_,_,_,T).

% number of conflicts for robot R at time step T
conflicted(R,0,0) :- robot(R).
conflicted(R,C+1,T) :- conflicted(R,C,T-1), conflict(R,T), move(R,_,T), robot(R), time(T).
conflicted(R,C,T) :- conflicted(R,C,T-1), not conflict(R,T), move(R,_,T), robot(R), time(T).
%num_conflicts(R,T,CN) :- CN = #count{T' : conflict(R,T')}, T' <= T, robot(R), time_(T), time_(T').
% if no conflict at the previous step, then copy the current step (with adjusted time step T_)
%move_(R,D,T_) :- move(R,D,T), T_ = T + CN * 2, num_conflicts(R,T,CN), not conflict(R,T-1), time(T), time_(T'), robot(R).
%move_(R,D,T) :-  move(R,D,T), num_conflicts(R,T,CN), not CN > 0, time(T), robot(R).
move_(R,D,T) :- move(R,D,T), conflicted(R,C,T-1), C = 0, time(T), robot(R).

% idea: move to the right in the direction perpendicular to the direction of the conflict
% Robot wants to move to the right
move_(R,(0,1),T+1) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(1,0),T+1), not border((X,Y),(X,Y+1)), time(T).
move_(R,(0,0),T+1) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(1,0),T+1), border((X,Y),(X,Y+1)), time(T).
% Robot wants to move to the left
move_(R,(0,-1),T+1) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(-1,0),T+1), not border((X,Y),(X,Y-1)), time(T).
move_(R,(0,0),T+1) :- horizontal_conflict(R,(X,Y),_,_,T), move(R,(-1,0),T+1), border((X,Y),(X,Y-1)), time(T).
% Robot wants to move down
move_(R,(-1,1),T+1) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,1),T+1), not border((X,Y),(X-1,Y)), time(T).
move_(R,(0,0),T+1) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,1),T+1), border((X,Y),(X-1,Y)), time(T).
% Robot wants to move up
move_(R,(0,-1),T+1) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,-1),T+1), not border((X,Y),(X+1,Y)), time(T).
move_(R,(0,0),T+1) :- vertical_conflict(R,(X,Y),_,_,T), move(R,(0,-1),T+1), border((X,Y),(X+1,Y)), time(T).


% return back to the plan
move_(R,D,T+2) :- move(R,D,T+1), conflict(R,T).
move_(R,(-D1,-D2),T+3) :- move_(R,(D1,D2),T+1), conflict(R,T).

% Show output
#show.
#show init/2.
%#show horizontal_conflict/5.
%#show border/2.
%#show vertical_conflict/5.
%#show moved/3.
%#show move/3.
%#show position/3.
%#show conflicted/3.
%#show conflict/2.
%#show move_/3.
#show occurs(object(robot,R), action(move,D),     T) :    move_(R,D,T).


