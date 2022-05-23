% number of conflicts for robot R at time step T
conflicted(R,0,0) :- robot(R).
conflicted(R,C+1,T) :- conflicted(R,C,T-1), conflict(R,T), move(R,_,T), robot(R), time(T).
conflicted(R,C,T) :- conflicted(R,C,T-1), not conflict(R,T), move(R,_,T), robot(R), time(T).
move_(R,D,T) :- move(R,D,T), conflicted(R,C,T-1), C = 0, time(T), robot(R).

% idea: move to the right in the direction perpendicular to the direction of the conflict
% Robot wants to move to the right
move_(R,(0,1),T+1) :- horizontal_edge_conflict(R,(X,Y),_,_,T), move(R,(1,0),T+1), nextto((X,Y),(0,1),(X,Y+1)), time(T).
move_(R,(0,0),T+1) :- horizontal_edge_conflict(R,(X,Y),_,_,T), move(R,(1,0),T+1), not nextto((X,Y),(0,1),(X,Y+1)), time(T).
% Robot wants to move to the left
move_(R,(0,-1),T+1) :- horizontal_edge_conflict(R,(X,Y),_,_,T), move(R,(-1,0),T+1), nextto((X,Y),(0,-1),(X,Y-1)), time(T).
move_(R,(0,0),T+1) :- horizontal_edge_conflict(R,(X,Y),_,_,T), move(R,(-1,0),T+1), not nextto((X,Y),(0,-1),(X,Y-1)), time(T).
% Robot wants to move down
move_(R,(-1,1),T+1) :- vertical_edge_conflict(R,(X,Y),_,_,T), move(R,(0,1),T+1), nextto((X,Y),(-1,0),(X-1,Y)), time(T).
move_(R,(0,0),T+1) :- vertical_edge_conflict(R,(X,Y),_,_,T), move(R,(0,1),T+1), not nextto((X,Y),(-1,0),(X-1,Y)), time(T).
% Robot wants to move up
move_(R,(0,-1),T+1) :- vertical_edge_conflict(R,(X,Y),_,_,T), move(R,(0,-1),T+1), nextto((X,Y),(1,0),(X+1,Y)), time(T).
move_(R,(0,0),T+1) :- vertical_edge_conflict(R,(X,Y),_,_,T), move(R,(0,-1),T+1), not nextto((X,Y),(1,0),(X+1,Y)), time(T).


% return back to the plan
move_(R,D,T+2) :- move(R,D,T+1), conflict(R,T).
move_(R,(-D1,-D2),T+3) :- move_(R,(D1,D2),T+1), conflict(R,T).