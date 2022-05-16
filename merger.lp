% number of conflicts for robot R at time step T
num_edge_conflicts(R,T,CN) :- CN = #count{T' : edge_conflict(R,T'), T' < T}, robot(R), time_(T), time_(T').
% if no conflict at the previous step, then copy the current step (with adjusted time step T_)
move_(R,D,T_) :- move(R,D,T), T_ = T + CN * 2, num_edge_conflicts(R,T,CN), not edge_conflict(R,T-1), time(T), time_(T'), robot(R).

% idea: make a random move in the direction perpendicular to the direction of the conflict
% doesn't work yet
%{move_(A,(M,0),T+1)}  :- vertical_conflict(A,(X,Y),B,(X,Y'),T), M=-1..1.
%{move_(A,(0,M),T+1)}   :- horizontal_conflict(A,(X,Y),B,(X,Y'),T), M=-1..1.

%:- move_(A,(0,0),T+1), move_(B,(0,0),T+1), vertical_conflict(A,_,B,_,T).
%:- move_(A,(0,0),T+1), move_(B,(0,0),T+1), horizontal_conflict(A,_,B,_,T).
%:- move_(A,(D1,_), T), move_(B,(D2,_),T), vertical_conflict(A,_,B,_,T-1), |D1+D2|>1.
%:- move_(A,(_,D1), T), move_(B,(_,D2),T), horizontal_conflict(A,_,B,_,T-1), |D1+D2|>1.

% idea: move -1 in the direction perpendicular to the direction of the conflict
move_(R,(0,-1),T+1) :- horizontal_edge_conflict(R,_,_,_,T).
move_(R,(-1,0),T+1) :- vertical_edge_conflict(R,_,_,_,T).

% return back to the plan
move_(R,D,T+2) :- move(R,D,T+1), edge_conflict(R,T).
move_(R,(-D1,-D2),T+3) :- move_(R,(D1,D2),T+1), edge_conflict(R,T).
