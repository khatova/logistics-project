#include "../input.lp".

%#const horizon=1.
time(1..horizon).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).

{ move(R,D,T) : direction(D) } 1 :- isRobot(R), time(T).

% - move/3 ----------------------------------------------------------------------
position(R,C,T) :- move(R,D,T), position(R,C',T-1),     nextto(C',D,C).
                :- move(R,D,T), position(R,C ,T-1), not nextto(C ,D,_).

% - inertia ---------------------------------------------------------------------
position(R,C,T) :- position(R,C,T-1), not move(R,_,T), isRobot(R), time(T).

% - edge collision --------------------------------------------------------------
moveto(C',C,T) :- nextto(C',D,C), position(R,C',T-1), move(R,D,T).
% :- moveto(C',C,T), moveto(C,C',T), C < C'.

% - vertex collision ------------------------------------------------------------
% :- { position(R,C,T) : isRobot(R) }  > 1, position(C), time(T).

% - auxiliaries -----------------------------------------------------------------
 :- { position(R,C,T) } != 1, isRobot(R), time(T).    % REDUNDANT but PERFORMANT?

edge_conflict(R,T) :- position(robot(R),C,T), position(robot(R),C1,T+1), position(robot(R1),C1,T), position(robot(R1),C,T+1), R<R1.

% two robots move to the same cell at the next step -> conflict at the current step
node_conflict(R1,R2,C,T) :- position(robot(R1),C,T+1), position(robot(R2),C,T+1), R1<R2.
node_conflict(R,T) :- node_conflict(R,_,_,T).

conflict(R,T) :- edge_conflict(R,T).
conflict(R,T) :- node_conflict(R,T).

num_conf(N) :- N = #count{R,T : conflict(R,T)}.
:- num_conf(N), N != numconf.

:- #count{R,T : conflict(R,T)} != numconf.
